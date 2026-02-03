// slot_management_screen.dart - FIXED
import 'package:flutter/material.dart';

class SlotManagementScreen extends StatefulWidget {
  final dynamic turf; // Accepts both AdminTurf and Map

  const SlotManagementScreen({super.key, this.turf});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> slots = [
    {
      'time': '6:00 AM',
      'status': 'available',
      'price': '₹500',
      'customer': null,
    },
    {
      'time': '7:00 AM',
      'status': 'booked',
      'price': '₹500',
      'customer': 'Rajesh Kumar',
    },
    {
      'time': '8:00 AM',
      'status': 'booked',
      'price': '₹500',
      'customer': 'Team Alpha',
    },
    {
      'time': '9:00 AM',
      'status': 'available',
      'price': '₹600',
      'customer': null,
    },
    {
      'time': '10:00 AM',
      'status': 'booked',
      'price': '₹600',
      'customer': 'Priya Sharma',
    },
    {
      'time': '11:00 AM',
      'status': 'blocked',
      'price': '₹600',
      'customer': null,
    },
    {
      'time': '12:00 PM',
      'status': 'booked',
      'price': '₹700',
      'customer': 'Vikram Singh',
    },
    {
      'time': '1:00 PM',
      'status': 'available',
      'price': '₹700',
      'customer': null,
    },
    {
      'time': '2:00 PM',
      'status': 'booked',
      'price': '₹700',
      'customer': 'Anita Rao',
    },
    {
      'time': '3:00 PM',
      'status': 'booked',
      'price': '₹800',
      'customer': 'Rahul Mehta',
    },
    {
      'time': '4:00 PM',
      'status': 'booked',
      'price': '₹800',
      'customer': 'Suresh Kumar',
    },
    {
      'time': '5:00 PM',
      'status': 'available',
      'price': '₹800',
      'customer': null,
    },
    {
      'time': '6:00 PM',
      'status': 'booked',
      'price': '₹900',
      'customer': 'Neha Gupta',
    },
    {
      'time': '7:00 PM',
      'status': 'available',
      'price': '₹900',
      'customer': null,
    },
    {
      'time': '8:00 PM',
      'status': 'booked',
      'price': '₹1000',
      'customer': 'Amit Sharma',
    },
  ];

