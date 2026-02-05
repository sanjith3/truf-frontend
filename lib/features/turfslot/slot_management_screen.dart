// slot_management_screen.dart - PREMIUM ADMIN UI WITH ADVANCED FEATURES
import 'package:flutter/material.dart';

class PremiumSlotManagementScreen extends StatefulWidget {
  final dynamic turf;

  const PremiumSlotManagementScreen({super.key, this.turf});

  @override
  State<PremiumSlotManagementScreen> createState() =>
      _PremiumSlotManagementScreenState();
}

class _PremiumSlotManagementScreenState
    extends State<PremiumSlotManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _selectedFilter = 'all';
  bool _isTurfDisabled = false;
  bool _emergencyMode = false;
  DateTime? _emergencyStartDate;
  DateTime? _emergencyEndDate;
  String _emergencyReason = '';

  // Time filter variables
  TimeOfDay? _filterStartTime;
  TimeOfDay? _filterEndTime;
  String _selectedTimeFilter = 'all';

  // Slot data
  List<Map<String, dynamic>> slots = [
    {
      'time': '6:00 AM',
      'endTime': '7:00 AM',
      'status': 'available',
      'price': '₹500',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '7:00 AM',
      'endTime': '8:00 AM',
      'status': 'booked',
      'price': '₹500',
      'customer': 'Rajesh Kumar',
      'bookingId': 'BK-001',
      'disabled': false,
    },
    {
      'time': '8:00 AM',
      'endTime': '9:00 AM',
      'status': 'booked',
      'price': '₹500',
      'customer': 'Team Alpha',
      'bookingId': 'BK-002',
      'disabled': false,
    },
    {
      'time': '9:00 AM',
      'endTime': '10:00 AM',
      'status': 'available',
      'price': '₹600',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '10:00 AM',
      'endTime': '11:00 AM',
      'status': 'booked',
      'price': '₹600',
      'customer': 'Priya Sharma',
      'bookingId': 'BK-003',
      'disabled': false,
    },
    {
      'time': '11:00 AM',
      'endTime': '12:00 PM',
      'status': 'available',
      'price': '₹600',
      'customer': null,
      'bookingId': null,
      'disabled': true,
    },
    {
      'time': '12:00 PM',
      'endTime': '1:00 PM',
      'status': 'booked',
      'price': '₹700',
      'customer': 'Vikram Singh',
      'bookingId': 'BK-004',
      'disabled': false,
    },
    {
      'time': '1:00 PM',
      'endTime': '2:00 PM',
      'status': 'available',
      'price': '₹700',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '2:00 PM',
      'endTime': '3:00 PM',
      'status': 'booked',
      'price': '₹700',
      'customer': 'Anita Rao',
      'bookingId': 'BK-005',
      'disabled': false,
    },
    {
      'time': '3:00 PM',
      'endTime': '4:00 PM',
      'status': 'booked',
      'price': '₹800',
      'customer': 'Rahul Mehta',
      'bookingId': 'BK-006',
      'disabled': false,
    },
    {
      'time': '4:00 PM',
      'endTime': '5:00 PM',
      'status': 'booked',
      'price': '₹800',
      'customer': 'Suresh Kumar',
      'bookingId': 'BK-007',
      'disabled': false,
    },
    {
      'time': '5:00 PM',
      'endTime': '6:00 PM',
      'status': 'available',
      'price': '₹800',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '6:00 PM',
      'endTime': '7:00 PM',
      'status': 'booked',
      'price': '₹900',
      'customer': 'Neha Gupta',
      'bookingId': 'BK-008',
      'disabled': false,
    },
    {
      'time': '7:00 PM',
      'endTime': '8:00 PM',
      'status': 'available',
      'price': '₹900',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '8:00 PM',
      'endTime': '9:00 PM',
      'status': 'booked',
      'price': '₹1000',
      'customer': 'Amit Sharma',
      'bookingId': 'BK-009',
      'disabled': false,
    },
  ];

  // Colors
  final Color _primary = const Color(0xFF00C853);
  final Color _accent = const Color(0xFFFF9800);
  final Color _danger = const Color(0xFFF44336);
  final Color _success = const Color(0xFF4CAF50);
  final Color _warning = const Color(0xFFFFB74D);
  final Color _bg = const Color(0xFFF8F9FA);
  final Color _card = Colors.white;
  final Color _textPrimary = const Color(0xFF1A1A1A);
  final Color _textSecondary = const Color(0xFF666666);
  final Color _disabledColor = const Color(0xFF9E9E9E);

  // Calculate stats
  int get availableCount =>
      slots.where((s) => s['status'] == 'available').length;
  int get bookedCount => slots.where((s) => s['status'] == 'booked').length;
  int get blockedCount => slots.where((s) => s['disabled'] == true).length;
  String get revenue {
    int total = 0;
    for (var slot in slots) {
      if (slot['status'] == 'booked') {
        total += int.parse(
          slot['price'].replaceAll('₹', '').replaceAll(',', ''),
        );
      }
    }
    return '₹$total';
  }

  // Helper methods
  Color _getStatusColor(Map<String, dynamic> slot) {
    if (slot['disabled'] == true) return _disabledColor;
    switch (slot['status']) {
      case 'available':
        return _success;
      case 'booked':
        return _accent;
      default:
        return _textSecondary;
    }
  }

  String _getStatusLabel(Map<String, dynamic> slot) {
    if (slot['disabled'] == true) return 'DISABLED';
    switch (slot['status']) {
      case 'available':
        return 'AVAILABLE';
      case 'booked':
        return 'BOOKED';
      default:
        return slot['status'].toUpperCase();
    }
  }

  IconData _getStatusIcon(Map<String, dynamic> slot) {
    if (slot['disabled'] == true) return Icons.block;
    switch (slot['status']) {
      case 'available':
        return Icons.check_circle;
      case 'booked':
        return Icons.event_available;
      default:
        return Icons.info_outline;
    }
  }

  void _toggleSlotDisabled(int index, bool value) {
    setState(() {
      if (slots[index]['status'] == 'available') {
        slots[index]['disabled'] = value;
      }
    });
  }

  void _toggleEmergencyMode() {
    if (_emergencyMode) {
      setState(() {
        _emergencyMode = false;
        _emergencyStartDate = null;
        _emergencyEndDate = null;
        _emergencyReason = '';
        for (var slot in slots) {
          if (slot['status'] == 'available') {
            slot['disabled'] = false;
          }
        }
      });
    } else {
      bool hasUpcomingBookings = slots.any(
        (slot) => slot['status'] == 'booked',
      );

      if (hasUpcomingBookings) {
        _showEmergencyWarningDialog();
      } else {
        _showEmergencyDateRangeDialog();
      }
    }
  }

  void _showEmergencyDateRangeDialog() {
    DateTime tempStartDate = DateTime.now();
    DateTime tempEndDate = DateTime.now().add(const Duration(days: 1));
    String tempReason = _emergencyReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Emergency Mode - Select Date Range'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disable all available slots for the selected date range:',
                    style: TextStyle(fontSize: 14, color: _textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Start Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempStartDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != tempStartDate) {
                        setState(() {
                          tempStartDate = picked;
                          if (tempEndDate.isBefore(tempStartDate)) {
                            tempEndDate = tempStartDate.add(
                              const Duration(days: 1),
                            );
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: _primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                                Text(
                                  '${tempStartDate.day} ${_getMonthName(tempStartDate.month)} ${tempStartDate.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // End Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempEndDate,
                        firstDate: tempStartDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != tempEndDate) {
                        setState(() {
                          tempEndDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: _primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                                Text(
                                  '${tempEndDate.day} ${_getMonthName(tempEndDate.month)} ${tempEndDate.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date Range: ${tempStartDate.day}${_getOrdinalSuffix(tempStartDate.day)} ${_getMonthName(tempStartDate.month)} to ${tempEndDate.day}${_getOrdinalSuffix(tempEndDate.day)} ${_getMonthName(tempEndDate.month)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Days: ${tempEndDate.difference(tempStartDate).inDays + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reason/Description
                  Text(
                    'Emergency Reason',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter reason for emergency mode (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _primary),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      tempReason = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _emergencyMode = true;
                    _emergencyStartDate = tempStartDate;
                    _emergencyEndDate = tempEndDate;
                    _emergencyReason = tempReason;
                    for (var slot in slots) {
                      if (slot['status'] == 'available') {
                        slot['disabled'] = true;
                      }
                    }
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Emergency'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  void _showEmergencyWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Enable Emergency Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, size: 48, color: _warning),
            const SizedBox(height: 16),
            const Text(
              'Emergency mode cannot be enabled because there are upcoming bookings.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait until all bookings are completed before enabling emergency mode.',
              style: TextStyle(fontSize: 12, color: _textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    DateTime tempStartDate = _startDate;
    DateTime tempEndDate = _endDate;
    String tempSelectedFilter = _selectedFilter;
    TimeOfDay? tempStartTime = _filterStartTime;
    TimeOfDay? tempEndTime = _filterEndTime;
    String tempTimeFilter = _selectedTimeFilter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Advanced Filters'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Start Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempStartDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != tempStartDate) {
                        setState(() {
                          tempStartDate = picked;
                          if (tempEndDate.isBefore(tempStartDate)) {
                            tempEndDate = tempStartDate.add(
                              const Duration(days: 1),
                            );
                          }
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                              Text(
                                '${tempStartDate.day} ${_getMonthName(tempStartDate.month)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.calendar_today, color: _primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // End Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempEndDate,
                        firstDate: tempStartDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != tempEndDate) {
                        setState(() {
                          tempEndDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                              Text(
                                '${tempEndDate.day} ${_getMonthName(tempEndDate.month)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.calendar_today, color: _primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tempEndDate.difference(tempStartDate).inDays + 1} days (${tempStartDate.day}${_getOrdinalSuffix(tempStartDate.day)} ${_getMonthName(tempStartDate.month)} - ${tempEndDate.day}${_getOrdinalSuffix(tempEndDate.day)} ${_getMonthName(tempEndDate.month)})',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Date Range Buttons
                  Text(
                    'Quick Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickDateRangeButton(
                        'Today',
                        1,
                        tempStartDate,
                        tempEndDate,
                        setState,
                      ),
                      _buildQuickDateRangeButton(
                        'Next 7 Days',
                        7,
                        tempStartDate,
                        tempEndDate,
                        setState,
                      ),
                      _buildQuickDateRangeButton(
                        'Next 30 Days',
                        30,
                        tempStartDate,
                        tempEndDate,
                        setState,
                      ),
                      _buildQuickDateRangeButton(
                        'Next 90 Days',
                        90,
                        tempStartDate,
                        tempEndDate,
                        setState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Time Filter Section
                  Text(
                    'Time Filter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time Range Selection
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  tempStartTime ??
                                  const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (picked != null) {
                              setState(() {
                                tempStartTime = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                                Text(
                                  tempStartTime != null
                                      ? tempStartTime!.format(context)
                                      : 'Select time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  tempEndTime ??
                                  const TimeOfDay(hour: 18, minute: 0),
                            );
                            if (picked != null) {
                              setState(() {
                                tempEndTime = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                                Text(
                                  tempEndTime != null
                                      ? tempEndTime!.format(context)
                                      : 'Select time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Time Filters
                  Text(
                    'Quick Time Filters',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickTimeFilter(
                        'Morning',
                        '6:00 AM',
                        '12:00 PM',
                        tempTimeFilter,
                        setState,
                      ),
                      _buildQuickTimeFilter(
                        'Afternoon',
                        '12:00 PM',
                        '5:00 PM',
                        tempTimeFilter,
                        setState,
                      ),
                      _buildQuickTimeFilter(
                        'Evening',
                        '5:00 PM',
                        '9:00 PM',
                        tempTimeFilter,
                        setState,
                      ),
                      _buildQuickTimeFilter(
                        'Night',
                        '9:00 PM',
                        '12:00 AM',
                        tempTimeFilter,
                        setState,
                      ),
                      _buildQuickTimeFilter(
                        'All Day',
                        'all',
                        'all',
                        tempTimeFilter,
                        setState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status Filter
                  Text(
                    'Slot Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterOption(
                        'All Slots',
                        'all',
                        tempSelectedFilter,
                        setState,
                      ),
                      _buildFilterOption(
                        'Available',
                        'available',
                        tempSelectedFilter,
                        setState,
                      ),
                      _buildFilterOption(
                        'Booked',
                        'booked',
                        tempSelectedFilter,
                        setState,
                      ),
                      _buildFilterOption(
                        'Disabled',
                        'disabled',
                        tempSelectedFilter,
                        setState,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterStartTime = null;
                    _filterEndTime = null;
                    _selectedTimeFilter = 'all';
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _startDate = tempStartDate;
                    _endDate = tempEndDate;
                    _selectedFilter = tempSelectedFilter;
                    _filterStartTime = tempStartTime;
                    _filterEndTime = tempEndTime;
                    _selectedTimeFilter = tempTimeFilter;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickDateRangeButton(
    String label,
    int days,
    DateTime tempStartDate,
    DateTime tempEndDate,
    Function(void Function()) setState,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tempStartDate = DateTime.now();
          tempEndDate = DateTime.now().add(Duration(days: days - 1));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: _textSecondary),
        ),
      ),
    );
  }

  Widget _buildQuickTimeFilter(
    String label,
    String startTime,
    String endTime,
    String tempTimeFilter,
    Function(void Function()) setState,
  ) {
    bool selected = tempTimeFilter == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          if (startTime == 'all') {
            tempTimeFilter = 'all';
          } else {
            tempTimeFilter = label.toLowerCase();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : _textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    String value,
    String tempSelectedFilter,
    Function(void Function()) setState,
  ) {
    bool selected = tempSelectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          tempSelectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : _textSecondary,
          ),
        ),
      ),
    );
  }

  void _showAddSlotDialog() {
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    String price = '500';
    bool isDisabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add New Time Slot',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Create a new booking slot',
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Selection
                            Text(
                              'SELECT TIME',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: _primary,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: _textPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() => selectedTime = picked);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Time',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedTime.format(context),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: _textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Slot will be: ${selectedTime.format(context)} - ${_calculateEndTime(selectedTime).format(context)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.access_time,
                                        color: _primary,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Price Input
                            Text(
                              'HOURLY PRICE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '₹',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: _primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: price,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter amount',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary,
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() => price = value);
                                      },
                                    ),
                                  ),
                                  Text(
                                    '/hour',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Status Toggle
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SLOT STATUS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _textSecondary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isDisabled ? 'Disabled' : 'Available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDisabled
                                              ? _danger
                                              : _success,
                                        ),
                                      ),
                                      Text(
                                        isDisabled
                                            ? 'Slot will not be bookable'
                                            : 'Slot will be available for booking',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Transform.scale(
                                    scale: 1.2,
                                    child: Switch(
                                      value: !isDisabled,
                                      onChanged: (value) {
                                        setState(() => isDisabled = !value);
                                      },
                                      activeColor: _success,
                                      inactiveThumbColor: _danger,
                                      activeTrackColor: _success.withOpacity(
                                        0.3,
                                      ),
                                      inactiveTrackColor: _danger.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Preview
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _primary.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PREVIEW',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _primary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${selectedTime.format(context)} - ${_calculateEndTime(selectedTime).format(context)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: _textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee,
                                                size: 16,
                                                color: _primary,
                                              ),
                                              Text(
                                                '$price/hour',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: _primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDisabled
                                              ? _danger.withOpacity(0.1)
                                              : _success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isDisabled
                                                ? _danger.withOpacity(0.3)
                                                : _success.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isDisabled
                                                  ? Icons.block
                                                  : Icons.check_circle,
                                              size: 14,
                                              color: isDisabled
                                                  ? _danger
                                                  : _success,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isDisabled
                                                  ? 'DISABLED'
                                                  : 'AVAILABLE',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDisabled
                                                    ? _danger
                                                    : _success,
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
                            const SizedBox(height: 24),
                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'CANCEL',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        slots.add({
                                          'time': selectedTime.format(context),
                                          'endTime': _calculateEndTime(
                                            selectedTime,
                                          ).format(context),
                                          'status': 'available',
                                          'price': '₹$price',
                                          'customer': null,
                                          'bookingId': null,
                                          'disabled': isDisabled,
                                        });
                                        slots.sort((a, b) {
                                          int hourA = _parseTimeTo24Hour(
                                            a['time'],
                                          );
                                          int hourB = _parseTimeTo24Hour(
                                            b['time'],
                                          );
                                          return hourA.compareTo(hourB);
                                        });
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ADD SLOT',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  TimeOfDay _calculateEndTime(TimeOfDay startTime) {
    int hour = startTime.hour + 1;
    int minute = startTime.minute;

    if (hour >= 24) {
      hour = hour % 24;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  int _parseTimeTo24Hour(String time) {
    List<String> parts = time.split(' ');
    String timePart = parts[0];
    String period = parts[1];

    List<String> timeParts = timePart.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return hour * 100 + minute;
  }

  void _showBookingDetails(Map<String, dynamic> slot) {
    if (slot['status'] != 'booked') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.confirmation_number, color: _primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot['bookingId'] ?? 'No ID',
                          style: TextStyle(fontSize: 14, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: _textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details
              _buildDetailRow(
                'Time Slot',
                '${slot['time']} - ${slot['endTime']}',
              ),
              _buildDetailRow('Price', slot['price']),
              _buildDetailRow('Customer', slot['customer'] ?? 'N/A'),
              _buildDetailRow('Status', 'Confirmed'),
              _buildDetailRow('Payment', 'Paid'),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: _danger),
                      ),
                      child: Text(
                        'Cancel Booking',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: _textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${monthNames[date.month - 1]}';
  }

  String _formatEmergencyDateRange() {
    if (_emergencyStartDate == null || _emergencyEndDate == null) {
      return 'Select date range';
    }
    return '${_emergencyStartDate!.day}${_getOrdinalSuffix(_emergencyStartDate!.day)} ${_getMonthName(_emergencyStartDate!.month)} - ${_emergencyEndDate!.day}${_getOrdinalSuffix(_emergencyEndDate!.day)} ${_getMonthName(_emergencyEndDate!.month)}';
  }

  @override
  Widget build(BuildContext context) {
    // Filter slots based on selected filter
    List<Map<String, dynamic>> filteredSlots = _selectedFilter == 'all'
        ? slots
        : slots.where((slot) => slot['status'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSlotDialog,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, size: 28),
      ),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slot Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              'Elite Football Ground',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Advanced Filters',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compact Stats Cards
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCompactStatCard(
                    'Revenue',
                    revenue,
                    Icons.currency_rupee,
                    _primary,
                  ),
                  _buildCompactStatCard(
                    'Booked',
                    '$bookedCount',
                    Icons.event_available,
                    _accent,
                  ),
                  _buildCompactStatCard(
                    'Available',
                    '$availableCount',
                    Icons.check_circle,
                    _success,
                  ),
                  _buildCompactStatCard(
                    'Disabled',
                    '$blockedCount',
                    Icons.block,
                    _danger,
                  ),
                ],
              ),
            ),

            // Emergency Mode Toggle with Date Range
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _emergencyMode ? _danger.withOpacity(0.1) : _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _emergencyMode ? _danger : Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _emergencyMode
                                ? _danger
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.emergency,
                            color: _emergencyMode ? Colors.white : _danger,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _emergencyMode
                                    ? 'Emergency Mode ON'
                                    : 'Emergency Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _emergencyMode
                                      ? _danger
                                      : _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _emergencyMode
                                    ? 'All available slots are disabled'
                                    : 'Click to disable slots for date range',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _emergencyMode,
                          onChanged: (value) => _toggleEmergencyMode(),
                          activeColor: _danger,
                        ),
                      ],
                    ),
                    // Show emergency date range when active
                    if (_emergencyMode &&
                        _emergencyStartDate != null &&
                        _emergencyEndDate != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _danger.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: _danger,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Emergency Active For:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _danger,
                                        ),
                                      ),
                                      Text(
                                        _formatEmergencyDateRange(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: _toggleEmergencyMode,
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: _danger,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            if (_emergencyReason.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Reason: $_emergencyReason',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _danger,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Slots Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              color: _bg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Slots',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    '${filteredSlots.length} slots • ${_selectedFilter.toUpperCase()}',
                    style: TextStyle(fontSize: 12, color: _textSecondary),
                  ),
                ],
              ),
            ),

            // Slots List
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSlots.length,
              itemBuilder: (context, index) {
                final slot = filteredSlots[index];
                return _buildSlotCard(slot, index);
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot, int index) {
    Color statusColor = _getStatusColor(slot);
    bool isBooked = slot['status'] == 'booked';
    bool isAvailable = slot['status'] == 'available';
    bool isDisabled = slot['disabled'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Time and Status Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Time and Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot['time']} - ${slot['endTime']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDisabled ? _disabledColor : _textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 16,
                            color: isDisabled ? _disabledColor : _primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            slot['price'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDisabled ? _disabledColor : _primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(slot), size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusLabel(slot),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.grey[100],
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Customer Info or Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isBooked) ...[
                  Icon(Icons.person, size: 18, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['customer']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking ID: ${slot['bookingId']}',
                          style: TextStyle(fontSize: 12, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showBookingDetails(slot),
                    icon: Icon(Icons.chevron_right, color: _textSecondary),
                  ),
                ] else ...[
                  Icon(
                    isDisabled ? Icons.block : Icons.lock_open,
                    size: 18,
                    color: isDisabled ? _disabledColor : _success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDisabled
                              ? 'Slot is disabled'
                              : 'Slot is available for booking',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDisabled ? _disabledColor : _textSecondary,
                          ),
                        ),
                        if (isDisabled && _emergencyMode)
                          Text(
                            'Emergency: ${_formatEmergencyDateRange()}',
                            style: TextStyle(fontSize: 11, color: _danger),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: !isDisabled,
                    onChanged: isBooked
                        ? null
                        : (value) => _toggleSlotDisabled(index, !value),
                    activeColor: _success,
                    inactiveThumbColor: _disabledColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
