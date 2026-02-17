// features/turfslot/slot_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/turf.dart';
import '../../services/turf_data_service.dart';
import '../../models/booking.dart';

// ------------------------------------------------------------
// AdminTimeSlot – extended model for management
// ------------------------------------------------------------
class AdminTimeSlot {
  final String time;
  final bool isBooked;
  bool isDisabled;
  bool hasOffer;
  final double basePrice;

  AdminTimeSlot({
    required this.time,
    required this.isBooked,
    required this.isDisabled,
    required this.hasOffer,
    required this.basePrice,
  });

  bool get isAvailable => !isBooked && !isDisabled;
  // effectivePrice always returns basePrice — discount calculation is backend-only.
  double get effectivePrice => basePrice;

  AdminTimeSlot copyWith({bool? isDisabled, bool? hasOffer}) {
    return AdminTimeSlot(
      time: time,
      isBooked: isBooked,
      isDisabled: isDisabled ?? this.isDisabled,
      hasOffer: hasOffer ?? this.hasOffer,
      basePrice: basePrice,
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

  // Global offer slots (from OfferSlotService) – kept for future use
  List<String> _globalOfferSlots = [];

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
  // Slot Dialog with Price Display
  // ------------------------------------------------------------
  Future<void> _showSlotDialog(AdminTimeSlot slot) async {
    bool tempDisabled = slot.isDisabled;
    bool tempEnableOffer = slot.hasOffer;
    String selectedOfferPercent = '20';
    final List<String> offerOptions = ['20', '30', '40', '50', 'custom'];
    TextEditingController customPercentController = TextEditingController();

    // StatefulBuilder allows us to rebuild the dialog on changes
    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Calculate discounted price on the fly
          double discountedPrice = slot.basePrice;
          int? offerPercent;
          if (tempEnableOffer) {
            if (selectedOfferPercent == 'custom') {
              offerPercent = int.tryParse(customPercentController.text);
            } else {
              offerPercent = int.tryParse(selectedOfferPercent);
            }
            if (offerPercent != null) {
              discountedPrice = slot.basePrice * (1 - offerPercent / 100);
            }
          }

          return AlertDialog(
            title: Text('Manage Slot: ${slot.time}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Price Info
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
                            Text(
                              'Selected Date: ${_formatDate(_selectedDate)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Regular Price:',
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
                        if (tempEnableOffer && offerPercent != null) ...[
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discounted Price ($offerPercent% off):',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                '₹${discountedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Offer Section
                  const Text(
                    'Offer Settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Enable Offer'),
                    value: tempEnableOffer,
                    onChanged: slot.isBooked
                        ? null
                        : (val) => setDialogState(() => tempEnableOffer = val),
                    secondary: Icon(
                      Icons.local_offer,
                      color: tempEnableOffer ? Colors.red : Colors.grey,
                    ),
                  ),
                  if (tempEnableOffer) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Discount Percentage:',
                      style: TextStyle(fontSize: 13),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedOfferPercent,
                            items: offerOptions.map((opt) {
                              return DropdownMenuItem<String>(
                                value: opt,
                                child: Text(
                                  opt == 'custom' ? 'Custom' : '$opt%',
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setDialogState(
                              () => selectedOfferPercent = val!,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        if (selectedOfferPercent == 'custom') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: customPercentController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setDialogState(
                                () {},
                              ), // rebuild to update discounted price
                              decoration: const InputDecoration(
                                labelText: 'Custom %',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Disable Section
                  const Text(
                    'Disable Settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Disable Slot'),
                    value: tempDisabled,
                    onChanged: slot.isBooked
                        ? null
                        : (val) => setDialogState(() => tempDisabled = val),
                    secondary: Icon(
                      Icons.block,
                      color: tempDisabled ? Colors.grey : Colors.grey,
                    ),
                  ),

                  if (slot.isBooked)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'This slot is already booked – cannot modify.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
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
                onPressed: slot.isBooked
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        int? offerPercent;
                        if (tempEnableOffer) {
                          if (selectedOfferPercent == 'custom') {
                            offerPercent = int.tryParse(
                              customPercentController.text,
                            );
                          } else {
                            offerPercent = int.tryParse(selectedOfferPercent);
                          }
                        }
                        _updateSlotSettings(
                          slot,
                          tempEnableOffer,
                          tempDisabled,
                          offerPercent,
                        );
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // Update single date slot settings (with custom offer %)
  // ------------------------------------------------------------
  Future<void> _updateSlotSettings(
    AdminTimeSlot slot,
    bool enableOffer,
    bool disable,
    int? offerPercent,
  ) async {
    if (_selectedTurf == null) return;

    double newPrice = slot.basePrice;
    if (enableOffer && offerPercent != null) {
      newPrice = slot.basePrice * (1 - offerPercent / 100);
    }

    setState(() {
      final index = _timeSlots.indexWhere((s) => s.time == slot.time);
      if (index != -1) {
        _timeSlots[index] = slot.copyWith(
          hasOffer: enableOffer,
          isDisabled: disable,
        );
      }
    });

    await _turfService
        .saveSlotData(_selectedTurf!.name, _selectedDate, slot.time, {
          'time': slot.time,
          'disabled': disable,
          'offer': enableOffer,
          'price': newPrice,
          'offerPercent': offerPercent,
        });
    _showSnackBar('Slot settings updated');
  }

  // ------------------------------------------------------------
  // Global offer management — disabled (offers now managed via API)
  // Kept placeholder for future admin panel integration
  Future<void> _toggleGlobalOffer(String slotTime) async {
    _showSnackBar('Offer management moved to admin panel');
  }

  // ------------------------------------------------------------
  // Stats computation
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
  // UI Components
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
              onTap: () => _showSlotDialog(slot),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// AdminTimeSlotCard – simple, tappable card
// ------------------------------------------------------------
class AdminTimeSlotCard extends StatelessWidget {
  final AdminTimeSlot slot;
  final VoidCallback onTap;

  const AdminTimeSlotCard({super.key, required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.isBooked;
    final isDisabled = slot.isDisabled;
    final hasOffer = slot.hasOffer;

    Color bgColor, borderColor, textColor;
    if (isBooked) {
      bgColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade700;
    } else if (isDisabled) {
      bgColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade700;
    } else if (hasOffer) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      textColor = Colors.red.shade800;
    } else {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade800;
    }

    return GestureDetector(
      onTap: onTap,
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
              ),
            ),
            Text(
              slot.time.split(' - ')[1],
              style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            if (isBooked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BOOKED',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isDisabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DISABLED',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (hasOffer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OFFER',
                  style: TextStyle(
                    fontSize: 8,
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
