import 'package:flutter/material.dart';
import '../Bookings_analitics/booking_analytics_screen.dart';
import '../Revenue_screen/revenue_report_screen.dart';
import '../Turf_performance/turf_performance_screen.dart';
import '../../services/turf_data_service.dart';
import '../bookings/my_bookings_screen.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  final List<String>? registeredTurfNames;
  const ReportsScreen({super.key, this.registeredTurfNames});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TurfDataService _turfService = TurfDataService();

  @override
  void initState() {
    super.initState();
    _turfService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _turfService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = _turfService.bookings;
    Iterable<Booking> filtered = allBookings;
    
    // If partner-specific, filter by all their registered turfs
    if (widget.registeredTurfNames != null && widget.registeredTurfNames!.isNotEmpty) {
      final normalizedNames = widget.registeredTurfNames!.map((n) => n.toLowerCase()).toList();
      filtered = allBookings.where((b) => normalizedNames.contains(b.turfName.toLowerCase()));
    }
    
    final completed = filtered.where((b) => b.status == BookingStatus.completed);
    final totalRev = completed.fold<double>(0, (sum, b) => sum + b.amount);
    final totalBookings = completed.length;
    final avgRev = totalBookings == 0 ? 0 : (totalRev / totalBookings).round();

    debugPrint("ReportsScreen built with turfs: ${widget.registeredTurfNames}");
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Detailed Reports Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DETAILED REPORTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Revenue Report Card
                  _buildPremiumReportCard(
                    title: 'Revenue Report',
                    description:
                        'Detailed revenue analysis, trends and breakdown',
                    icon: Icons.trending_up_rounded,
                    color: Color(0xFF1976D2), // Professional Blue
                    gradientColors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                    stats: [
                      _buildStatItem('Total Revenue', '₹${NumberFormat('#,##,###').format(totalRev.toInt())}'),
                      _buildStatItem('Growth', widget.registeredTurfNames != null ? "+15.2%" : "+12.5%"),
                      _buildStatItem('Avg/Booking', '₹${NumberFormat('#,##,###').format(avgRev)}'),
                    ],
                    screen: RevenueReportScreen(registeredTurfNames: widget.registeredTurfNames),
                  ),

                  SizedBox(height: 16),

                  // Booking Analytics Card
                  _buildPremiumReportCard(
                    title: 'Booking Analytics',
                    description: 'Booking patterns, customer behavior insights',
                    icon: Icons.calendar_today_rounded,
                    color: Color(0xFFF57C00), // Professional Orange
                    gradientColors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
                    stats: [
                      _buildStatItem('Total Bookings', '$totalBookings'),
                      _buildStatItem('Active Now', widget.registeredTurfNames != null ? "2" : "8"),
                      _buildStatItem('Success Rate', "95%"),
                    ],
                    screen: BookingAnalyticsScreen(registeredTurfNames: widget.registeredTurfNames),
                  ),

                  SizedBox(height: 16),

                  // Turf Performance Card
                  _buildPremiumReportCard(
                    title: 'Turf Performance',
                    description: 'Individual turf metrics and comparisons',
                    icon: Icons.leaderboard_rounded,
                    color: Color(0xFF7B1FA2), // Professional Purple
                    gradientColors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
                    stats: [
                      _buildStatItem('Focus', widget.registeredTurfNames != null ? '${widget.registeredTurfNames!.length} Turfs' : 'All Turfs'),
                      _buildStatItem('Avg Rating', widget.registeredTurfNames != null ? "4.8★" : "4.7★"),
                      _buildStatItem('Occupancy', "82%"),
                    ],
                    screen: TurfPerformanceScreen(registeredTurfNames: widget.registeredTurfNames),
                  ),
                ],
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildPremiumReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required List<Widget> stats,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Icon and Title
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(icon, size: 28, color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Stats Row
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: stats,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tap to view detailed report',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'View Report',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Decorative Element
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Bottom Left Decorative Element
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }
}