  List<String> days = [
    'Today',
    'Tomorrow',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  int selectedDay = 0;

  // Filter states
  String _selectedFilter = 'all'; // all, available, booked, blocked
  bool _isTurfDisabled = false;

  // Emergency disable duration
  String? _selectedDisableDuration;
  List<String> disableOptions = [
    'Today only',
    '2 days',
    '1 week',
    '2 weeks',
    '1 month',
    'Until further notice',
  ];

  // Helper method to safely extract turf properties
  String _getTurfProperty(String key, String defaultValue) {
    if (widget.turf == null) return defaultValue;

    // Try to access as map first
    if (widget.turf is Map) {
      final value = (widget.turf as Map)[key];
      return value?.toString() ?? defaultValue;
    }

    // Try to access as object using reflection-like approach
    try {
      // For AdminTurf object
      switch (key) {
        case 'name':
          return widget.turf.name?.toString() ?? defaultValue;
        case 'location':
          return widget.turf.location?.toString() ?? defaultValue;
        case 'price':
          return widget.turf.price?.toString() ?? defaultValue;
        case 'rating':
          return widget.turf.rating?.toString() ?? defaultValue;
        case 'images':
          return widget.turf.images?.isNotEmpty == true
              ? widget.turf.images[0]?.toString() ?? ''
              : '';
        default:
          return defaultValue;
      }
    } catch (e) {
      return defaultValue;
    }
  }

  void _toggleSlotStatus(int index) {
    setState(() {
      if (slots[index]['status'] == 'available') {
        slots[index]['status'] = 'blocked';
      } else if (slots[index]['status'] == 'blocked') {
        slots[index]['status'] = 'available';
      }
      // Can't toggle booked slots
    });
  }

  void _toggleTurfStatus() {
    if (_isTurfDisabled) {
      // Re-enable turf
      setState(() {
        _isTurfDisabled = false;
        _selectedDisableDuration = null;
        // Also unblock all slots that were blocked due to turf disable
        for (var slot in slots) {
          if (slot['status'] == 'blocked' && slot['customer'] == null) {
            slot['status'] = 'available';
          }
        }
      });
    } else {
      // Check if there are any upcoming bookings
      bool hasUpcomingBookings = slots.any(
        (slot) => slot['status'] == 'booked' && slot['customer'] != null,
      );

      if (hasUpcomingBookings) {
        _showCannotDisableDialog();
      } else {
        _showDisableOptionsDialog();
      }
    }
  }

  void _showCannotDisableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cannot Disable Turf'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'You cannot disable this turf because there are upcoming bookings.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Please complete all existing bookings or wait until they are finished before disabling.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDisableOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Disable Turf Temporarily'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select disable duration:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                ...disableOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedDisableDuration,
                    onChanged: (value) {
                      setState(() {
                        _selectedDisableDuration = value;
                      });
                    },
                  );
                }).toList(),
                if (_selectedDisableDuration != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Note: All available slots will be blocked during this period.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _selectedDisableDuration != null
                    ? () {
                        setState(() {
                          _isTurfDisabled = true;
                          // Block all available slots
                          for (var slot in slots) {
                            if (slot['status'] == 'available') {
                              slot['status'] = 'blocked';
                            }
                          }
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Turf disabled for $_selectedDisableDuration',
                            ),
                            backgroundColor: Color(0xFF00C853),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C853),
                ),
                child: Text('Disable Turf'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Get filtered slots based on selected filter
  List<Map<String, dynamic>> get filteredSlots {
    if (_selectedFilter == 'all') return slots;
    return slots.where((slot) => slot['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    int availableCount = slots.where((s) => s['status'] == 'available').length;
    int bookedCount = slots.where((s) => s['status'] == 'booked').length;
    int blockedCount = slots.where((s) => s['status'] == 'blocked').length;

    // Use helper method to safely extract turf properties
    String turfName = _getTurfProperty('name', 'Slot Management');
    String turfLocation = _getTurfProperty('location', '');
    String turfImage = _getTurfProperty('images', '');
    String turfPrice = _getTurfProperty('price', '0');
    String turfRating = _getTurfProperty('rating', '0.0');

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              turfName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            if (turfLocation.isNotEmpty)
              Text(
                turfLocation,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
        backgroundColor: Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Turf Info Card (if turf is provided)
          if (widget.turf != null)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (turfImage.isNotEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(turfImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.stadium, color: Colors.grey[500]),
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turfName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (turfLocation.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                turfLocation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
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
                        '₹${turfPrice}/hr',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 2),
                          Text(turfRating, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Date Selector
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Date Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: () {},
                    ),
                    Column(
                      children: [
                        Text(
                          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_selectedDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: () {},
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Quick Day Selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(days.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = index;
                            // Update date logic here
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selectedDay == index
                                ? Color(0xFF00C853)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedDay == index
                                  ? Color(0xFF00C853)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedDay == index
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: selectedDay == index
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Slot Stats and Filters
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Slot Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSlotStat(
                      'Available',
                      availableCount,
                      Color(0xFF00C853),
                      Icons.check_circle,
                    ),
                    _buildSlotStat(
                      'Booked',
                      bookedCount,
                      Color(0xFFFF9800),
                      Icons.event_available,
                    ),
                    _buildSlotStat(
                      'Blocked',
                      blockedCount,
                      Color(0xFFF44336),
                      Icons.block,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      SizedBox(width: 8),
                      _buildFilterChip('Available', 'available'),
                      SizedBox(width: 8),
                      _buildFilterChip('Booked', 'booked'),
                      SizedBox(width: 8),
                      _buildFilterChip('Blocked', 'blocked'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Emergency Disable Switch
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _isTurfDisabled ? Icons.warning : Icons.safety_check,
                  color: _isTurfDisabled ? Colors.red : Colors.green,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTurfDisabled
                            ? 'Turf is Disabled'
                            : 'Emergency Disable',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isTurfDisabled ? Colors.red : Colors.black87,
                        ),
                      ),
                      Text(
                        _isTurfDisabled
                            ? 'Users cannot see or book this turf'
                            : 'Temporarily disable turf for maintenance',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isTurfDisabled,
                  onChanged: (value) => _toggleTurfStatus(),
                  activeColor: Colors.red,
                ),
              ],
            ),
          ),

          // Slot List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredSlots.length,
              itemBuilder: (context, index) {
                final slot = filteredSlots[index];
                return _buildSlotItem(slot, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotStat(String title, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Color(0xFF00C853),
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : Colors.grey[700],
      ),
    );
  }

  Widget _buildSlotItem(Map<String, dynamic> slot, int index) {
    Color statusColor = slot['status'] == 'available'
        ? Colors.green
        : slot['status'] == 'booked'
        ? Colors.orange
        : Colors.red;
    IconData statusIcon = slot['status'] == 'available'
        ? Icons.check_circle
        : slot['status'] == 'booked'
        ? Icons.event_available
        : Icons.block;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot['time'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                slot['price'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00C853),
                ),
              ),
            ],
          ),
          Spacer(),
          if (slot['customer'] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  slot['customer']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Text(
                    'BOOKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      SizedBox(width: 6),
                      Text(
                        slot['status'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                if (slot['status'] != 'booked')
                  Switch(
                    value: slot['status'] == 'available',
                    onChanged: _isTurfDisabled
                        ? null
                        : (value) => _toggleSlotStatus(index),
                    activeColor: Color(0xFF00C853),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    List<String> months = [
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
}
