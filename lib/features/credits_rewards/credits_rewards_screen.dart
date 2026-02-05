import 'package:flutter/material.dart';

class CreditsRewardsScreen extends StatefulWidget {
  const CreditsRewardsScreen({super.key});

  @override
  State<CreditsRewardsScreen> createState() => _CreditsRewardsScreenState();
}

class _CreditsRewardsScreenState extends State<CreditsRewardsScreen> {
  int _selectedCategory = 0; // 0: Earned, 1: Used
  int _currentTarget = 10; // Current booking target for free booking
  int _bookingsMade = 7; // Bookings made towards current target
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

  // User's frequently played turfs
  final List<Map<String, dynamic>> frequentTurfs = [
    {
      'id': '1',
      'name': 'Redhills Arena',
      'location': 'Redhills, Chennai',
      'image': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68',
      'bookings': 12,
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Elite Football Ground',
      'location': 'Race Course, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1511886929837-354d827aae26',
      'bookings': 8,
      'rating': 4.9,
    },
    {
      'id': '3',
      'name': 'Sports Hub Arena',
      'location': 'Peelamedu, Coimbatore',
      'image': 'https://images.unsplash.com/photo-1531315630201-bb15abeb1653',
      'bookings': 5,
      'rating': 4.6,
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
      'credits': '+1',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF4CAF50),
    },
    {
      'type': 'earned',
      'title': 'Elite Football Ground',
      'description': 'Booking completed • Jan 12, 2024',
      'credits': '+1',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF4CAF50),
    },
    {
      'type': 'earned',
      'title': 'Weekend Bonus',
      'description': 'Weekend booking • Jan 8, 2024',
      'credits': '+2',
      'icon': Icons.celebration_outlined,
      'color': Color(0xFF2196F3),
    },
    {
      'type': 'lost',
      'title': 'Late Cancellation',
      'description': 'Sports Hub Arena • Jan 10, 2024',
      'credits': '-2',
      'icon': Icons.cancel_outlined,
      'color': Color(0xFFF44336),
    },
    {
      'type': 'earned',
      'title': 'Referral Bonus',
      'description': 'Friend referral • Jan 5, 2024',
      'credits': '+5',
      'icon': Icons.people_outline,
      'color': Color(0xFF9C27B0),
    },
    {
      'type': 'used',
      'title': 'Free Booking Redeemed',
      'description': 'Redhills Arena • Dec 28, 2023',
      'credits': '-10',
      'icon': Icons.sports_soccer,
      'color': Color(0xFFFF9800),
    },
  ];

  void _showRedeemScreen() {
    if (_bookingsMade < _currentTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need ${_currentTarget - _bookingsMade} more bookings to redeem a free booking',
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
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                const SizedBox(height: 10),
                const Text(
                  'Book your favorite turf using your credits',
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
                    itemCount: frequentTurfs.length,
                    itemBuilder: (context, index) {
                      final turf = frequentTurfs[index];
                      final isSelected = _selectedTurf == turf['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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

                // Time Slot Selection
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
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      final isSelected = _selectedSlot == slot['time'];
                      final isAvailable = slot['available'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            slot['time'] as String,
                            style: TextStyle(
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

                const SizedBox(height: 30),

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
                            'Your Booking Target:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '$_bookingsMade/$_currentTarget bookings',
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
              'Next Target: ${_currentTarget + 10} bookings',
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
                _bookingsMade = 0;
                _currentTarget += 10;
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                    "BOOKINGS MADE",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _bookingsMade.toString(),
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
                        title: "Credits Earned",
                        value: userCredits['totalCredits'].toString(),
                        color: Colors.green[700]!,
                        icon: Icons.add_circle_outline,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      _buildStatItem(
                        title: "Credits Used",
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
                          "$_bookingsMade/$_currentTarget",
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
                    _bookingsMade >= _currentTarget
                        ? "You're eligible for a free booking!"
                        : "Complete ${_currentTarget - _bookingsMade} more bookings for a free slot",
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
                              (_bookingsMade / _currentTarget),
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
                        "$_bookingsMade bookings made",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Text(
                        "$_currentTarget target",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildInfoPoint("• 1 booking = 1 credit"),
                  const SizedBox(height: 8),
                  _buildInfoPoint("• Complete 10 bookings = 1 free booking"),
                  const SizedBox(height: 8),
                  _buildInfoPoint("• After redemption, target increases by 10"),
                  const SizedBox(height: 8),
                  _buildInfoPoint("• Weekend bookings earn 2 credits each"),
                  const SizedBox(height: 8),
                  _buildInfoPoint("• Refer friends for 5 credit bonus"),
                  const SizedBox(height: 8),
                  _buildInfoPoint("• Late cancellations deduct 2 credits"),
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    _bookingsMade >= _currentTarget
                        ? Icons.celebration
                        : Icons.timeline,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _bookingsMade >= _currentTarget
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
                    _bookingsMade >= _currentTarget
                        ? "You've completed $_currentTarget bookings"
                        : "$_bookingsMade/$_currentTarget bookings completed",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Next Target: ${_currentTarget + 10} bookings",
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
                      ),
                      child: Text(
                        _bookingsMade >= _currentTarget
                            ? "REDEEM FREE BOOKING"
                            : "NEED ${_currentTarget - _bookingsMade} MORE BOOKINGS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _bookingsMade >= _currentTarget
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
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
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
