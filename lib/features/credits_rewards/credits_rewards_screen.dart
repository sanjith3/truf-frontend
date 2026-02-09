import 'package:flutter/material.dart';

class CreditsRewardsScreen extends StatefulWidget {
  const CreditsRewardsScreen({super.key});

  @override
  State<CreditsRewardsScreen> createState() => _CreditsRewardsScreenState();
}

class _CreditsRewardsScreenState extends State<CreditsRewardsScreen> {
  int _selectedCategory = 0; // 0: Earned, 1: Used
  int _currentTarget =
      100; // Current credit target for free booking (100 credits = 1 free booking)
  int _creditsEarned = 85; // Credits earned towards current target
  bool _showRedeemDialog = false;
  String? _selectedTurf;
  String? _selectedSlot;

  // Professional color scheme
  final Color primaryColor = const Color(0xFF4CAF50); // Professional Green
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;

  // Mock data - replace with actual data
  final Map<String, int> userCredits = {
    'totalCredits': 1250,
    'availableCredits': 850,
    'usedCredits': 400,
  };

  // User's regularly booked turfs (sorted by booking frequency)
  final List<Map<String, dynamic>> regularTurfs = [
    {
      'id': '1',
      'name': 'Redhills Arena',
      'location': 'Redhills, Chennai',
      'image': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68',
      'bookings': 45,
      'rating': 4.8,
      'isRegular': true,
    },
    {
      'id': '2',
      'name': 'Elite Football Ground',
      'location': 'Race Course, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1511886929837-354d827aae26',
      'bookings': 38,
      'rating': 4.9,
      'isRegular': true,
    },
    {
      'id': '3',
      'name': 'Sports Hub Arena',
      'location': 'Peelamedu, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1531315630201-bb15abeb1653',
      'bookings': 28,
      'rating': 4.6,
      'isRegular': true,
    },
    {
      'id': '4',
      'name': 'City Sports Complex',
      'location': 'Gandhipuram, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
      'bookings': 22,
      'rating': 4.7,
      'isRegular': true,
    },
    {
      'id': '5',
      'name': 'Turf Masters',
      'location': 'Saibaba Colony, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6',
      'bookings': 18,
      'rating': 4.5,
      'isRegular': true,
    },
    {
      'id': '6',
      'name': 'Victory Turf',
      'location': 'RS Puram, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1551958219-acbc608c6377',
      'bookings': 15,
      'rating': 4.4,
      'isRegular': true,
    },
  ];

  // Available time slots
  final List<Map<String, dynamic>> timeSlots = [
    {'time': '06:00 AM', 'available': true},
    {'time': '08:00 AM', 'available': true},
    {'time': '10:00 AM', 'available': false},
    {'time': '12:00 PM', 'available': true},
    {'time': '02:00 PM', 'available': true},
    {'time': '04:00 PM', 'available': false},
    {'time': '06:00 PM', 'available': true},
    {'time': '08:00 PM', 'available': true},
  ];

