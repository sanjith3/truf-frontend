// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:turfzone/features/home/user_home_screen.dart';
import 'package:turfzone/features/editslottime/operations_center_screen.dart';
import 'package:turfzone/features/editslottime/edit_turf_screen.dart';
import 'package:turfzone/features/bookings/my_bookings_screen.dart';
import 'package:turfzone/features/turfslot/turf_slots_screen.dart';
// New screen for slot view

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> turfs = [
    {
      'id': 'T001',
      'name': 'final',
      'city': 'Coimbatore',
      'price': '₹799.00/hr',
      'rating': '4.5',
      'totalBookings': 24,
      'monthlyBookings': 12,
      'revenue': '₹9,588',
      'image':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?q=80&w=2070',
    },
  ];

  List<Map<String, dynamic>> stats = [
    {
      'title': 'Total Turfs',
      'value': '1',
      'icon': Icons.grass,
      'color': Color(0xFF00C853),
      'subtitle': 'Active listings',
    },
    {
      'title': 'Total Bookings',
      'value': '24',
      'icon': Icons.calendar_month,
      'color': Color(0xFF2196F3),
      'subtitle': 'All time',
    },
    {
      'title': 'Revenue',
      'value': '₹9,588',
      'icon': Icons.currency_rupee,
      'color': Color(0xFF4CAF50),
      'subtitle': 'This month',
    },
    {
      'title': 'Avg Rating',
      'value': '4.5★',
      'icon': Icons.star,
      'color': Color(0xFFFF9800),
      'subtitle': 'From 8 reviews',
    },
  ];

  List<Map<String, dynamic>> todaySlots = [
    {'time': '6:00 AM', 'status': 'Available', 'user': null},
    {'time': '7:00 AM', 'status': 'Booked', 'user': 'Rajesh Kumar'},
    {'time': '8:00 AM', 'status': 'Booked', 'user': 'Vikram Singh'},
    {'time': '9:00 AM', 'status': 'Available', 'user': null},
    {'time': '10:00 AM', 'status': 'Booked', 'user': 'Priya Sharma'},
    {'time': '11:00 AM', 'status': 'Available', 'user': null},
    {'time': '12:00 PM', 'status': 'Booked', 'user': 'Anita Rao'},
    {'time': '1:00 PM', 'status': 'Available', 'user': null},
    {'time': '2:00 PM', 'status': 'Booked', 'user': 'Rahul Mehta'},
    {'time': '3:00 PM', 'status': 'Booked', 'user': 'Suresh Kumar'},
    {'time': '4:00 PM', 'status': 'Booked', 'user': 'Neha Gupta'},
    {'time': '5:00 PM', 'status': 'Available', 'user': null},
    {'time': '6:00 PM', 'status': 'Booked', 'user': 'Amit Sharma'},
    {'time': '7:00 PM', 'status': 'Available', 'user': null},
    {'time': '8:00 PM', 'status': 'Booked', 'user': 'Deepak Verma'},
  ];

  int get availableSlotsCount {
    return todaySlots.where((slot) => slot['status'] == 'Available').length;
  }

  int get bookedSlotsCount {
    return todaySlots.where((slot) => slot['status'] == 'Booked').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partner Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Welcome back, 8856142056',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => UserHomeScreen()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.switch_account, size: 18),
              label: Text('User Mode', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            height: 56,
            color: Colors.white,
            child: Row(
              children: [
                _buildTabItem('Dashboard', Icons.dashboard, 0),
                _buildTabItem('Bookings', Icons.calendar_month, 1),
                _buildTabItem('Slots', Icons.schedule, 2),
              ],
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                // Dashboard Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: stats.length,
                        itemBuilder: (context, index) =>
                            _buildStatCard(stats[index]),
                      ),

                      SizedBox(height: 24),

                      // My Turf Listing
                      _buildSectionTitle('My Turf Listing', Icons.grass),
                      SizedBox(height: 12),
                      _buildTurfCard(),
                    ],
                  ),
                ),

                // Bookings Tab
                MyBookingsScreen(),

                // Slots Tab (Manage Slots)
                OperationsCenterScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index
                    ? Color(0xFF00C853)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: _selectedTab == index
                    ? Color(0xFF00C853)
                    : Colors.grey[500],
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _selectedTab == index
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: _selectedTab == index
                      ? Color(0xFF00C853)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat['icon'], size: 20, color: stat['color']),
                ),
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              stat['title'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              stat['subtitle']?.toString() ?? "",
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFF00C853)),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTurfCard() {
    return Container(
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
          // Turf Image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(turfs[0]['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    turfs[0]['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white70),
                      SizedBox(width: 4),
                      Text(
                        turfs[0]['city'],
                        style: TextStyle(color: Colors.white70),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              turfs[0]['rating'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          turfs[0]['price'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Bookings',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${turfs[0]['monthlyBookings']} bookings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          turfs[0]['revenue'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Today's Slot Stats
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$availableSlotsCount',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00C853),
                              ),
                            ),
                            Text(
                              'slots',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.blue[200]),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Booked',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$bookedSlotsCount',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              'slots',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildTurfActionButton(
                        'Edit',
                        Icons.edit,
                        Color(0xFF2196F3),
                        EditTurfScreen(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildTurfActionButton(
                        'View Slots',
                        Icons.remove_red_eye,
                        Color(0xFF00C853),
                        TurfSlotsScreen(slotsData: todaySlots),
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

  Widget _buildTurfActionButton(
    String text,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      icon: Icon(icon, size: 16),
      label: Text(text, style: TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.2)),
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
    );
  }
}
