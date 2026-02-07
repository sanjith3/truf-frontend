import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingAnalyticsScreen extends StatefulWidget {
  const BookingAnalyticsScreen({super.key});

  @override
  State<BookingAnalyticsScreen> createState() => _BookingAnalyticsScreenState();
}

class _BookingAnalyticsScreenState extends State<BookingAnalyticsScreen> {
  List<String> turfNames = [
    'All Turfs',
    'Green Field Arena',
    'City Sports Turf',
    'Elite Football Ground',
    'Sports Hub Arena',
  ];

  String selectedTurf = 'All Turfs';
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

  // Base booking data
  final List<Map<String, dynamic>> _allBookingData = [
    {'time': '6-9 AM', 'bookings': 15, 'percentage': 12},
    {'time': '9-12 PM', 'bookings': 35, 'percentage': 28},
    {'time': '12-3 PM', 'bookings': 42, 'percentage': 33},
    {'time': '3-6 PM', 'bookings': 58, 'percentage': 46},
    {'time': '6-9 PM', 'bookings': 85, 'percentage': 68},
    {'time': '9-12 AM', 'bookings': 25, 'percentage': 20},
  ];

  List<Map<String, dynamic>> get bookingData {
    double multiplier = 1.0;
    if (selectedTurf != 'All Turfs') multiplier = 0.7;
    return _allBookingData.map((d) => {
      'time': d['time'],
      'bookings': ((d['bookings'] as int) * multiplier).round(),
      'percentage': d['percentage']
    }).toList();
  }

  // Base day wise data  
  final List<Map<String, dynamic>> _allDayWiseData = [
    {'day': 'Monday', 'bookings': 35, 'cancellations': 2, 'revenue': 25000},
    {'day': 'Tuesday', 'bookings': 42, 'cancellations': 1, 'revenue': 32000},
    {'day': 'Wednesday', 'bookings': 38, 'cancellations': 3, 'revenue': 28000},
    {'day': 'Thursday', 'bookings': 45, 'cancellations': 1, 'revenue': 35000},
    {'day': 'Friday', 'bookings': 52, 'cancellations': 4, 'revenue': 45000},
    {'day': 'Saturday', 'bookings': 65, 'cancellations': 2, 'revenue': 58000},
    {'day': 'Sunday', 'bookings': 58, 'cancellations': 3, 'revenue': 52000},
  ];

  List<Map<String, dynamic>> get dayWiseData {
    double multiplier = 1.0;
    if (selectedTurf != 'All Turfs') multiplier = 0.8;
    
    // Simulate time period changes
    if (selectedPeriod == 'Today') multiplier *= 0.15;
    else if (selectedPeriod == 'This Week') multiplier *= 1.0;
    else if (selectedPeriod == 'This Month') multiplier *= 4.0;

    return _allDayWiseData.map((d) => {
      'day': d['day'],
      'bookings': ((d['bookings'] as int) * multiplier).round(),
      'cancellations': ((d['cancellations'] as int) * multiplier).round(),
      'revenue': ((d['revenue'] as int) * multiplier).round(),
    }).toList();
  }

  int get totalBookings {
    return dayWiseData.fold<int>(
      0,
      (sum, day) => sum + (day['bookings'] as int),
    );
  }

  int get totalCancellations {
    return dayWiseData.fold<int>(
      0,
      (sum, day) => sum + (day['cancellations'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Booking Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2196F3),
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
                          child: _buildStatCard(
                            'Total Bookings',
                            '$totalBookings',
                            '+8.2%',
                            Icons.event_available,
                            Color(0xFF2196F3),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Cancellation Rate',
                            '${(totalCancellations / totalBookings * 100).toStringAsFixed(1)}%',
                            '-1.2%',
                            Icons.cancel,
                            Color(0xFFF44336),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Peak Hours',
                            '6-9 PM',
                            '68% bookings',
                            Icons.access_time,
                            Color(0xFFFF9800),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Avg Booking Duration',
                            '2.5 hrs',
                            '+0.3 hrs',
                            Icons.timer,
                            Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),



            SizedBox(height: 24),

            // Daily Booking Trends
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
                      'Daily Booking Trends',
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
                        children: dayWiseData.map((day) {
                          int maxBookings = dayWiseData
                              .map((e) => e['bookings'])
                              .reduce((a, b) => a > b ? a : b);
                          double heightPercentage =
                              day['bookings'] / maxBookings;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 25,
                                height: 150 * heightPercentage,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2196F3),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                day['day'].substring(
                                  0,
                                  3,
                                ), // Show short day name
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${day['bookings']}',
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

            // NEW: Daily Bookings Breakdown
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
                      'Daily Bookings Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...dayWiseData.map((dayData) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
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
                                    dayData['day'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                  SizedBox(height: 4),
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
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: dayData['cancellations'] > 3
                                          ? Colors.red[50]
                                          : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${dayData['cancellations']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: dayData['cancellations'] > 3
                                            ? Colors.red
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
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
                    }).toList(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Key Insights section REMOVED as requested
            SizedBox(height: 32),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: subtitle.contains('+')
                  ? Colors.green
                  : subtitle.contains('-')
                  ? Colors.red
                  : Colors.grey[600],
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
              Icon(Icons.filter_alt, color: Color(0xFF2196F3)),
              SizedBox(width: 10),
              Text('Filter Booking Analytics'),
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
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Color(0xFF2196F3),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filters applied successfully'),
                    backgroundColor: Color(0xFF2196F3),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
              ),
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
          backgroundColor: Color(0xFF2196F3),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading Booking Analytics Report...'),
        backgroundColor: Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading Booking Analytics as PDF...'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
