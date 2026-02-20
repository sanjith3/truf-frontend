import 'package:flutter/material.dart';
import 'package:turfzone/features/home/user_home_screen.dart';
import 'package:turfzone/features/editslottime/edit_turf_screen.dart';
import 'my_bookings_screen.dart';
import 'package:turfzone/models/booking.dart';
import '../../services/api_service.dart';
import 'package:turfzone/features/turfslot/slot_management_screen.dart';
import 'package:turfzone/features/partner/join_partner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reports_screen.dart';
import '../../services/turf_data_service.dart';

// Turf model for admin
class AdminTurf {
  final String id;
  final String name;
  final String location;
  final double distance;
  final int price;
  final double rating;
  final List<String> images;
  final List<String> amenities;
  final String mapLink;
  final String address;
  final String description;
  final int todayBookings;
  final double todayRevenue;
  final int totalBookings;
  final double totalRevenue;
  final int slotsCount;
  final double avgRating;
  bool isActive;

  AdminTurf({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.price,
    required this.rating,
    required this.images,
    required this.amenities,
    required this.mapLink,
    required this.address,
    required this.description,
    this.todayBookings = 0,
    this.todayRevenue = 0,
    this.totalBookings = 0,
    this.totalRevenue = 0,
    this.slotsCount = 0,
    this.avgRating = 0,
    this.isActive = true,
  });
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedNavIndex = 0;
  final Color primaryGreen = const Color(0xFF1DB954);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  String? _registeredTurfName;
  List<String> _registeredTurfNames = [];
  List<AdminTurf> _filteredAdminTurfs = [];

  // Live dashboard stats from API
  Map<String, dynamic> _dashboardStats = {};

  final TurfDataService _turfService = TurfDataService();

  @override
  void initState() {
    super.initState();
    _turfService.addListener(_onDataChanged);
    // Load local data first (immediate), then fetch from API
    _loadRegisteredTurf();
    _initOwnerTurfs();
    _loadDashboardStats();
  }

  /// Fetch owner turfs from API, then rebuild dashboard
  Future<void> _initOwnerTurfs() async {
    try {
      await _turfService.loadMyTurfs();
      print(
        '🏠 _initOwnerTurfs: loadMyTurfs completed, ${_turfService.myTurfs.length} turfs',
      );
    } catch (e) {
      print('🚨 _initOwnerTurfs error: $e');
    }
    // Rebuild dashboard with API data
    if (mounted) {
      _loadRegisteredTurf();
    }
  }

