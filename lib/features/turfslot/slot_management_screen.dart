// slot_management_screen.dart - PREMIUM ADMIN UI WITH ADVANCED FEATURES
import 'package:flutter/material.dart';
import '../../services/offer_slot_service.dart';
import '../../services/turf_data_service.dart';
import '../../models/booking.dart';

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
  bool _emergencyMode = false;
  DateTime? _emergencyStartDate;
  DateTime? _emergencyEndDate;
  String _emergencyReason = '';
  List<String> _offerSlots = []; // Loaded from service

  // Slot data
  List<Map<String, dynamic>> slots = [];

  // Colors
  final Color _primary = const Color(0xFF00C853);
  final Color _accent = const Color(0xFFFF9800);
  final Color _danger = const Color(0xFFF44336);
  final Color _success = const Color(0xFF4CAF50);
  final Color _warning = const Color(0xFFFFB74D);
  final Color _offerColor = const Color(0xFF9C27B0);
  final Color _bg = const Color(0xFFF8F9FA);
  final Color _card = Colors.white;
  final Color _textPrimary = const Color(0xFF1A1A1A);
  final Color _textSecondary = const Color(0xFF666666);
  final Color _disabledColor = const Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadOfferSlots();
  }

  Future<void> _loadOfferSlots() async {
    final offerSlots = await OfferSlotService.getOfferSlots();
    if (mounted) {
      setState(() {
        _offerSlots = offerSlots;
      });
      _generateSlots();
    }
  }
  
  void _generateSlots() {
    final turfName = widget.turf?.name ?? '';
    final List<Map<String, dynamic>> saved = TurfDataService().getSavedSlots(turfName, _selectedDate) ?? [];
    
    // Get bookings for this turf and date for real-time reconciliation
    final bookings = TurfDataService().bookings.where((b) => 
      b.turfName == turfName && 
      b.date.year == _selectedDate.year &&
      b.date.month == _selectedDate.month &&
      b.date.day == _selectedDate.day &&
      b.status != BookingStatus.cancelled
    ).toList();

    if (saved.isNotEmpty) {
      setState(() {
        // Load saved slots and reconcile status with real bookings
        slots = saved.map((s) {
          final slotMap = Map<String, dynamic>.from(s);
          // Re-check booking status
          Booking? booking;
          final matchingBookings = bookings.where(
            (b) => '${b.startTime} - ${b.endTime}' == slotMap['time']
          ).toList();
          
          if (matchingBookings.isNotEmpty) {
            booking = matchingBookings.first;
            slotMap['status'] = 'booked';
            slotMap['customer'] = booking.userName;
            slotMap['userPhone'] = booking.userPhone;
            slotMap['bookingId'] = booking.bookingId;
          } else if (slotMap['status'] == 'booked') {
            // If it was booked but now booking is gone, set to available
            slotMap['status'] = 'available';
            slotMap['customer'] = null;
            slotMap['bookingId'] = null;
          }
          return slotMap;
        }).toList();
      });
      return;
    }
    
    final List<Map<String, dynamic>> newSlots = [];
    final defaultPrice = widget.turf?.price ?? 500;
    
    // Generate slots from 6 AM to 1 AM next day
    for (int hour = 6; hour <= 23; hour++) {
      _addSlot(hour, newSlots, bookings, defaultPrice);
    }
    
    // Midnight slot
    _addSlot(0, newSlots, bookings, defaultPrice);

    setState(() {
      slots = newSlots;
    });
    
    // Save generated defaults
    TurfDataService().saveSlots(turfName, _selectedDate, slots);
  }

  void _addSlot(int hour, List<Map<String, dynamic>> slotList, List<dynamic> bookings, int defaultPrice) {
    bool isAM = hour < 12;
    String period = isAM ? 'AM' : 'PM';
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    int nextHour = hour + 1;
    if (nextHour == 24) nextHour = 0;
    bool nextIsAM = nextHour < 12;
    String nextPeriod = nextIsAM ? 'AM' : 'PM';
    int nextDisplayHour = nextHour > 12 ? nextHour - 12 : (nextHour == 0 ? 12 : nextHour);

    String startTime = '$displayHour:00 $period';
    String endTime = '$nextDisplayHour:00 $nextPeriod';
    String timeKey = '$startTime - $endTime';
    
    // Check if booked
    Booking? booking;
    final matchingBookings = bookings.where(
      (b) => '${b.startTime} - ${b.endTime}' == timeKey
    ).toList();
    
    if (matchingBookings.isNotEmpty) {
      booking = matchingBookings.first as Booking;
    }

    bool isBooked = booking != null;

    bool isEmergencyForDate = _emergencyMode;
    if (_emergencyMode &&
        _emergencyStartDate != null &&
        _emergencyEndDate != null) {
      DateTime date = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      DateTime start = DateTime(
        _emergencyStartDate!.year,
        _emergencyStartDate!.month,
        _emergencyStartDate!.day,
      );
      DateTime end = DateTime(
        _emergencyEndDate!.year,
        _emergencyEndDate!.month,
        _emergencyEndDate!.day,
      );

      isEmergencyForDate =
          (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
          (date.isAtSameMomentAs(end) || date.isBefore(end));
    }

    slotList.add({
      'time': timeKey, // Fixed format for compatibility
      'startTime': startTime,
      'endTime': endTime,
      'status': isBooked ? 'booked' : 'available',
      'price': defaultPrice,
      'customer': isBooked ? (booking?.userName ?? 'Unknown') : null,
      'userPhone': isBooked ? (booking?.userPhone ?? '') : null,
      'bookingId': isBooked ? (booking?.bookingId ?? '') : null,
      'disabled': isEmergencyForDate,
      'originalPrice': defaultPrice,
      'date': _selectedDate,
    });
  }

  // Calculate stats
  int get availableCount =>
      slots.where((s) => s['status'] == 'available').length;
  int get bookedCount => slots.where((s) => s['status'] == 'booked').length;
  int get blockedCount => slots.where((s) => s['disabled'] == true).length;
  int get offerCount =>
      slots.where((s) => _offerSlots.contains(s['time'])).length;

  String get revenue {
    int total = 0;
    for (var slot in slots) {
      if (slot['status'] == 'booked') {
        total += slot['price'] as int;
      }
    }
    return '₹$total';
  }

  // Helper methods
  Color _getStatusColor(Map<String, dynamic> slot) {
    if (slot['disabled'] == true) return _disabledColor;
    if (_offerSlots.contains(slot['time'])) return _offerColor;
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
    if (_offerSlots.contains(slot['time'])) return 'OFFER';
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
    if (_offerSlots.contains(slot['time'])) return Icons.local_offer;
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
    // Save the updated slots list
    final turfName = widget.turf?.name ?? '';
    TurfDataService().saveSlots(turfName, _selectedDate, slots);
  }

  void _toggleEmergencyMode() {
    if (_emergencyMode) {
      // Show confirmation dialog before turning off emergency mode
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable Emergency Mode'),
          content: const Text(
            'Are you sure you want to turn off emergency mode? All disabled slots will be enabled again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
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
                  // Save the updated slots list
                  final turfName = widget.turf?.name ?? '';
                  TurfDataService().saveSlots(turfName, _selectedDate, slots);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Emergency mode disabled'),
                    backgroundColor: _success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Disable'),
            ),
          ],
        ),
      );
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

  Future<void> _toggleOfferSlot(int index) async {
    final slot = slots[index];

    if (_offerSlots.contains(slot['time'])) {
      // Remove offer
      await _removeOfferSlot(index);
    } else {
      // Show offer dialog
      await _showSetOfferDialog(index);
    }

    // Refresh offer slots
    await _loadOfferSlots();
  }

  Future<void> _removeOfferSlot(int index) async {
    final slot = slots[index];
    final originalPrice = slot['originalPrice'] ?? slot['price'];

    setState(() {
      slots[index]['price'] = originalPrice;
    });

    await OfferSlotService.removeOfferSlot(slot['time']);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer removed for ${slot['time']} slot'),
          backgroundColor: _offerColor,
        ),
      );
    }
  }

  Future<void> _showSetOfferDialog(int index) async {
    final slot = slots[index];
    final originalPrice = slot['originalPrice'] ?? slot['price'];
    TextEditingController offerPriceController = TextEditingController(
      text: slot['price'].toString(),
    );
    TextEditingController offerPercentageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void updateOfferPrice(String percentage) {
            if (percentage.isEmpty) return;
            double percent = double.parse(percentage);
            double discountedPrice = originalPrice * (1 - (percent / 100));
            offerPriceController.text = discountedPrice.round().toString();
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.local_offer, color: _offerColor),
                const SizedBox(width: 10),
                const Text('Set Offer for Slot'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot['time']} - ${slot['endTime']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Original Price: ₹$originalPrice',
                    style: TextStyle(fontSize: 14, color: _textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Discount Percentage
                  Text(
                    'Discount Percentage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: offerPercentageController,
                    decoration: InputDecoration(
                      hintText: 'Enter discount %',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: updateOfferPrice,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['10', '20', '30', '50'].map((percent) {
                      return OutlinedButton(
                        onPressed: () {
                          offerPercentageController.text = percent;
                          updateOfferPrice(percent);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _offerColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          '$percent%',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Offer Price
                  Text(
                    'Offer Price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: offerPriceController,
                    decoration: InputDecoration(
                      hintText: 'Enter offer price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  if (offerPriceController.text.isNotEmpty)
                    Text(
                      'You are offering ${((originalPrice - int.parse(offerPriceController.text)) / originalPrice * 100).toStringAsFixed(1)}% discount',
                      style: TextStyle(fontSize: 12, color: _offerColor),
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
                onPressed: () async {
                  final offerPrice =
                      int.tryParse(offerPriceController.text) ?? originalPrice;
                  if (offerPrice >= originalPrice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Offer price must be less than original price',
                        ),
                        backgroundColor: _danger,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    slots[index]['price'] = offerPrice;
                  });
                  await OfferSlotService.addOfferSlot(
                    slot['time'],
                    offerPrice,
                    originalPrice,
                  );
                  await _loadOfferSlots();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Offer set for ${slot['time']} slot'),
                        backgroundColor: _offerColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _offerColor),
                child: const Text('Set Offer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEmergencyDateRangeDialog() {
    DateTime tempStartDate = DateTime.now();
    DateTime tempEndDate = DateTime.now().add(const Duration(days: 7));
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
                  const Text(
                    'Disable all available slots for the selected date range:',
                  ),
                  const SizedBox(height: 20),

                  // Start Date
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      '${tempStartDate.day} ${_getMonthName(tempStartDate.month)} ${tempStartDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
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
                  ),

                  // End Date
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      '${tempEndDate.day} ${_getMonthName(tempEndDate.month)} ${tempEndDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
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
                  ),

                  const SizedBox(height: 16),

                  // Reason/Description
                  const Text(
                    'Emergency Reason (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter reason...',
                      border: OutlineInputBorder(),
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
                  // Apply emergency mode logic here
                    setState(() {
                    _emergencyMode = true;
                    _emergencyStartDate = tempStartDate;
                    _emergencyEndDate = tempEndDate;
                    _emergencyReason = tempReason;
                    // Note: In a real app this would call an API
                    // For now we just update local state which affects _generateSlots
                  });
                  Navigator.pop(context);
                  this.setState(() {
                     _generateSlots(); // Regenerate slots to reflect disabled status
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Emergency mode enabled'),
                      backgroundColor: _danger,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enable Emergency'),
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filters',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Filter slots by date and status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Range Section
                          Text(
                            'DATE RANGE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                              letterSpacing: 1,
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
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
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
                                        'Start Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${tempStartDate.day} ${_getMonthName(tempStartDate.month)} ${tempStartDate.year}',
                                        style: TextStyle(
                                          fontSize: 16,
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
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null && picked != tempEndDate) {
                                setState(() {
                                  tempEndDate = picked;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
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
                                        'End Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${tempEndDate.day} ${_getMonthName(tempEndDate.month)} ${tempEndDate.year}',
                                        style: TextStyle(
                                          fontSize: 16,
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

                          // Quick Date Range Buttons
                          Text(
                            'QUICK RANGE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  tempStartDate = DateTime.now();
                                  tempEndDate = DateTime.now();
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  tempStartDate = DateTime.now();
                                  tempEndDate = DateTime.now().add(
                                    const Duration(days: 6),
                                  );
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    '7 Days',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  tempStartDate = DateTime.now();
                                  tempEndDate = DateTime.now().add(
                                    const Duration(days: 29),
                                  );
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    '30 Days',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  tempStartDate = DateTime.now();
                                  tempEndDate = DateTime.now().add(
                                    const Duration(days: 89),
                                  );
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    '90 Days',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Status Filter
                          Text(
                            'SLOT STATUS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // All Slots
                              GestureDetector(
                                onTap: () =>
                                    setState(() => tempSelectedFilter = 'all'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempSelectedFilter == 'all'
                                        ? _primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tempSelectedFilter == 'all'
                                          ? _primary
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'All Slots',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: tempSelectedFilter == 'all'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: tempSelectedFilter == 'all'
                                          ? Colors.white
                                          : _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              // Available
                              GestureDetector(
                                onTap: () => setState(
                                  () => tempSelectedFilter = 'available',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempSelectedFilter == 'available'
                                        ? _primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tempSelectedFilter == 'available'
                                          ? _primary
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          tempSelectedFilter == 'available'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: tempSelectedFilter == 'available'
                                          ? Colors.white
                                          : _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              // Booked
                              GestureDetector(
                                onTap: () => setState(
                                  () => tempSelectedFilter = 'booked',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempSelectedFilter == 'booked'
                                        ? _primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tempSelectedFilter == 'booked'
                                          ? _primary
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Booked',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: tempSelectedFilter == 'booked'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: tempSelectedFilter == 'booked'
                                          ? Colors.white
                                          : _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              // Disabled
                              GestureDetector(
                                onTap: () => setState(
                                  () => tempSelectedFilter = 'disabled',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempSelectedFilter == 'disabled'
                                        ? _primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tempSelectedFilter == 'disabled'
                                          ? _primary
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Disabled',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          tempSelectedFilter == 'disabled'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: tempSelectedFilter == 'disabled'
                                          ? Colors.white
                                          : _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              // Offers
                              GestureDetector(
                                onTap: () => setState(
                                  () => tempSelectedFilter = 'offers',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempSelectedFilter == 'offers'
                                        ? _primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tempSelectedFilter == 'offers'
                                          ? _primary
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Offers',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: tempSelectedFilter == 'offers'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: tempSelectedFilter == 'offers'
                                          ? Colors.white
                                          : _textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = 'all';
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'RESET',
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
                                _startDate = tempStartDate;
                                _endDate = tempEndDate;
                                _selectedFilter = tempSelectedFilter;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'APPLY',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddSlotDialog() {
    TimeOfDay selectedTime = const TimeOfDay(hour: 4, minute: 0);
    String price = '500';
    bool isDisabled = false;
    DateTime selectedDate = _selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    physics: const ClampingScrollPhysics(),
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
                              // Time Selection - Made wider
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
                                  final TimeOfDay?
                                  picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                    builder: (context, child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false,
                                        ),
                                        child: Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: _primary,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: _textPrimary,
                                            ),
                                            timePickerTheme:
                                                TimePickerThemeData(
                                                  backgroundColor: Colors.white,
                                                ),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() => selectedTime = picked);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                    20,
                                  ), // Increased padding
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
                                      Expanded(
                                        child: Column(
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
                                            const SizedBox(height: 6),
                                            Text(
                                              selectedTime.format(context),
                                              style: TextStyle(
                                                fontSize:
                                                    28, // Increased font size
                                                fontWeight: FontWeight.w700,
                                                color: _textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Slot will be: ${selectedTime.format(context)} - ${_calculateEndTime(selectedTime).format(context)}',
                                              style: TextStyle(
                                                fontSize:
                                                    13, // Increased font size
                                                color: _textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 56, // Increased size
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: _primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.access_time,
                                          color: _primary,
                                          size: 28, // Increased icon size
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Date Selection
                              Text(
                                'SELECT DATE',
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
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null &&
                                      picked != selectedDate) {
                                    setState(() => selectedDate = picked);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
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
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: _primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            _isSameDate(
                                                  selectedDate,
                                                  DateTime.now(),
                                                )
                                                ? 'Today'
                                                : _formatDate(selectedDate),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.edit, color: _textSecondary),
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
                                  vertical: 12, // Increased padding
                                ),
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '₹',
                                      style: TextStyle(
                                        fontSize: 28, // Increased font size
                                        fontWeight: FontWeight.w700,
                                        color: _primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
                                          fontSize: 28, // Increased font size
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
                                        fontSize: 16, // Increased font size
                                        color: _textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Status Toggle
                              Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ), // Increased padding
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
                                    Expanded(
                                      child: Column(
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
                                          const SizedBox(height: 6),
                                          Text(
                                            isDisabled
                                                ? 'Disabled'
                                                : 'Available',
                                            style: TextStyle(
                                              fontSize:
                                                  18, // Increased font size
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
                                              fontSize:
                                                  13, // Increased font size
                                              color: _textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 1.3, // Increased switch size
                                      child: Switch(
                                        value: !isDisabled,
                                        onChanged: (value) {
                                          setState(() => isDisabled = !value);
                                        },
                                        activeColor: _success,
                                        inactiveThumbColor: _disabledColor,
                                        activeTrackColor: _success.withOpacity(
                                          0.3,
                                        ),
                                        inactiveTrackColor: _disabledColor
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Preview
                              Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ), // Increased padding
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
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${selectedTime.format(context)} - ${_calculateEndTime(selectedTime).format(context)}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize:
                                                      20, // Increased font size
                                                  fontWeight: FontWeight.w700,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text(
                                                    '₹$price/hour',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          16, // Increased font size
                                                      color: _primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                120, // Increased max width
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  16, // Increased padding
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDisabled
                                                  ? _danger.withOpacity(0.1)
                                                  : _success.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isDisabled
                                                    ? _danger.withOpacity(0.3)
                                                    : _success.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isDisabled
                                                      ? Icons.block
                                                      : Icons.check_circle,
                                                  size:
                                                      16, // Increased icon size
                                                  color: isDisabled
                                                      ? _danger
                                                      : _success,
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    isDisabled
                                                        ? 'DISABLED'
                                                        : 'AVAILABLE',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          13, // Increased font size
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isDisabled
                                                          ? _danger
                                                          : _success,
                                                    ),
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
                              const SizedBox(height: 24),

                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18, // Increased padding
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'CANCEL',
                                        style: TextStyle(
                                          fontSize: 16, // Increased font size
                                          fontWeight: FontWeight.w600,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ), // Increased spacing
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          slots.add({
                                            'time': selectedTime.format(
                                              context,
                                            ),
                                            'endTime': _calculateEndTime(
                                              selectedTime,
                                            ).format(context),
                                            'date': selectedDate,
                                            'status': 'available',
                                            'price': int.parse(price),
                                            'customer': null,
                                            'bookingId': null,
                                            'disabled': isDisabled,
                                            'originalPrice': int.parse(price),
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
                                          // Save the updated slots list
                                          final turfName = widget.turf?.name ?? '';
                                          TurfDataService().saveSlots(turfName, _selectedDate, slots);
                                        });
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18, // Increased padding
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add, size: 22),
                                          const SizedBox(width: 10),
                                          Text(
                                            'ADD SLOT',
                                            style: TextStyle(
                                              fontSize:
                                                  16, // Increased font size
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
              _buildDetailRow('Price', '₹${slot['price']}'),
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

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
        : _selectedFilter == 'disabled'
        ? slots.where((slot) => slot['disabled'] == true).toList()
        : _selectedFilter == 'offers'
        ? slots.where((slot) => _offerSlots.contains(slot['time'])).toList()
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
            tooltip: 'Filters',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date Selector
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calendar_month, color: _primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _generateSlots();
                      }
                    },
                    icon: const Icon(Icons.edit_calendar),
                    color: _primary,
                    tooltip: 'Change Date',
                  ),
                ],
              ),
            ),

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
                  _buildCompactStatCard(
                    'Offers',
                    '$offerCount',
                    Icons.local_offer,
                    _offerColor,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${filteredSlots.length} slots',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
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
    bool hasOffer = _offerSlots.contains(slot['time']);

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
                      // Time with inline Date badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${slot['time']} - ${slot['endTime']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDisabled
                                    ? _disabledColor
                                    : _textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // Date badge inline with time
                          if (slot.containsKey('date') && slot['date'] != null)
                            Builder(
                              builder: (context) {
                                DateTime? slotDate;
                                if (slot['date'] is DateTime) {
                                  slotDate = slot['date'] as DateTime;
                                } else if (slot['date'] is String) {
                                  try {
                                    slotDate = DateTime.parse(slot['date']);
                                  } catch (_) {
                                    slotDate = null;
                                  }
                                }
                                if (slotDate == null) return const SizedBox();
                                final bool isToday = _isSameDate(
                                  slotDate,
                                  DateTime.now(),
                                );
                                final bool isTomorrow = _isSameDate(
                                  slotDate,
                                  DateTime.now().add(const Duration(days: 1)),
                                );

                                String dateLabel;
                                Color badgeColor;

                                if (isToday) {
                                  dateLabel = 'Today';
                                  badgeColor = _primary;
                                } else if (isTomorrow) {
                                  dateLabel = 'Tomorrow';
                                  badgeColor = Colors.orange;
                                } else {
                                  dateLabel = _formatDate(slotDate);
                                  badgeColor = Colors.blue;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: badgeColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    dateLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: badgeColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${slot['price']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: hasOffer
                                  ? _offerColor
                                  : (isDisabled ? _disabledColor : _primary),
                            ),
                          ),
                          if (hasOffer && slot['originalPrice'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                '₹${slot['originalPrice']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  constraints: const BoxConstraints(maxWidth: 150),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(slot), size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getStatusLabel(slot),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
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
                          slot['customer'] ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking ID: ${slot['bookingId']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => _showBookingDetails(slot),
                    icon: Icon(Icons.chevron_right, color: _textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else ...[
                  Icon(
                    hasOffer
                        ? Icons.local_offer
                        : (isDisabled ? Icons.block : Icons.lock_open),
                    size: 18,
                    color: hasOffer
                        ? _offerColor
                        : (isDisabled ? _disabledColor : _success),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasOffer
                              ? 'Special offer available'
                              : (isDisabled
                                    ? 'Slot is disabled'
                                    : 'Slot is available for booking'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: hasOffer
                                ? _offerColor
                                : (isDisabled
                                      ? _disabledColor
                                      : _textSecondary),
                          ),
                        ),
                        if (isDisabled && _emergencyMode)
                          Text(
                            'Emergency: ${_formatEmergencyDateRange()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: _danger),
                          ),
                      ],
                    ),
                  ),

                  // Set Offer Button (only for available slots)
                  if (isAvailable && !isDisabled)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleOfferSlot(index),
                        icon: Icon(
                          hasOffer
                              ? Icons.local_offer
                              : Icons.local_offer_outlined,
                          size: 16,
                        ),
                        label: Text(
                          hasOffer ? 'Remove Offer' : 'Set Offer',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasOffer
                              ? _offerColor.withOpacity(0.1)
                              : _offerColor,
                          foregroundColor: hasOffer
                              ? _offerColor
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // Switch for enabling/disabling
                  Container(
                    width: 50,
                    child: Switch(
                      value: !isDisabled,
                      onChanged: isBooked
                          ? null
                          : (value) => _toggleSlotDisabled(index, !value),
                      activeColor: _success,
                      inactiveThumbColor: _disabledColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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
