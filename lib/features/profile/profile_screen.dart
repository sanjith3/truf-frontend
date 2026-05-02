import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:turfspotx/features/partner/join_partner_screen.dart';
import 'package:turfspotx/features/bookings/my_bookings_screen.dart';
import 'package:turfspotx/features/Help_support/help_support_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:turfspotx/features/credits_rewards/credits_rewards_screen.dart';
import 'package:turfspotx/screens/login_screen.dart';
import 'package:turfspotx/features/profile/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfspotx/features/Admin_pinset/admin_pin_screen.dart';
import '../../services/auth_state.dart';
import 'package:turfspotx/features/referral/invite_friends_screen.dart';
import 'package:turfspotx/features/wallet/wallet_screen.dart';
import '../../models/loyalty_tier.dart';
import '../../screens/loyalty/loyalty_tiers_screen.dart';
import '../../screens/support/support_ticket_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "User Name";
  String _userEmail = "user@example.com";
  String _userPhone = "+91 98765 43210";
  String _userDob = "";
  File? _userImage;
  bool _isPartner = false;
  String _memberSince = "";
  int _totalBookings = 0;
  int _credits = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "User Name";

      String? savedEmail = prefs.getString('userEmail');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _userEmail = savedEmail;
      } else {
        // Generate default email based on name (e.g., Ram -> ram@gmail.com)
        String cleanName = _userName.toLowerCase().replaceAll(
          RegExp(r'\s+'),
          '',
        );
        _userEmail = "$cleanName@gmail.com";
      }

      String? phone = prefs.getString('userPhone');
      _userPhone = phone != null ? "+91 $phone" : "Phone number not set";
      _isPartner = AuthState.instance.isOwner;
    });

    // Fetch live stats from backend
    _loadProfileStats();
  }

  Future<void> _loadProfileStats() async {
    print('📡 Calling _loadProfileStats()');
    try {
      // Refresh auth state from API (keeps role in sync)
      await AuthState.instance.loadProfile();

      final user = AuthState.instance.userProfile;
      print('📥 AuthState userProfile: $user');
      if (user != null && mounted) {
        setState(() {
          _totalBookings = user['total_bookings'] ?? 0;
          _credits = user['available_credits'] ?? 0;
          _isPartner = AuthState.instance.isOwner;
          _userDob = user['date_of_birth'] ?? "";

          if (user['created_at'] != null) {
            try {
              final createdAt = DateTime.parse(user['created_at']);
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
              _memberSince = '${months[createdAt.month - 1]} ${createdAt.year}';
              print('✅ Member since correctly set to: $_memberSince');
            } catch (e) {
              print('❌ Date Parse Error: $e');
              _memberSince = '';
            }
          } else {
            print('⚠️ user["created_at"] is null!');
          }
        });
      } else {
        print('⚠️ Either user is null or widget is not mounted');
      }
    } catch (e) {
      // Silently fail — show 0 on error
      debugPrint('❌ Profile stats error: $e');
      if (mounted) {
        setState(() {
          _memberSince = '';
        });
      }
    }
  }

  Widget build(BuildContext context) {
    final userStats = {
      'totalBookings': _totalBookings,
      'credits': _credits,
      'memberSince': _memberSince,
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar - Reduced height significantly
          SliverAppBar(
            expandedHeight: 60, // Much smaller
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1DB954),
            elevation: 0,
            centerTitle: false,
            title: const Text(
              "Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 22,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        currentName: _userName,
                        currentEmail: _userEmail,
                        currentDob: _userDob,
                      ),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    final newDob = result['dob'];
                    final newName = result['name'] ?? _userName;

                    setState(() {
                      _userName = newName;
                      _userEmail = result['email'] ?? _userEmail;
                      _userImage = result['image'];
                      _userDob = newDob ?? _userDob;
                    });

                    // Sync with backend
                    try {
                      final api = ApiService();
                      await api.putAuth(
                        '/api/users/user-profile/update_profile/',
                        body: {
                          'first_name': newName,
                          if (newDob != null && newDob.toString().isNotEmpty)
                            'date_of_birth': newDob,
                        },
                      );
                      // Trigger a profile reload so other screens get updated info
                      await AuthState.instance.loadProfile();
                    } catch (e) {
                      print('❌ Profile Update API Error: $e');
                    }
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1DB954), const Color(0xFF17A34A)],
                  ),
                ),
              ),
            ),
          ),

          // Profile Header Section - Minimal transformation
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -10, 0),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Profile Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Image
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFF1DB954,
                                    ).withOpacity(0.2),
                                    width: 3,
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1DB954),
                                      Color(0xFF17A34A),
                                    ],
                                  ),
                                ),
                                child: ClipOval(
                                  child: _userImage != null
                                      ? Image.file(
                                          _userImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 45,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              // Verified Badge
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1DB954),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: Color(0xFF1DB954),
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // User Info
                          Column(
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userEmail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userPhone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Member Since
                          if (userStats['memberSince'] != '')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DB954).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: const Color(0xFF1DB954),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Member since ${userStats['memberSince']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1DB954),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats Grid - 2 items only
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                        value: userStats['totalBookings'].toString(),
                        label: "Total Bookings",
                        icon: Icons.confirmation_number,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        value: userStats['credits'].toString(),
                        label: "Credits",
                        icon: Icons.credit_score,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Menu Options
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // My Bookings
                _buildMenuCard(
                  icon: Icons.calendar_today,
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

                const SizedBox(height: 10),

                // Credits & Rewards
                _buildMenuCard(
                  icon: Icons.credit_score,
                  title: "Credits & Rewards",
                  subtitle: "View your credits and rewards",
                  badge: "New",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreditsRewardsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Invite Friends
                _buildMenuCard(
                  icon: Icons.card_giftcard,
                  title: "Invite Friends",
                  subtitle: "Earn ₹50 per friend who books",
                  badge: "₹50",
                  iconColor: const Color(0xFFFF6B00),
                  bgColor: const Color(0xFFFF6B00).withOpacity(0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InviteFriendsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Wallet
                _buildMenuCard(
                  icon: Icons.account_balance_wallet,
                  title: "Wallet",
                  subtitle: "View balance, cashback & transactions",
                  iconColor: const Color(0xFF6C63FF),
                  bgColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Loyalty Badge
                _buildLoyaltyCard(),

                const SizedBox(height: 10),

                // My Support Tickets
                _buildMenuCard(
                  icon: Icons.support_agent,
                  title: "My Support Tickets",
                  subtitle: "View and reply to your open tickets",
                  iconColor: const Color(0xFF00B4D8),
                  bgColor: const Color(0xFF00B4D8).withOpacity(0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupportTicketListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Help & Support
                _buildMenuCard(
                  icon: Icons.help_center,
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

                const SizedBox(height: 10),

                // Become a Partner - Only show if NOT already a partner
                if (!_isPartner)
                  _buildMenuCard(
                    icon: Icons.business_center,
                    title: "Become a Partner",
                    subtitle: "List your turf and earn money",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JoinPartnerScreen(),
                        ),
                      ).then(
                        (_) => _loadUserData(),
                      ); // Refresh status when back
                    },
                  ),

                if (_isPartner)
                  _buildMenuCard(
                    icon: Icons.workspace_premium,
                    iconColor: const Color(0xFFFFD700),
                    bgColor: const Color(0xFFFFD700).withOpacity(0.1),
                    title: "Partner Dashboard",
                    subtitle: "Manage your registered turf",
                    onTap: () async {
                      // Check if owner has approved turf
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      final status = await _checkApprovalStatus();

                      if (context.mounted) {
                        Navigator.pop(context); // Remove loading dialog
                      }

                      if (status['can_access'] == true) {
                        // Has approved turf → go to PIN
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AdminPinScreen(pushOnSuccess: true),
                            ),
                          );
                        }
                      } else {
                        // No approved turf → show pending message
                        if (context.mounted) {
                          _showPendingApprovalDialog(status);
                        }
                      }
                    },
                  ),

                const SizedBox(height: 10),

                // Privacy Policy
                _buildMenuCard(
                  icon: Icons.privacy_tip,
                  title: "Privacy Policy",
                  subtitle: "How we handle your data",
                  onTap: () => _launchURL("https://TurfSpotX.com/legal/privacy"),
                ),

                const SizedBox(height: 10),

                // Terms & Conditions
                _buildMenuCard(
                  icon: Icons.description,
                  title: "Terms & Conditions",
                  subtitle: "User agreement and policies",
                  onTap: () => _launchURL("https://TurfSpotX.com/legal/terms"),
                ),

                const SizedBox(height: 20),

                // Logout Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _showLogoutDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.logout,
                                color: Colors.red.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Sign out from your account",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.grass,
                          size: 32,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "TurfSpotX",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "v1.0.0",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "© 2024 TurfSpotX. All rights reserved.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? iconColor,
    Color? bgColor,
  }) {
    final themeColor = const Color(0xFF1DB954);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor ?? themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor ?? themeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
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
                      color: Colors.black.withOpacity(0.15),
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
                              onTap: () async {
                                debugPrint("Logout button pressed");

                                // 1. Clear JWT tokens (CRITICAL — prevents auto-login)
                                await ApiService.clearTokens();
                                await AuthState.instance.clear();

                                // 2. Clear all cached user data
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('userName');
                                await prefs.remove('userEmail');
                                await prefs.remove('userPhone');
                                await prefs.remove('hasShownWelcome');
                                await prefs.remove('isPartner');
                                await prefs.remove('registeredTurfName');
                                await prefs.remove('registeredLocation');
                                await prefs.remove('registeredPrice');
                                await prefs.remove('isLoggedIn');
                                await prefs.remove('userRole');

                                // 3. Reset navigation stack — remove ALL routes
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Logged out successfully"),
                                      backgroundColor: Color(0xFF1DB954),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
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

  Widget _buildLoyaltyCard() {
    final bookings = _totalBookings; // From your state
    final currentTier = LoyaltyTier.getTierForBookings(bookings);

    // Find next tier
    final nextTierIndex = LoyaltyTier.allTiers.indexWhere(
      (tier) => tier.minBookings > bookings,
    );
    final nextTier = nextTierIndex != -1
        ? LoyaltyTier.allTiers[nextTierIndex]
        : null;

    // Calculate progress to next tier
    double progress = 1.0;
    String progressText = '';

    if (nextTier != null) {
      final neededForCurrent = currentTier.minBookings;
      final neededForNext = nextTier.minBookings;
      progress =
          (bookings - neededForCurrent) / (neededForNext - neededForCurrent);
      progress = progress.clamp(0.0, 1.0);
      progressText = '$bookings/${nextTier.minBookings} bookings';
    } else {
      progressText = '$bookings bookings (Max tier)';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoyaltyTiersScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentTier.color.withOpacity(0.2),
              currentTier.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: currentTier.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentTier.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    currentTier.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentTier.displayName} Member',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        progressText,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: currentTier.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(currentTier.color),
                minHeight: 6,
              ),
            ),
            if (nextTier != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTier.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: currentTier.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${nextTier.minBookings - bookings} more to ${nextTier.displayName}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    nextTier.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: nextTier.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _checkApprovalStatus() async {
    try {
      final response = await ApiService().getAuth(
        '/api/users/owner/approval-status/',
      );
      return response;
    } catch (e) {
      return {'can_access': false, 'message': 'Error checking status'};
    }
  }

  void _showPendingApprovalDialog(Map<String, dynamic> status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏳ Pending Approval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your turf is under review by our team.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              '• Pending turfs: ${status['pending_count'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '• Approved turfs: ${status['approved_count'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              'You will be notified once approved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
