import 'package:flutter/material.dart';
import 'package:turfzone/features/partner/join_partner_screen.dart';
import 'package:turfzone/features/bookings/my_bookings_screen.dart';
import 'package:turfzone/features/Help_support/help_support_screen.dart';
import 'package:turfzone/features/Privacy_policy/privacy_policy_screen.dart';
import 'package:turfzone/features/Terms_condition/terms_conditions_screen.dart';
// Add this import:
import 'package:turfzone/features/credits_rewards/credits_rewards_screen.dart'; // Add this line

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual user data
    final userStats = {
      'totalBookings': 24,
      'cancelledBookings': 3,
      'credits': 1250,
      'memberSince': 'Jan 2023',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header with better design
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1DB954),
                  const Color(0xFF1DB954),
                  const Color(0xFF1DB954).withOpacity(0.95),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
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
                // Profile Image with better shadow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background glow effect
                      Container(
                        width: 98,
                        height: 98,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      // Profile icon
                      Container(
                        width: 94,
                        height: 94,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1DB954),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      // Verified badge
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Color(0xFF1DB954),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // User Info with better typography
                Column(
                  children: [
                    const Text(
                      "John Doe",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "john.doe@example.com",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Member Since with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Member since ${userStats['memberSince']}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Cards - Floating above content
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.confirmation_number_outlined,
                      value: userStats['totalBookings'].toString(),
                      label: "Total Bookings",
                      color: const Color(0xFF1DB954),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    _buildStatItem(
                      icon: Icons.cancel_outlined,
                      value: userStats['cancelledBookings'].toString(),
                      label: "Cancelled",
                      color: Colors.orange,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    _buildStatItem(
                      icon: Icons.credit_score_outlined,
                      value: userStats['credits'].toString(),
                      label: "Credits",
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8), // Reduced spacing
          // Menu Options - Using Expanded to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Account Section
                    _buildMenuSection(
                      title: "Account",
                      items: [
                        _buildMenuTile(
                          icon: Icons.calendar_today_outlined,
                          title: "My Bookings",
                          subtitle: "View and manage your bookings",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen(),
                              ),
                            );
                          },
                        ),
                        // Updated this tile to navigate to CreditsRewardsScreen
                        _buildMenuTile(
                          icon: Icons.credit_score_outlined,
                          title: "Credits & Rewards",
                          subtitle: "View your credits and rewards",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreditsRewardsScreen(),
                              ),
                            );
                          },
                          showBadge: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Support Section
                    _buildMenuSection(
                      title: "Support",
                      items: [
                        _buildMenuTile(
                          icon: Icons.help_outline_outlined,
                          title: "Help & Support",
                          subtitle: "FAQs, Contact us, Feedback",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpSupportScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.business_outlined,
                          title: "Become a Partner",
                          subtitle: "List your turf and earn money",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JoinPartnerScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Legal Section
                    _buildMenuSection(
                      title: "Legal",
                      items: [
                        _buildMenuTile(
                          icon: Icons.privacy_tip_outlined,
                          title: "Privacy Policy",
                          subtitle: "How we handle your data",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.description_outlined,
                          title: "Terms & Conditions",
                          subtitle: "User agreement and policies",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsConditionsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Logout Button with better design
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _showLogoutDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Sign out from your account",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App Info with better styling
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "TurfZone v1.0.0",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "© 2024 TurfZone. All rights reserved.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
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
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                if (index < items.length - 1) {
                  return Column(
                    children: [
                      item,
                      Padding(
                        padding: const EdgeInsets.only(left: 72),
                        child: Divider(
                          height: 0,
                          thickness: 1,
                          color: Colors.grey.shade100,
                        ),
                      ),
                    ],
                  );
                }
                return item;
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1DB954), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              "New",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.red.shade600,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Are you sure you want to sign out from your account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(height: 0),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                    content: Text("Logged out successfully"),
                                    backgroundColor: Color(0xFF1DB954),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: EdgeInsets.all(20),
                                  ),
                                );
                              },
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}