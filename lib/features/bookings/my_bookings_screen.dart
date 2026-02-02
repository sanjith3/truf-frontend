import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Booking> _allBookings = [];

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

    // Initialize with sample bookings
    final now = DateTime.now();
    _allBookings.addAll([
      // Upcoming/Pending - Today's booking
      Booking(
        id: '1',
        turfName: 'Green Field Arena',
        location: 'PN Pudur',
        distance: 2.5,
        rating: 4.8,
        date: DateTime(now.year, now.month, now.day),
        startTime: '18:00',
        endTime: '19:00',
        amount: 500,
        status: BookingStatus.upcoming,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-001',
        amenities: ["Lights", "Parking", "Water"],
        mapLink: "https://maps.app.goo.gl/xyz123",
        address: "123 Sports Complex, PN Pudur, Coimbatore",
      ),
      // Upcoming - Tomorrow
      Booking(
        id: '2',
        turfName: 'Elite Football Ground',
        location: 'Race Course',
        distance: 3.1,
        rating: 4.9,
        date: DateTime(now.year, now.month, now.day + 1),
        startTime: '17:00',
        endTime: '18:00',
        amount: 800,
        status: BookingStatus.upcoming,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-002',
        amenities: ["Flood Lights", "Gym", "Parking", "WiFi", "Showers"],
        mapLink: "https://maps.app.goo.gl/def789",
        address: "Race Course Road, Coimbatore",
      ),
      // Completed - Yesterday (automatically moved from upcoming)
      Booking(
        id: '3',
        turfName: 'City Sports Turf',
        location: 'Gandhipuram',
        distance: 4.2,
        rating: 4.5,
        date: DateTime(now.year, now.month, now.day - 1),
        startTime: '18:00',
        endTime: '19:00',
        amount: 650,
        status: BookingStatus.completed,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-003',
        amenities: ["Cafeteria", "Parking"],
        mapLink: "https://maps.app.goo.gl/abc456",
        address: "45 Main Road, Gandhipuram, Coimbatore",
      ),
      // Completed - 2 days ago
      Booking(
        id: '4',
        turfName: 'Victory Sports Park',
        location: 'Peelamedu',
        distance: 5.7,
        rating: 4.3,
        date: DateTime(now.year, now.month, now.day - 2),
        startTime: '19:00',
        endTime: '20:00',
        amount: 450,
        status: BookingStatus.completed,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-004',
        amenities: ["Flood Lights", "Parking", "Water"],
        mapLink: "https://maps.app.goo.gl/ghi012",
        address: "Peelamedu Industrial Estate, Coimbatore",
      ),
      // Cancelled
      Booking(
        id: '5',
        turfName: 'Premium Sports Arena',
        location: 'Singanallur',
        distance: 6.2,
        rating: 4.7,
        date: DateTime(now.year, now.month, now.day + 2),
        startTime: '20:00',
        endTime: '21:00',
        amount: 1200,
        status: BookingStatus.cancelled,
        paymentStatus: 'Refunded',
        bookingId: 'TURF-2024-005',
        amenities: ["Flood Lights", "Parking", "Water", "Showers", "Cafeteria"],
        mapLink: "https://maps.app.goo.gl/jkl345",
        address: "Singanallur Industrial Area, Coimbatore",
      ),
    ]);

    // Start checking for completed bookings
    _startStatusCheckTimer();
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
      if (booking.status == BookingStatus.upcoming) {
        // Check if booking time has passed
        final bookingDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          int.parse(booking.startTime.split(':')[0]),
          int.parse(booking.startTime.split(':')[1]),
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
        .where((b) => b.status == BookingStatus.upcoming)
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

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                booking.status = BookingStatus.cancelled;
                booking.paymentStatus = 'Refund Initiated';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Booking cancelled successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Upcoming"),
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
            const Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Book your first turf to get started",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingTurfCard(
          booking: bookings[index],
          imageUrl:
              _turfImages[bookings[index].turfName] ??
              "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800",
          showCancelButton: showCancelButton,
          onCancel: () => _cancelBooking(bookings[index]),
          onOpenMap: (mapLink) => _openMapLocation(mapLink),
        );
      },
    );
  }
}

class BookingTurfCard extends StatelessWidget {
  final Booking booking;
  final String imageUrl;
  final bool showCancelButton;
  final VoidCallback onCancel;
  final Function(String) onOpenMap;

  const BookingTurfCard({
    super.key,
    required this.booking,
    required this.imageUrl,
    required this.showCancelButton,
    required this.onCancel,
    required this.onOpenMap,
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
      case BookingStatus.upcoming:
        statusColor = Colors.orange;
        statusText = "Upcoming";
        statusIcon = Icons.access_time;
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = "Completed";
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Cancelled";
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Status Badge (Top Left)
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Booking ID Badge
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.bookingId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Distance Badge with Map Navigation
              Positioned(
                bottom: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () => onOpenMap(booking.mapLink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF1DB954),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${booking.distance} km",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Booking Details
          Padding(
            padding: const EdgeInsets.all(20),
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
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  booking.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${booking.amount}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                        const Text(
                          "/hour",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Booking Date & Time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${booking.startTime} - ${booking.endTime}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: booking.paymentStatus == 'Paid'
                              ? Colors.green.shade50
                              : booking.paymentStatus.contains('Refund')
                              ? Colors.orange.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: booking.paymentStatus == 'Paid'
                                ? Colors.green.shade100
                                : booking.paymentStatus.contains('Refund')
                                ? Colors.orange.shade100
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          booking.paymentStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: booking.paymentStatus == 'Paid'
                                ? Colors.green.shade800
                                : booking.paymentStatus.contains('Refund')
                                ? Colors.orange.shade800
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                if (showCancelButton &&
                    booking.status == BookingStatus.upcoming)
                  Row(
                    children: [
                      // Cancel Booking Button - Compact and clean
                      Expanded(
                        child: SizedBox(
                          height: 48, // Medium height
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.red.shade300),
                              backgroundColor: Colors.red.shade50,
                            ),
                            child: Text(
                              "Cancel Booking",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // View Details Button - Compact and clean
                      Expanded(
                        child: SizedBox(
                          height: 48, // Medium height
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to booking details or turf details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Viewing booking details",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (booking.status == BookingStatus.completed)
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Rate this turf
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Rating feature coming soon"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Rate This Turf",
                            style: TextStyle(
                              fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}

class Booking {
  final String id;
  final String turfName;
  final String location;
  final double distance;
  final double rating;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double amount;
  BookingStatus status;
  String paymentStatus;
  final String bookingId;
  final List<String> amenities;
  final String mapLink;
  final String address;

  Booking({
    required this.id,
    required this.turfName,
    required this.location,
    required this.distance,
    required this.rating,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.bookingId,
    required this.amenities,
    required this.mapLink,
    required this.address,
  });
}

enum BookingStatus { upcoming, completed, cancelled }

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