  // Credit transactions
  final List<Map<String, dynamic>> creditTransactions = [
    {
      'type': 'earned',
      'title': 'Redhills Arena',
      'description': 'Booking completed • Jan 15, 2024',
      'credits': '+10',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF4CAF50),
    },
    {
      'type': 'earned',
      'title': 'Elite Football Ground',
      'description': 'Booking completed • Jan 12, 2024',
      'credits': '+10',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF4CAF50),
    },
    {
      'type': 'earned',
      'title': 'Weekend Bonus',
      'description': 'Weekend booking • Jan 8, 2024',
      'credits': '+20',
      'icon': Icons.celebration_outlined,
      'color': Color(0xFF2196F3),
    },
    {
      'type': 'lost',
      'title': 'Late Cancellation',
      'description': 'Sports Hub Arena • Jan 10, 2024',
      'credits': '-20',
      'icon': Icons.cancel_outlined,
      'color': Color(0xFFF44336),
    },
    {
      'type': 'earned',
      'title': 'Referral Bonus',
      'description': 'Friend referral • Jan 5, 2024',
      'credits': '+50',
      'icon': Icons.people_outline,
      'color': Color(0xFF9C27B0),
    },
    {
      'type': 'used',
      'title': 'Free Booking Redeemed',
      'description': 'Redhills Arena • Dec 28, 2023',
      'credits': '-100',
      'icon': Icons.sports_soccer,
      'color': Color(0xFFFF9800),
    },
  ];

  void _showHowItWorksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            SizedBox(width: 10),
            Text(
              "How It Works",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoDialogItem(
                "1. Credit System",
                "• 1 booking = 10 credits",
              ),
              SizedBox(height: 8),
              _buildInfoDialogItem(
                "2. Free Booking",
                "• 100 credits = 1 free booking",
              ),
              SizedBox(height: 8),
              _buildInfoDialogItem(
                "3. Regular Turfs",
                "• Free bookings available only for your regularly booked turfs",
              ),
              SizedBox(height: 8),
              _buildInfoDialogItem(
                "4. Weekend Bonus",
                "• Weekend bookings earn 20 credits each",
              ),
              SizedBox(height: 8),
              _buildInfoDialogItem(
                "5. Referral Bonus",
                "• Refer friends for 50 credit bonus",
              ),
              SizedBox(height: 8),
              _buildInfoDialogItem(
                "6. Penalties",
                "• Late cancellations deduct 20 credits",
              ),
              SizedBox(height: 8),
              _buildInfoDialogItem(
                "7. Target Reset",
                "• After redemption, target resets to 100 credits",
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tip: Book regularly at the same turf to unlock free bookings!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got It',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDialogItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  void _showRedeemScreen() {
    if (_creditsEarned < _currentTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need ${_currentTarget - _creditsEarned} more credits to redeem a free booking',
          ),
          backgroundColor: Colors.orange,
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
            height:
                MediaQuery.of(context).size.height *
                0.9, // Reduced height to prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Redeem Free Booking',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Free bookings available only for regularly booked turfs',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Turf Selection with fixed height container
                const Text(
                  'Select Regular Turf',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 250, // Fixed height to prevent overflow
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: regularTurfs.length,
                    itemBuilder: (context, index) {
                      final turf = regularTurfs[index];
                      final isSelected = _selectedTurf == turf['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(turf['image'] as String),
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
                                    Icons.event,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${turf['bookings']} bookings',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedTurf = turf['id'] as String;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Time Slot Selection with fixed height
                const Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 70, // Fixed height for time slots
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      final isSelected = _selectedSlot == slot['time'];
                      final isAvailable = slot['available'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            slot['time'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : isAvailable
                                  ? Colors.black87
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: isAvailable
                              ? Colors.grey.shade100
                              : Colors.grey.shade200,
                          disabledColor: Colors.grey.shade200,
                          onSelected: isAvailable
                              ? (selected) {
                                  setState(() {
                                    _selectedSlot = selected
                                        ? slot['time'] as String
                                        : null;
                                  });
                                }
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? primaryColor
                                  : isAvailable
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Redeem Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Credits Required:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '100 credits',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Credits:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '$_creditsEarned credits',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ELIGIBLE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Redeem Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedTurf == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a turf'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      if (_selectedSlot == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a time slot'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Handle redemption
                      Navigator.pop(context);
                      _showConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Redeem Free Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.check_circle,
          color: Color(0xFF4CAF50),
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Booking Redeemed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              'Your free booking has been confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Text(
              'Next Target: 100 credits',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Update state after redemption
              setState(() {
                _creditsEarned = 0;
                // Target remains 100 credits for next free booking
              });
            },
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Credits & Rewards",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showHowItWorksDialog,
            tooltip: 'How it works',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics:
            const ClampingScrollPhysics(), // Changed to ClampingScrollPhysics
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              // Main Credit Balance Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "CREDITS EARNED",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _creditsEarned.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "out of $_currentTarget needed",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          title: "Total Credits",
                          value: userCredits['totalCredits'].toString(),
                          color: Colors.green[700]!,
                          icon: Icons.add_circle_outline,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        _buildStatItem(
                          title: "Available Credits",
                          value: userCredits['availableCredits'].toString(),
                          color: Colors.blue[700]!,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        _buildStatItem(
                          title: "Used Credits",
                          value: userCredits['usedCredits'].toString(),
                          color: Colors.orange[700]!,
                          icon: Icons.remove_circle_outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress to Free Booking
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Free Booking Progress",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$_creditsEarned/$_currentTarget",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _creditsEarned >= _currentTarget
                          ? "You're eligible for a free booking!"
                          : "Earn ${_currentTarget - _creditsEarned} more credits for a free booking",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Progress Bar
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width:
                                (MediaQuery.of(context).size.width - 80) *
                                (_creditsEarned / _currentTarget),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$_creditsEarned credits earned",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "$_currentTarget target",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // How It Works Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
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
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "How It Works",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showHowItWorksDialog,
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoPoint("• 1 booking = 10 credits"),
                    const SizedBox(height: 8),
                    _buildInfoPoint("• 100 credits = 1 free booking"),
                    const SizedBox(height: 8),
                    _buildInfoPoint(
                      "• Free bookings for regularly booked turfs only",
                    ),
                    const SizedBox(height: 8),
                    _buildInfoPoint("• Weekend bookings earn 20 credits"),
                    const SizedBox(height: 8),
                    _buildInfoPoint("• Refer friends for 50 credit bonus"),
                    const SizedBox(height: 8),
                    _buildInfoPoint("• Late cancellations deduct 20 credits"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Credit Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Credit Activity",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Track your credits earned and used",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),

                    // Category Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedCategory == 0
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Earned",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedCategory == 0
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedCategory == 1
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Used",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedCategory == 1
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
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

              const SizedBox(height: 20),

              // Transactions List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: creditTransactions
                      .where(
                        (transaction) => _selectedCategory == 0
                            ? transaction['type'] == 'earned' ||
                                  transaction['type'] == 'lost'
                            : transaction['type'] == 'used',
                      )
                      .map(
                        (transaction) => _buildTransactionItem(
                          icon: transaction['icon'] as IconData,
                          title: transaction['title'] as String,
                          description: transaction['description'] as String,
                          credits: transaction['credits'] as String,
                          color: transaction['color'] as Color,
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Redeem CTA
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _creditsEarned >= _currentTarget
                          ? Icons.celebration
                          : Icons.timeline,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _creditsEarned >= _currentTarget
                          ? "Ready to Redeem!"
                          : "Keep Going!",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _creditsEarned >= _currentTarget
                          ? "You've earned $_currentTarget credits"
                          : "$_creditsEarned/$_currentTarget credits earned",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Next Target: 100 credits",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showRedeemScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _creditsEarned >= _currentTarget
                              ? "REDEEM FREE BOOKING"
                              : "NEED ${_currentTarget - _creditsEarned} MORE CREDITS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _creditsEarned >= _currentTarget
                                ? primaryColor
                                : Colors.orange[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String description,
    required String credits,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            credits,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: credits.startsWith('+')
                  ? Colors.green[700]
                  : credits.startsWith('-')
                  ? Colors.red[700]
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle, size: 8, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
