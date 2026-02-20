import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/analytics_service.dart';

class RevenueReportScreen extends StatefulWidget {
  final List<String>? registeredTurfNames;
  const RevenueReportScreen({super.key, this.registeredTurfNames});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  final AnalyticsService _analytics = AnalyticsService();

  // Turf dropdown
  List<Map<String, dynamic>> _turfs = [];
  int? _selectedTurfId;
  String _selectedTurfName = 'All Turfs';

  // Period dropdown
  String _selectedPeriod = 'week';
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

  String _totalRevenue = '₹0';
  String _avgWeekly = '₹0';
  String _growthText = '0%';
  double _growthValue = 0;

  List<Map<String, dynamic>> _dailyBreakdown = [];
  Map<String, double> _weeklyTrend = {};

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

      final data = await _analytics.getRevenueReport(
        turfId: _selectedTurfId,
        period: _selectedPeriod,
      );

      if (!mounted) return;

      // Parse turfs for dropdown
      final turfs =
          (data['turfs'] as List?)
              ?.map((t) => t as Map<String, dynamic>)
              .toList() ??
          [];

      final totalRev =
          double.tryParse(data['total_revenue']?.toString() ?? '0') ?? 0;
      final avgWeekly =
          double.tryParse(data['avg_weekly']?.toString() ?? '0') ?? 0;
      final growth = (data['growth'] as num?)?.toDouble() ?? 0;

      final trend = data['weekly_trend'] as Map<String, dynamic>? ?? {};
      final breakdown =
          (data['daily_breakdown'] as List?)
              ?.map((d) => d as Map<String, dynamic>)
              .toList() ??
          [];

      setState(() {
        _turfs = turfs;
        _totalRevenue = '₹${_formatNum(totalRev)}';
        _avgWeekly = '₹${_formatNum(avgWeekly)}';
        _growthValue = growth;
        _growthText = '${growth >= 0 ? "+" : ""}${growth.toStringAsFixed(1)}%';
        _weeklyTrend = trend.map((k, v) => MapEntry(k, (v as num).toDouble()));
        _dailyBreakdown = breakdown;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load revenue data';
        });
      }
      debugPrint('Revenue fetch error: $e');
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

  double get _maxRevenue {
    if (_dailyBreakdown.isEmpty) return 1.0;
    final max = _dailyBreakdown
        .map((e) => (e['revenue'] as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);
    return max == 0 ? 1.0 : max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Revenue Report',
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
                    // Filters Card
                    _buildFiltersCard(),
                    const SizedBox(height: 24),
                    // Revenue Chart
                    _buildWeeklyChart(),
                    const SizedBox(height: 24),
                    // Revenue Breakdown
                    _buildDailyBreakdown(),
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
                            setState(() {
                              _selectedTurfId = value;
                              _selectedTurfName = value == null
                                  ? 'All Turfs'
                                  : _turfs
                                            .firstWhere(
                                              (t) => t['id'] == value,
                                            )['name']
                                            ?.toString() ??
                                        '';
                            });
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
            Row(
              children: [
                Expanded(
                  child: _buildRevenueStatCard(
                    'Total Revenue',
                    _totalRevenue,
                    _growthText,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRevenueStatCard(
                    'Avg Weekly Rev',
                    _avgWeekly,
                    _growthValue >= 0 ? '+' : '',
                    Icons.show_chart,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
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
              'Weekly Revenue Trend',
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
                      children: _dailyBreakdown.map((data) {
                        final rev = (data['revenue'] as num).toDouble();
                        double heightPct = rev / _maxRevenue;
                        final dayLabel =
                            (data['day']?.toString() ?? '').length >= 3
                            ? data['day'].toString().substring(0, 3)
                            : data['day'].toString();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 30,
                              height: (150 * heightPct).clamp(0.0, 150.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C853),
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
                              rev >= 1000
                                  ? '₹${(rev / 1000).toStringAsFixed(0)}K'
                                  : '₹${rev.toInt()}',
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

  Widget _buildDailyBreakdown() {
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
              'Revenue Breakdown',
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
              ..._dailyBreakdown.map((data) {
                final rev = (data['revenue'] as num).toDouble();
                final dayLabel = (data['day']?.toString() ?? '').length >= 3
                    ? data['day'].toString().substring(0, 3)
                    : data['day'].toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          dayLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: rev / _maxRevenue,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF00C853),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${rev.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${data['bookings']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
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

  Widget _buildRevenueStatCard(
    String title,
    String value,
    String change,
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
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              if (change.isNotEmpty && change != '+')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: change.contains('+')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: change.contains('+') ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
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
        ],
      ),
    );
  }
}
