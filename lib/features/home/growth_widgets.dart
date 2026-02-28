import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

// ─── COMBINED STREAK + SOCIAL PROOF BAR (compact ~40px) ───
/// Merges streak and live stats into a single compact row:
///   "🔥 1 week streak | Next: ₹30 • ⚡ 4 games today"
class StreakStatsBar extends StatefulWidget {
  const StreakStatsBar({super.key});

  @override
  State<StreakStatsBar> createState() => _StreakStatsBarState();
}

class _StreakStatsBarState extends State<StreakStatsBar> {
  final ApiService _api = ApiService();
  int _currentStreak = 0;
  int _nextRewardAt = 3;
  int _todayBookings = 0;
  bool _hasStreak = false;
  bool _hasStats = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadStats(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStreak(), _loadStats()]);
  }

  Future<void> _loadStreak() async {
    try {
      final data = await _api.getAuth('/api/growth/streak-loyalty/streak/');
      if (mounted && data['success'] == true) {
        setState(() {
          _currentStreak = data['current_streak'] ?? 0;
          _nextRewardAt = data['next_reward_at'] ?? 3;
          _hasStreak = _currentStreak > 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final data = await _api.get('/api/growth/live-stats/stats/');
      if (mounted && data['success'] == true) {
        setState(() {
          _todayBookings = data['today_bookings'] ?? 0;
          _hasStats = _todayBookings > 0;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStreak && !_hasStats) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (_hasStreak) ...[
            Text(
              '🔥 $_currentStreak week streak',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(
              ' • Next: ₹${_nextRewardAt * 10}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (_hasStreak && _hasStats)
            const Text(
              '  │  ',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          if (_hasStats)
            Text(
              '⚡ $_todayBookings games today',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

// ─── FIRST-TIME OFFER BANNER (Swiggy/Zomato compact ~60px) ───
/// Shows "Welcome to TurfZone, {name}!" with countdown + BOOK NOW.
/// Hidden if: first_booking_completed == true OR user dismissed with [X].
class FirstOfferBanner extends StatefulWidget {
  final VoidCallback? onBookNow;

  const FirstOfferBanner({super.key, this.onBookNow});

  @override
  State<FirstOfferBanner> createState() => _FirstOfferBannerState();
}

class _FirstOfferBannerState extends State<FirstOfferBanner> {
  bool _showOffer = false;
  bool _dismissed = false;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkOfferEligibility();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkOfferEligibility() async {
    final prefs = await SharedPreferences.getInstance();

    // Check server-side flag
    final firstBookingDone = prefs.getBool('first_booking_completed') ?? false;
    if (firstBookingDone) return;

    // Check local dismissal/usage
    final offerUsed = prefs.getBool('first_offer_used') ?? false;
    final offerDismissed = prefs.getBool('first_offer_dismissed') ?? false;
    if (offerUsed || offerDismissed) return;

    _userName = prefs.getString('userName') ?? '';

    final firstShownStr = prefs.getString('first_offer_shown_at');
    DateTime firstShown;
    if (firstShownStr == null) {
      firstShown = DateTime.now();
      await prefs.setString(
        'first_offer_shown_at',
        firstShown.toIso8601String(),
      );
    } else {
      firstShown = DateTime.parse(firstShownStr);
    }

    final expiresAt = firstShown.add(const Duration(hours: 24));
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return;

    if (!mounted) return;
    setState(() {
      _showOffer = true;
      _remaining = expiresAt.difference(now);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = expiresAt.difference(DateTime.now());
      if (r.isNegative) {
        _timer?.cancel();
        if (mounted) setState(() => _showOffer = false);
        return;
      }
      if (mounted) setState(() => _remaining = r);
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _dismiss() async {
    setState(() => _dismissed = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_offer_dismissed', true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOffer || _dismissed) return const SizedBox.shrink();

    final greeting = _userName.isNotEmpty
        ? '🎉 Welcome, $_userName!'
        : '🎉 Welcome to TurfZone!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: greeting + timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$greeting  Get ₹50 off!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '🔥 ${_formatDuration(_remaining)} remaining',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // BOOK NOW button
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: widget.onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'BOOK NOW',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),

          // Close [X]
          GestureDetector(
            onTap: _dismiss,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LOYALTY BADGE ───
/// Shows loyalty level with progress bar (for profile screen).
class LoyaltyBadge extends StatefulWidget {
  const LoyaltyBadge({super.key});

  @override
  State<LoyaltyBadge> createState() => _LoyaltyBadgeState();
}

class _LoyaltyBadgeState extends State<LoyaltyBadge> {
  final ApiService _api = ApiService();
  String _level = 'Bronze';
  int _totalBookings = 0;
  int _nextLevelAt = 5;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLoyalty();
  }

  Future<void> _loadLoyalty() async {
    try {
      final data = await _api.getAuth('/api/growth/streak-loyalty/loyalty/');
      if (mounted && data['success'] == true) {
        setState(() {
          _level = data['level'] ?? 'Bronze';
          _totalBookings = data['total_bookings'] ?? 0;
          _nextLevelAt = data['next_level_at'] ?? 5;
          _loaded = true;
        });
      }
    } catch (e) {
      debugPrint('Loyalty load error: $e');
    }
  }

  Color _getLevelColor() {
    switch (_level.toLowerCase()) {
      case 'silver':
        return Colors.blueGrey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.deepPurple;
      default:
        return const Color(0xFFCD7F32); // Bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final color = _getLevelColor();
    final progress = _nextLevelAt > 0
        ? (_totalBookings / _nextLevelAt).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.workspace_premium, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_level Member',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_totalBookings bookings',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$_totalBookings / $_nextLevelAt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── REFERRAL PROGRESS BAR (compact) ───
/// Shows referral progress toward 3-friend cashback goal on home screen.
class ReferralProgressBar extends StatefulWidget {
  const ReferralProgressBar({super.key});

  @override
  State<ReferralProgressBar> createState() => _ReferralProgressBarState();
}

class _ReferralProgressBarState extends State<ReferralProgressBar> {
  final ApiService _api = ApiService();
  int _installs = 0;
  int _target = 3;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final res = await _api.getAuth('/api/growth/referral/stats/');
      if (res['success'] == true && mounted) {
        final installs = res['installs'] ?? 0;
        setState(() {
          _installs = installs;
          _show = installs > 0 && installs < _target;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final progress = _installs / _target;
    final remaining = _target - _installs;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, size: 16, color: Color(0xFF1DB954)),
          const SizedBox(width: 8),
          Text(
            '$_installs/$_target friends',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1DB954),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$remaining more for ₹50!',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
