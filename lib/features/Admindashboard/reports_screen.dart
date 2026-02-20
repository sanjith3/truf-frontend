import 'package:flutter/material.dart';
import '../Bookings_analitics/booking_analytics_screen.dart';
import '../Revenue_screen/revenue_report_screen.dart';
import '../../services/analytics_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  final List<String>? registeredTurfNames;
  const ReportsScreen({super.key, this.registeredTurfNames});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  final Color _primaryColor = const Color(0xFF1DB954);
  final Color _secondaryColor = const Color(0xFF4CD964);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3748);
  final Color _hintColor = const Color(0xFFA0AEC0);

  bool _loading = true;
  String _error = '';

  // Dashboard data
  String _todayRevenue = '₹0';
  int _todayBookings = 0;
  String _todayAverage = '₹0';

  String _totalRevenue = '₹0';
  String _avgRevenue = '₹0';
  String _growthText = '0%';
  Color _growthColor = Colors.grey;

  int _totalBookings = 0;
  String _successRate = '0%';
  String _peakHours = 'No data';

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });

      final data = await _analytics.getDashboardSummary();

      if (!mounted) return;

      final today = data['today'] ?? {};
      final revenue = data['revenue_report'] ?? {};
      final booking = data['booking_analytics'] ?? {};

      final todayRev =
          double.tryParse(today['revenue']?.toString() ?? '0') ?? 0;
      final todayAvg =
          double.tryParse(today['average']?.toString() ?? '0') ?? 0;
      final totalRev =
          double.tryParse(revenue['total']?.toString() ?? '0') ?? 0;
      final avgRev =
          double.tryParse(revenue['average']?.toString() ?? '0') ?? 0;
      final growth = (revenue['growth'] as num?)?.toDouble() ?? 0;
      final successRate = (booking['success_rate'] as num?)?.toDouble() ?? 0;

      setState(() {
        _todayRevenue = '₹${_formatNum(todayRev)}';
        _todayBookings = (today['bookings'] as int?) ?? 0;
        _todayAverage = '₹${_formatNum(todayAvg)}';

        _totalRevenue = '₹${_formatNum(totalRev)}';
        _avgRevenue = '₹${_formatNum(avgRev)}';
        _growthText = '${growth >= 0 ? "+" : ""}${growth.toStringAsFixed(1)}%';
        _growthColor = growth >= 0 ? Colors.green[700]! : Colors.red[700]!;

        _totalBookings = (booking['total'] as int?) ?? 0;
        _successRate = '${successRate.toStringAsFixed(1)}%';
        _peakHours = booking['peak_hours']?.toString() ?? 'No data';

        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load analytics';
        });
      }
      debugPrint('Dashboard fetch error: $e');
    }
  }

  String _formatNum(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    } else if (v >= 1000) {
      return NumberFormat('#,##,###').format(v.toInt());
    }
    return v.toStringAsFixed(v == v.toInt() ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: _hintColor),
                  const SizedBox(height: 12),
                  Text(
                    _error,
                    style: TextStyle(color: _hintColor, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.registeredTurfNames != null
                                  ? 'Your Turf Analytics'
                                  : 'Performance Dashboard',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View detailed reports and insights',
                              style: TextStyle(fontSize: 14, color: _hintColor),
                            ),
                          ],
                        ),
                      ),

                      // Today's Overview Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_primaryColor, _secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.timeline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'TODAY\'S OVERVIEW',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem(
                                  title: 'Revenue',
                                  value: _todayRevenue,
                                  icon: Icons.currency_rupee,
                                  color: Colors.white,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildStatItem(
                                  title: 'Bookings',
                                  value: '$_todayBookings',
                                  icon: Icons.calendar_today,
                                  color: Colors.white,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildStatItem(
                                  title: 'Average',
                                  value: _todayAverage,
                                  icon: Icons.trending_up,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reports Section Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _textColor,
                          ),
                        ),
                      ),

                      // Revenue Report Card
                      _buildCleanReportCard(
                        title: 'Revenue Report',
                        description: 'Revenue analysis and trends',
                        icon: Icons.trending_up,
                        iconColor: Colors.green[700]!,
                        stats: [
                          _buildMiniStatItem(
                            label: 'Total',
                            value: _totalRevenue,
                            color: Colors.green[700]!,
                          ),
                          _buildMiniStatItem(
                            label: 'Average',
                            value: _avgRevenue,
                            color: Colors.blue[700]!,
                          ),
                          _buildMiniStatItem(
                            label: 'Growth',
                            value: _growthText,
                            color: _growthColor,
                          ),
                        ],
                        screen: RevenueReportScreen(
                          registeredTurfNames: widget.registeredTurfNames,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Booking Analytics Card
                      _buildCleanReportCard(
                        title: 'Booking Analytics',
                        description: 'Booking patterns and insights',
                        icon: Icons.analytics,
                        iconColor: Colors.blue[700]!,
                        stats: [
                          _buildMiniStatItem(
                            label: 'Total',
                            value: '$_totalBookings',
                            color: Colors.blue[700]!,
                          ),
                          _buildMiniStatItem(
                            label: 'Success',
                            value: _successRate,
                            color: Colors.green[700]!,
                          ),
                          _buildMiniStatItem(
                            label: 'Peak',
                            value: _peakHours,
                            color: Colors.orange[700]!,
                          ),
                        ],
                        screen: BookingAnalyticsScreen(
                          registeredTurfNames: widget.registeredTurfNames,
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.9)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<Widget> stats,
    required Widget screen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 22, color: iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: TextStyle(fontSize: 13, color: _hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: stats,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey[100]),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
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

  Widget _buildMiniStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
