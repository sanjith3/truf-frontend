// features/turfslot/slot_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/turf.dart';
import '../../services/turf_data_service.dart';
import '../../services/api_service.dart';
import '../../models/booking.dart';

// ------------------------------------------------------------
// Shared time utility — single source of truth
// ------------------------------------------------------------
bool isSlotPast(DateTime selectedDate, String slotTime) {
  final startStr = slotTime.split(' - ')[0].trim();
  final parts = startStr.split(' ');
  if (parts.length < 2) return false;

  final timeParts = parts[0].split(':');
  final period = parts[1]; // AM or PM
  int hour = int.tryParse(timeParts[0]) ?? 0;
  final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  final now = DateTime.now();
  final slotDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    hour,
    minute,
  );

  return slotDateTime.isBefore(now);
}

// ------------------------------------------------------------
// AdminTimeSlot – simplified model
// ------------------------------------------------------------
class AdminTimeSlot {
  final String time;
  final int? slotId;
  final bool isBooked;
  bool isDisabled;
  bool hasOffer;
  final double basePrice;
  final bool isPast;

  String? offerType;
  double? offerValue;

  AdminTimeSlot({
    required this.time,
    this.slotId,
    required this.isBooked,
    required this.isDisabled,
    required this.hasOffer,
    required this.basePrice,
    this.isPast = false,
    this.offerType,
    this.offerValue,
  });

  bool get isAvailable => !isBooked && !isDisabled && !isPast;
  double get effectivePrice => basePrice;

  AdminTimeSlot copyWith({
    bool? isDisabled,
    bool? hasOffer,
    String? offerType,
    double? offerValue,
  }) {
    return AdminTimeSlot(
      time: time,
      slotId: slotId,
      isBooked: isBooked,
      isDisabled: isDisabled ?? this.isDisabled,
      hasOffer: hasOffer ?? this.hasOffer,
      basePrice: basePrice,
      isPast: isPast,
      offerType: offerType ?? this.offerType,
      offerValue: offerValue ?? this.offerValue,
    );
  }
}

