import 'package:flutter/material.dart';
import 'package:turfzone/features/editslottime/edit_turf_screen.dart';
import 'package:turfzone/features/Admindashboard/admin_turf_model.dart';
import 'my_bookings_screen.dart';
import '../../services/api_service.dart';
import 'package:turfzone/features/turfslot/slot_management_screen.dart';
import 'package:turfzone/features/partner/join_partner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reports_screen.dart';
import '../../services/turf_data_service.dart';
import 'pending_approval_screen.dart';
import 'referral_qr_card.dart';
import 'package:turfzone/features/home/user_home_screen.dart';

// ─── WIDGET ────────────────────────────────────────────────────────────────────

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // ── palette
  static const _green = Color(0xFF1DB954);
  static const _darkGreen = Color(0xFF158040);
  static const _bg = Color(0xFFF5F7F6);

  int _selectedNavIndex = 0;

  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _weeklyStats = {};
  List<AdminTurf> _filteredAdminTurfs = [];
  Map<String, dynamic>? _pendingApprovalData;

  String _userName = 'Partner';
  String _userPhone = '';
  String _userEmail = '';
  String _memberSince = '';

  final TurfDataService _turfService = TurfDataService();
  List<Widget> _navScreens = [];

  // ── init ────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _turfService.addListener(_onDataChanged);
    _loadAll();
  }

  @override
  void dispose() {
    _turfService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _rebuildTurfList();
  }

  Future<void> _loadAll() async {
    await _initOwnerTurfs();
    await Future.wait([_loadDashboardStats(), _loadWeeklyStats()]);
    _updateNavScreens();
  }

  Future<void> _refreshAll() async {
    await _initOwnerTurfs();
    await Future.wait([_loadDashboardStats(), _loadWeeklyStats()]);
    _updateNavScreens();
  }

  Future<void> _initOwnerTurfs() async {
    try {
      await _turfService.loadMyTurfs();
    } catch (e) {
      debugPrint('_initOwnerTurfs error: $e');
    }
    if (mounted) _rebuildTurfList();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final res = await ApiService().getAuth(
        '/api/turfs/turfs/owner_dashboard_stats/',
      );
      if (!mounted) return;
      if (res['success'] == true) {
        if (res['can_manage'] == false) {
          setState(() {
            _pendingApprovalData = res;
            _dashboardStats = {};
          });
        } else {
          setState(() {
            _dashboardStats = res;
            _pendingApprovalData = null;
          });
          _rebuildTurfList();
        }
      }
    } catch (e) {
      debugPrint('Dashboard stats error: $e');
    }
  }

  Future<void> _loadWeeklyStats() async {
    try {
      final res = await ApiService().getAuth('/api/turfs/turfs/weekly_stats/');
      if (!mounted || res['success'] != true) return;
      setState(() {
        _weeklyStats = res;
      });
      final perTurfList = res['per_turf'] as List<dynamic>? ?? [];
      final perTurfMap = <int, Map<String, dynamic>>{};
      for (final s in perTurfList) {
        final m = s as Map<String, dynamic>;
        perTurfMap[m['id'] as int] = m;
      }
      if (perTurfMap.isNotEmpty) {
        setState(() {
          _filteredAdminTurfs = _filteredAdminTurfs.map((turf) {
            final id = int.tryParse(turf.id) ?? -1;
            final ws = perTurfMap[id];
            if (ws == null) return turf;
            return turf.copyWith(
              weeklyRevenue: (ws['weekly_revenue'] as num?)?.toDouble() ?? 0,
              lastWeekRevenue:
                  (ws['last_week_revenue'] as num?)?.toDouble() ?? 0,
              weeklyBookings: (ws['weekly_bookings'] as int?) ?? 0,
              lastWeekBookings: (ws['last_week_bookings'] as int?) ?? 0,
              revenueChangePct:
                  (ws['revenue_change_pct'] as num?)?.toDouble() ?? 0,
              bookingChange: (ws['booking_change'] as int?) ?? 0,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Weekly stats error: $e');
    }
  }

  void _rebuildTurfList() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('userName') ?? 'Partner';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _memberSince = _formatMemberSince(
        prefs.getString('userJoinedDate') ?? '',
      );

      _filteredAdminTurfs = [];
      final apiTurfs = _turfService.myTurfs;
      final rawTurfs = _turfService.myTurfsRaw;

      final perTurfStats = <int, Map<String, dynamic>>{};
      final perTurf = _dashboardStats['per_turf_stats'] as List<dynamic>?;
      if (perTurf != null) {
        for (final s in perTurf) {
          final m = s as Map<String, dynamic>;
          perTurfStats[m['id'] as int] = m;
        }
      }

      for (var i = 0; i < apiTurfs.length; i++) {
        final turf = apiTurfs[i];
        final rawStats = (i < rawTurfs.length)
            ? rawTurfs[i]['stats'] as Map<String, dynamic>?
            : null;
        final statsMap =
            rawStats ??
            perTurfStats[int.tryParse(turf.id.toString()) ?? -1] ??
            <String, dynamic>{};

        final rawSports = (i < rawTurfs.length)
            ? rawTurfs[i]['sports'] as List<dynamic>?
            : null;
        final sportsList =
            rawSports
                ?.map((s) {
                  if (s is Map) return s['name']?.toString() ?? '';
                  return s.toString();
                })
                .where((s) => s.isNotEmpty)
                .toList() ??
            <String>[];

        _filteredAdminTurfs.add(
          AdminTurf(
            id: turf.id.toString(),
            name: turf.name,
            location: turf.city,
            distance: turf.distance,
            price: turf.price,
            rating: turf.rating,
            reviewCount: (statsMap['review_count'] as int?) ?? 0,
            images: turf.images,
            amenities: turf.amenities,
            sports: sportsList,
            mapLink: turf.mapLink,
            address: turf.address,
            description: turf.description,
            todayBookings: (statsMap['today_bookings'] as int?) ?? 0,
            todayRevenue:
                double.tryParse('${statsMap['today_revenue'] ?? 0}') ?? 0,
            totalBookings: (statsMap['total_bookings'] as int?) ?? 0,
            totalRevenue:
                double.tryParse('${statsMap['total_revenue'] ?? 0}') ?? 0,
            slotsCount: (statsMap['slots_count'] as int?) ?? 0,
            avgRating: ((statsMap['avg_rating'] ?? turf.rating) as num)
                .toDouble(),
            isShutdown: (statsMap['is_shutdown'] as bool?) ?? false,
            shutdownStart: statsMap['shutdown_start'] as String?,
            shutdownEnd: statsMap['shutdown_end'] as String?,
            shutdownReason: statsMap['shutdown_reason'] as String? ?? '',
            isActive: turf.turfStatus == 'approved',
          ),
        );
      }
      _updateNavScreens();
    });
  }

  void _updateNavScreens() {
    if (!mounted) return;
    setState(() {
      _navScreens = [
        _buildDashboard(),
        ReportsScreen(
          registeredTurfNames: _filteredAdminTurfs.map((t) => t.name).toList(),
        ),
      ];
    });
  }

  // ── Computed getters ─────────────────────────────────────────────────────────

  double get _weeklyRevenue {
    final v = (_weeklyStats['current_week'] as Map?)?['revenue'];
    return (v as num?)?.toDouble() ?? 0;
  }

  int get _weeklyBookings {
    final v = (_weeklyStats['current_week'] as Map?)?['bookings'];
    return (v as int?) ?? 0;
  }

  double get _revenueChangePct {
    final v = (_weeklyStats['changes'] as Map?)?['revenue_percent'];
    return (v as num?)?.toDouble() ?? 0;
  }

  int get _bookingChangeCnt {
    final v = (_weeklyStats['changes'] as Map?)?['bookings_count'];
    return (v as int?) ?? 0;
  }

  double get _totalRevenue {
    final v = _dashboardStats['total_revenue'];
    return double.tryParse('$v') ?? 0;
  }

  // Referral info (placeholder — backend referral tracking not yet implemented)
  String get _referralCode =>
      'TURF${_userPhone.isEmpty ? "000" : _userPhone.substring(_userPhone.length > 4 ? _userPhone.length - 4 : 0)}';
  int get _referralCount => 0;
  double get _referralEarnings => 0;

  String _formatMemberSince(String raw) {
    if (raw.isEmpty) return '';
    try {
      final d = DateTime.parse(raw);
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
      return '${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  String _daysUntilPayout() {
    final d = (7 - DateTime.now().weekday) % 7;
    if (d == 0) return 'today';
    if (d == 1) return 'tomorrow';
    return 'Mon';
  }

  int get _currentWeekNumber {
    final now = DateTime.now();
    return ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil();
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasApproved = _turfService.myTurfs.any(
      (t) => t.turfStatus == 'approved',
    );
    if (_pendingApprovalData != null && !hasApproved) {
      final data = _pendingApprovalData!;
      final rawStatuses = data['turf_statuses'] as List<dynamic>? ?? [];
      return PendingApprovalScreen(
        pendingCount: data['pending_count'] as int? ?? 0,
        rejectedCount: data['rejected_count'] as int? ?? 0,
        suspendedCount: data['suspended_count'] as int? ?? 0,
        message: data['message'] as String? ?? 'Your turf is under review.',
        turfStatuses: rawStatuses
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        onRefresh: _refreshAll,
      );
    }

    if (_navScreens.isEmpty) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _navScreens[_selectedNavIndex]),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Dashboard page ──────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return RefreshIndicator(
      color: _green,
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Performance Overview ──
                  _sectionLabel('Performance Overview'),
                  const SizedBox(height: 10),
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // ── Referral Program ──
                  _sectionLabel('Referral Program'),
                  const SizedBox(height: 10),
                  ReferralQrCard(
                    referralCode: _referralCode,
                    referralCount: _referralCount,
                    referralEarnings: _referralEarnings,
                  ),
                  const SizedBox(height: 24),

                  // ── Turf Management ──
                  _sectionLabel('Turf Management'),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your turfs, slots and bookings',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 14),
                  if (_filteredAdminTurfs.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredAdminTurfs.map(_buildTurfCard),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A4020), _darkGreen],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_filteredAdminTurfs.length} turf${_filteredAdminTurfs.length == 1 ? "" : "s"}'
                  '${_memberSince.isNotEmpty ? " · Member since $_memberSince" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(170),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _headerIconBtn(
                Icons.home_rounded,
                _goToUserHome,
                tooltip: 'Back to User View',
              ),
              const SizedBox(height: 8),
              _headerIconBtn(Icons.refresh_rounded, _refreshAll),
              const SizedBox(height: 8),
              _headerIconBtn(Icons.person_outline_rounded, _showPartnerProfile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap, {String? tooltip}) =>
      Tooltip(
        message: tooltip ?? '',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      );

  void _goToUserHome() {
    // Pop everything and go back to the user home screen.
    // Using pushAndRemoveUntil so the back button from home
    // never returns to the owner dashboard.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      (route) => false,
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A2E),
    ),
  );

  // ── Stats Row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final revUp = _revenueChangePct >= 0;
    final bkUp = _bookingChangeCnt >= 0;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            topLabel: 'WEEK $_currentWeekNumber',
            icon: Icons.trending_up_rounded,
            iconColor: _green,
            value: '₹${_weeklyRevenue.toStringAsFixed(0)}',
            sublabel: 'Revenue',
            badge:
                '${revUp ? "+" : ""}${_revenueChangePct.toStringAsFixed(0)}%',
            badgeUp: revUp,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            topLabel: 'WEEK $_currentWeekNumber',
            icon: Icons.book_online_rounded,
            iconColor: Colors.blue,
            value: '$_weeklyBookings',
            sublabel: 'Bookings',
            badge: '${bkUp ? "+" : ""}$_bookingChangeCnt',
            badgeUp: bkUp,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            topLabel: 'TOTAL',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.orange,
            value: '₹${_totalRevenue.toStringAsFixed(0)}',
            sublabel: 'Earned',
            badge: 'Payout ${_daysUntilPayout()}',
            badgeUp: true,
            badgeColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String topLabel,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String sublabel,
    required String badge,
    required bool badgeUp,
    Color? badgeColor,
  }) {
    final bc = badgeColor ?? (badgeUp ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.3,
                ),
              ),
              Icon(icon, size: 15, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                badgeColor != null
                    ? Icons.calendar_today_rounded
                    : badgeUp
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 10,
                color: bc,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    color: bc,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Turf Card ────────────────────────────────────────────────────────────────

  Widget _buildTurfCard(AdminTurf turf) {
    final isShutdown = turf.isShutdown;
    final statusColor = isShutdown ? Colors.red.shade700 : _green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Status strip ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  isShutdown
                      ? 'DISABLED${turf.shutdownEnd != null ? " · until ${_fmtDateStr(turf.shutdownEnd!)}" : ""}'
                      : 'ACTIVE',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                const SizedBox(width: 3),
                Text(
                  '${turf.rating.toStringAsFixed(1)} (${turf.reviewCount})',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + name row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Turf thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: turf.images.isNotEmpty
                          ? Image.network(
                              turf.images.first,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            turf.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                turf.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _green.withAlpha(18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '₹${turf.price}/hr',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Shutdown warning
                if (isShutdown && turf.shutdownReason.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Reason: ${turf.shutdownReason}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // ── Weekly performance table ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withAlpha(30)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'WEEKLY PERFORMANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _perfCol(
                            'This Week',
                            '₹${turf.weeklyRevenue.toStringAsFixed(0)}',
                            '${turf.weeklyBookings} bookings',
                          ),
                          _divider(),
                          _perfCol(
                            'Last Week',
                            '₹${turf.lastWeekRevenue.toStringAsFixed(0)}',
                            '${turf.lastWeekBookings} bookings',
                          ),
                          _divider(),
                          _perfCol(
                            'Change',
                            '${turf.revenueChangePct >= 0 ? "+" : ""}${turf.revenueChangePct.toStringAsFixed(0)}%',
                            '${turf.bookingChange >= 0 ? "+" : ""}${turf.bookingChange} bk',
                            valueColor: turf.revenueChangePct >= 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Action buttons ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionBtn(
                      Icons.visibility_rounded,
                      'Details',
                      Colors.blue,
                      () => _showTurfDetails(turf),
                    ),
                    _actionBtn(
                      isShutdown
                          ? Icons.power_settings_new_rounded
                          : Icons.power_off_rounded,
                      isShutdown ? 'Enable' : 'Disable',
                      isShutdown ? _green : Colors.red.shade700,
                      () => _handleShutdown(turf),
                    ),
                    _actionBtn(
                      Icons.edit_rounded,
                      'Edit',
                      Colors.orange.shade700,
                      () => _navigateToEdit(turf),
                    ),
                    _actionBtn(
                      Icons.list_alt_rounded,
                      'Bookings',
                      Colors.purple,
                      () => _navigateToBookings(turf),
                    ),
                    _actionBtn(
                      Icons.schedule_rounded,
                      'Slots',
                      Colors.indigo,
                      () => _navigateToSlots(turf),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      Icons.sports_soccer_rounded,
      color: Colors.grey.shade300,
      size: 28,
    ),
  );

  Widget _perfCol(
    String label,
    String value,
    String sub, {
    Color? valueColor,
  }) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          sub,
          style: TextStyle(fontSize: 9, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 36,
    color: Colors.grey.withAlpha(40),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.sports_soccer_rounded, size: 56, color: Colors.grey[200]),
          const SizedBox(height: 12),
          const Text(
            'No turfs yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Register your first turf to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JoinPartnerScreen()),
            ),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Turf'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Turf Details Modal ──────────────────────────────────────────────────────

  void _showTurfDetails(AdminTurf turf) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turf.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              turf.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Colors.amber,
                          ),
                          Text(
                            ' ${turf.rating.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${turf.reviewCount} reviews',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (turf.images.isNotEmpty) ...[
                _detailSection('Photos'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: turf.images.length,
                    itemBuilder: (_, i) => Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(turf.images[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (turf.description.isNotEmpty) ...[
                _detailSection('Description'),
                const SizedBox(height: 6),
                Text(
                  turf.description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
              ],

              if (turf.amenities.isNotEmpty) ...[
                _detailSection('Amenities'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: turf.amenities
                      .map(
                        (a) => Chip(
                          label: Text(a, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue.withAlpha(18),
                          side: BorderSide(color: Colors.blue.withAlpha(40)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              if (turf.sports.isNotEmpty) ...[
                _detailSection('Sports Available'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: turf.sports
                      .map(
                        (s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          backgroundColor: _green.withAlpha(18),
                          side: BorderSide(color: _green.withAlpha(40)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              _detailSection('All-Time Stats'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _infoStat(
                    'Total Bookings',
                    '${turf.totalBookings}',
                    Icons.book_online_rounded,
                  ),
                  _infoStat(
                    'Total Revenue',
                    '₹${turf.totalRevenue.toStringAsFixed(0)}',
                    Icons.currency_rupee_rounded,
                  ),
                  _infoStat(
                    'Active Slots',
                    '${turf.slotsCount}',
                    Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A2E),
    ),
  );

  Widget _infoStat(String label, String value, IconData icon) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: _green),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  // ── Shutdown flow ────────────────────────────────────────────────────────────

  void _handleShutdown(AdminTurf turf) {
    if (turf.isShutdown) {
      _confirmReactivate(turf);
    } else {
      _showShutdownModal(turf);
    }
  }

  void _confirmReactivate(AdminTurf turf) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Re-enable Turf'),
        content: Text(
          '${turf.name} will become visible and accept bookings immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _doReactivate(turf);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Re-enable'),
          ),
        ],
      ),
    );
  }

  void _showShutdownModal(AdminTurf turf) {
    DateTime? startDate;
    DateTime? endDate;
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Disable ${turf.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The turf will be hidden from users and no new bookings will be accepted.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _datePicker(
                          label: 'From Date',
                          selected: startDate,
                          onTap: () async {
                            final d = await _pickDate(
                              ctx,
                              first: DateTime.now(),
                            );
                            if (d != null) setModal(() => startDate = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _datePicker(
                          label: 'To Date',
                          selected: endDate,
                          onTap: () async {
                            final d = await _pickDate(
                              ctx,
                              first: startDate ?? DateTime.now(),
                            );
                            if (d != null) setModal(() => endDate = d);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      hintText: 'e.g. Maintenance, Renovation…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Admin will be notified. You can re-enable at any time.',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              (startDate != null &&
                                  endDate != null &&
                                  reasonCtrl.text.trim().isNotEmpty)
                              ? () {
                                  Navigator.pop(ctx);
                                  _doShutdown(
                                    turf,
                                    startDate!,
                                    endDate!,
                                    reasonCtrl.text.trim(),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.power_off_rounded, size: 15),
                          label: const Text('Disable Turf'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? selected,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  selected != null ? _fmtDate(selected) : 'Select date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected != null
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey[400],
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<DateTime?> _pickDate(BuildContext ctx, {required DateTime first}) =>
      showDatePicker(
        context: ctx,
        initialDate: first,
        firstDate: first,
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (_, child) => Theme(
          data: Theme.of(
            ctx,
          ).copyWith(colorScheme: const ColorScheme.light(primary: _green)),
          child: child!,
        ),
      );

  Future<void> _doShutdown(
    AdminTurf turf,
    DateTime start,
    DateTime end,
    String reason,
  ) async {
    try {
      await ApiService().postAuth(
        '/api/turfs/turfs/${turf.id}/owner_shutdown/',
        body: {
          'start_date': _isoDate(start),
          'end_date': _isoDate(end),
          'reason': reason,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${turf.name} disabled until ${_fmtDate(end)}'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
        _refreshAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to disable turf'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _doReactivate(AdminTurf turf) async {
    try {
      await ApiService().postAuth(
        '/api/turfs/turfs/${turf.id}/owner_reactivate/',
        body: {},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${turf.name} is now active!'),
            backgroundColor: _green,
          ),
        );
        _refreshAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reactivate turf'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Partner profile ──────────────────────────────────────────────────────────

  Future<void> _showPartnerProfile() async {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Partner Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', nameCtrl.text.trim());
                    await prefs.setString('userEmail', emailCtrl.text.trim());
                    if (mounted) {
                      setState(() {
                        _userName = nameCtrl.text.trim();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(child: _navItem(Icons.dashboard_rounded, 'Dashboard', 0)),
            Expanded(child: _navItem(Icons.bar_chart_rounded, 'Reports', 1)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedNavIndex = index;
        _updateNavScreens();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? _green : Colors.grey[400], size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? _green : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _navigateToEdit(AdminTurf turf) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => EditTurfScreen(turf: turf)),
  );

  void _navigateToBookings(AdminTurf turf) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
  );

  void _navigateToSlots(AdminTurf turf) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SlotManagementScreen()),
  );

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) {
    const m = [
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
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  String _fmtDateStr(String iso) {
    try {
      return _fmtDate(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
