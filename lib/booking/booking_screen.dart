import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../turffdetail/turfdetails_screen.dart';
import '../payment/payment_summary_screen.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Turf turf;
  const BookingScreen({super.key, required this.turf});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  List<ApiSlot> _slots = [];
  final Set<int> _selectedSlotIds = {};
  bool _isLoading = true;
  bool _isProcessing = false; // Double-tap guard for Proceed button
  String? _errorMessage;

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  // ─── AVAILABILITY API ───
  Future<void> _fetchAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedSlotIds.clear();
    });

    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final response = await _api.get(
        '/api/bookings/bookings/availability/',
        queryParams: {'turf_id': widget.turf.id.toString(), 'date': dateStr},
      );

      if (response['success'] == true) {
        final List<dynamic> slotsJson = response['slots'] ?? [];
        setState(() {
          _slots = slotsJson.map((s) => ApiSlot.fromJson(s)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to load slots';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load availability. Check connection.';
        _isLoading = false;
      });
      print('🚨 Availability error: $e');
    }
  }

  // ─── SELECTED SLOTS HELPERS ───
  List<ApiSlot> get _selectedSlots =>
      _slots.where((s) => _selectedSlotIds.contains(s.slotId)).toList();

  /// Sum of final_price for selected slots — directly from API, no math
  String get _totalDisplay {
    int total = 0;
    for (final slot in _selectedSlots) {
      total += int.tryParse(slot.finalPrice.split('.')[0]) ?? 0;
    }
    return total.toString();
  }

  /// Sum of original_price for selected slots — for strikethrough
  String get _originalTotalDisplay {
    int total = 0;
    for (final slot in _selectedSlots) {
      total += int.tryParse(slot.originalPrice.split('.')[0]) ?? 0;
    }
    return total.toString();
  }

  bool get _hasAnyOfferInSelected => _selectedSlots.any((s) => s.hasOffer);

  // ─── DATE HELPERS ───
  List<DateTime> _getNext30Days() {
    List<DateTime> days = [];
    DateTime currentDate = DateTime.now();
    for (int i = 0; i < 30; i++) {
      days.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day + i),
      );
    }
    return days;
  }

  void _onDateSelected(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
    _fetchAvailability();
  }

  void _toggleSlot(ApiSlot slot) {
    if (!slot.isAvailable) return;
    setState(() {
      if (_selectedSlotIds.contains(slot.slotId)) {
        _selectedSlotIds.remove(slot.slotId);
      } else {
        _selectedSlotIds.add(slot.slotId);
      }
    });
  }

  void _proceedToPayment() {
    if (_isProcessing) return; // Double-tap guard
    if (_selectedSlotIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time slot'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSummaryScreen(
          turf: widget.turf,
          bookingDate: dateStr,
          slotIds: _selectedSlotIds.toList(),
          selectedSlots: _selectedSlots,
        ),
      ),
    ).then((_) {
      // Re-enable after returning from payment screen
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  // ─── SLOT TIME PARSING (for category grouping) ───
  int _getHourFromSlot(ApiSlot slot) {
    // Parse "06:00:00" or "6:00 AM" style
    final parts = slot.startTime.split(':');
    if (parts.isNotEmpty) {
      return int.tryParse(parts[0]) ?? 0;
    }
    return 0;
  }

  // ─── BUILD ───
  @override
  Widget build(BuildContext context) {
    final next30Days = _getNext30Days();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Turf"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Turf Info Card
          TurfInfoCard(turf: widget.turf),
          const SizedBox(height: 16),

          // Date selector
          _buildDateSelector(next30Days),
          const SizedBox(height: 16),

          // Color legend
          _buildClarityBox(),
          const SizedBox(height: 16),

          // Time slot header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  "Select Time Slots",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    "${_selectedSlotIds.length} selected",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Time slots or loading/error
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1DB954),
                      ),
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchAvailability,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                          ),
                          child: const Text(
                            "Retry",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : _slots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No slots available for this date",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildTimeSectionForCategory(
                          title: 'Morning',
                          subtitle: '6 AM – 12 PM',
                          filter: (slot) {
                            final hour = _getHourFromSlot(slot);
                            return hour >= 6 && hour < 12;
                          },
                        ),
                        _buildTimeSectionForCategory(
                          title: 'Afternoon',
                          subtitle: '12 PM – 5 PM',
                          filter: (slot) {
                            final hour = _getHourFromSlot(slot);
                            return hour >= 12 && hour < 17;
                          },
                        ),
                        _buildTimeSectionForCategory(
                          title: 'Evening',
                          subtitle: '5 PM – 11 PM',
                          filter: (slot) {
                            final hour = _getHourFromSlot(slot);
                            return hour >= 17 && hour <= 23;
                          },
                        ),
                        _buildTimeSectionForCategory(
                          title: 'Midnight',
                          subtitle: '12 AM – 6 AM',
                          filter: (slot) {
                            final hour = _getHourFromSlot(slot);
                            return hour >= 0 && hour < 6;
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),

      // Sticky bottom bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── UI COMPONENTS ───

  Widget _buildClarityBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 8,
        children: [
          _legendItem(
            color: Colors.green,
            label: 'Available',
            borderColor: Colors.green.shade800,
          ),
          _legendItem(
            color: Colors.red.shade50,
            label: 'Booked',
            borderColor: Colors.red.shade300,
            textColor: Colors.red.shade700,
          ),
          _legendItem(
            color: Colors.grey.shade200,
            label: 'Past',
            borderColor: Colors.grey.shade400,
            textColor: Colors.grey.shade500,
          ),
          _legendItem(
            color: Colors.orange.shade50,
            label: 'Blocked',
            borderColor: Colors.orange.shade300,
            textColor: Colors.orange.shade700,
          ),
          _legendItem(
            color: Colors.blue,
            label: 'Selected',
            borderColor: Colors.blue.shade800,
            textColor: Colors.blue,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: const Center(
                  child: Icon(Icons.local_offer, size: 8, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Offer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    Color? borderColor,
    Color textColor = Colors.black87,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(List<DateTime> days) {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final DateTime normalizedSelectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isToday = day.isAtSameMomentAs(today);
            final isSelected = normalizedSelectedDate.isAtSameMomentAs(day);

            return GestureDetector(
              onTap: () => _onDateSelected(day),
              child: Container(
                width: 60,
                margin: EdgeInsets.only(
                  right: index == days.length - 1 ? 0 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1DB954)
                      : isToday
                      ? Colors.blue.shade50
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday && !isSelected
                        ? Colors.blue.shade200
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(day.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? Colors.blue.shade800
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getMonthName(day.month),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white70
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeSectionForCategory({
    required String title,
    required String subtitle,
    required bool Function(ApiSlot) filter,
  }) {
    final filtered = _slots.where(filter).toList();
    if (filtered.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final slot = filtered[index];
            final isSelected = _selectedSlotIds.contains(slot.slotId);
            return ApiSlotCard(
              slot: slot,
              isSelected: isSelected,
              onTap: () => _toggleSlot(slot),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.6),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _selectedSlotIds.isNotEmpty && !_isProcessing
              ? _proceedToPayment
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedSlotIds.isNotEmpty && _hasAnyOfferInSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    "₹$_originalTotalDisplay",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Text(
                _selectedSlotIds.isNotEmpty
                    ? "BOOK ${_selectedSlotIds.length} HOUR${_selectedSlotIds.length > 1 ? "S" : ""}  •  ₹$_totalDisplay"
                    : "SELECT TIME SLOTS",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
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
}

// ─── API SLOT MODEL ───
/// All fields are from the availability API response.
/// Money values are String — NEVER double.
class ApiSlot {
  final int slotId;
  final String startTime;
  final String endTime;
  final String originalPrice;
  final String finalPrice;
  final bool hasOffer;
  final String discountAmount;
  final bool isAvailable;
  final bool isPast;
  final bool isBooked;
  final bool isBlocked;
  final String status; // "available" | "past" | "booked" | "blocked"

  ApiSlot({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.originalPrice,
    required this.finalPrice,
    required this.hasOffer,
    required this.discountAmount,
    required this.isAvailable,
    required this.isPast,
    required this.isBooked,
    required this.isBlocked,
    required this.status,
  });

  factory ApiSlot.fromJson(Map<String, dynamic> json) {
    return ApiSlot(
      slotId: json['slot_id'] ?? 0,
      startTime: json['start_time']?.toString() ?? '00:00',
      endTime: json['end_time']?.toString() ?? '00:00',
      originalPrice: json['original_price']?.toString() ?? '0',
      finalPrice: json['final_price']?.toString() ?? '0',
      hasOffer: json['has_offer'] == true,
      discountAmount: json['discount_amount']?.toString() ?? '0',
      isAvailable: json['is_available'] == true,
      isPast: json['is_past'] == true,
      isBooked: json['is_booked'] == true,
      isBlocked: json['is_blocked'] == true,
      status: json['status']?.toString() ?? 'available',
    );
  }

  /// Display-friendly time: "06:00 - 07:00"
  String get displayTime {
    String formatTime(String t) {
      final parts = t.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts[1];
        final period = h >= 12 ? 'PM' : 'AM';
        final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
        return '$displayH:$m $period';
      }
      return t;
    }

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}

// ─── TURF INFO CARD ───
class TurfInfoCard extends StatelessWidget {
  final Turf turf;
  const TurfInfoCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TurfDetailsScreen(turf: turf)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: turf.images.isNotEmpty
                      ? NetworkImage(turf.images.first)
                      : const NetworkImage(
                          "https://via.placeholder.com/150?text=No+Image",
                        ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          turf.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    turf.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        turf.rating.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

// ─── SLOT CARD WIDGET ───
class ApiSlotCard extends StatelessWidget {
  final ApiSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const ApiSlotCard({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    String? statusLabel;

    if (!slot.isAvailable) {
      // Distinct visual states for each unavailable reason
      if (slot.isBooked) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade700;
        statusLabel = 'Booked';
      } else if (slot.isBlocked) {
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        textColor = Colors.orange.shade700;
        statusLabel = 'Blocked';
      } else {
        // Past or generic unavailable
        bgColor = Colors.grey.shade200;
        borderColor = Colors.grey.shade400;
        textColor = Colors.grey.shade500;
        statusLabel = slot.isPast ? 'Past' : null;
      }
    } else if (isSelected) {
      bgColor = Colors.blue;
      borderColor = Colors.blue;
      textColor = Colors.white;
    } else {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade800;
    }

    return GestureDetector(
      onTap: slot.isAvailable ? onTap : null,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slot.displayTime.split(" - ")[0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration: slot.isPast
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.displayTime.split(" - ")[1],
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withOpacity(0.9),
                      decoration: slot.isPast
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (statusLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (slot.hasOffer && slot.isAvailable)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer, size: 10, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      "OFFER",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (slot.hasOffer && slot.isAvailable && !isSelected)
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