// ------------------------------------------------------------
// Main SlotManagementScreen
// ------------------------------------------------------------
class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  final TurfDataService _turfService = TurfDataService();

  List<Turf> _allTurfs = [];
  Turf? _selectedTurf;

  DateTime _selectedDate = DateTime.now();
  List<AdminTimeSlot> _timeSlots = [];

  bool _isLoading = false;
  String _filterOption = 'all';

  @override
  void initState() {
    super.initState();
    _loadTurfs();
  }

  // ------------------------------------------------------------
  // Data loading
  // ------------------------------------------------------------
  Future<void> _loadTurfs() async {
    setState(() => _isLoading = true);
    _allTurfs = await _turfService.getAllTurfs();
    if (_allTurfs.isNotEmpty) {
      _selectedTurf = _allTurfs.first;
      _loadSlotsForDate(_selectedDate);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadSlotsForDate(DateTime date) async {
    if (_selectedTurf == null) return;
    setState(() => _isLoading = true);

    final turf = _selectedTurf!;
    final api = ApiService();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final res = await api.getAuth(
        '/api/bookings/bookings/availability/?turf_id=${turf.id}&date=$dateStr',
      );

      if (res['success'] == true && res['slots'] != null) {
        final List<AdminTimeSlot> slots = [];
        for (final s in res['slots']) {
          final startTime = _convertTo12Hour(s['start_time'] ?? '');
          final endTime = _convertTo12Hour(s['end_time'] ?? '');
          final slotTime = '$startTime - $endTime';

          final status = s['status'] ?? 'available';
          final slotId = s['slot_id'];

          slots.add(
            AdminTimeSlot(
              time: slotTime,
              slotId: slotId is int ? slotId : int.tryParse(slotId.toString()),
              isBooked: status == 'booked',
              isDisabled: status == 'disabled',
              hasOffer: s['has_offer'] == true,
              basePrice:
                  double.tryParse(s['original_price']?.toString() ?? '0') ??
                  turf.price.toDouble(),
              isPast: status == 'past',
              offerType: s['offer_type'],
              offerValue: s['offer_value'] != null
                  ? double.tryParse(s['offer_value'].toString())
                  : null,
            ),
          );
        }

        setState(() {
          _timeSlots = slots;
          _isLoading = false;
        });
      } else {
        _loadSlotsFromLocalData(date);
      }
    } catch (e) {
      debugPrint('Error loading slots from API: $e');
      _loadSlotsFromLocalData(date);
    }
  }

  String _convertTo12Hour(String time24) {
    final parts = time24.split(':');
    if (parts.length < 2) return time24;
    int hour = int.tryParse(parts[0]) ?? 0;
    final min = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:$min $period';
  }

  void _loadSlotsFromLocalData(DateTime date) {
    final turf = _selectedTurf!;
    final turfName = turf.name;

    final bookings = _turfService.bookings
        .where(
          (b) =>
              b.turfName == turfName &&
              b.date.year == date.year &&
              b.date.month == date.month &&
              b.date.day == date.day &&
              b.status != BookingStatus.cancelled,
        )
        .toList();

    final bookedSlotTimes = bookings
        .map((b) => "${b.startTime} - ${b.endTime}")
        .toSet();
    final savedSlots = _turfService.getSavedSlots(turfName, date) ?? [];
    final allPossibleSlots = _generateAllTimeSlots();
    final List<AdminTimeSlot> slots = [];

    for (final slotTime in allPossibleSlots) {
      final saved = savedSlots.firstWhere(
        (s) => s['time'] == slotTime,
        orElse: () => <String, dynamic>{},
      );

      final isBooked = bookedSlotTimes.contains(slotTime);
      final isDisabled = saved.isNotEmpty ? saved['disabled'] == true : false;
      final hasOffer = saved.isNotEmpty ? saved['offer'] == true : false;
      final basePrice = saved.isNotEmpty && saved.containsKey('price')
          ? (saved['price'] as num).toDouble()
          : turf.price.toDouble();

      slots.add(
        AdminTimeSlot(
          time: slotTime,
          isBooked: isBooked,
          isDisabled: isDisabled,
          hasOffer: hasOffer,
          basePrice: basePrice,
          isPast: isSlotPast(_selectedDate, slotTime),
        ),
      );
    }

    setState(() {
      _timeSlots = slots;
      _isLoading = false;
    });
  }

  List<String> _generateAllTimeSlots() {
    final List<String> slots = [];
    for (int hour = 6; hour <= 23; hour++) slots.add(_formatSlot(hour));
    for (int hour = 0; hour <= 5; hour++) slots.add(_formatSlot(hour));
    return slots;
  }

  String _formatSlot(int hour) {
    final nextHour = (hour + 1) % 24;
    return '${_formatTime(hour)} - ${_formatTime(nextHour)}';
  }

  String _formatTime(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  // ------------------------------------------------------------
  // Slot Dialog — Disable toggle + Offer toggle
  // ------------------------------------------------------------
  Future<void> _showSlotDialog(AdminTimeSlot slot) async {
    if (slot.isPast) {
      _showSnackBar('Past slots cannot be modified', isError: true);
      return;
    }

    if (slot.isBooked) {
      _showSnackBar('Booked slots cannot be modified', isError: true);
      return;
    }

    if (_selectedTurf == null || slot.slotId == null) {
      debugPrint('DEBUG: turfId=${_selectedTurf?.id}, slotId=${slot.slotId}');
      _showSnackBar('Missing turf or slot info', isError: true);
      return;
    }

    // State for the dialog
    bool slotDisabled = slot.isDisabled;
    bool offerEnabled = slot.hasOffer;

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text('Manage Slot: ${slot.time}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.today, size: 16),
                            const SizedBox(width: 8),
                            Text('Date: ${_formatDate(_selectedDate)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Base Price:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '₹${slot.basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Disable Slot toggle ---
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      slotDisabled ? 'Slot Disabled' : 'Disable Slot',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: slotDisabled ? Colors.red : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      slotDisabled
                          ? 'This slot is currently disabled'
                          : 'Turn ON to prevent bookings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    secondary: Icon(
                      slotDisabled ? Icons.block : Icons.check_circle,
                      color: slotDisabled ? Colors.red : Colors.green,
                    ),
                    value: slotDisabled,
                    onChanged: (val) {
                      setDialogState(() => slotDisabled = val);
                    },
                    activeColor: Colors.red,
                  ),

                  const Divider(),

                  // --- Enable Offer toggle ---
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Enable Offer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: offerEnabled
                            ? Colors.deepOrange
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      offerEnabled
                          ? 'Offer is active on this slot'
                          : 'Add a discount offer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    secondary: Icon(
                      Icons.local_offer,
                      color: offerEnabled ? Colors.deepOrange : Colors.grey,
                    ),
                    value: offerEnabled,
                    onChanged: slotDisabled
                        ? null // Can't set offer on disabled slot
                        : (val) {
                            setDialogState(() => offerEnabled = val);
                          },
                    activeColor: Colors.deepOrange,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);

                  final disableChanged = slotDisabled != slot.isDisabled;
                  final offerChanged = offerEnabled != slot.hasOffer;

                  // 1. Handle disable toggle
                  if (disableChanged) {
                    await _executeDisableAction(
                      slot,
                      slotDisabled ? 'disable' : 'enable',
                    );
                  }

                  // 2. Handle offer toggle
                  if (offerChanged && !slotDisabled) {
                    if (offerEnabled) {
                      // Offer turned ON → open offer dialog
                      _showOfferBottomSheet(slot);
                    } else {
                      // Offer turned OFF → call delete_offer
                      await _deleteOffer(slot);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // Offer Bottom Sheet — Swiggy-style
  // ------------------------------------------------------------
  void _showOfferBottomSheet(AdminTimeSlot slot) {
    String selectedOfferType = 'percentage';
    final valueController = TextEditingController();
    DateTime? validUntil;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    const Text(
                      'Create Offer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.time}  •  Base ₹${slot.basePrice.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // --- Offer Type ---
                const Text(
                  'Offer Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _offerTypeChip(
                        label: 'Percentage (%)',
                        isSelected: selectedOfferType == 'percentage',
                        onTap: () {
                          setSheetState(() {
                            selectedOfferType = 'percentage';
                            valueController.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _offerTypeChip(
                        label: 'Flat (₹)',
                        isSelected: selectedOfferType == 'flat',
                        onTap: () {
                          setSheetState(() {
                            selectedOfferType = 'flat';
                            valueController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Value ---
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: selectedOfferType == 'percentage'
                        ? 'Discount % (max 90)'
                        : 'Discount ₹ (max ₹${(slot.basePrice - 1).toStringAsFixed(0)})',
                    prefixIcon: Icon(
                      selectedOfferType == 'percentage'
                          ? Icons.percent
                          : Icons.currency_rupee,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Valid Until (optional) ---
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() => validUntil = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          validUntil != null
                              ? 'Valid Until: ${_formatDate(validUntil!)}'
                              : 'Valid Until (optional)',
                          style: TextStyle(
                            color: validUntil != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Save Button ---
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate value
                      final value = double.tryParse(valueController.text);
                      if (value == null || value <= 0) {
                        _showSnackBar('Enter a valid value', isError: true);
                        return;
                      }

                      if (selectedOfferType == 'percentage' && value > 90) {
                        _showSnackBar('Max percentage is 90%', isError: true);
                        return;
                      }

                      if (selectedOfferType == 'flat' &&
                          value >= slot.basePrice) {
                        _showSnackBar(
                          'Flat discount must be less than ₹${slot.basePrice.toStringAsFixed(0)}',
                          isError: true,
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      await _createOffer(
                        slot,
                        selectedOfferType,
                        value,
                        validUntil,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Offer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _offerTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.deepOrange : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // API: Disable / Enable slot
  // ------------------------------------------------------------
  Future<void> _executeDisableAction(AdminTimeSlot slot, String action) async {
    if (_selectedTurf == null || slot.slotId == null) {
      debugPrint('DEBUG: turfId=${_selectedTurf?.id}, slotId=${slot.slotId}');
      _showSnackBar('Missing turf or slot info', isError: true);
      return;
    }

    final api = ApiService();
    final turfId = _selectedTurf!.id;

    debugPrint('TURF ID: $turfId | SLOT ID: ${slot.slotId} | ACTION: $action');

    try {
      final endpoint = action == 'disable' ? 'disable_slot' : 'enable_slot';
      final res = await api.postAuth(
        '/api/turfs/turfs/$turfId/$endpoint/',
        body: {'slot_id': slot.slotId},
      );

      if (res['success'] == true) {
        setState(() {
          final idx = _timeSlots.indexWhere((s) => s.time == slot.time);
          if (idx != -1) {
            _timeSlots[idx] = slot.copyWith(isDisabled: action == 'disable');
          }
        });
        _showSnackBar(action == 'disable' ? 'Slot disabled' : 'Slot enabled');
      } else {
        _showSnackBar(res['error'] ?? 'Failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  // ------------------------------------------------------------
  // API: Create offer
  // ------------------------------------------------------------
  Future<void> _createOffer(
    AdminTimeSlot slot,
    String offerType,
    double value,
    DateTime? validUntil,
  ) async {
    if (_selectedTurf == null || slot.slotId == null) {
      _showSnackBar('Missing turf or slot info', isError: true);
      return;
    }

    final api = ApiService();
    final turfId = _selectedTurf!.id;
    final now = DateTime.now();
    final validFromStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Default valid_until: 30 days from today if not picked
    final until = validUntil ?? now.add(const Duration(days: 30));
    final validUntilStr =
        '${until.year}-${until.month.toString().padLeft(2, '0')}-${until.day.toString().padLeft(2, '0')}';

    debugPrint(
      'CREATE OFFER: turfId=$turfId slotId=${slot.slotId} '
      'type=$offerType value=$value from=$validFromStr until=$validUntilStr',
    );

    try {
      final res = await api.postAuth(
        '/api/turfs/turfs/$turfId/create_offer/',
        body: {
          'slot_id': slot.slotId,
          'offer_type': offerType,
          'value': value,
          'valid_from': validFromStr,
          'valid_until': validUntilStr,
        },
      );

      if (res['success'] == true) {
        setState(() {
          final idx = _timeSlots.indexWhere((s) => s.time == slot.time);
          if (idx != -1) {
            _timeSlots[idx] = slot.copyWith(
              hasOffer: true,
              offerType: offerType,
              offerValue: value,
            );
          }
        });
        _showSnackBar('Offer created!');
      } else {
        _showSnackBar(res['error'] ?? 'Failed to create offer', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  // ------------------------------------------------------------
  // API: Delete (deactivate) offer
  // ------------------------------------------------------------
  Future<void> _deleteOffer(AdminTimeSlot slot) async {
    if (_selectedTurf == null || slot.slotId == null) {
      _showSnackBar('Missing turf or slot info', isError: true);
      return;
    }

    final api = ApiService();
    final turfId = _selectedTurf!.id;

    debugPrint('DELETE OFFER: turfId=$turfId slotId=${slot.slotId}');

    try {
      final res = await api.postAuth(
        '/api/turfs/turfs/$turfId/delete_offer/',
        body: {'slot_id': slot.slotId},
      );

      if (res['success'] == true) {
        setState(() {
          final idx = _timeSlots.indexWhere((s) => s.time == slot.time);
          if (idx != -1) {
            _timeSlots[idx] = slot.copyWith(
              hasOffer: false,
              offerType: null,
              offerValue: null,
            );
          }
        });
        _showSnackBar('Offer removed');
      } else {
        _showSnackBar(res['error'] ?? 'Failed to remove offer', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  // ------------------------------------------------------------
  // Stats
  // ------------------------------------------------------------
  int get _bookedCount => _timeSlots.where((s) => s.isBooked).length;
  int get _availableCount => _timeSlots.where((s) => s.isAvailable).length;
  int get _disabledCount =>
      _timeSlots.where((s) => s.isDisabled && !s.isBooked).length;
  int get _offerCount =>
      _timeSlots.where((s) => s.hasOffer && !s.isBooked).length;
  double get _todayRevenue => _timeSlots
      .where((s) => s.isBooked)
      .fold(0.0, (sum, s) => sum + s.effectivePrice);

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------
  int _getHourFromSlotString(String slot) {
    final start = slot.split(' - ')[0].trim();
    final parts = start.split(' ');
    if (parts.length < 2) return 0;
    final hourMin = parts[0];
    final period = parts[1];
    final hour = int.parse(hourMin.split(':')[0]);
    if (period == 'PM' && hour != 12) return hour + 12;
    if (period == 'AM' && hour == 12) return 0;
    return hour;
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  List<DateTime> _getNext30Days() {
    final List<DateTime> days = [];
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      days.add(DateTime(now.year, now.month, now.day + i));
    }
    return days;
  }

  String _getDayName(int weekday) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  String _getMonthName(int month) => [
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
  ][month - 1];

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot Management'),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'disabled', child: Text('Disabled')),
              const PopupMenuItem(value: 'offer', child: Text('Offer')),
            ],
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: _selectedTurf == null
          ? const Center(child: Text('No turfs available'))
          : Column(
              children: [
                _buildTurfSelector(),
                _buildDateSelector(),
                _buildStatsCards(),
                _buildTimeSlotHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTimeSlotGrid(),
                ),
              ],
            ),
    );
  }

  // ------------------------------------------------------------
  // UI Components (unchanged design)
  // ------------------------------------------------------------
  Widget _buildTurfSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Turf>(
          isExpanded: true,
          value: _selectedTurf,
          hint: const Text('Select Turf'),
          items: _allTurfs.map((turf) {
            return DropdownMenuItem<Turf>(
              value: turf,
              child: Row(
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(turf.name, style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
          onChanged: (turf) {
            setState(() => _selectedTurf = turf);
            if (turf != null) _loadSlotsForDate(_selectedDate);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final days = _getNext30Days();
    final today = DateTime.now();
    final normalizedSelected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final normalizedToday = DateTime(today.year, today.month, today.day);

    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        itemBuilder: (ctx, idx) {
          final day = days[idx];
          final isToday = day.isAtSameMomentAs(normalizedToday);
          final isSelected = day.isAtSameMomentAs(normalizedSelected);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = day);
              _loadSlotsForDate(day);
            },
            child: Container(
              width: 65,
              margin: EdgeInsets.only(right: idx == days.length - 1 ? 0 : 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1DB954)
                    : isToday
                    ? Colors.blue.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.green.shade700
                      : isToday
                      ? Colors.blue.shade200
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1DB954).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(day.weekday),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? Colors.blue.shade800
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getMonthName(day.month),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
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

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statCard(
            'Revenue',
            '₹${_todayRevenue.toStringAsFixed(0)}',
            Colors.green,
          ),
          _statCard('Booked', '$_bookedCount', Colors.blue),
          _statCard('Available', '$_availableCount', Colors.orange),
          _statCard('Disabled', '$_disabledCount', Colors.grey),
          _statCard('Offers', '$_offerCount', Colors.red),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            'Manage Time Slots',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              '${_timeSlots.where((s) => s.isAvailable).length} available',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    Iterable<AdminTimeSlot> filtered = _timeSlots;
    if (_filterOption == 'disabled')
      filtered = filtered.where((s) => s.isDisabled);
    if (_filterOption == 'offer') filtered = filtered.where((s) => s.hasOffer);

    final morning = filtered.where((s) {
      final h = _getHourFromSlotString(s.time);
      return h >= 6 && h < 12;
    }).toList();
    final afternoon = filtered.where((s) {
      final h = _getHourFromSlotString(s.time);
      return h >= 12 && h < 17;
    }).toList();
    final evening = filtered.where((s) {
      final h = _getHourFromSlotString(s.time);
      return h >= 18 && h <= 23;
    }).toList();
    final midnight = filtered.where((s) {
      final h = _getHourFromSlotString(s.time);
      return h >= 0 && h < 6;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (morning.isNotEmpty)
            _buildCategory('Morning', '6 AM – 12 PM', morning),
          if (afternoon.isNotEmpty)
            _buildCategory('Afternoon', '12 PM – 5 PM', afternoon),
          if (evening.isNotEmpty)
            _buildCategory('Evening', '6 PM – 11 PM', evening),
          if (midnight.isNotEmpty)
            _buildCategory('Midnight', '12 AM – 6 AM', midnight),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCategory(
    String title,
    String subtitle,
    List<AdminTimeSlot> slots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1DB954),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: slots.length,
          itemBuilder: (ctx, idx) {
            final slot = slots[idx];
            return AdminTimeSlotCard(
              slot: slot,
              isPast: slot.isPast,
              onTap: slot.isPast ? () {} : () => _showSlotDialog(slot),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// AdminTimeSlotCard – simple state-aware card
// ------------------------------------------------------------
class AdminTimeSlotCard extends StatelessWidget {
  final AdminTimeSlot slot;
  final VoidCallback onTap;
  final bool isPast;

  const AdminTimeSlotCard({
    super.key,
    required this.slot,
    required this.onTap,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.isBooked;
    final isDisabled = slot.isDisabled;
    final hasOffer = slot.hasOffer;

    Color bgColor, borderColor, textColor, badgeColor;
    String? badge;

    // Priority: past > booked > disabled > offer > available
    if (isPast) {
      bgColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade500;
      badgeColor = Colors.grey.shade600;
      badge = 'PAST';
    } else if (isBooked) {
      bgColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade300;
      textColor = Colors.blue.shade800;
      badgeColor = Colors.blue;
      badge = 'BOOKED';
    } else if (isDisabled) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      textColor = Colors.red.shade700;
      badgeColor = Colors.red;
      badge = 'DISABLED';
    } else if (hasOffer) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade400;
      textColor = Colors.green.shade800;
      badgeColor = Colors.deepOrange;
      badge = 'OFFER';
    } else {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade800;
      badgeColor = Colors.green;
    }

    return GestureDetector(
      onTap: isPast ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.time.split(' - ')[0],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
                decoration: isPast ? TextDecoration.lineThrough : null,
              ),
            ),
            Text(
              slot.time.split(' - ')[1],
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.8),
                decoration: isPast ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 7,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
