import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/turf.dart';
import '../booking/booking_screen.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

/// Payment Summary Screen — Swiggy/Zomato style redesign
///
/// RULES (unchanged):
/// - Zero client-side money calculations
/// - Money as String, NEVER double
/// - All amounts come from backend preview response
class PaymentSummaryScreen extends StatefulWidget {
  final Turf turf;
  final String bookingDate;
  final List<int> slotIds;
  final List<ApiSlot> selectedSlots;

  const PaymentSummaryScreen({
    super.key,
    required this.turf,
    required this.bookingDate,
    required this.slotIds,
    required this.selectedSlots,
  });

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  static const _kGreen = Color(0xFF1DB954);
  static const _kBg = Color(0xFFF6F7F9);

  final ApiService _api = ApiService();
  final TextEditingController _couponCtrl = TextEditingController();

  // ─── State ───
  bool _isLoading = true;
  String? _errorMessage;

  // ─── From preview API — String, never double ───
  String _previewToken = '';
  String _subtotal = '0';
  String _gstAmount = '0';
  String _platformFee = '0';
  String _gstOnPlatformFee = '0';
  String _totalPayable = '0';
  String _firstBookingDiscount = '0';
  String _turfName = '';
  String _expiresAt = '';

  // ─── Coupon ───
  bool _isApplyingCoupon = false;
  String? _appliedCoupon;
  String _couponDiscount = '0';
  String? _couponError;

  // ─── Available Offers (fetched from API, user-specific) ───
  List<Map<String, dynamic>> _availableOffers = [];
  bool _loadingOffers = false;

  // ─── Timer ───
  Timer? _countdownTimer;
  int _secondsLeft = 300; // 5 min default

