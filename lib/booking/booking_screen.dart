import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../turffdetail/turfdetails_screen.dart';
import '../payment/payment_summary_screen.dart';
import '../services/offer_slot_service.dart';
import '../services/turf_data_service.dart';
import '../features/bookings/my_bookings_screen.dart';
import '../models/booking.dart';

class BookingScreen extends StatefulWidget {
  final Turf turf;
  const BookingScreen({super.key, required this.turf});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedTimeSlots = [];
  List<TimeSlot> _availableTimeSlots = [];

  // Offer slots defined by admin
  List<String> _offerSlots = [];

  // Helper to check if current turf has an offer
  bool get _hasTurfOffer {
    final offerTurfNames = [
      'Green Field Arena',
      'Elite Football Ground',
      'Shuttle Masters Academy',
      'Royal Turf Ground',
      'City Sports Turf',
    ];
    return offerTurfNames.contains(widget.turf.name);
  }

  // Calculate price for a single slot based on whether it has an offer
  double _getSlotPrice(String slotTime) {
    final turfName = widget.turf.name;
    final saved = TurfDataService().getSavedSlots(turfName, _selectedDate);
    double basePrice = widget.turf.price.toDouble();

    if (saved != null) {
      final slot = saved.firstWhere(
        (s) => s['time'] == slotTime,
        orElse: () => <String, dynamic>{},
      );
      if (slot.containsKey('price')) {
        basePrice = (slot['price'] as num).toDouble();
      }
    }

    if (_hasTurfOffer && _offerSlots.contains(slotTime)) {
      return basePrice * 0.8; // 20% discount
    }
    return basePrice;
  }

  @override
  void initState() {
    super.initState();
    _loadOfferSlots();
  }

  Future<void> _loadOfferSlots() async {
    final offerSlots = await OfferSlotService.getOfferSlots();
    setState(() {
      _offerSlots = offerSlots;
    });
    _generateTimeSlots();
  }

  // ------------------------------------------------------------
  // Generate all time slots for the selected date
  // ------------------------------------------------------------
  void _generateTimeSlots() {
    List<TimeSlot> slots = [];
    final turfName = widget.turf.name;

    // Real bookings from the service for THIS turf and date
    final existingBookings = TurfDataService().bookings
        .where(
          (b) =>
              b.turfName == turfName &&
              b.date.year == _selectedDate.year &&
              b.date.month == _selectedDate.month &&
              b.date.day == _selectedDate.day &&
              b.status != BookingStatus.cancelled,
        )
        .toList();

    final bookedSlotTimes = existingBookings
        .map((b) => "${b.startTime} - ${b.endTime}")
        .toList();

    // Check if admin has saved custom slots for this turf/date
    final saved = TurfDataService().getSavedSlots(turfName, _selectedDate);

    if (saved != null && saved.isNotEmpty) {
      // Use admin-defined slots
      for (var s in saved) {
        String slotTime = s['time'];
        bool isBooked =
            bookedSlotTimes.contains(slotTime) || s['status'] == 'booked';
        bool isDisabled = s['disabled'] == true;
        bool hasOffer = _hasTurfOffer && _offerSlots.contains(slotTime);

        slots.add(
          TimeSlot(
            time: slotTime,
            isAvailable: !isBooked && !isDisabled,
            hasOffer: hasOffer,
          ),
        );
      }
    } else {
      // ----- FALLBACK: Generate default slots -----
      // Day slots: 6:00 AM – 11:00 PM
      for (int hour = 6; hour <= 23; hour++) {
        bool isAM = hour < 12;
        String period = isAM ? 'AM' : 'PM';
        int displayHour = hour > 12 ? hour - 12 : hour;
        if (displayHour == 0) displayHour = 12;

        int nextHour = hour + 1;
        if (nextHour == 24) nextHour = 0;
        bool nextIsAM = nextHour < 12;
        String nextPeriod = nextIsAM ? 'AM' : 'PM';
        int nextDisplayHour = nextHour > 12 ? nextHour - 12 : nextHour;
        if (nextDisplayHour == 0) nextDisplayHour = 12;

        String startTime = '$displayHour:00 $period';
        String endTime = '$nextDisplayHour:00 $nextPeriod';
        String slot = '$startTime - $endTime';

        bool hasOffer = _hasTurfOffer && _offerSlots.contains(slot);
        bool isBooked = bookedSlotTimes.contains(slot);

        slots.add(
          TimeSlot(time: slot, isAvailable: !isBooked, hasOffer: hasOffer),
        );
      }

      // ----- Midnight slots: 12:00 AM – 5:00 AM -----
      for (int hour = 0; hour <= 5; hour++) {
        bool isAM = hour < 12;
        String period = isAM ? 'AM' : 'PM';
        int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        int nextHour = (hour + 1) % 24;
        bool nextIsAM = nextHour < 12;
        String nextPeriod = nextIsAM ? 'AM' : 'PM';
        int nextDisplayHour = nextHour == 0
            ? 12
            : (nextHour > 12 ? nextHour - 12 : nextHour);

        String startTime = '$displayHour:00 $period';
        String endTime = '$nextDisplayHour:00 $nextPeriod';
        String slot = '$startTime - $endTime';

        bool hasOffer = _hasTurfOffer && _offerSlots.contains(slot);
        bool isBooked = bookedSlotTimes.contains(slot);

        slots.add(
          TimeSlot(time: slot, isAvailable: !isBooked, hasOffer: hasOffer),
        );
      }
    }

    setState(() {
      _availableTimeSlots = slots;
    });
  }

