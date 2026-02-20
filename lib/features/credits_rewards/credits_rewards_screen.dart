import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/turf.dart';
import '../../booking/booking_screen.dart';

class CreditsRewardsScreen extends StatefulWidget {
  const CreditsRewardsScreen({super.key});

  @override
  State<CreditsRewardsScreen> createState() => _CreditsRewardsScreenState();
}

class _CreditsRewardsScreenState extends State<CreditsRewardsScreen> {
  int _currentTarget = 100; // Display constant — backend enforces actual rule
  int _creditsEarned =
      0; // available_credits % 100 (progress towards next free booking)
  bool _isLoading = true;

  // Live data from API
  int _totalCredits = 0;
  int _availableCredits = 0;
  int _usedCredits = 0;

  // Professional color scheme
  final Color primaryColor = const Color(0xFF4CAF50); // Professional Green
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadCreditsData();
  }

  Future<void> _loadCreditsData() async {
    try {
      final response = await ApiService().getAuth(
        '/api/users/user-profile/me/',
      );
      if (response != null && response['success'] == true) {
        final user = response['user'];
        setState(() {
          _totalCredits = user['total_credits'] ?? 0;
          _availableCredits = user['available_credits'] ?? 0;
          _usedCredits = user['used_credits'] ?? 0;
          _creditsEarned = _availableCredits % _currentTarget;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Credits data error: $e');
      setState(() => _isLoading = false);
    }
  }

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
    if (_availableCredits < _currentTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need ${_currentTarget - (_availableCredits % _currentTarget)} more credits to redeem a free booking',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show confirmation, then turf picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Redeem Free Booking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          '100 credits will be deducted upon successful redemption.\n\nYou\'ll select a turf and one time slot next.',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showTurfPicker();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Choose Turf',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TURF PICKER BOTTOM SHEET ───
  void _showTurfPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TurfPickerSheet(
        onTurfSelected: (turf) {
          Navigator.pop(ctx); // close sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingScreen(turf: turf, isRedeemFlow: true),
            ),
          ).then((_) {
            // Refresh credits after returning
            _loadCreditsData();
          });
        },
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
                          value: _totalCredits.toString(),
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
                          value: _availableCredits.toString(),
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
                          value: _usedCredits.toString(),
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

// ─── TURF PICKER BOTTOM SHEET ───
class _TurfPickerSheet extends StatefulWidget {
  final void Function(Turf turf) onTurfSelected;
  const _TurfPickerSheet({required this.onTurfSelected});

  @override
  State<_TurfPickerSheet> createState() => _TurfPickerSheetState();
}

class _TurfPickerSheetState extends State<_TurfPickerSheet> {
  List<Turf> _turfs = [];
  List<Turf> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchTurfs();
  }

  Future<void> _fetchTurfs() async {
    try {
      final response = await ApiService().get('/api/turfs/turfs/');
      if (response != null && response['results'] != null) {
        final list = (response['results'] as List)
            .map((j) => Turf.fromJson(j))
            .toList();
        setState(() {
          _turfs = list;
          _filtered = list;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Turf fetch error: $e');
      setState(() => _loading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      _filtered = _turfs
          .where(
            (t) =>
                t.name.toLowerCase().contains(q.toLowerCase()) ||
                t.city.toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Turf for Free Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search turfs...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      _search.isEmpty
                          ? 'No turfs available'
                          : 'No turfs matching "$_search"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (_, i) {
                      final turf = _filtered[i];
                      final img = turf.images.isNotEmpty
                          ? turf.images[0]
                          : null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img != null
                                ? Image.network(
                                    img,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.sports_soccer,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.sports_soccer,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          title: Text(
                            turf.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            turf.city.isNotEmpty ? turf.city : turf.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onTap: () => widget.onTurfSelected(turf),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
