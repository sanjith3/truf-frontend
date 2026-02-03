import 'package:flutter/material.dart';

class CreditsRewardsScreen extends StatefulWidget {
  const CreditsRewardsScreen({super.key});

  @override
  State<CreditsRewardsScreen> createState() => _CreditsRewardsScreenState();
}

class _CreditsRewardsScreenState extends State<CreditsRewardsScreen> {
  bool _isEarnExpanded = false;
  bool _isRewardsExpanded = false;
  String _selectedTurf = '';
  TimeOfDay? _selectedTime;
  bool _showBookingDialog = false;

  // Mock data - replace with actual data
  final Map<String, int> userCredits = {
    'totalCredits': 1250,
    'availableCredits': 850,
    'usedCredits': 400,
    'nextReward': 10,
    'currentProgress': 7,
  };

  final List<Map<String, dynamic>> creditHistory = [
    {
      'type': 'earned',
      'title': 'Turf Booking - Mumbai FC',
      'description': 'Completed booking on Jan 15',
      'credits': '+50',
      'date': 'Jan 15, 2024',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
    },
    {
      'type': 'lost',
      'title': 'Cancelled Booking',
      'description': 'Late cancellation penalty',
      'credits': '-25',
      'date': 'Jan 10, 2024',
      'icon': Icons.cancel_outlined,
      'color': Colors.orange,
    },
    {
      'type': 'earned',
      'title': 'Weekend Special',
      'description': 'Weekend booking bonus',
      'credits': '+20',
      'date': 'Jan 8, 2024',
      'icon': Icons.celebration_outlined,
      'color': Colors.purple,
    },
    {
      'type': 'earned',
      'title': 'Referral Bonus',
      'description': 'Referred a friend',
      'credits': '+100',
      'date': 'Jan 5, 2024',
      'icon': Icons.people_outline,
      'color': Colors.blue,
    },
  ];

  final List<Map<String, dynamic>> availableTurfs = [
    {
      'name': 'Mumbai FC Turf',
      'location': 'Bandra, Mumbai',
      'credits': 500,
      'rating': 4.5,
      'image': 'assets/turf1.jpg',
    },
    {
      'name': 'Sports Arena',
      'location': 'Andheri, Mumbai',
      'credits': 500,
      'rating': 4.2,
      'image': 'assets/turf2.jpg',
    },
    {
      'name': 'Goal Post Arena',
      'location': 'Powai, Mumbai',
      'credits': 500,
      'rating': 4.7,
      'image': 'assets/turf3.jpg',
    },
  ];

