import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../payment/payment_screen.dart';
import '../services/offer_slot_service.dart';

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
  final double _fixedConvenienceFee = 10.0; // Fixed fee of ₹10
  List<String> _offerSlots = []; // Will be loaded from service

  double get _offerPrice => widget.turf.price * 0.8;

  // Check if any selected slot has an offer
  bool get _hasAnyOfferSlot {
    return widget.selectedTimeSlots.any((slot) => _offerSlots.contains(slot));
  }

  // Get price for a specific slot
  double _getSlotPrice(String slot) {
    return _offerSlots.contains(slot)
        ? _offerPrice
        : widget.turf.price.toDouble();
  }

  @override
  void initState() {
    super.initState();
    _loadOfferSlots();
  }

  Future<void> _loadOfferSlots() async {
    final offerSlots = await OfferSlotService.getOfferSlots();
    setState(() {
      _offerSlots = offerSlots;
    });
  }

  @override
  Widget build(BuildContext context) {
    final convenienceFee = _fixedConvenienceFee;
    final finalAmount = widget.totalAmount + convenienceFee;
    final hasAnyOffer = _hasAnyOfferSlot;

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
                    _buildDetailRow(
                      "Rate per hour",
                      hasAnyOffer
                          ? "₹${widget.turf.price} (₹${_offerPrice.toInt()} for offer slots)"
                          : "₹${widget.turf.price}",
                      valueColor: hasAnyOffer ? const Color(0xFF1DB954) : null,
                    ),
                    const SizedBox(height: 15),
                    ...widget.selectedTimeSlots.map((slot) {
                      final isOfferSlot = _offerSlots.contains(slot);
                      final slotPrice = _getSlotPrice(slot);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isOfferSlot
                                      ? Icons.local_offer
                                      : Icons.circle,
                                  size: isOfferSlot ? 12 : 8,
                                  color: isOfferSlot
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  slot,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Text(
                              "₹${slotPrice.toInt()}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isOfferSlot
                                    ? const Color(0xFF1DB954)
                                    : Colors.black,
                              ),
                            ),
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
                    if (hasAnyOffer)
                      _buildPaymentRow(
                        "Original Price",
                        "₹${(widget.turf.price * widget.selectedTimeSlots.length).toStringAsFixed(0)}",
                        description: "Standard rate without offer",
                      ),
                    _buildPaymentRow(
                      hasAnyOffer ? "Discounted Base Amount" : "Base Amount",
                      "₹${widget.totalAmount.toStringAsFixed(0)}",
                      color: hasAnyOffer ? const Color(0xFF1DB954) : null,
                      isBold: hasAnyOffer,
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
                        "A fixed platform fee of ₹10 is charged per booking for maintenance and support services.",
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

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
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
