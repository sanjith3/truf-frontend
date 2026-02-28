import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../booking/booking_screen.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

/// Payment Summary Screen
///
/// Receives: turfId, bookingDate, slotIds from BookingScreen
/// Calls: POST /api/bookings/bookings/preview/
/// Displays: All financial data from API response
/// Stores: preview_token + total_payable for confirm step
///
/// RULES:
/// - Zero client-side calculations
/// - Money as String, NEVER double
/// - All numbers come from backend preview response
class PaymentSummaryScreen extends StatefulWidget {
  final Turf turf;
  final String bookingDate;
  final List<int> slotIds;
  final List<ApiSlot> selectedSlots; // For display only (time labels)

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
  final ApiService _api = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  // ─── All from preview API — String, never double ───
  String _previewToken = '';
  String _subtotal = '0';
  String _discountTotal = '0';
  String _gstAmount = '0';
  String _platformFee = '0';
  String _gstOnPlatformFee = '0';
  String _totalPayable = '0';
  String _firstBookingDiscount = '0';
  String _turfName = '';
  String _expiresAt = '';

  @override
  void initState() {
    super.initState();
    _callPreviewApi();
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
        setState(() {
          _previewToken = response['preview_token'] ?? '';
          _subtotal = response['subtotal']?.toString() ?? '0';
          _discountTotal = response['discount_total']?.toString() ?? '0';
          _gstAmount = response['gst_amount']?.toString() ?? '0';
          _platformFee = response['platform_fee']?.toString() ?? '0';
          _gstOnPlatformFee =
              response['gst_on_platform_fee']?.toString() ?? '0';
          _totalPayable = response['total_payable']?.toString() ?? '0';
          _firstBookingDiscount =
              response['first_booking_discount']?.toString() ?? '0';
          _turfName = response['turf_name']?.toString() ?? widget.turf.name;
          _expiresAt = response['expires_at']?.toString() ?? '';
          _isLoading = false;
        });
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
      print('🚨 Preview error: $e');
    }
  }

  void _proceedToPayment() {
    if (_previewToken.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          previewToken: _previewToken,
          totalPayable: _totalPayable,
          turfName: _turfName,
          bookingDate: widget.bookingDate,
          slotCount: widget.slotIds.length,
          turf: widget.turf,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Summary"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1DB954),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Generating preview...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? _buildErrorView()
          : _buildSummaryView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Go Back",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryView() {
    final hasDiscount = _discountTotal != '0' && _discountTotal != '0.00';
    final hasFirstBookingDiscount =
        _firstBookingDiscount != '0' && _firstBookingDiscount != '0.00';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turf info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: widget.turf.images.isNotEmpty
                                ? NetworkImage(widget.turf.images.first)
                                : const NetworkImage(
                                    "https://via.placeholder.com/150",
                                  ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _turfName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.bookingDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "${widget.slotIds.length} slot${widget.slotIds.length > 1 ? 's' : ''} selected",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Selected slots
                const Text(
                  "Selected Slots",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...widget.selectedSlots.map((slot) => _slotRow(slot)),

                const SizedBox(height: 20),

                // Price breakdown — ALL from API
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Price Breakdown",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      _priceRow("Subtotal", "₹$_subtotal"),
                      if (hasDiscount)
                        _priceRow(
                          "Discount",
                          "- ₹$_discountTotal",
                          isGreen: true,
                        ),
                      _priceRow("GST (18%)", "₹$_gstAmount"),
                      _priceRow("Platform Fee", "₹$_platformFee"),
                      _priceRow("GST on Platform Fee", "₹$_gstOnPlatformFee"),
                      if (hasFirstBookingDiscount)
                        _priceRow(
                          "First Booking Discount",
                          "- ₹$_firstBookingDiscount",
                          isGreen: true,
                        ),
                      const Divider(height: 20),
                      _priceRow(
                        "Total Payable",
                        "₹$_totalPayable",
                        isBold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Expiry notice
                if (_expiresAt.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "This preview expires in 5 minutes. Complete payment before it expires.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom: Pay button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                "PROCEED TO PAY  •  ₹$_totalPayable",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _slotRow(ApiSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                slot.displayTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (slot.hasOffer)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    "₹${slot.originalPrice}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              Text(
                "₹${slot.finalPrice}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: slot.hasOffer ? Colors.red.shade600 : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isGreen = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isGreen
                  ? Colors.green.shade700
                  : (isBold ? Colors.black : Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