  final List<TimeOfDay> availableTimes = [
    const TimeOfDay(hour: 6, minute: 0),
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
  ];

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1DB954),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showRedeemBookingDialog() {
    if (userCredits['availableCredits']! < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You need at least 500 credits to redeem a free booking',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Redeem Free Booking',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Book your favorite turf using 500 credits',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Turf Selection
                const Text(
                  'Select Turf',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableTurfs.length,
                    itemBuilder: (context, index) {
                      final turf = availableTurfs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedTurf == turf['name']
                                ? const Color(0xFF1DB954)
                                : Colors.grey.shade200,
                            width: _selectedTurf == turf['name'] ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DB954).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(turf['image'] as String),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            turf['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                turf['location'] as String,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${turf['rating']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.credit_score_outlined,
                                    color: const Color(0xFF1DB954),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${turf['credits']} credits',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: _selectedTurf == turf['name']
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1DB954),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedTurf = turf['name'] as String;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Time Selection
                const Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableTimes.length,
                    itemBuilder: (context, index) {
                      final time = availableTimes[index];
                      final isSelected = _selectedTime == time;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1DB954),
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTime = selected ? time : null;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF1DB954)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Redeem Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedTurf.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a turf'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      if (_selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a time slot'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Handle booking confirmation
                      Navigator.pop(context);
                      _showBookingConfirmation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Confirm Booking - 500 Credits",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.check_circle,
          color: Color(0xFF1DB954),
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Your booking at $_selectedTurf has been confirmed.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 10),
            if (_selectedTime != null)
              Text(
                'Time: ${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 10),
            const Text(
              '500 credits have been deducted from your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF1DB954),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credits & Rewards"),
        backgroundColor: const Color(0xFF1DB954),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("How Credits Work"),
                  content: const Text(
                    "• 50 credits = 1 completed booking\n"
                    "• 500 credits = 1 free booking\n"
                    "• Credits expire after 1 year\n"
                    "• Weekend bookings earn extra credits\n"
                    "• Refer friends for bonus credits",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Total Credits Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1DB954).withOpacity(0.9),
                    const Color(0xFF1DB954),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Available Credits",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userCredits['availableCredits'].toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Credits",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // Credits Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCreditStat(
                        title: "Total Earned",
                        value: userCredits['totalCredits'].toString(),
                        icon: Icons.trending_up_outlined,
                        color: Colors.green,
                      ),
                      _buildCreditStat(
                        title: "Used Credits",
                        value: userCredits['usedCredits'].toString(),
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Next Reward Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Next Reward",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Earn 10 more credits to get a FREE booking!",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Progress",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "${userCredits['currentProgress']}/${userCredits['nextReward']} credits",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1DB954),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 80) *
                                    ((userCredits['currentProgress']! /
                                            userCredits['nextReward']!)
                                        .toDouble()),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1DB954),
                                      Color(0xFF17A34A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You need ${(userCredits['nextReward'] ?? 0) - (userCredits['currentProgress'] ?? 0)} more credits for your next reward",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // How to Earn Credits (Expandable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Color(0xFF1DB954),
                          size: 22,
                        ),
                      ),
                      title: const Text(
                        "How to Earn Credits",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _isEarnExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF1DB954),
                        ),
                        onPressed: () {
                          setState(() {
                            _isEarnExpanded = !_isEarnExpanded;
                          });
                        },
                      ),
                    ),

                    // Expandable Content
                    if (_isEarnExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                        child: Column(
                          children: [
                            _buildEarningMethod(
                              icon: Icons.sports_soccer,
                              title: "Complete Bookings",
                              description:
                                  "Earn 50 credits for every completed booking",
                              color: const Color(0xFF1DB954),
                            ),
                            const SizedBox(height: 10),
                            _buildEarningMethod(
                              icon: Icons.people_outline,
                              title: "Refer Friends",
                              description:
                                  "Earn 100 credits for every successful referral",
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 10),
                            _buildEarningMethod(
                              icon: Icons.star_outline,
                              title: "Weekend Bonus",
                              description:
                                  "Earn extra 20 credits on weekend bookings",
                              color: Colors.purple,
                            ),
                            const SizedBox(height: 10),
                            _buildEarningMethod(
                              icon: Icons.rate_review_outlined,
                              title: "Write Reviews",
                              description:
                                  "Earn 10 credits for each turf review",
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // How Rewards Work (Expandable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
                          color: Color(0xFF1DB954),
                          size: 22,
                        ),
                      ),
                      title: const Text(
                        "How Rewards Work",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _isRewardsExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF1DB954),
                        ),
                        onPressed: () {
                          setState(() {
                            _isRewardsExpanded = !_isRewardsExpanded;
                          });
                        },
                      ),
                    ),

                    // Expandable Content
                    if (_isRewardsExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRewardPoint(
                              "• Every completed booking earns you 50 credits",
                            ),
                            const SizedBox(height: 8),
                            _buildRewardPoint(
                              "• When you reach 500 credits, you get 1 FREE booking",
                            ),
                            const SizedBox(height: 8),
                            _buildRewardPoint(
                              "• Free booking can be redeemed at any available turf",
                            ),
                            const SizedBox(height: 8),
                            _buildRewardPoint(
                              "• Credits are deducted for late cancellations",
                            ),
                            const SizedBox(height: 8),
                            _buildRewardPoint(
                              "• Credits expire after 1 year of inactivity",
                            ),
                            const SizedBox(height: 8),
                            _buildRewardPoint(
                              "• Weekend bookings earn extra 20 credits",
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Credits History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Credits History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all history
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: Color(0xFF1DB954),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...creditHistory
                      .map(
                        (history) => _buildHistoryItem(
                          icon: history['icon'] as IconData,
                          title: history['title'] as String,
                          description: history['description'] as String,
                          credits: history['credits'] as String,
                          date: history['date'] as String,
                          color: history['color'] as Color,
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Redeem Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DB954), Color(0xFF17A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Ready to Redeem?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You have ${userCredits['availableCredits']} credits available",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "500 credits = 1 Free Booking",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showRedeemBookingDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                        child: Text(
                          userCredits['availableCredits']! >= 500
                              ? "Redeem Free Booking"
                              : "Need ${500 - userCredits['availableCredits']!} more credits",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: userCredits['availableCredits']! >= 500
                                ? const Color(0xFF1DB954)
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEarningMethod({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 6, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String description,
    required String credits,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      credits,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: credits.startsWith('+')
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