  @override
  void dispose() {
    _turfService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      _loadRegisteredTurf();
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Fetch aggregate dashboard stats from backend
  Future<void> _loadDashboardStats() async {
    try {
      final api = ApiService();
      final res = await api.getAuth('/api/turfs/turfs/owner_dashboard_stats/');
      if (res['success'] == true && mounted) {
        setState(() => _dashboardStats = res);
      }
    } catch (e) {
      debugPrint('Dashboard stats error: $e');
    }
  }

  Future<void> _loadRegisteredTurf() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Partner";
      _userPhone = prefs.getString('userPhone') ?? "";
      _userEmail = prefs.getString('userEmail') ?? "";
      _businessName = prefs.getString('businessName') ?? "";

      _registeredTurfNames =
          prefs.getStringList('registeredTurfNames_$_userPhone') ?? [];
      _registeredTurfName = prefs.getString('registeredTurfName');

      if (_registeredTurfName != null &&
          !_registeredTurfNames.contains(_registeredTurfName)) {
        _registeredTurfNames.add(_registeredTurfName!);
      }

      _filteredAdminTurfs = [];
      Set<String> processedIds = {};
      final now = DateTime.now();

      // ── PRIMARY: Use API turfs from loadMyTurfs() ──
      final apiTurfs = _turfService.myTurfs;
      final rawTurfs = _turfService.myTurfsRaw;
      if (apiTurfs.isNotEmpty) {
        print('🏠 OWNER DASH: ${apiTurfs.length} turfs from API');
        for (var i = 0; i < apiTurfs.length; i++) {
          final turf = apiTurfs[i];
          // Extract stats from raw JSON (may be null for public browsing)
          final rawStats = (i < rawTurfs.length)
              ? rawTurfs[i]['stats'] as Map<String, dynamic>?
              : null;

          processedIds.add(turf.id.toString());
          _filteredAdminTurfs.add(
            AdminTurf(
              id: turf.id.toString(),
              name: turf.name,
              location: turf.city,
              distance: turf.distance,
              price: turf.price,
              rating: turf.rating,
              images: turf.images.isNotEmpty
                  ? turf.images
                  : [
                      'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
                    ],
              amenities: turf.amenities,
              mapLink: turf.mapLink,
              address: turf.address,
              description: turf.description,
              todayBookings: rawStats?['today_bookings'] ?? 0,
              todayRevenue:
                  double.tryParse('${rawStats?['today_revenue'] ?? 0}') ?? 0,
              totalBookings: rawStats?['total_bookings'] ?? 0,
              totalRevenue:
                  double.tryParse('${rawStats?['total_revenue'] ?? 0}') ?? 0,
              slotsCount: rawStats?['slots_count'] ?? 0,
              avgRating: (rawStats?['avg_rating'] ?? 0).toDouble(),
              isActive: turf.turfStatus == 'approved',
            ),
          );
        }
      }

      // ── FALLBACK: Add locally registered turfs not yet in API ──
      Set<String> processedNames = processedIds.isNotEmpty
          ? _filteredAdminTurfs.map((t) => t.name.toLowerCase()).toSet()
          : {};

      for (var name in _registeredTurfNames) {
        if (processedNames.contains(name.toLowerCase())) continue;

        final turfBookings = TurfDataService().bookings
            .where(
              (b) =>
                  b.turfName == name &&
                  isSameDay(b.date, now) &&
                  b.status != BookingStatus.cancelled,
            )
            .toList();

        int todayBookings = turfBookings.length;
        double todayRevenue = turfBookings.fold(
          0.0,
          (sum, b) => sum + b.amount,
        );

        final savedSlots = TurfDataService().getSavedSlots(name, now);
        int slotsCount;
        if (savedSlots != null) {
          slotsCount = savedSlots
              .where((s) => s['status'] == 'available' && s['disabled'] != true)
              .length;
        } else {
          slotsCount = 24 - todayBookings;
        }

        final matches = adminTurfs
            .where((t) => t.name.toLowerCase() == name.toLowerCase())
            .toList();

        if (matches.isNotEmpty) {
          for (var mat in matches) {
            _filteredAdminTurfs.add(
              AdminTurf(
                id: mat.id,
                name: mat.name,
                location: mat.location,
                distance: mat.distance,
                price: mat.price,
                rating: mat.rating,
                images: mat.images,
                amenities: mat.amenities,
                mapLink: mat.mapLink,
                address: mat.address,
                description: mat.description,
                todayBookings: todayBookings,
                todayRevenue: todayRevenue.toDouble(),
                slotsCount: slotsCount,
                isActive: mat.isActive,
              ),
            );
          }
        } else {
          // Dynamic turf from SharedPreferences
          String? loc = prefs.getString('turf_data_${name}_location');
          int? price = prefs.getInt('turf_data_${name}_price');

          if (loc == null && name == _registeredTurfName) {
            loc = prefs.getString('registeredLocation');
            price = prefs.getInt('registeredPrice');
          }

          _filteredAdminTurfs.add(
            AdminTurf(
              id: 'reg_${name}_${now.millisecondsSinceEpoch}',
              name: name,
              location: loc ?? "Registered Location",
              distance: 0.0,
              price: price ?? 500,
              rating: 5.0,
              images: [
                "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800",
              ],
              amenities: ["All Standards"],
              mapLink: "",
              address: "Your Registered Address",
              description: "Your newly registered turf",
              todayBookings: todayBookings,
              todayRevenue: todayRevenue.toDouble(),
              slotsCount: slotsCount,
            ),
          );
        }
        processedNames.add(name.toLowerCase());
      }

      print('🏠 TOTAL ADMIN TURFS: ${_filteredAdminTurfs.length}');
      _updateNavScreens();
    });
  }

  String _userName = "Partner";
  String _userPhone = "";
  String _userEmail = "";
  String _businessName = "";

  Future<void> _showPartnerProfile() async {
    final nameController = TextEditingController(text: _userName);
    final phoneController = TextEditingController(text: _userPhone);
    final emailController = TextEditingController(text: _userEmail);
    final businessController = TextEditingController(text: _businessName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Partner Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Your business information",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              _buildProfileField(
                "Full Name",
                nameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildProfileField(
                "Phone Number",
                phoneController,
                Icons.phone_android_outlined,
              ),
              const SizedBox(height: 20),
              _buildProfileField(
                "Email Address",
                emailController,
                Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              _buildProfileField(
                "Business/Brand Name",
                businessController,
                Icons.business_outlined,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'userName',
                      nameController.text.trim(),
                    );
                    await prefs.setString(
                      'userPhone',
                      phoneController.text.trim(),
                    );
                    await prefs.setString(
                      'userEmail',
                      emailController.text.trim(),
                    );
                    await prefs.setString(
                      'businessName',
                      businessController.text.trim(),
                    );

                    setState(() {
                      _userName = nameController.text.trim();
                      _userPhone = phoneController.text.trim();
                      _userEmail = emailController.text.trim();
                      _businessName = businessController.text.trim();
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated successfully"),
                        backgroundColor: Color(0xFF1DB954),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryGreen),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  // Admin turfs data — previously hardcoded, now all from API
  List<AdminTurf> adminTurfs = [];

  // Business Stats — from live API
  double get totalRevenue {
    final val = _dashboardStats['today_revenue'];
    if (val == null) return 0;
    return double.tryParse('$val') ?? 0;
  }

  int get totalBookings {
    return (_dashboardStats['today_bookings'] as int?) ?? 0;
  }

  int get totalAvailableSlots =>
      _filteredAdminTurfs.fold(0, (sum, turf) => sum + turf.slotsCount);

  double get averageRating {
    final val = _dashboardStats['avg_rating'];
    if (val == null) return 0;
    return (val is num) ? val.toDouble() : (double.tryParse('$val') ?? 0);
  }

  // Navigation Screens
  List<Widget> _navScreens = [];

  void _updateNavScreens() {
    setState(() {
      _navScreens = [
        _buildDashboard(),
        ReportsScreen(
          registeredTurfNames: _registeredTurfNames.isNotEmpty
              ? _registeredTurfNames
              : (_registeredTurfName != null ? [_registeredTurfName!] : null),
        ),
      ];
    });
  }

  void _toggleTurfStatus(String turfId) {
    setState(() {
      final turf = _filteredAdminTurfs.firstWhere((t) => t.id == turfId);
      turf.isActive = !turf.isActive;
    });
  }

  // ------------------------------------------------------------
  // NEW: Disable Turf with Date Range & Reason
  // ------------------------------------------------------------
  Future<void> _showDisableTurfDialog(AdminTurf turf) async {
    DateTime? fromDate;
    DateTime? toDate;
    final reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text('Disable ${turf.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select date range and provide a reason for disabling this turf.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // From Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fromDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => fromDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fromDate == null
                                ? 'Select'
                                : _formatDate(fromDate!),
                          ),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // To Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: toDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => toDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            toDate == null ? 'Select' : _formatDate(toDate!),
                          ),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reason
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for disabling',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Maintenance, Event, etc.',
                    ),
                    maxLines: 2,
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
                onPressed: (fromDate == null || toDate == null)
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _submitDisableRequest(
                          turf,
                          fromDate!,
                          toDate!,
                          reasonController.text.trim(),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Disable'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitDisableRequest(
    AdminTurf turf,
    DateTime from,
    DateTime to,
    String reason,
  ) {
    // TODO: Implement actual backend request to notify "turfzone members"
    // For now, simulate a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Disable request sent for ${turf.name} from ${_formatDate(from)} to ${_formatDate(to)}.\nReason: ${reason.isEmpty ? 'Not provided' : reason}',
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 5),
      ),
    );

    // Optional: You can also mark the turf as temporarily inactive in the UI
    // setState(() { ... });
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_navScreens.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _navScreens[_selectedNavIndex]),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade800, Colors.green.shade700],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome $_userName 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Managing ${_filteredAdminTurfs.length} turfs',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserHomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinPartnerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _showPartnerProfile,
                      icon: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickStat(
                value: '₹${totalRevenue.toStringAsFixed(0)}',
                label: 'Today\'s Revenue',
                icon: Icons.trending_up,
                color: Colors.white,
              ),
              _buildQuickStat(
                value: '$totalBookings',
                label: 'Total Bookings',
                icon: Icons.event,
                color: Colors.white,
              ),
              _buildQuickStat(
                value: '${averageRating.toStringAsFixed(1)}★',
                label: 'Avg Rating',
                icon: Icons.star,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Turf Management',
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
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_filteredAdminTurfs.where((t) => t.isActive).length} Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your turf, slots and bookings',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._filteredAdminTurfs.map((turf) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildTurfCard(turf),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTurfCard(AdminTurf turf) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section - Image & Status
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  turf.images[0],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: turf.isActive ? primaryGreen : Colors.grey[700],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    turf.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Action Buttons Row (View Details + Disable)
              Positioned(
                bottom: 12,
                left: 12,
                child: Row(
                  children: [
                    // View Details Button
                    GestureDetector(
                      onTap: () => _showTurfDetails(turf),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // NEW: Disable Turf Button
                    GestureDetector(
                      onTap: () => _showDisableTurfDialog(turf),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.block,
                          size: 16,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            turf.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  turf.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${turf.price}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTurfStat(
                      icon: Icons.event,
                      value: '${turf.todayBookings}',
                      label: 'Bookings',
                      color: Colors.blue,
                    ),
                    _buildTurfStat(
                      icon: Icons.trending_up,
                      value: '₹${turf.todayRevenue.toInt()}',
                      label: 'Revenue',
                      color: primaryGreen,
                    ),
                    _buildTurfStat(
                      icon: Icons.schedule,
                      value: '${turf.slotsCount}',
                      label: 'Slots',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons Row (Slots, Edit, Bookings)
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTurfActionButton(
                          icon: Icons.schedule,
                          label: 'Slots',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SlotManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _buildTurfActionButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditTurfScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _buildTurfActionButton(
                          icon: Icons.receipt_long,
                          label: 'Bookings',
                          color: primaryGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurfStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTurfActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isSelected: _selectedNavIndex == 0,
              onTap: () => setState(() => _selectedNavIndex = 0),
            ),
            _buildNavItem(
              icon: Icons.analytics,
              label: 'Reports',
              isSelected: _selectedNavIndex == 1,
              onTap: () => setState(() => _selectedNavIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryGreen : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? primaryGreen : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTurfDetails(AdminTurf turf) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    turf.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        turf.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            turf.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Amenities',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: turf.amenities
                                .map(
                                  (amenity) => Chip(
                                    label: Text(amenity),
                                    backgroundColor: primaryGreen.withOpacity(
                                      0.1,
                                    ),
                                    labelStyle: TextStyle(color: primaryGreen),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
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
        );
      },
    );
  }
}
