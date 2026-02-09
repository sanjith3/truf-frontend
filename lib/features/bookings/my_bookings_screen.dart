import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'booking_details_screen.dart';
import '../../services/turf_data_service.dart';
import '../../models/booking.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool isAdmin; // Add this parameter to identify if user is admin
  const MyBookingsScreen({super.key, this.isAdmin = false});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TurfDataService _turfService = TurfDataService();

  List<Booking> get _allBookings => _turfService.bookings;

  // Define turf images for each booking
  final Map<String, String> _turfImages = {
    'Green Field Arena':
        'https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800',
    'Elite Football Ground':
        'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
    'City Sports Turf':
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
    'Victory Sports Park':
        'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800',
    'Premium Sports Arena':
        'https://images.unsplash.com/photo-1547347298-4074fc3086f0?w=800',
    'Budget Sports Ground':
        'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=800',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _turfService.initDemoBookings();
    _startStatusCheckTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh bookings when returning to this screen
    setState(() {});
  }

  void _startStatusCheckTimer() {
    // Check every minute for bookings that should be moved to completed
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _updateBookingStatuses();
        _startStatusCheckTimer();
      }
    });
  }

  void _updateBookingStatuses() {
    final now = DateTime.now();
    bool updated = false;

    for (var booking in _allBookings) {
      if (booking.status == BookingStatus.upcoming ||
          booking.status == BookingStatus.pending ||
          booking.status == BookingStatus.confirmed) {
        // Check if booking time has passed
        final bookingDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          int.parse(
            booking.startTime.split(':')[0].replaceAll(RegExp(r'[^0-9]'), ''),
          ),
          int.parse(
            booking.startTime.split(':')[1].replaceAll(RegExp(r'[^0-9]'), ''),
          ),
        );

        // If current time is after booking end time + 1 hour buffer, mark as completed
        final endTime = bookingDateTime.add(
          const Duration(hours: 2),
        ); // 1 hour slot + 1 hour buffer
        if (now.isAfter(endTime)) {
          booking.status = BookingStatus.completed;
          updated = true;
        }
      }
    }

    if (updated) {
      setState(() {});
    }
  }

  List<Booking> get _upcomingBookings {
    return _allBookings
        .where(
          (b) =>
              b.status == BookingStatus.upcoming ||
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed,
        )
        .toList();
  }

  List<Booking> get _completedBookings {
    return _allBookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();
  }

  List<Booking> get _cancelledBookings {
    return _allBookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();
  }

  // Check if booking can be cancelled (within 1 hour of booking time for users, anytime for admin)
  bool _canCancelBooking(Booking booking) {
    // ✅ Admin can cancel anytime (only if not already cancelled/completed)
    if (widget.isAdmin) {
      return booking.status == BookingStatus.upcoming ||
          booking.status == BookingStatus.pending ||
          booking.status == BookingStatus.confirmed;
    }

    // ✅ User rule → allow cancel ONLY within 60 minutes BEFORE start time
    final now = DateTime.now();

    final bookingDateTime = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      int.parse(
        booking.startTime.split(':')[0].replaceAll(RegExp(r'[^0-9]'), ''),
      ),
      int.parse(
        booking.startTime.split(':')[1].replaceAll(RegExp(r'[^0-9]'), ''),
      ),
    );

    final differenceInMinutes = bookingDateTime.difference(now).inMinutes;

    return differenceInMinutes <= 60 && differenceInMinutes >= 0;
  }

  void _cancelBooking(Booking booking) {
    final canCancel = _canCancelBooking(booking);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.isAdmin
              ? "Cancel Booking (Admin)"
              : (canCancel ? "Cancel Booking" : "Cancellation Not Allowed"),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isAdmin
                  ? "Are you sure you want to cancel this booking as admin?"
                  : (canCancel
                        ? "Are you sure you want to cancel this booking?"
                        : "This booking cannot be cancelled because:"),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isAdmin
                    ? Colors.blue[50]
                    : (canCancel ? Colors.orange[50] : Colors.red[50]),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isAdmin
                      ? Colors.blue[200]!
                      : (canCancel ? Colors.orange[200]! : Colors.red[200]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• Refund will be processed within 7 business days",
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                  if (!widget.isAdmin) ...[
                    const SizedBox(height: 4),
                    Text(
                      "• Cancellation allowed only within 1 hour after booking start",

                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ],
                  if (!canCancel && !widget.isAdmin) ...[
                    const SizedBox(height: 4),
                    Text(
                      "• You can cancel only within 1 hour after the booking start time",

                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),

          // ✅ Show confirm button ONLY if cancellation allowed
          if (widget.isAdmin || canCancel)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  booking.status = BookingStatus.cancelled;
                  booking.paymentStatus = 'Refund Initiated';
                  if (widget.isAdmin) booking.cancelledByAdmin = true;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.isAdmin
                          ? "Booking cancelled by admin. Refund in 7 days."
                          : "Booking cancelled. Refund in 7 days.",
                    ),
                    backgroundColor: widget.isAdmin
                        ? Colors.blue
                        : Colors.green,
                  ),
                );
              },
              child: Text(
                widget.isAdmin ? "Cancel as Admin" : "Confirm Cancel",
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openMapLocation(String mapLink) async {
    final Uri uri = Uri.parse(mapLink);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  void _showRatingDialog(BuildContext context, String turfName) {
    double rating = 0;
    String review = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rate Your Experience",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "How was your experience at $turfName?",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Star Rating
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rating = (index + 1).toDouble();
                              });
                            },
                            child: Icon(
                              index < rating.toInt()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 40,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        rating == 0
                            ? "Tap to rate"
                            : "${rating.toInt()}.0 Stars",
                        style: TextStyle(
                          fontSize: 14,
                          color: rating == 0
                              ? Colors.grey[500]
                              : Colors.amber[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Review Description
                    const Text(
                      "Add a Review",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        maxLines: 4,
                        onChanged: (value) => review = value,
                        decoration: const InputDecoration(
                          hintText: "Share your experience (optional)...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: rating == 0
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          rating == 5
                                              ? "Thanks for your ${rating.toInt()}-star review! ❤️"
                                              : "Thanks for your ${rating.toInt()}-star review!",
                                        ),
                                        backgroundColor: const Color(
                                          0xFF00C853,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: const Text(
                              "Submit Review",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    if (rating == 0)
                      Center(
                        child: Text(
                          "Please select a rating",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _viewBookingDetails(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          booking: booking,
          imageUrl:
              _turfImages[booking.turfName] ??
              "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800",
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? "Admin: Bookings" : "My Bookings"),
        backgroundColor: widget.isAdmin
            ? const Color(0xFF1DB954)
            : const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: "Scheduled"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Tab
          _buildBookingList(
            bookings: _upcomingBookings,
            emptyMessage: "No upcoming bookings",
            showCancelButton: true,
          ),
          // Completed Tab
          _buildBookingList(
            bookings: _completedBookings,
            emptyMessage: "No completed bookings",
            showCancelButton: false,
          ),
          // Cancelled Tab
          _buildBookingList(
            bookings: _cancelledBookings,
            emptyMessage: "No cancelled bookings",
            showCancelButton: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList({
    required List<Booking> bookings,
    required String emptyMessage,
    required bool showCancelButton,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isAdmin
                  ? "No bookings found for this status"
                  : "Book your first turf to get started",
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final canCancel = _canCancelBooking(bookings[index]);
        return BookingTurfCard(
          booking: bookings[index],
          imageUrl:
              _turfImages[bookings[index].turfName] ??
              "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800",
          showCancelButton: showCancelButton,
          canCancel: canCancel,
          isAdmin: widget.isAdmin,
          onCancel: () => _cancelBooking(bookings[index]),
          onOpenMap: (mapLink) => _openMapLocation(mapLink),
          onRate: (turfName) => _showRatingDialog(context, turfName),
          onViewDetails: () => _viewBookingDetails(bookings[index]),
        );
      },
    );
  }
}

class BookingTurfCard extends StatelessWidget {
  final Booking booking;
  final String imageUrl;
  final bool showCancelButton;
  final bool canCancel;
  final bool isAdmin;
  final VoidCallback onCancel;
  final Function(String) onOpenMap;
  final Function(String) onRate;
  final VoidCallback onViewDetails;

  const BookingTurfCard({
    super.key,
    required this.booking,
    required this.imageUrl,
    required this.showCancelButton,
    required this.canCancel,
    required this.isAdmin,
    required this.onCancel,
    required this.onOpenMap,
    required this.onRate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(booking.date, DateTime.now());
    final isTomorrow = isSameDay(
      booking.date,
      DateTime.now().add(const Duration(days: 1)),
    );

    String dateText;
    if (isToday) {
      dateText = "Today";
    } else if (isTomorrow) {
      dateText = "Tomorrow";
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(booking.date);
    }

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (booking.status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
      case BookingStatus.upcoming:
        statusColor = isAdmin
            ? const Color(0xFF1DB954)
            : const Color(0xFF00C853);
        statusText = "Upcoming";
        statusIcon = Icons.access_time;
        break;
      case BookingStatus.completed:
        statusColor = Colors.blue;
        statusText = "Completed";
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.grey[700]!;
        statusText = "Cancelled";
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Status Badge
          Stack(
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Status Badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Admin Badge
              if (isAdmin && showCancelButton && canCancel)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Admin: Can Cancel",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // User: Cancellation Info Badge (if within 1 hour window)
              if (!isAdmin && showCancelButton && canCancel)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.timer, size: 10, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "Can Cancel",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Paid Status Badge
              if (booking.paymentStatus == 'Paid')
                Positioned(
                  top:
                      (isAdmin && showCancelButton && canCancel) ||
                          (!isAdmin && showCancelButton && canCancel)
                      ? 40
                      : 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? const Color(0xFF1DB954)
                          : const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Paid",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Refund Status Badge
              if (booking.paymentStatus.contains('Refund'))
                Positioned(
                  top:
                      (isAdmin && showCancelButton && canCancel) ||
                          (!isAdmin && showCancelButton && canCancel)
                      ? 40
                      : 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.paymentStatus,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Cancelled by Admin Badge
              if (booking.cancelledByAdmin == true)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Cancelled by Admin",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Booking Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.turfName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: isAdmin
                                    ? const Color(0xFF1DB954)
                                    : Colors.redAccent,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onOpenMap(booking.mapLink),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (isAdmin
                                      ? const Color(0xFF1DB954)
                                      : const Color(0xFF00C853))
                                  .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions,
                          color: isAdmin
                              ? const Color(0xFF1DB954)
                              : const Color(0xFF00C853),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Date & Time
                Row(
                  children: [
                    _buildFeatureInfo(Icons.calendar_today, dateText),
                    const SizedBox(width: 12),
                    _buildFeatureInfo(
                      Icons.access_time,
                      "${booking.startTime} - ${booking.endTime}",
                    ),
                  ],
                ),

                // Cancellation Policy Info
                if (showCancelButton)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: canCancel
                              ? (isAdmin ? Colors.blue : Colors.green)
                              : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isAdmin
                                ? (canCancel
                                      ? "Admin: Can cancel this booking anytime"
                                      : "Booking cannot be cancelled")
                                : (canCancel
                                      ? "Cancellation available (within 1 hour window)"
                                      : "Cancellation window expired"),
                            style: TextStyle(
                              fontSize: 11,
                              color: canCancel
                                  ? (isAdmin ? Colors.blue : Colors.green)
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: onViewDetails,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isAdmin
                                  ? const Color(0xFF1DB954)
                                  : const Color(0xFF00C853),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              color: isAdmin
                                  ? const Color(0xFF1DB954)
                                  : const Color(0xFF00C853),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (showCancelButton)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onCancel,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAdmin
                                  ? Colors.blue
                                  : Colors.redAccent,

                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isAdmin ? "Cancel as Admin" : "Cancel",
                              style: TextStyle(
                                color: (isAdmin || canCancel)
                                    ? Colors.white
                                    : Colors.grey[100],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (booking.status == BookingStatus.completed)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => onRate(booking.turfName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAdmin
                                  ? const Color(0xFF1DB954)
                                  : const Color(0xFF00C853),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Rate Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
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

  Widget _buildFeatureInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
