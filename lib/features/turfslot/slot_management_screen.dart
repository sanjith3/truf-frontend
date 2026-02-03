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

  // Slot data
  List<Map<String, dynamic>> slots = [
    {
      'time': '6:00 AM',
      'status': 'available',
      'price': '₹500',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '7:00 AM',
      'status': 'booked',
      'price': '₹500',
      'customer': 'Rajesh Kumar',
      'bookingId': 'BK-001',
      'disabled': false,
    },
    {
      'time': '8:00 AM',
      'status': 'booked',
      'price': '₹500',
      'customer': 'Team Alpha',
      'bookingId': 'BK-002',
      'disabled': false,
    },
    {
      'time': '9:00 AM',
      'status': 'available',
      'price': '₹600',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '10:00 AM',
      'status': 'booked',
      'price': '₹600',
      'customer': 'Priya Sharma',
      'bookingId': 'BK-003',
      'disabled': false,
    },
    {
      'time': '11:00 AM',
      'status': 'available',
      'price': '₹600',
      'customer': null,
      'bookingId': null,
      'disabled': true, // Manually disabled
    },
    {
      'time': '12:00 PM',
      'status': 'booked',
      'price': '₹700',
      'customer': 'Vikram Singh',
      'bookingId': 'BK-004',
      'disabled': false,
    },
    {
      'time': '1:00 PM',
      'status': 'available',
      'price': '₹700',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '2:00 PM',
      'status': 'booked',
      'price': '₹700',
      'customer': 'Anita Rao',
      'bookingId': 'BK-005',
      'disabled': false,
    },
    {
      'time': '3:00 PM',
      'status': 'booked',
      'price': '₹800',
      'customer': 'Rahul Mehta',
      'bookingId': 'BK-006',
      'disabled': false,
    },
    {
      'time': '4:00 PM',
      'status': 'booked',
      'price': '₹800',
      'customer': 'Suresh Kumar',
      'bookingId': 'BK-007',
      'disabled': false,
    },
    {
      'time': '5:00 PM',
      'status': 'available',
      'price': '₹800',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '6:00 PM',
      'status': 'booked',
      'price': '₹900',
      'customer': 'Neha Gupta',
      'bookingId': 'BK-008',
      'disabled': false,
    },
    {
      'time': '7:00 PM',
      'status': 'available',
      'price': '₹900',
      'customer': null,
      'bookingId': null,
      'disabled': false,
    },
    {
      'time': '8:00 PM',
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
      // Only allow toggling if slot is available (not booked)
      if (slots[index]['status'] == 'available') {
        slots[index]['disabled'] = value;
      }
    });
  }

  void _toggleEmergencyMode() {
    if (_emergencyMode) {
      // Turn off emergency mode
      setState(() {
        _emergencyMode = false;
        // Re-enable all slots that were disabled by emergency mode
        for (var slot in slots) {
          if (slot['status'] == 'available') {
            slot['disabled'] = false;
          }
        }
      });
    } else {
      // Check if there are upcoming bookings
      bool hasUpcomingBookings = slots.any(
        (slot) => slot['status'] == 'booked',
      );

      if (hasUpcomingBookings) {
        _showEmergencyWarningDialog();
      } else {
        setState(() {
          _emergencyMode = true;
          // Disable all available slots
          for (var slot in slots) {
            if (slot['status'] == 'available') {
              slot['disabled'] = true;
            }
          }
        });
      }
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
              _buildDetailRow('Time', slot['time']),
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Filter slots based on selected filter
    List<Map<String, dynamic>> filteredSlots = _selectedFilter == 'all'
        ? slots
        : slots.where((slot) => slot['status'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: _bg,
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
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
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

          // Date Range Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                ),
                              ),
                              Text(
                                _formatDate(_startDate),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                ),
                              ),
                              Text(
                                _formatDate(_endDate),
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
                const SizedBox(height: 8),
                Text(
                  'Viewing ${_endDate.difference(_startDate).inDays + 1} days',
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),

          // Emergency Mode Toggle
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _emergencyMode ? _danger : Colors.transparent,
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
                            color: _emergencyMode ? _danger : _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emergencyMode
                              ? 'All available slots are disabled'
                              : 'Click to disable all available slots',
                          style: TextStyle(fontSize: 13, color: _textSecondary),
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
            ),
          ),

          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Available', 'available'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Booked', 'booked'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Disabled', 'disabled'),
                ],
              ),
            ),
          ),

          // Slots List
          Expanded(
            child: Container(
              color: _bg,
              child: Column(
                children: [
                  // Slots Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    color: Colors.white,
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
                          '${filteredSlots.length} slots',
                          style: TextStyle(fontSize: 14, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Slots List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSlots.length,
                      itemBuilder: (context, index) {
                        final slot = filteredSlots[index];
                        return _buildSlotCard(slot, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildFilterChip(String label, String value) {
    bool selected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : _textSecondary,
          ),
        ),
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
                        slot['time'],
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
                        if (isDisabled)
                          Text(
                            'Emergency maintenance',
                            style: TextStyle(fontSize: 12, color: _danger),
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
