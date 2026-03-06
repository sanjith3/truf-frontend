import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/booking.dart';
import 'booking_success_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;
  final bool isAdmin;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    this.isAdmin = false,
  });

  Future<void> _openMapLocation(BuildContext context, String mapLink) async {
    if (mapLink.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Map link not available")));
      return;
    }
    final Uri uri = Uri.parse(mapLink);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Google Maps")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Real financial breakdown from API
    final double finalPrice = booking.amount;
    final double totalPrice = booking.totalPrice > 0
        ? booking.totalPrice
        : finalPrice;
    final double discount = booking.discount;
    final double gst = booking.gstAmount;
    final double platformFee = booking.platformFee;
    final double creditsUsed = booking.creditsUsed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(booking.status),
                      color: _getStatusColor(booking.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.status == BookingStatus.upcoming
                            ? "Booking Confirmed"
                            : _getStatusText(booking.status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(booking.status),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Booking ID: ${booking.bookingId}",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Turf Details Card
            const Text(
              "Turf Details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Turf Image — real API URL or green gradient placeholder
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child:
                          booking.imageUrl != null &&
                              booking.imageUrl!.isNotEmpty
                          ? Image.network(
                              booking.imageUrl!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return _buildImagePlaceholder(loading: true);
                              },
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Turf name + rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.turfName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (booking.rating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      booking.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking.address.isNotEmpty
                                    ? booking.address
                                    : booking.location,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Offer badge
                        if (booking.hasActiveOffer &&
                            booking.offerValue != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DB954).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF1DB954).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  size: 14,
                                  color: Color(0xFF1DB954),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  booking.offerType == 'percentage'
                                      ? '${booking.offerValue}% OFF offer applied'
                                      : '₹${booking.offerValue} OFF offer applied',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1DB954),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openMapLocation(context, booking.mapLink),
                            icon: const Icon(Icons.map_outlined),
                            label: const Text("View on Maps"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF00C853),
                              side: const BorderSide(color: Color(0xFF00C853)),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time + Sports info
            Row(
              children: [
                Expanded(
                  child: _buildInfoSection(
                    "Date & Time",
                    "${DateFormat('MMM dd, yyyy').format(booking.date)}\n${booking.startTime} - ${booking.endTime}",
                    Icons.access_time_filled,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoSection(
                    "Sports",
                    booking.sports.isNotEmpty
                        ? booking.sports.take(3).join(", ")
                        : (booking.amenities.isNotEmpty
                              ? booking.amenities.take(3).join(", ")
                              : "—"),
                    Icons.sports_soccer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amenities row (only if there are amenities)
            if (booking.amenities.isNotEmpty) ...[
              _buildInfoSection(
                "Amenities",
                booking.amenities.join("  •  "),
                Icons.checklist,
                fullWidth: true,
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 8),

            // Payment Bill
            const Text(
              "Payment Summary",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildPaymentRow(
                    "Base Price",
                    "₹${totalPrice.toStringAsFixed(0)}",
                  ),
                  if (discount > 0)
                    _buildPaymentRow(
                      "Discount",
                      "-₹${discount.toStringAsFixed(0)}",
                      valueColor: const Color(0xFF00C853),
                    ),
                  if (gst > 0)
                    _buildPaymentRow("GST", "₹${gst.toStringAsFixed(0)}"),
                  if (platformFee > 0)
                    _buildPaymentRow(
                      "Platform Fee",
                      "₹${platformFee.toStringAsFixed(0)}",
                    ),
                  if (creditsUsed > 0)
                    _buildPaymentRow(
                      "Credits Used",
                      "-₹${creditsUsed.toStringAsFixed(0)}",
                      valueColor: Colors.purple,
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  _buildPaymentRow(
                    "Total Paid",
                    "₹${finalPrice.toStringAsFixed(0)}",
                    isTotal: true,
                  ),
                  const SizedBox(height: 12),
                  // Payment status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: booking.paymentStatus.toLowerCase() == 'paid'
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          booking.paymentStatus.toLowerCase() == 'paid'
                              ? Icons.verified_user
                              : Icons.info_outline,
                          size: 16,
                          color: booking.paymentStatus.toLowerCase() == 'paid'
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Payment: ${booking.paymentStatus.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: booking.paymentStatus.toLowerCase() == 'paid'
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cancelled reason
            if (booking.status == BookingStatus.cancelled &&
                booking.cancelledReason != null &&
                booking.cancelledReason!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[400], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Cancellation reason: ${booking.cancelledReason}",
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Invite Teammates — only for upcoming/confirmed bookings
            if (booking.status == BookingStatus.upcoming ||
                booking.status == BookingStatus.confirmed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF6B00).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text('⚡', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          'Invite your team to this game!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share with teammates and earn ₹10 per join',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingSuccessScreen(
                                bookingId: int.tryParse(booking.bookingId) ?? 0,
                                turfName: booking.turfName,
                                bookingDate: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(booking.date),
                                timeSlot:
                                    '${booking.startTime} - ${booking.endTime}',
                                totalPaid: booking.amount.toStringAsFixed(0),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.groups, size: 18),
                        label: const Text('Invite Teammates'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Help
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Need help with this booking?",
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1DB954), Color(0xFF0D7A35)],
        ),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : const Icon(Icons.grass, size: 48, color: Colors.white54),
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String value,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF00C853)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color:
                  valueColor ??
                  (isTotal ? const Color(0xFF00C853) : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
      case BookingStatus.upcoming:
        return const Color(0xFF00C853);
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.redAccent;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
      case BookingStatus.upcoming:
        return Icons.event_available;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.cancelled:
        return Icons.event_busy;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return "Pending";
      case BookingStatus.confirmed:
        return "Confirmed";
      case BookingStatus.upcoming:
        return "Upcoming";
      case BookingStatus.completed:
        return "Completed";
      case BookingStatus.cancelled:
        return "Cancelled";
    }
  }
}