  // ------------------------------------------------------------
  // Parse the start hour from a TimeSlot (e.g., "6:00 AM" -> 6)
  // ------------------------------------------------------------
  int _getHourFromSlot(TimeSlot slot) {
    final start = slot.time.split(' - ')[0].trim();
    final parts = start.split(' ');
    if (parts.length < 2) return 0;
    final hourMin = parts[0];
    final period = parts[1];
    final hour = int.parse(hourMin.split(':')[0]);
    if (period == 'PM' && hour != 12) return hour + 12;
    if (period == 'AM' && hour == 12) return 0;
    return hour;
  }

  double _calculateTotal() {
    double total = 0;
    for (var slot in _selectedTimeSlots) {
      total += _getSlotPrice(slot);
    }
    return total;
  }

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

  void _selectSlot(TimeSlot slot) {
    setState(() {
      if (slot.isAvailable) {
        if (_selectedTimeSlots.contains(slot.time)) {
          _selectedTimeSlots.remove(slot.time);
        } else {
          _selectedTimeSlots.add(slot.time);
        }
      }
    });
  }

  void _proceedToPayment() {
    if (_selectedTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time slot'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final totalAmount = _calculateTotal();
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid booking amount. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSummaryScreen(
          turf: widget.turf,
          selectedDate: _selectedDate,
          selectedTimeSlots: _selectedTimeSlots,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final next30Days = _getNext30Days();
    final totalAmount = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Turf"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Turf Info Card (tappable → details screen)
          TurfInfoCard(turf: widget.turf),

          const SizedBox(height: 16),

          // Date selector – NO header text
          _buildDateSelector(next30Days),

          const SizedBox(height: 16),

          // Color legend / clarity box
          _buildClarityBox(),

          const SizedBox(height: 16),

          // Time slot header (without the green hint)
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
                    "${_selectedTimeSlots.length} selected",
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

          // Time slots – fully scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Morning (6 AM – 11:59 AM)
                  _buildTimeSectionForCategory(
                    title: 'Morning',
                    subtitle: '6 AM – 12 PM',
                    filter: (slot) {
                      final hour = _getHourFromSlot(slot);
                      return hour >= 6 && hour < 12;
                    },
                  ),

                  // Afternoon (12 PM – 5 PM)
                  _buildTimeSectionForCategory(
                    title: 'Afternoon',
                    subtitle: '12 PM – 5 PM',
                    filter: (slot) {
                      final hour = _getHourFromSlot(slot);
                      return hour >= 12 && hour < 17;
                    },
                  ),

                  // Evening (6 PM – 11 PM)
                  _buildTimeSectionForCategory(
                    title: 'Evening',
                    subtitle: '6 PM – 11 PM',
                    filter: (slot) {
                      final hour = _getHourFromSlot(slot);
                      return hour >= 18 && hour <= 23;
                    },
                  ),

                  // Midnight (12 AM – 5 AM)
                  _buildTimeSectionForCategory(
                    title: 'Midnight',
                    subtitle: '12 AM – 6 AM',
                    filter: (slot) {
                      final hour = _getHourFromSlot(slot);
                      return hour >= 0 && hour < 6;
                    },
                  ),

                  // Extra bottom padding to avoid content being hidden behind the sticky bar
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky bottom booking bar
      bottomNavigationBar: _buildBottomBar(totalAmount),
    );
  }

  // ------------------------------------------------------------
  // UI Components
  // ------------------------------------------------------------
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
            color: Colors.grey.shade200,
            label: 'Booked',
            borderColor: Colors.grey.shade500,
            textColor: Colors.grey.shade600,
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
              onTap: () {
                setState(() {
                  _selectedDate = day;
                  _selectedTimeSlots.clear();
                });
              },
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

  /// Builds a time section based on a filter predicate.
  Widget _buildTimeSectionForCategory({
    required String title,
    required String subtitle,
    required bool Function(TimeSlot) filter,
  }) {
    final filtered = _availableTimeSlots.where(filter).toList();
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
            final isSelected = _selectedTimeSlots.contains(slot.time);
            return TimeSlotCard(
              slot: slot,
              isSelected: isSelected,
              onTap: () => _selectSlot(slot),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(double totalAmount) {
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
          onPressed: _selectedTimeSlots.isNotEmpty ? _proceedToPayment : null,
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
              if (_selectedTimeSlots.isNotEmpty &&
                  _selectedTimeSlots.any((slot) => _offerSlots.contains(slot)))
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    "₹${(widget.turf.price * _selectedTimeSlots.length).toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Text(
                _selectedTimeSlots.isNotEmpty
                    ? "BOOK ${_selectedTimeSlots.length} HOUR${_selectedTimeSlots.length > 1 ? "S" : ""}  •  ₹${totalAmount.toStringAsFixed(0)}"
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

// -----------------------------------------------------------------
// TurfInfoCard – Displays turf summary, tappable to details
// -----------------------------------------------------------------
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
                        child: Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1DB954),
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if ([
                            'Green Field Arena',
                            'Elite Football Ground',
                            'Shuttle Masters Academy',
                            'Royal Turf Ground',
                          ].contains(turf.name)) ...[
                            Text(
                              "₹${turf.price}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              "₹${(turf.price * 0.8).toInt()}/hr",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1DB954),
                              ),
                            ),
                          ] else
                            Text(
                              "₹${turf.price}/hour",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1DB954),
                              ),
                            ),
                        ],
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

// -----------------------------------------------------------------
// TimeSlot model and card widget
// -----------------------------------------------------------------
class TimeSlot {
  final String time;
  final bool isAvailable;
  final bool hasOffer;

  TimeSlot({
    required this.time,
    required this.isAvailable,
    this.hasOffer = false,
  });
}

class TimeSlotCard extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotCard({
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

    if (!slot.isAvailable) {
      bgColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade600;
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
                    slot.time.split(" - ")[0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.time.split(" - ")[1],
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withOpacity(0.9),
                    ),
                  ),
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
