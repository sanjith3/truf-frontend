import 'package:flutter/material.dart';
import '../Bookings_analitics/booking_analytics_screen.dart';
import '../Revenue_screen/revenue_report_screen.dart';
import '../../services/turf_data_service.dart';
import '../bookings/my_bookings_screen.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';

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
    if (widget.registeredTurfNames != null &&
        widget.registeredTurfNames!.isNotEmpty) {
      final normalizedNames = widget.registeredTurfNames!
          .map((n) => n.toLowerCase())
          .toList();
      filtered = allBookings.where(
        (b) => normalizedNames.contains(b.turfName.toLowerCase()),
      );
    }

    final completed = filtered.where(
      (b) => b.status == BookingStatus.completed,
    );
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
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY\'S OVERVIEW',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            title: 'Revenue',
                            value:
                                '₹${NumberFormat('#,##,###').format(totalRev.toInt())}',
                            icon: Icons.currency_rupee,
                            color: Colors.green[700]!,
                          ),
                          _buildStatItem(
                            title: 'Bookings',
                            value: '$totalBookings',
                            icon: Icons.calendar_today,
                            color: Colors.blue[700]!,
                          ),
                          _buildStatItem(
                            title: 'Average',
                            value: '₹$avgRev',
                            icon: Icons.trending_up,
                            color: Colors.orange[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Reports Section
              Text(
                'Detailed Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Access detailed analytics and insights',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              SizedBox(height: 20),

              // Revenue Report Card
              _buildCleanReportCard(
                title: 'Revenue Report',
                description: 'Detailed revenue analysis, trends and breakdown',
                icon: Icons.trending_up,
                stats: [
                  _buildMiniStatItem(
                    label: 'Total Revenue',
                    value:
                        '₹${NumberFormat('#,##,###').format(totalRev.toInt())}',
                  ),
                  _buildMiniStatItem(
                    label: 'Avg per Booking',
                    value: '₹${NumberFormat('#,##,###').format(avgRev)}',
                  ),
                  _buildMiniStatItem(
                    label: 'Growth',
                    value: widget.registeredTurfNames != null
                        ? "+15.2%"
                        : "+12.5%",
                  ),
                ],
                screen: RevenueReportScreen(
                  registeredTurfNames: widget.registeredTurfNames,
                ),
              ),

              SizedBox(height: 16),

              // Booking Analytics Card
              _buildCleanReportCard(
                title: 'Booking Analytics',
                description: 'Booking patterns, customer behavior insights',
                icon: Icons.analytics,
                stats: [
                  _buildMiniStatItem(
                    label: 'Total Bookings',
                    value: '$totalBookings',
                  ),
                  _buildMiniStatItem(label: 'Success Rate', value: '95%'),
                  _buildMiniStatItem(label: 'Peak Hours', value: '6-9 PM'),
                ],
                screen: BookingAnalyticsScreen(
                  registeredTurfNames: widget.registeredTurfNames,
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCleanReportCard({
    required String title,
    required String description,
    required IconData icon,
    required List<Widget> stats,
    required Widget screen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 24, color: Colors.black87),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: stats,
                  ),
                ),
              ],
            ),
          ),

          // Footer with View Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  child: Text(
                    'View detailed analysis and insights',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screen),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'View Report',
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
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
