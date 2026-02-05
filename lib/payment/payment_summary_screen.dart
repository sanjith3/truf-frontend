import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../payment/payment_screen.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final Turf turf;
  final DateTime selectedDate;
  final List<String> selectedTimeSlots;
  final double totalAmount;

  const PaymentSummaryScreen({
    super.key,
    required this.turf,
    required this.selectedDate,
    required this.selectedTimeSlots,
    required this.totalAmount,
  });

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  final double _fixedConvenienceFee = 20.0; // Fixed fee of ₹20

  @override
  Widget build(BuildContext context) {
    final convenienceFee = _fixedConvenienceFee;
    final finalAmount = widget.totalAmount + convenienceFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Summary"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Turf Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
                          image: NetworkImage(widget.turf.images[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turf.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.turf.location,
                            style: TextStyle(
                              fontSize: 14,
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

              // Booking Details
              const Text(
                "Booking Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      "Date",
                      "${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}",
                    ),
                    _buildDetailRow(
                      "Total Hours",
                      "${widget.selectedTimeSlots.length} hour(s)",
                    ),
                    _buildDetailRow("Rate per hour", "₹${widget.turf.price}"),
                    const SizedBox(height: 15),
                    ...widget.selectedTimeSlots.map((slot) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 10),
                            Text(slot, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Payment Breakdown
              const Text(
                "Payment Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildPaymentRow(
                      "Base Amount",
                      "₹${widget.totalAmount.toStringAsFixed(0)}",
                    ),
                    _buildPaymentRow(
                      "Platform Fee",
                      "₹${convenienceFee.toStringAsFixed(0)}",
                      description: "Fixed service charge per booking",
                    ),
                    const Divider(height: 25),
                    _buildPaymentRow(
                      "Total Payable",
                      "₹${finalAmount.toStringAsFixed(0)}",
                      isBold: true,
                      color: const Color(0xFF1DB954),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Convenience Fee Explanation
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "A fixed platform fee of ₹20 is charged per booking for maintenance and support services.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Terms & Conditions
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "• Platform fee is non-refundable",
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const Text(
                      "• Cancellation allowed up to 2 hours before booking",
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const Text(
                      "• All payments are secure and encrypted",
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    Text(
                      "• Platform fee: Fixed ₹20 per booking",
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Proceed to Payment Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          turf: widget.turf,
                          selectedDate: widget.selectedDate,
                          selectedTimeSlots: widget.selectedTimeSlots,
                          baseAmount: widget.totalAmount,
                          platformFee: convenienceFee,
                          totalAmount: finalAmount,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    "PROCEED TO PAY ₹${finalAmount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    String? description,
    bool isBold = false,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
