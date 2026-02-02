import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../turffdetail/turfdetails_screen.dart';
import '../payment/payment_summary_screen.dart';

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
  final List<String> _bookedSlots = [
    '10:00 AM - 11:00 AM',
    '02:00 PM - 03:00 PM',
    '07:00 PM - 08:00 PM',
    '11:00 PM - 12:00 AM',
  ];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    List<TimeSlot> slots = [];

    // Generate time slots from 6 AM to 1 AM
    for (int hour = 6; hour <= 23; hour++) {
      bool isAM = hour < 12;
      String period = isAM ? 'AM' : 'PM';
      int displayHour = hour > 12 ? hour - 12 : hour;
      if (displayHour == 0) displayHour = 12;

      // Next hour
      int nextHour = hour + 1;
      if (nextHour == 24) nextHour = 0;
      bool nextIsAM = nextHour < 12;
      String nextPeriod = nextIsAM ? 'AM' : 'PM';
      int nextDisplayHour = nextHour > 12 ? nextHour - 12 : nextHour;
      if (nextDisplayHour == 0) nextDisplayHour = 12;

      String startTime = '$displayHour:00 $period';
      String endTime = '$nextDisplayHour:00 $nextPeriod';
      String slot = '$startTime - $endTime';

      slots.add(
        TimeSlot(time: slot, isAvailable: !_bookedSlots.contains(slot)),
      );
    }

    // Add midnight slot
    slots.add(
      TimeSlot(
        time: '12:00 AM - 01:00 AM',
        isAvailable: !_bookedSlots.contains('12:00 AM - 01:00 AM'),
      ),
    );

    setState(() {
      _availableTimeSlots = slots;
    });
  }

  double _calculateTotal() {
    return widget.turf.price.toDouble() * _selectedTimeSlots.length;
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
    if (_selectedTimeSlots.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSummaryScreen(
            turf: widget.turf,
            selectedDate: _selectedDate,
            selectedTimeSlots: _selectedTimeSlots,
            totalAmount: _calculateTotal(),
          ),
        ),
      );
    }
  }

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
          // Turf Info Card
          TurfInfoCard(turf: widget.turf),

          const SizedBox(height: 16),

          // Date Selection (Next 30 Days)
          _buildDateSelector(next30Days),

          const SizedBox(height: 16),

          // Time Slot Selection Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Select Time Slots",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                const SizedBox(height: 4),
                Text(
                  "Tap multiple slots to book consecutive hours",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Time Slots Grid - Expanded to take remaining space
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Morning Section (6 AM - 12 PM)
                    _buildTimeSection("Morning", 0, 6),

                    // Afternoon Section (1 PM - 5 PM)
                    _buildTimeSection("Afternoon", 6, 11),

                    // Evening Section (6 PM - 1 AM)
                    _buildTimeSection(
                      "Evening",
                      11,
                      _availableTimeSlots.length,
                    ),

                    const SizedBox(height: 20), // Extra space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Book Button at Bottom
      bottomNavigationBar: _buildBottomBar(totalAmount),
    );
  }

  Widget _buildDateSelector(List<DateTime> days) {
    // Find today's date for comparison
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Check if selected date is today (for comparison)
    final DateTime normalizedSelectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Date (Next 30 Days)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
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
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
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
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, int startIndex, int endIndex) {
    final sectionSlots = _availableTimeSlots.sublist(
      startIndex,
      endIndex.clamp(0, _availableTimeSlots.length),
    );

    if (sectionSlots.isEmpty) return const SizedBox();

    // Determine time range for subtitle
    String subtitle = "";
    if (title == "Morning") {
      subtitle = "6 AM - 12 PM";
    } else if (title == "Afternoon") {
      subtitle = "1 PM - 5 PM";
    } else {
      subtitle = "6 PM - 1 AM";
    }

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
            childAspectRatio: 2.2, // Adjusted for better fit
          ),
          itemCount: sectionSlots.length,
          itemBuilder: (context, index) {
            final slot = sectionSlots[index];
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
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
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: Text(
            _selectedTimeSlots.isNotEmpty
                ? "BOOK ${_selectedTimeSlots.length} HOUR${_selectedTimeSlots.length > 1 ? "S" : ""}  •  ₹${totalAmount.toStringAsFixed(0)}"
                : "SELECT TIME SLOTS",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
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
                  image: NetworkImage(turf.images[0]),
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
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({required this.time, required this.isAvailable});
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
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      textColor = Colors.red.shade800;
    } else if (isSelected) {
      bgColor = const Color(0xFF1DB954);
      borderColor = const Color(0xFF1DB954);
      textColor = Colors.white;
    } else {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade800;
    }

    return GestureDetector(
      onTap: slot.isAvailable ? onTap : null,
      child: Container(
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
    );
  }
}
