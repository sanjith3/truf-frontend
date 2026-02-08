import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/turf_data_service.dart';
import '../bookings/my_bookings_screen.dart';
import '../../models/booking.dart';

class RevenueReportScreen extends StatefulWidget {
  final List<String>? registeredTurfNames;
  const RevenueReportScreen({super.key, this.registeredTurfNames});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  List<String> turfNames = [
    'All Turfs',
    'Green Field Arena',
    'City Sports Turf',
    'Elite Football Ground',
    'Sports Hub Arena',
  ];
  String selectedTurf = 'All Turfs';
  
  final TurfDataService _turfService = TurfDataService();

  @override
  void initState() {
    super.initState();
    _turfService.addListener(_onTurfDataChanged);
    if (widget.registeredTurfNames != null && widget.registeredTurfNames!.isNotEmpty) {
      if (widget.registeredTurfNames!.length > 1) {
        turfNames = ['All My Turfs', ...widget.registeredTurfNames!];
        selectedTurf = 'All My Turfs';
      } else {
        selectedTurf = widget.registeredTurfNames!.first;
        turfNames = [widget.registeredTurfNames!.first];
      }
    }
  }

  @override
  void dispose() {
    _turfService.removeListener(_onTurfDataChanged);
    super.dispose();
  }

  void _onTurfDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String selectedPeriod = 'This Month';
  List<String> periods = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Quarter',
    'This Year',
    'Custom Range',
  ];

  // For custom date range
  DateTime? startDate;
  DateTime? endDate;
  bool showCustomDatePicker = false;

  List<Map<String, dynamic>> get revenueData {
    final allBookings = _turfService.bookings;
    Iterable<Booking> filteredBookings = allBookings;

    if (selectedTurf == 'All My Turfs' && widget.registeredTurfNames != null) {
      filteredBookings = allBookings.where((b) => widget.registeredTurfNames!.contains(b.turfName));
    } else if (selectedTurf != 'All Turfs') {
      filteredBookings = allBookings.where((b) => b.turfName == selectedTurf);
    }

    // Filter by period (Simplified for demo)
    final now = DateTime.now();
    if (selectedPeriod == 'Today') {
      filteredBookings = filteredBookings.where((b) => isSameDay(b.date, now));
    } else if (selectedPeriod == 'This Week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      filteredBookings = filteredBookings.where((b) => b.date.isAfter(weekStart.subtract(const Duration(seconds: 1))));
    }

    // Group by Day of Week for the chart
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<Map<String, dynamic>> groupedData = List.generate(7, (i) => {
      'day': days[i],
      'revenue': 0,
      'bookings': 0,
    });

    for (var booking in filteredBookings) {
      // weekday is 1 for Mon, 7 for Sun
      final index = booking.date.weekday - 1;
      if (index >= 0 && index < 7) {
        groupedData[index]['revenue'] = (groupedData[index]['revenue'] as int) + booking.amount.toInt();
        groupedData[index]['bookings'] = (groupedData[index]['bookings'] as int) + 1;
      }
    }

    return groupedData;
  }

  double get maxRevenue {
    final values = revenueData.map((e) => e['revenue'] as int).toList();
    final max = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1.0 : max.toDouble();
  }

  int get totalRevenueValue => revenueData.fold(0, (sum, item) => sum + (item['revenue'] as int));
  int get avgDailyRevenueValue => revenueData.isEmpty ? 0 : (totalRevenueValue / revenueData.length).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Revenue Report',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
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
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedTurf,
                                  underline: SizedBox(),
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                  ),
                                  items: turfNames.map((turf) {
                                    return DropdownMenuItem<String>(
                                      value: turf,
                                      child: Text(turf),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTurf = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
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
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedPeriod,
                                  underline: SizedBox(),
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                  ),
                                  items: periods.map((period) {
                                    return DropdownMenuItem<String>(
                                      value: period,
                                      child: Text(period),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPeriod = value!;
                                      if (value == 'Custom Range') {
                                        _selectDateRange(context);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRevenueStatCard(
                            'Total Revenue',
                            '₹${NumberFormat('#,##,###').format(totalRevenueValue)}',
                            '+15.2%',
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildRevenueStatCard(
                            'Avg Weekly Rev',
                            '₹${NumberFormat('#,##,###').format(avgDailyRevenueValue)}',
                            '+8.7%',
                            Icons.show_chart,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Revenue Chart
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Revenue Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: revenueData.map((data) {
                          double heightPercentage =
                              data['revenue'] / maxRevenue;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 30,
                                height: (150 * heightPercentage).clamp(0.0, 150.0).toDouble(),
                                decoration: BoxDecoration(
                                  color: Color(0xFF00C853),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                data['day'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹${(data['revenue'] / 1000).toStringAsFixed(0)}K',
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
            ),

            SizedBox(height: 24),

            // Revenue Breakdown
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...revenueData.map((data) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                data['day'],
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
                                value: data['revenue'] / maxRevenue,
                                backgroundColor: Colors.grey[200],
                                color: Color(0xFF00C853),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${data['revenue'].toString()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(
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
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Summary section REMOVED as requested
            SizedBox(height: 32),
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
      padding: EdgeInsets.all(16),
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
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
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

  // Method to show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.green),
              SizedBox(width: 10),
              Text('Filter Options'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turf Selection
                Text(
                  'Select Turf',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: selectedTurf,
                    underline: SizedBox(),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    items: turfNames.map((turf) {
                      return DropdownMenuItem<String>(
                        value: turf,
                        child: Text(turf),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTurf = value!;
                      });
                      Navigator.pop(context);
                      _showFilterDialog(); // Reopen dialog to show updated selection
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Time Period Selection
                Text(
                  'Time Period',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: selectedPeriod,
                    underline: SizedBox(),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    items: periods.map((period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == 'Custom Range') {
                        Navigator.pop(context);
                        _selectDateRange(context);
                      } else {
                        setState(() {
                          selectedPeriod = value!;
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Display selected custom date range
                if (selectedPeriod == 'Custom Range' &&
                    startDate != null &&
                    endDate != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${DateFormat('MMM dd, yyyy').format(startDate!)} to ${DateFormat('MMM dd, yyyy').format(endDate!)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply filters logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filters applied successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Apply Filters'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );
      },
    );
  }

  // Method to select date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now().subtract(Duration(days: 30)),
        end: endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedPeriod = 'Custom Range';
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Date range selected: ${DateFormat('MMM dd, yyyy').format(startDate!)} to ${DateFormat('MMM dd, yyyy').format(endDate!)}',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading Revenue Report...'),
        backgroundColor: Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading Revenue Report as PDF...'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
