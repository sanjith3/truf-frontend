  // my_bookings_screen.dart - UPDATED
  import 'package:flutter/material.dart';
  import 'package:url_launcher/url_launcher.dart';

  class MyBookingsScreen extends StatefulWidget {
    const MyBookingsScreen({super.key});

    @override
    State<MyBookingsScreen> createState() => _MyBookingsScreenState();
  }

  class _MyBookingsScreenState extends State<MyBookingsScreen> {
    int _selectedFilter = 0;
    List<String> filters = ['Today', 'Upcoming', 'Past', 'All'];

    Future<void> _launchCaller(String phoneNumber) async {
      final Uri url = Uri.parse('tel:$phoneNumber');
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch dialer for $phoneNumber")),
          );
        }
      }
    }

    List<Map<String, dynamic>> allBookings = [
      {
        'id': 'BK001',
        'customer': 'Rajesh Kumar',
        'phone': '+91 8825934519',
        'date': 'Today, 7:00 AM',
        'duration': '1 hour',
        'amount': '₹500',
        'status': 'confirmed',
        'payment': 'Paid',
        'turf': 'final',
      },
      {
        'id': 'BK002',
        'customer': 'Team Alpha',
        'phone': '+91 8825934519',
        'date': 'Today, 8:00 AM',
        'duration': '1 hour',
        'amount': '₹500',
        'status': 'confirmed',
        'payment': 'Paid',
        'turf': 'final',
      },
      {
        'id': 'BK003',
        'customer': 'Priya Sharma',
        'phone': '+91 8825934519',
        'date': 'Today, 10:00 AM',
        'duration': '1 hour',
        'amount': '₹600',
        'status': 'pending',
        'payment': 'Pending',
        'turf': 'final',
      },
      {
        'id': 'BK004',
        'customer': 'Vikram Singh',
        'phone': '+91 8825934519',
        'date': 'Today, 12:00 PM',
        'duration': '2 hours',
        'amount': '₹1,400',
        'status': 'confirmed',
        'payment': 'Paid',
        'turf': 'final',
      },
      {
        'id': 'BK005',
        'customer': 'Anita Rao',
        'phone': '+91 8825934519',
        'date': 'Tomorrow, 2:00 PM',
        'duration': '1 hour',
        'amount': '₹700',
        'status': 'confirmed',
        'payment': 'Paid',
        'turf': 'final',
      },
      {
        'id': 'BK006',
        'customer': 'Rahul Mehta',
        'phone': '+91 8825934519',
        'date': 'Tomorrow, 3:00 PM',
        'duration': '2 hours',
        'amount': '₹1,600',
        'status': 'cancelled',
        'payment': 'Refunded',
        'turf': 'final',
      },
      {
        'id': 'BK007',
        'customer': 'Suresh Kumar',
        'phone': '+91 8825934519',
        'date': 'Tomorrow, 4:00 PM',
        'duration': '1 hour',
        'amount': '₹800',
        'status': 'confirmed',
        'payment': 'Paid',
        'turf': 'final',
      },
      {
        'id': 'BK008',
        'customer': 'Neha Gupta',
        'phone': '+91 8825934519',
        'date': 'Tomorrow, 6:00 PM',
        'duration': '1 hour',
        'amount': '₹900',
        'status': 'confirmed',
        'payment': 'Paid',
        'turf': 'final',
      },
    ];

    List<Map<String, dynamic>> get filteredBookings {
      switch (_selectedFilter) {
        case 0: // Today
          return allBookings.where((b) => b['date'].contains('Today')).toList();
        case 1: // Upcoming
          return allBookings
              .where((b) => b['date'].contains('Tomorrow'))
              .toList();
        case 2: // Past
          return allBookings.where((b) => b['status'] == 'cancelled').toList();
        default:
          return allBookings;
      }
    }

    double get todayRevenue {
      return filteredBookings
          .where((b) => b['payment'] == 'Paid')
          .map(
            (b) =>
                double.parse(b['amount'].replaceAll('₹', '').replaceAll(',', '')),
          )
          .fold(0, (sum, amount) => sum + amount);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'Bookings Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF00C853),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Revenue Summary
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Revenue',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹${todayRevenue.toStringAsFixed(0)}',
                        style: TextStyle(
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
                      SizedBox(height: 4),
                      Text(
                        '${filteredBookings.length}',
                        style: TextStyle(
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
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(filters.length, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: ChoiceChip(
                        label: Text(filters[index]),
                        selected: _selectedFilter == index,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = index;
                          });
                        },
                        selectedColor: Color(0xFF00C853),
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
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(filteredBookings[index], index);
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
      Color statusColor = booking['status'] == 'confirmed'
          ? Colors.green
          : booking['status'] == 'pending'
          ? Colors.orange
          : Colors.red;
      String statusText = booking['status'].toUpperCase();

      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking['id'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ),

            Divider(height: 0),

            // Customer Info
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF00C853).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.person, color: Color(0xFF00C853)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['customer'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                            SizedBox(width: 4),
                            Text(
                              booking['phone'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
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
                        booking['amount'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        booking['date'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchCaller(booking['phone']),
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

    void _confirmBooking(Map<String, dynamic> booking, int index) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Booking'),
          content: Text(
            'Confirm booking ${booking['id']} for ${booking['customer']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  booking['status'] = 'confirmed';
                  booking['payment'] = 'Paid';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking confirmed'),
                    backgroundColor: Color(0xFF00C853),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00C853)),
              child: Text('Yes, Confirm'),
            ),
          ],
        ),
      );
    }

    void _cancelBooking(Map<String, dynamic> booking, int index) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cancel Booking'),
          content: Text(
            'Cancel booking ${booking['id']} for ${booking['customer']}?\n\nRefund will be processed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  booking['status'] = 'cancelled';
                  booking['payment'] = 'Refunded';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking cancelled and refunded'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Yes, Cancel'),
            ),
          ],
        ),
      );
    }
  }
