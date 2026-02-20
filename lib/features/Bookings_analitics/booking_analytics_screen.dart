import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/analytics_service.dart';

class BookingAnalyticsScreen extends StatefulWidget {
  final List<String>? registeredTurfNames;
  const BookingAnalyticsScreen({super.key, this.registeredTurfNames});

  @override
  State<BookingAnalyticsScreen> createState() => _BookingAnalyticsScreenState();
}

class _BookingAnalyticsScreenState extends State<BookingAnalyticsScreen> {
  final AnalyticsService _analytics = AnalyticsService();

  // Turf dropdown
  List<Map<String, dynamic>> _turfs = [];
  int? _selectedTurfId;

  // Period dropdown
  String _selectedPeriod = 'month';
  final Map<String, String> _periodLabels = {
    'today': 'Today',
    'week': 'This Week',
    'month': 'This Month',
    'quarter': 'This Quarter',
    'year': 'This Year',
  };

  // Data
  bool _loading = true;
  String _error = '';

  int _totalBookings = 0;
  String _cancellationRate = '0%';
  String _peakHours = 'No data';
  String _avgDuration = '0 hrs';

  List<Map<String, dynamic>> _dailyBreakdown = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });

      final data = await _analytics.getBookingAnalytics(
        turfId: _selectedTurfId,
        period: _selectedPeriod,
      );

      if (!mounted) return;

      final turfs =
          (data['turfs'] as List?)
              ?.map((t) => t as Map<String, dynamic>)
              .toList() ??
          [];

      final cancRate = (data['cancellation_rate'] as num?)?.toDouble() ?? 0;
      final avgDur = (data['avg_duration'] as num?)?.toDouble() ?? 0;

      final breakdown =
          (data['daily_breakdown'] as List?)
              ?.map((d) => d as Map<String, dynamic>)
              .toList() ??
          [];

      setState(() {
        _turfs = turfs;
        _totalBookings = (data['total_bookings'] as int?) ?? 0;
        _cancellationRate = '${cancRate.toStringAsFixed(1)}%';
        _peakHours = data['peak_hours']?.toString() ?? 'No data';
        _avgDuration = '${avgDur.toStringAsFixed(1)} hrs';
        _dailyBreakdown = breakdown;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load booking analytics';
        });
      }
      debugPrint('Booking analytics fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Booking Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    _error,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filters + Stats Card
                    _buildFiltersCard(),
                    const SizedBox(height: 24),
                    // Daily Booking Trends chart
                    _buildDailyTrendsChart(),
                    const SizedBox(height: 24),
                    // Daily Bookings Breakdown
                    _buildDailyBreakdownTable(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Turf selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Turf',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButton<int?>(
                          value: _selectedTurfId,
                          underline: const SizedBox(),
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Turfs'),
                            ),
                            ..._turfs.map(
                              (t) => DropdownMenuItem<int?>(
                                value: t['id'] as int,
                                child: Text(
                                  t['name']?.toString() ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedTurfId = value);
                            _fetchData();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Period selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Period',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          underline: const SizedBox(),
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                          items: _periodLabels.entries.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(e.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPeriod = value);
                              _fetchData();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats row 1
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Bookings',
                    '$_totalBookings',
                    '',
                    Icons.event_available,
                    const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cancellation Rate',
                    _cancellationRate,
                    '',
                    Icons.cancel,
                    const Color(0xFFF44336),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats row 2
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Peak Hours',
                    _peakHours,
                    'Most active period',
                    Icons.access_time,
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Duration',
                    _avgDuration,
                    '',
                    Icons.timer,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTrendsChart() {
    final maxBookings = _dailyBreakdown.isEmpty
        ? 1
        : _dailyBreakdown
              .map((e) => (e['bookings'] as int?) ?? 0)
              .fold<int>(0, (a, b) => a > b ? a : b);
    final maxVal = maxBookings == 0 ? 1 : maxBookings;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Booking Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _dailyBreakdown.isEmpty
                  ? Center(
                      child: Text(
                        'No data for this period',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _dailyBreakdown.map((day) {
                        final bookings = (day['bookings'] as int?) ?? 0;
                        double heightPct = bookings / maxVal;
                        final dayLabel =
                            (day['day']?.toString() ?? '').length >= 3
                            ? day['day'].toString().substring(0, 3)
                            : day['day'].toString();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 25,
                              height: (150 * heightPct).clamp(0.0, 150.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$bookings',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdownTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Bookings Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (_dailyBreakdown.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No data for this period',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._dailyBreakdown.map((dayData) {
                final cancellations = (dayData['cancellations'] as int?) ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      // Day
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayData['day']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Day',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Total Bookings
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${dayData['bookings']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Bookings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cancellations
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cancellations > 3
                                    ? Colors.red[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$cancellations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: cancellations > 3
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cancellations',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
