// my_bookings_screen.dart (in features/bookings/)
import 'package:flutter/material.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedFilter = 0;
  List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK001',
      'user': 'Rajesh Kumar',
      'phone': '9876543210',
      'date': 'Today, 4:00 PM',
      'duration': '2 hours',
      'amount': '₹1,598',
      'status': 'Confirmed',
      'color': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'id': 'BK002',
      'user': 'Priya Sharma',
      'phone': '9876543211',
      'date': 'Today, 6:00 PM',
      'duration': '1.5 hours',
      'amount': '₹1,198',
      'status': 'Pending',
      'color': Colors.orange,
      'icon': Icons.pending,
    },
    {
      'id': 'BK003',
      'user': 'Vikram Singh',
      'phone': '9876543212',
      'date': 'Tomorrow, 8:00 AM',
      'duration': '3 hours',
      'amount': '₹2,397',
      'status': 'Completed',
      'color': Colors.blue,
      'icon': Icons.done_all,
    },
    {
      'id': 'BK004',
      'user': 'Anita Rao',
      'phone': '9876543213',
      'date': 'Mar 15, 2:00 PM',
      'duration': '2 hours',
      'amount': '₹1,598',
      'status': 'Cancelled',
      'color': Colors.red,
      'icon': Icons.cancel,
    },
  ];

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
          // Filter Tabs
          Container(
            height: 60,
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterTab('All', 0),
                _buildFilterTab('Today', 1),
                _buildFilterTab('Upcoming', 2),
                _buildFilterTab('Past', 3),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('24', 'Total'),
                        _buildStatItem('12', 'Confirmed'),
                        _buildStatItem('3', 'Pending'),
                        _buildStatItem('2', 'Cancelled'),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Bookings List
                  ...bookings.map((booking) => _buildBookingCard(booking)).toList(),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedFilter == index ? Color(0xFF00C853) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: _selectedFilter == index ? FontWeight.w600 : FontWeight.w500,
                color: _selectedFilter == index ? Color(0xFF00C853) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF00C853),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: booking['color'].withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(booking['icon'], size: 14, color: booking['color']),
                      SizedBox(width: 6),
                      Text(
                        booking['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: booking['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 0),
          
          // User Info
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
                        booking['user'],
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
          
          // Footer Actions
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.phone, size: 16),
                    label: Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.chat, size: 16),
                    label: Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (booking['status'] == 'Pending') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirm Booking'),
                            content: Text('Confirm booking ${booking['id']} for ${booking['user']}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    booking['status'] = 'Confirmed';
                                    booking['color'] = Colors.green;
                                    booking['icon'] = Icons.check_circle;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Booking confirmed'),
                                      backgroundColor: Color(0xFF00C853),
                                    ),
                                  );
                                },
                                child: Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.check, size: 16),
                    label: Text(booking['status'] == 'Pending' ? 'Confirm' : 'View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
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