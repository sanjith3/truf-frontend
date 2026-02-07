import 'package:flutter/material.dart';

class TurfPerformanceScreen extends StatefulWidget {
  const TurfPerformanceScreen({super.key});

  @override
  State<TurfPerformanceScreen> createState() => _TurfPerformanceScreenState();
}

class _TurfPerformanceScreenState extends State<TurfPerformanceScreen> {
  String selectedPeriod = 'This Month';
  List<String> periods = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Quarter',
    'This Year',
  ];

  final List<Map<String, dynamic>> _allTurfs = [
    {
      'name': 'Green Field Arena',
      'revenue': 95880,
      'bookings': 142,
      'rating': 4.8,
      'utilization': 78,
      'growth': '+15.2%',
      'color': Color(0xFF00C853),
    },
    {
      'name': 'City Sports Turf',
      'revenue': 75000,
      'bookings': 115,
      'rating': 4.5,
      'utilization': 65,
      'growth': '+8.7%',
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Elite Football Ground',
      'revenue': 120000,
      'bookings': 165,
      'rating': 4.9,
      'utilization': 85,
      'growth': '+22.3%',
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Sports Hub Arena',
      'revenue': 70000,
      'bookings': 98,
      'rating': 4.6,
      'utilization': 62,
      'growth': '+5.4%',
      'color': Color(0xFF9C27B0),
    },
  ];

  List<Map<String, dynamic>> get turfs {
    double multiplier = 1.0;
    if (selectedPeriod == 'Today') multiplier = 0.05;
    else if (selectedPeriod == 'This Week') multiplier = 0.25;
    else if (selectedPeriod == 'This Month') multiplier = 1.0;
    else if (selectedPeriod == 'Last Month') multiplier = 0.9;
    else if (selectedPeriod == 'This Quarter') multiplier = 3.0;
    else if (selectedPeriod == 'This Year') multiplier = 12.0;

    return _allTurfs.map((t) => {
      'name': t['name'],
      'revenue': ((t['revenue'] as int) * multiplier).round(),
      'bookings': ((t['bookings'] as int) * multiplier).round(),
      'rating': t['rating'],
      'utilization': t['utilization'],
      'growth': t['growth'],
      'color': t['color'],
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Sort turfs by revenue (descending)
    turfs.sort((a, b) => b['revenue'].compareTo(a['revenue']));

    double totalRevenue = turfs.fold<double>(
      0,
      (sum, turf) => sum + (turf['revenue'] as num).toDouble(),
    );

    int totalBookings = turfs.fold<int>(
      0,
      (sum, turf) => sum + (turf['bookings'] as int),
    );

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Turf Performance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.leaderboard,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Performance Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Real-time metrics for all turfs',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOverviewStat(
                          'Revenue',
                          '₹${(totalRevenue / 1000).toStringAsFixed(0)}K',
                          '+12.5%',
                          Icons.currency_rupee,
                          Colors.white,
                        ),
                        _buildOverviewStat(
                          'Bookings',
                          totalBookings.toString(),
                          '+8.2%',
                          Icons.event_available,
                          Colors.white,
                        ),
                        _buildOverviewStat(
                          'Rating',
                          '4.7★',
                          '+0.3',
                          Icons.star,
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24), // Increased spacing
              // Performance Ranking Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TURF RANKING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 20), // Increased spacing
                    ...turfs.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> turf = entry.value;
                      double revenuePercentage =
                          (turf['revenue'] / totalRevenue * 100);

                      return Container(
                        margin: EdgeInsets.only(bottom: 20), // Increased margin
                        padding: EdgeInsets.all(20), // Increased padding
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            // Top Row: Rank and Basic Info
                            Row(
                              children: [
                                Container(
                                  width: 40, // Slightly larger
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: turf['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ), // Rounded more
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 18, // Larger font
                                        fontWeight: FontWeight.w800,
                                        color: turf['color'],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16), // Increased spacing
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        turf['name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8), // Increased spacing
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16, // Slightly larger
                                            color: Colors.amber,
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ), // Increased spacing
                                          Text(
                                            '${turf['rating']}',
                                            style: TextStyle(
                                              fontSize: 14, // Larger font
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ), // Increased spacing
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    6,
                                                  ), // Rounded more
                                            ),
                                            child: Text(
                                              turf['growth'],
                                              style: TextStyle(
                                                fontSize: 12, // Larger font
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
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
                                      '₹${(turf['revenue'] / 1000).toStringAsFixed(0)}K',
                                      style: TextStyle(
                                        fontSize: 20, // Larger font
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 6), // Increased spacing
                                    Text(
                                      '${turf['bookings']} bookings',
                                      style: TextStyle(
                                        fontSize: 12, // Larger font
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 20), // Increased spacing
                            // Utilization Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Utilization',
                                      style: TextStyle(
                                        fontSize: 14, // Larger font
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '${turf['utilization']}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800, // Bolder
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10), // Increased spacing
                                Container(
                                  height: 8, // Thicker bar
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: turf['utilization'] / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: turf['utilization'] > 70
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20), // Increased spacing
                            // Key Metrics Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMiniStat(
                                  'Revenue Share',
                                  '${revenuePercentage.toStringAsFixed(1)}%',
                                  Icons.pie_chart,
                                  turf['color'],
                                ),
                                _buildMiniStat(
                                  'Per Booking',
                                  '₹${(turf['revenue'] / turf['bookings']).toStringAsFixed(0)}',
                                  Icons.currency_rupee,
                                  Color(0xFF00C853),
                                ),
                                _buildMiniStat(
                                  'Daily Avg',
                                  '${(turf['bookings'] / 30).toStringAsFixed(1)}',
                                  Icons.calendar_today,
                                  Color(0xFF2196F3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 32), // Increased spacing
              // Download Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 18,
                    ), // Increased padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.download_outlined, size: 22), // Larger icon
                  label: Text(
                    'Download Performance Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: 40), // Increased bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStat(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10), // Increased padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12), // Rounded more
          ),
          child: Icon(icon, size: 22, color: color), // Larger icon
        ),
        SizedBox(height: 12), // Increased spacing
        Text(
          value,
          style: TextStyle(
            fontSize: 20, // Larger font
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 6), // Increased spacing
        Text(
          title,
          style: TextStyle(
            fontSize: 13, // Larger font
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12), // Added padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color), // Larger icon
          SizedBox(height: 8), // Increased spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 16, // Larger font
              fontWeight: FontWeight.w800, // Bolder
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6), // Increased spacing
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _downloadReport() {
    // Simulate a successful download
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Performance Report Downloaded Successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            ),
            SizedBox(width: 12),
            Text('Generating Performance Report...'),
          ],
        ),
        backgroundColor: Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}