  @override
  void initState() {
    super.initState();
    _callPreviewApi(); // _loadAvailableOffers is called after subtotal is known
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ─── PREVIEW API ───
  Future<void> _callPreviewApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _api.postAuth(
        '/api/bookings/bookings/preview/',
        body: {
          'turf_id': widget.turf.id,
          'booking_date': widget.bookingDate,
          'slot_ids': widget.slotIds,
        },
      );

      if (response['success'] == true) {
        final expiresAt = response['expires_at']?.toString() ?? '';
        int secs = 300;
        if (expiresAt.isNotEmpty) {
          try {
            final exp = DateTime.parse(expiresAt).toLocal();
            secs = exp.difference(DateTime.now()).inSeconds.clamp(0, 600);
          } catch (_) {}
        }
        setState(() {
          _previewToken = response['preview_token'] ?? '';
          _subtotal = response['subtotal']?.toString() ?? '0';
          _gstAmount = response['gst_amount']?.toString() ?? '0';
          _platformFee = response['platform_fee']?.toString() ?? '0';
          _gstOnPlatformFee =
              response['gst_on_platform_fee']?.toString() ?? '0';
          _totalPayable = response['total_payable']?.toString() ?? '0';
          _firstBookingDiscount =
              response['first_booking_discount']?.toString() ?? '0';
          _turfName = response['turf_name']?.toString() ?? widget.turf.name;
          _expiresAt = expiresAt;
          _secondsLeft = secs;
          _isLoading = false;
        });
        _startCountdown();
        _loadAvailableOffers(); // Now has correct _subtotal for min_order filtering
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Preview failed';
          _isLoading = false;
        });
      }
    } on AuthExpiredException {
      setState(() {
        _errorMessage = 'Session expired. Please login again.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      String msg;
      if (e.statusCode == 409) {
        msg =
            'One or more slots are no longer available. Please go back and re-select.';
      } else if (e.statusCode == 401) {
        msg = 'Session expired. Please login again.';
      } else {
        msg = 'Could not generate preview. Please try again.';
      }
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Check your network.';
        _isLoading = false;
      });
      debugPrint('Preview error: $e');
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _countdownTimer?.cancel();
        return;
      }
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── COUPON ───
  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _couponError = 'Please enter a coupon code');
      return;
    }
    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });
    try {
      final resp = await _api.postAuth(
        '/api/coupons/validate/',
        body: {'code': code, 'amount': _subtotal},
      );
      if (resp['valid'] == true) {
        setState(() {
          _appliedCoupon = code;
          _couponDiscount = resp['discount']?.toString() ?? '0';
          _couponCtrl.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Coupon $code applied!'),
                ],
              ),
              backgroundColor: _kGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        setState(() => _couponError = resp['message'] ?? 'Invalid coupon code');
      }
    } catch (_) {
      setState(() => _couponError = 'Failed to apply coupon. Try again.');
    } finally {
      setState(() => _isApplyingCoupon = false);
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = '0';
      _couponError = null;
    });
  }

  void _tapOfferChip(String code) {
    _couponCtrl.text = code;
    Clipboard.setData(ClipboardData(text: code));
  }

  // ─── PAYMENT ───
  String get _effectiveTotal {
    try {
      final base = double.parse(_totalPayable);
      final disc = double.parse(_couponDiscount);
      return (base - disc).toStringAsFixed(2);
    } catch (_) {
      return _totalPayable;
    }
  }

  void _proceedToPayment() {
    if (_previewToken.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          previewToken: _previewToken,
          totalPayable: _effectiveTotal,
          turfName: _turfName,
          bookingDate: widget.bookingDate,
          slotCount: widget.slotIds.length,
          turf: widget.turf,
          couponDiscount: _couponDiscount,
          couponCode: _appliedCoupon ?? '',
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoader()
          : _errorMessage != null
          ? _buildError()
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black87,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Payment Summary',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kGreen),
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16),
          Text(
            'Generating secure preview…',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTurfCard(),
                const SizedBox(height: 16),
                _buildSlotsCard(),
                const SizedBox(height: 16),
                _buildPriceCard(),
                const SizedBox(height: 16),
                _buildCouponCard(),
                const SizedBox(height: 16),
                _buildOffersCard(),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  // ─── TURF CARD ───
  Widget _buildTurfCard() {
    final date = _tryParseDate(widget.bookingDate);
    final dateStr = date != null ? _formatDate(date) : widget.bookingDate;
    final slotLabel = widget.selectedSlots.isNotEmpty
        ? '${widget.selectedSlots.first.displayTime}'
              '${widget.selectedSlots.length > 1 ? ' + ${widget.selectedSlots.length - 1} more' : ''}'
        : '${widget.slotIds.length} slot${widget.slotIds.length > 1 ? 's' : ''}';

    return _card(
      child: Row(
        children: [
          // Turf image or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.turf.images.isNotEmpty
                ? Image.network(
                    widget.turf.images.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _turfIconBox(),
                  )
                : _turfIconBox(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _turfName.isEmpty ? widget.turf.name : _turfName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFF1DB954),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Color(0xFF1DB954),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        slotLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _turfIconBox() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.sports_soccer_rounded, color: _kGreen, size: 30),
    );
  }

  // ─── SLOTS CARD ───
  Widget _buildSlotsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'SELECTED SLOT${widget.selectedSlots.length > 1 ? 'S' : ''}',
          ),
          const SizedBox(height: 12),
          ...widget.selectedSlots.map((s) => _slotRow(s)),
        ],
      ),
    );
  }

  Widget _slotRow(ApiSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, size: 16, color: _kGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              slot.displayTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          if (slot.hasOffer) ...[
            Text(
              '₹${slot.originalPrice}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '₹${slot.finalPrice}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: slot.hasOffer ? Colors.red.shade600 : _kGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PRICE CARD ───
  Widget _buildPriceCard() {
    final hasFirstDiscount =
        _firstBookingDiscount != '0' && _firstBookingDiscount != '0.00';
    final hasCouponDiscount =
        _appliedCoupon != null &&
        _couponDiscount != '0' &&
        _couponDiscount != '0.00';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PRICE DETAILS'),
          const SizedBox(height: 14),
          _priceRow('Subtotal', '₹$_subtotal'),
          _priceRow('GST (18%)', '₹$_gstAmount'),
          _priceRow('Platform Fee', '₹$_platformFee'),
          _priceRow('GST on Platform Fee', '₹$_gstOnPlatformFee'),

          if (hasFirstDiscount || hasCouponDiscount) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade200, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'SAVINGS',
                      style: TextStyle(
                        fontSize: 11,
                        color: _kGreen,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade200, thickness: 1),
                  ),
                ],
              ),
            ),
            if (hasFirstDiscount)
              _priceRow(
                'First Booking Discount',
                '-₹$_firstBookingDiscount',
                isDiscount: true,
              ),
            if (hasCouponDiscount)
              _priceRow(
                'Coupon ($_appliedCoupon)',
                '-₹$_couponDiscount',
                isDiscount: true,
                trailing: GestureDetector(
                  onTap: _removeCoupon,
                  child: const Icon(
                    Icons.cancel_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
          ],

          Divider(height: 24, color: Colors.grey.shade200, thickness: 1),
          _priceRow('Total Payable', '₹$_effectiveTotal', isTotal: true),
        ],
      ),
    );
  }

  // ─── COUPON CARD ───
  Widget _buildCouponCard() {
    if (_appliedCoupon != null) {
      return _card(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: _kGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appliedCoupon!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _kGreen,
                    ),
                  ),
                  Text(
                    'Saving ₹$_couponDiscount on this order',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _removeCoupon,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Colors.red.shade400,
              ),
              child: const Text(
                'REMOVE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: _kGreen, size: 18),
              const SizedBox(width: 8),
              _sectionTitle('APPLY COUPON'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0,
                    ),
                    errorText: _couponError,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: _kBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kGreen, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kGreen.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isApplyingCoupon
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'APPLY',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── AVAILABLE OFFERS ───
  Future<void> _loadAvailableOffers() async {
    setState(() => _loadingOffers = true);
    try {
      // Pass subtotal so the backend can filter by min_order_value
      final subtotal = _subtotal.isNotEmpty ? _subtotal : '0';
      final data = await _api.getAuth(
        '/api/coupons/available/?amount=$subtotal',
      );
      if (data['success'] == true && mounted) {
        final raw = data['offers'] as List<dynamic>? ?? [];
        setState(() {
          _availableOffers = raw
              .map((o) => Map<String, dynamic>.from(o as Map))
              .toList();
        });
      }
    } catch (_) {
      // Non-fatal: offers section simply stays empty
    } finally {
      if (mounted) setState(() => _loadingOffers = false);
    }
  }

  Widget _buildOffersCard() {
    // Don't render the section at all when loading is done and list is empty
    if (!_loadingOffers && _availableOffers.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'OFFERS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1565C0),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Available for you',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_loadingOffers)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loadingOffers && _availableOffers.isEmpty)
            // Skeleton placeholder while loading
            ...List.generate(
              2,
              (_) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            ..._availableOffers.map(
              (o) => _offerChip(
                o['code'] as String,
                o['saving'] as String,
                o['desc'] as String,
              ),
            ),
        ],
      ),
    );
  }

  Widget _offerChip(String code, String saving, String desc) {
    return GestureDetector(
      onTap: () => _tapOfferChip(code),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                ),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1565C0),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    saving,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFF1565C0),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM BAR ───
  Widget _buildBottomBar() {
    final isExpiring = _secondsLeft <= 60 && _expiresAt.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer pill
          if (_expiresAt.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isExpiring ? Colors.red.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isExpiring
                      ? Colors.red.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 16,
                    color: isExpiring
                        ? Colors.red.shade600
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Preview expires in ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isExpiring
                          ? Colors.red.shade600
                          : Colors.orange.shade700,
                    ),
                  ),
                  Text(
                    _timerLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isExpiring
                          ? Colors.red.shade700
                          : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Pay button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _previewToken.isEmpty || _secondsLeft == 0
                  ? null
                  : _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'PROCEED TO PAY  ₹$_effectiveTotal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ───

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 15 : 14,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
                color: isTotal ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
          ),
          if (trailing != null) ...[trailing, const SizedBox(width: 6)],
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isDiscount
                  ? _kGreen
                  : isTotal
                  ? Colors.black87
                  : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = days[d.weekday - 1];
    return '$wd, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
