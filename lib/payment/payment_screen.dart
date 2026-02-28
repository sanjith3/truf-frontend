import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/bookings/my_bookings_screen.dart';
import '../features/home/user_home_screen.dart';
import '../features/referral/invite_friends_screen.dart';
import '../models/turf.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';

/// Payment Screen — Razorpay checkout flow
///
/// Receives: previewToken (String), totalPayable (String), metadata
/// Flow:
///   1. POST /api/payments/create-order/ → Razorpay order_id
///   2. Open Razorpay checkout SDK
///   3. On success → POST /api/payments/verify/ → booking confirmed
///
/// RULES:
/// - totalPayable is String, NEVER double
/// - No local booking creation
/// - All booking data comes from backend verify/confirm response
class PaymentScreen extends StatefulWidget {
  final String previewToken;
  final String totalPayable; // Always String, never double
  final String turfName;
  final String bookingDate;
  final int slotCount;
  final Turf turf;

  const PaymentScreen({
    super.key,
    required this.previewToken,
    required this.totalPayable,
    required this.turfName,
    required this.bookingDate,
    required this.slotCount,
    required this.turf,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'gpay';
  bool _isProcessing = false;
  String _userName = 'Guest User';
  String _userPhone = '';
  String _userEmail = '';

  final ApiService _api = ApiService();
  late Razorpay _razorpay;

  // Stored after create-order, used in verify
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Guest User';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  // ─── STEP 1: Create Razorpay order via backend ───
  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final response = await _api.postAuthRaw(
        '/api/payments/create-order/',
        body: {'preview_token': widget.previewToken},
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);
      final statusCode = response.statusCode;

      if (statusCode == 200 && body['order_id'] != null) {
        // Order created — open Razorpay checkout
        _currentOrderId = body['order_id'];
        final keyId = body['key_id'] ?? '';
        final amount = body['amount']; // in paise

        var options = {
          'key': keyId,
          'amount': amount,
          'order_id': _currentOrderId,
          'name': 'TurfZone',
          'description': '${widget.turfName} - ${widget.bookingDate}',
          'prefill': {
            'name': _userName,
            'contact': _userPhone,
            'email': _userEmail,
          },
          'theme': {'color': '#1DB954'},
        };

        _razorpay.open(options);
      } else if (statusCode == 503) {
        // Payment gateway not configured — fall back to direct confirm
        setState(() => _isProcessing = false);
        _fallbackDirectConfirm();
      } else if (statusCode == 400) {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          "Error",
          body['error']?.toString() ?? "Could not create payment order.",
          shouldGoBack: true,
        );
      } else if (statusCode == 401) {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          "Session Expired",
          "Your session has expired. Please login again.",
          shouldGoToLogin: true,
        );
      } else {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          "Error",
          body['error']?.toString() ??
              "Payment order failed. Please try again.",
        );
      }
    } on AuthExpiredException {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog(
        "Session Expired",
        "Your session has expired. Please login again.",
        shouldGoToLogin: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      // Fallback to direct confirm if Razorpay unavailable
      _fallbackDirectConfirm();
      print('🚨 Create order error: $e');
    }
  }

  // ─── STEP 2a: Razorpay payment success → verify + confirm ───
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    try {
      final verifyResponse = await _api.postAuthRaw(
        '/api/payments/verify/',
        body: {
          'razorpay_order_id': response.orderId ?? '',
          'razorpay_payment_id': response.paymentId ?? '',
          'razorpay_signature': response.signature ?? '',
          'preview_token': widget.previewToken,
          'total_payable': widget.totalPayable,
        },
      );

      if (!mounted) return;

      final body = jsonDecode(verifyResponse.body);

      if (verifyResponse.statusCode == 200 && body['success'] == true) {
        setState(() => _isProcessing = false);
        _showPaymentSuccess(
          bookingId: body['booking_id']?.toString() ?? '',
          bookingDate: widget.bookingDate,
          startTime: '',
          endTime: '',
          totalPaid: widget.totalPayable,
        );
      } else {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          "Verification Failed",
          body['error']?.toString() ??
              "Payment was received but booking confirmation failed. Contact support.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog(
        "Verification Error",
        "Payment may have been processed. Please check My Bookings or contact support.",
      );
      print('🚨 Verify error: $e');
    }
  }

  // ─── STEP 2b: Razorpay payment error ───
  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showErrorDialog(
      "Payment Failed",
      response.message ?? "Payment was cancelled or failed. Please try again.",
    );
  }

  // ─── STEP 2c: External wallet selected ───
  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  // ─── FALLBACK: Direct confirm (when Razorpay not configured) ───
  Future<void> _fallbackDirectConfirm() async {
    setState(() => _isProcessing = true);

    try {
      final response = await _api.postAuthRaw(
        '/api/bookings/bookings/confirm/',
        body: {
          'preview_token': widget.previewToken,
          'total_payable': widget.totalPayable,
        },
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);
      final statusCode = response.statusCode;

      if (statusCode == 201 && body['success'] == true) {
        // Refresh user profile so first_booking_completed updates immediately
        await AuthState.instance.loadProfile();
        setState(() => _isProcessing = false);
        _showPaymentSuccess(
          bookingId: body['booking_id']?.toString() ?? '',
          bookingDate: body['booking_date']?.toString() ?? widget.bookingDate,
          startTime: body['start_time']?.toString() ?? '',
          endTime: body['end_time']?.toString() ?? '',
          totalPaid: body['total_payable']?.toString() ?? widget.totalPayable,
        );
      } else if (statusCode == 410) {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          "Preview Expired",
          "Your booking preview has expired. Please go back and try again.",
          shouldGoBack: true,
        );
      } else if (statusCode == 409) {
        final error = body['error']?.toString() ?? 'Conflict';
        final newTotal = body['new_total_payable']?.toString();
        setState(() => _isProcessing = false);
        if (newTotal != null) {
          _showErrorDialog(
            "Price Changed",
            "The price has changed since your preview.\n\nNew total: ₹$newTotal\n\nPlease go back and re-preview.",
            shouldGoBack: true,
          );
        } else {
          _showErrorDialog("Slot Unavailable", error, shouldGoBack: true);
        }
      } else {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          "Error",
          body['error']?.toString() ?? "Booking failed. Please try again.",
        );
      }
    } on AuthExpiredException {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog(
        "Session Expired",
        "Your session has expired. Please login again.",
        shouldGoToLogin: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog(
        "Connection Error",
        "Could not connect to server. Please check your network.",
      );
      print('🚨 Confirm error: $e');
    }
  }

  void _showErrorDialog(
    String title,
    String message, {
    bool shouldGoBack = false,
    bool shouldGoToLogin = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (shouldGoToLogin) {
                // Clear tokens and go to login
                ApiService.clearTokens();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                  (route) => false,
                );
              } else if (shouldGoBack) {
                Navigator.pop(context); // Go back to summary
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccess({
    required String bookingId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String totalPaid,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 40,
                    color: Color(0xFF1DB954),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your booking at ${widget.turfName} is confirmed",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Confirmation details — ALL from backend
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildConfirmationRow("Booking ID", "#$bookingId"),
                      _buildConfirmationRow("Turf", widget.turfName),
                      _buildConfirmationRow("Date", bookingDate),
                      _buildConfirmationRow(
                        "Duration",
                        "${widget.slotCount} hour(s)",
                      ),
                      _buildConfirmationRow("Time", "$startTime - $endTime"),
                      const Divider(height: 20),
                      _buildConfirmationRow(
                        "Amount Paid",
                        "₹$totalPaid",
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Invite Friends CTA ───
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1DB954).withOpacity(0.08),
                        const Color(0xFF1ED760).withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1DB954).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎉 Earn ₹50 cashback by inviting 3 friends!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InviteFriendsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Invite Friends Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // My Bookings button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserHomeScreen(),
                        ),
                        (route) => false,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyBookingsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "View My Bookings",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? const Color(0xFF1DB954) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
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
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow("Turf", widget.turfName),
                        _buildSummaryRow("Date", widget.bookingDate),
                        _buildSummaryRow(
                          "Slots",
                          "${widget.slotCount} hour(s)",
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          "Total Payable",
                          "₹${widget.totalPayable}",
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment methods
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    'gpay',
                    'Google Pay',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                  _buildPaymentOption(
                    'phonepe',
                    'PhonePe',
                    Icons.phone_android,
                    Colors.purple,
                  ),
                  _buildPaymentOption(
                    'paytm',
                    'Paytm',
                    Icons.payment,
                    Colors.blue.shade300,
                  ),
                  _buildPaymentOption(
                    'card',
                    'Credit/Debit Card',
                    Icons.credit_card,
                    Colors.orange,
                  ),
                  _buildPaymentOption('upi', 'UPI', Icons.qr_code, Colors.teal),

                  const SizedBox(height: 16),

                  // User info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$_userName  •  $_userPhone",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Secure payment badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Your payment is secured",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pay button
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
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        "PAY ₹${widget.totalPayable}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? Colors.black : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1DB954).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1DB954) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1DB954) : iconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1DB954) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1DB954),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
