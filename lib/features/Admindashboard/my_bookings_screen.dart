// my_bookings_screen.dart — LIVE API VERSION
// Fetches owner bookings from backend. Phone numbers are already masked by API.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final ApiService _api = ApiService();
  int _selectedFilter = 0;
  List<String> filters = ['Today', 'Upcoming', 'Past', 'All'];

  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOwnerBookings();
  }

  // ─── FETCH OWNER BOOKINGS FROM API ───
  Future<void> _loadOwnerBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _api.getAuth(
        '/api/bookings/bookings/owner_bookings/',
      );

      if (response is Map && response['success'] == true) {
        final results = response['results'] as List? ?? [];
        setState(() {
          _allBookings = List<Map<String, dynamic>>.from(
            results.map((e) => Map<String, dynamic>.from(e)),
          );
          _isLoading = false;
        });
        print('📋 Loaded ${_allBookings.length} owner bookings');
      } else {
        setState(() {
          _allBookings = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🚨 Error loading owner bookings: $e');
      setState(() {
        _error = 'Failed to load bookings';
        _isLoading = false;
      });
    }
  }

  // ─── INITIATE CALL VIA API ───
  Future<void> _initiateCall(int bookingId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _api.postAuth(
        '/api/bookings/bookings/$bookingId/initiate_call/',
      );

      Navigator.of(context).pop(); // dismiss loading

      if (response is Map && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Call initiated'),
              backgroundColor: const Color(0xFF00C853),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['error'] ?? 'Failed to initiate call'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // dismiss loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─── FILTER BOOKINGS ───
  List<Map<String, dynamic>> get filteredBookings {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    switch (_selectedFilter) {
      case 0: // Today
        return _allBookings.where((b) => b['booking_date'] == today).toList();
      case 1: // Upcoming
        return _allBookings
            .where(
              (b) =>
                  b['booking_date'] != null &&
                  b['booking_date'].compareTo(today) > 0,
            )
            .toList();
      case 2: // Past
        return _allBookings
            .where(
              (b) =>
                  b['booking_date'] != null &&
                      b['booking_date'].compareTo(today) < 0 ||
                  b['booking_status'] == 'cancelled',
            )
            .toList();
      default: // All
        return _allBookings;
    }
  }

  double get todayRevenue {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _allBookings
        .where(
          (b) =>
              b['booking_date'] == today &&
              b['payment_status'] == 'paid' &&
              b['booking_status'] != 'cancelled',
        )
        .fold(0.0, (sum, b) {
          final price = b['final_price'] ?? b['total_price'] ?? 0;
          return sum + (double.tryParse('$price') ?? 0);
        });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${h12}:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final bookingDay = DateTime(date.year, date.month, date.day);

      if (bookingDay == today) return 'Today';
      if (bookingDay == tomorrow) return 'Tomorrow';
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Bookings Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOwnerBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Revenue Summary
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Revenue",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${todayRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Bookings',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filteredBookings.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(filters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(filters[index]),
                      selected: _selectedFilter == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = index;
                        });
                      },
                      selectedColor: const Color(0xFF00C853),
                      labelStyle: TextStyle(
                        color: _selectedFilter == index
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Booking List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOwnerBookings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bookings will appear here when customers book your turfs',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOwnerBookings,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(filteredBookings[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final bookingStatus = booking['booking_status'] ?? 'pending';
    Color statusColor =
        bookingStatus == 'confirmed' || bookingStatus == 'completed'
        ? Colors.green
        : bookingStatus == 'pending'
        ? Colors.orange
        : Colors.red;
    String statusText = bookingStatus.toString().toUpperCase();

    final customerName = booking['customer_name'] ?? 'Customer';
    final customerPhone = booking['customer_phone'] ?? '+91 XXXX XXXX';
    final amount = booking['final_price'] ?? booking['total_price'] ?? '0';
    final dateStr = _formatDate(booking['booking_date']);
    final startTime = _formatTime(booking['start_time']);
    final endTime = _formatTime(booking['end_time']);
    final turfName = booking['turf_name'] ?? '';
    final bookingId = booking['id'];
    final paymentStatus = booking['payment_status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#$bookingId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (turfName.isNotEmpty)
                      Text(
                        turfName,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: paymentStatus == 'paid'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        paymentStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: paymentStatus == 'paid'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 0),

          // Customer Info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF00C853)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            customerPhone,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$dateStr, $startTime - $endTime',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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
                      '₹$amount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions — Call button (uses API, not direct dialer)
          if (bookingStatus == 'confirmed' || bookingStatus == 'completed')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _initiateCall(bookingId),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Customer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
