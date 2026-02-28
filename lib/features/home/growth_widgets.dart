import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

// ─── STREAK CARD ───
/// Shows current booking streak with progress bar toward next reward.
class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  final ApiService _api = ApiService();
  int _currentStreak = 0;
  int _nextRewardAt = 3;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    try {
      final data = await _api.getAuth('/api/growth/streak-loyalty/streak/');
      if (mounted && data['success'] == true) {
        setState(() {
          _currentStreak = data['current_streak'] ?? 0;
          _nextRewardAt = data['next_reward_at'] ?? 3;
          _loaded = true;
        });
      }
    } catch (e) {
      debugPrint('Streak load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _currentStreak == 0) return const SizedBox.shrink();

    final progress = _nextRewardAt > 0
        ? (_currentStreak / _nextRewardAt).clamp(0.0, 1.0)
        : 0.0;
    final rewardAmount = _nextRewardAt * 10;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B00).withOpacity(0.1),
            const Color(0xFFFF9800).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_currentStreak week streak!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next reward at $_nextRewardAt weeks: ₹$rewardAmount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SOCIAL PROOF BANNER ───
/// Shows "X games booked today" for social proof.
class SocialProofBanner extends StatefulWidget {
  const SocialProofBanner({super.key});

  @override
  State<SocialProofBanner> createState() => _SocialProofBannerState();
}

class _SocialProofBannerState extends State<SocialProofBanner> {
  final ApiService _api = ApiService();
  int _todayBookings = 0;
  String _topCity = '';
  int _topCityCount = 0;
  bool _loaded = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    // Refresh every 30 seconds
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

  Future<void> _loadStats() async {
    try {
      final data = await _api.get('/api/growth/live-stats/stats/');
      if (mounted && data['success'] == true) {
        final cityBookings =
            data['city_bookings'] as Map<String, dynamic>? ?? {};
        String topCity = '';
        int topCount = 0;
        cityBookings.forEach((city, count) {
          if ((count as int) > topCount) {
            topCity = city;
            topCount = count;
          }
        });

        setState(() {
          _todayBookings = data['today_bookings'] ?? 0;
          _topCity = topCity;
          _topCityCount = topCount;
          _loaded = true;
        });
      }
    } catch (e) {
      debugPrint('Live stats error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _todayBookings == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$_todayBookings games booked today',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (_topCity.isNotEmpty) ...[
                    const TextSpan(text: ' • '),
                    TextSpan(
                      text: '$_topCityCount in $_topCity',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FIRST-TIME OFFER BANNER (Swiggy/Zomato style) ───
/// Shows "Welcome to TurfZone, {name}!" with countdown timer.
/// Hidden if: first_booking_completed == true OR user dismissed with [X].
class FirstOfferBanner extends StatefulWidget {
  const FirstOfferBanner({super.key});

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

    // Check if user already completed first booking (from API via AuthState)
    final firstBookingDone = prefs.getBool('first_booking_completed') ?? false;
    if (firstBookingDone) return;

    // Check if offer was dismissed or used
    final offerUsed = prefs.getBool('first_offer_used') ?? false;
    if (offerUsed) return;

    // Get user name for personalization
    _userName = prefs.getString('userName') ?? '';

    // Calculate timer
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
        ? '🎉 Welcome to TurfZone, $_userName!'
        : '🎉 Welcome to TurfZone!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get ₹50 off on your first booking',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Timer row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥 ', style: TextStyle(fontSize: 13)),
                          Text(
                            '${_formatDuration(_remaining)} remaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'BOOK NOW',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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

          // Close [X] button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
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
  String _level = 'Newbie';
  String _emoji = '🌱';
  String? _next;
  int _progress = 0;
  int _needed = 5;
  int _totalBookings = 0;
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
          _level = data['level'] ?? 'Newbie';
          _emoji = data['emoji'] ?? '🌱';
          _next = data['next'];
          _progress = data['progress'] ?? 0;
          _needed = data['needed'] ?? 5;
          _totalBookings = data['total_bookings'] ?? 0;
          _loaded = true;
        });
      }
    } catch (e) {
      debugPrint('Loyalty load error: $e');
    }
  }

  Color _getLevelColor() {
    switch (_level) {
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Silver':
        return const Color(0xFF9E9E9E);
      case 'Bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF1DB954);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final color = _getLevelColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_level Member',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  if (_next != null)
                    Text(
                      "You're $_needed bookings away from $_next!",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_totalBookings bookings',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REFERRAL PROGRESS BAR ───
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1DB954).withOpacity(0.08),
              const Color(0xFF1ED760).withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, size: 18, color: Color(0xFF1DB954)),
                const SizedBox(width: 8),
                Text(
                  '$_installs of $_target friends joined',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '$remaining more for ₹50!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1DB954),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
