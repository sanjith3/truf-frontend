import 'package:flutter/material.dart';
import '../features/bookings/my_bookings_screen.dart';
import '../features/home/user_home_screen.dart';
import '../models/turf.dart';
import '../services/turf_data_service.dart';

class PaymentScreen extends StatefulWidget {
  final Turf turf;
  final DateTime selectedDate;
  final List<String> selectedTimeSlots;
  final double baseAmount;
  final double platformFee;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.turf,
    required this.selectedDate,
    required this.selectedTimeSlots,
    required this.baseAmount,
    required this.platformFee,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'gpay';
  bool _isProcessing = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'gpay',
      name: 'Google Pay',
      imageAsset: 'assets/images/icons/payments/gpay.png',
      color: Colors.red,
      description: 'UPI & Wallet',
    ),
    PaymentMethod(
      id: 'paytm',
      name: 'Paytm',
      imageAsset: 'assets/images/icons/payments/paytm.png',
      color: Colors.blue,
      description: 'Wallet & UPI',
    ),
    PaymentMethod(
      id: 'phonepe',
      name: 'PhonePe',
      imageAsset: 'assets/images/icons/payments/phonepe.png',
      color: Colors.purple,
      description: 'UPI & Wallet',
    ),
    PaymentMethod(
      id: 'card',
      name: 'Credit/Debit Card',
      imageAsset: 'assets/images/icons/payments/card.png',
      color: Colors.orange,
      description: 'Visa, Mastercard, RuPay',
    ),
    PaymentMethod(
      id: 'netbanking',
      name: 'Net Banking',
      imageAsset: 'assets/images/icons/payments/bank.png',
      color: Colors.green,
      description: 'All major banks',
    ),
  ];

  void _processPayment() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
      });
      _showPaymentSuccess();
    });
  }

  void _showPaymentSuccess() {
    // Save booking to service
    final newBooking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      turfName: widget.turf.name,
      location: widget.turf.location,
      distance: widget.turf.distance,
      rating: widget.turf.rating,
      date: widget.selectedDate,
      startTime: widget.selectedTimeSlots.first.split(" - ")[0],
      endTime: widget.selectedTimeSlots.last.split(" - ")[1],
      amount: widget.totalAmount,
      status: BookingStatus.upcoming,
      paymentStatus: 'Paid',
      bookingId: 'TURF-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      amenities: widget.turf.amenities,
      mapLink: widget.turf.mapLink,
      address: widget.turf.address,
    );
    TurfDataService().addBooking(newBooking);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                "Your booking at ${widget.turf.name} is confirmed",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildConfirmationRow("Turf", widget.turf.name),
                    _buildConfirmationRow(
                      "Date",
                      "${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}",
                    ),
                    _buildConfirmationRow(
                      "Duration",
                      "${widget.selectedTimeSlots.length} hour(s)",
                    ),
                    ...widget.selectedTimeSlots
                        .map((slot) => _buildConfirmationRow("Slot", slot))
                        .toList(),
                    const Divider(height: 20),
                    _buildConfirmationRow(
                      "Amount Paid",
                      "₹${widget.totalAmount.toStringAsFixed(0)}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "GO TO MY BOOKINGS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF1DB954) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method.id == _selectedPaymentMethod,
      orElse: () => _paymentMethods.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Payment Method"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Compact Total Amount Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "₹${widget.totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            "₹${widget.platformFee.toInt()} fee",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${widget.selectedTimeSlots.length} hour${widget.selectedTimeSlots.length > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.turf.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment Methods
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choose Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Payment Methods List
                  Column(
                    children: _paymentMethods.map((method) {
                      return _buildPaymentMethodCard(method);
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // Selected Payment Method Details
                  if (selectedMethod.description.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: selectedMethod.color.withAlpha(13),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedMethod.color.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selectedMethod.color.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              selectedMethod.imageAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Text(
                                      selectedMethod.name.substring(0, 2),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: selectedMethod.color,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Paying with ${selectedMethod.name}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedMethod.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 25),

                  // Terms & Conditions
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      "• Your payment is secured with 256-bit SSL encryption\n"
                      "• No card details are stored on our servers\n"
                      "• Refunds are processed within 5-7 business days",
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // Pay Now Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
            ),
            child: _isProcessing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text("Processing..."),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "PAY SECURELY - ₹${widget.totalAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: method.color.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: method.color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                method.imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      method.name.substring(0, 2),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: method.color,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: method.color, size: 24),
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String imageAsset;
  final Color color;
  final String description;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.color,
    required this.description,
  });
}
