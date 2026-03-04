import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/offer_service.dart';

// ─── COLOUR CONSTANTS ─────────────────────────────────────────────────────
const _kGreen = Color(0xFF1DB954);
const _kPurple = Color(0xFF6C63FF);

// ═══════════════════════════════════════════════════════════════════════════
// OFFER BANNER ROW — dynamic stack of banners fetched from backend config
// ═══════════════════════════════════════════════════════════════════════════

class OfferBannersRow extends StatefulWidget {
  final VoidCallback? onBookNow;
  const OfferBannersRow({super.key, this.onBookNow});

  @override
  State<OfferBannersRow> createState() => _OfferBannersRowState();
}

class _OfferBannersRowState extends State<OfferBannersRow> {
  final _api = ApiService();
  AllOfferConfigs? _config;
  bool _firstBookingDone = false;
  bool _dismissed = false;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _firstBookingDone = prefs.getBool('first_booking_completed') ?? false;
    _userName = prefs.getString('userName') ?? '';

    // Load offer config
    try {
      final resp = await _api.get('/api/growth/config/');
      if (resp['success'] == true && mounted) {
        setState(() => _config = AllOfferConfigs.fromJson(resp['config']));
        _startFirstBookingTimer();
      }
    } catch (_) {}
  }

  void _startFirstBookingTimer() async {
    if (_firstBookingDone || !(_config?.firstBooking.isActive ?? false)) return;
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('first_offer_dismissed') ?? false;
    if (dismissed) {
      setState(() => _dismissed = true);
      return;
    }
    final shownStr = prefs.getString('first_offer_shown_at');
    final firstShown = shownStr != null
        ? DateTime.parse(shownStr)
        : DateTime.now();
    if (shownStr == null)
      await prefs.setString(
        'first_offer_shown_at',
        firstShown.toIso8601String(),
      );
    final expiresAt = firstShown.add(
      Duration(days: _config!.firstBooking.expiryDays),
    );
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return;
    setState(() => _remaining = expiresAt.difference(now));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = expiresAt.difference(DateTime.now());
      if (!mounted) return;
      if (r.isNegative) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining = r);
    });
  }

  void _dismissFirstBooking() async {
    setState(() => _dismissed = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_offer_dismissed', true);
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null) return const SizedBox.shrink();

    final banners = <Widget>[];

    // 1. First Booking Banner
    if (!_firstBookingDone &&
        !_dismissed &&
        _config!.firstBooking.isActive &&
        _remaining > Duration.zero) {
      final amount =
          _config!.firstBooking.discountAmount?.toStringAsFixed(0) ??
          '${_config!.firstBooking.discountPercent ?? 0}%';
      banners.add(
        _FirstBookingBanner(
          amount: amount,
          remainingText: _fmtDuration(_remaining),
          userName: _userName,
          onBookNow: widget.onBookNow,
          onDismiss: _dismissFirstBooking,
        ),
      );
    }

    // 2. Last Minute Banner
    if (_config!.lastMinute.isActive) {
      banners.add(_LastMinuteBanner(config: _config!.lastMinute));
    }

    if (banners.isEmpty) return const SizedBox.shrink();
    return Column(
      children: banners
          .map(
            (b) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: b,
            ),
          )
          .toList(),
    );
  }
}

// ─── FIRST BOOKING BANNER ─────────────────────────────────────────────────
class _FirstBookingBanner extends StatelessWidget {
  final String amount, remainingText, userName;
  final VoidCallback? onBookNow, onDismiss;
  const _FirstBookingBanner({
    required this.amount,
    required this.remainingText,
    required this.userName,
    this.onBookNow,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = userName.isNotEmpty ? '🎉 Hi $userName!' : '🎉 Welcome!';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$greeting  Get ₹$amount off!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      remainingText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      ' remaining',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _kPurple,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
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

// ─── LAST MINUTE BANNER ───────────────────────────────────────────────────
class _LastMinuteBanner extends StatelessWidget {
  final OfferConfig config;
  const _LastMinuteBanner({required this.config});

  int get _maxDiscount {
    int max = 0;
    for (final w in config.lastMinuteWindows) {
      if (w.length >= 3 && w[2] > max) max = w[2];
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    if (_maxDiscount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF3D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST MINUTE DEAL — Up to $_maxDiscount% off!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Book within a few hours for big discounts',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STREAK & STATS BAR — updated to use backend config
// ═══════════════════════════════════════════════════════════════════════════

class StreakStatsBar extends StatefulWidget {
  const StreakStatsBar({super.key});
  @override
  State<StreakStatsBar> createState() => _StreakStatsBarState();
}

class _StreakStatsBarState extends State<StreakStatsBar> {
  final _api = ApiService();
  int _currentStreak = 0;
  int _nextRewardAmount = 25;
  int _todayBookings = 0;
  bool _hasStreak = false;
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
          _nextRewardAmount = data['next_reward_amount'] ?? 25;
          _hasStreak = _currentStreak > 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final data = await _api.get('/api/growth/live-stats/stats/');
      if (mounted && data['success'] == true) {
        setState(() => _todayBookings = data['today_bookings'] ?? 0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasStats = _todayBookings > 0;
    if (!_hasStreak && !hasStats) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (_hasStreak) ...[
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$_currentStreak week streak',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(
              ' • Next: ₹$_nextRewardAmount',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (_hasStreak && hasStats)
            const Text(
              '  │  ',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          if (hasStats) ...[
            const Text('⚡', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              '$_todayBookings games today',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOYALTY BADGE — uses backend tier config
// ═══════════════════════════════════════════════════════════════════════════

class LoyaltyBadge extends StatefulWidget {
  const LoyaltyBadge({super.key});
  @override
  State<LoyaltyBadge> createState() => _LoyaltyBadgeState();
}

class _LoyaltyBadgeState extends State<LoyaltyBadge> {
  final _api = ApiService();
  String _level = 'Newbie';
  int _totalBookings = 0;
  int _nextLevelAt = 5;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getAuth('/api/growth/streak-loyalty/loyalty/');
      if (mounted && data['success'] == true) {
        setState(() {
          _level = data['level'] ?? 'Newbie';
          _totalBookings = data['total_bookings'] ?? 0;
          _nextLevelAt = (data['needed'] ?? 5) + _totalBookings;
          _loaded = true;
        });
      }
    } catch (_) {}
  }

  Color get _color {
    switch (_level.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return Colors.blueGrey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  String get _emoji {
    switch (_level.toLowerCase()) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'platinum':
        return '💎';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final color = _color;
    final progress = _nextLevelAt > 0
        ? (_totalBookings / _nextLevelAt).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
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
                child: Text(_emoji, style: const TextStyle(fontSize: 28)),
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
                      '$_totalBookings bookings total',
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
                    minHeight: 7,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$_totalBookings/$_nextLevelAt',
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

// ═══════════════════════════════════════════════════════════════════════════
// REFERRAL PROGRESS BAR — compact home widget
// ═══════════════════════════════════════════════════════════════════════════

class ReferralProgressBar extends StatefulWidget {
  const ReferralProgressBar({super.key});
  @override
  State<ReferralProgressBar> createState() => _ReferralProgressBarState();
}

class _ReferralProgressBarState extends State<ReferralProgressBar> {
  final _api = ApiService();
  int _installs = 0;
  int _target = 3;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    final remaining = _target - _installs;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGreen.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, size: 16, color: _kGreen),
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
                value: (_installs / _target).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
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

// ═══════════════════════════════════════════════════════════════════════════
// WALLET SUMMARY CARD — shows balance + expiring amount
// ═══════════════════════════════════════════════════════════════════════════

class WalletSummaryCard extends StatefulWidget {
  final VoidCallback? onTap;
  const WalletSummaryCard({super.key, this.onTap});
  @override
  State<WalletSummaryCard> createState() => _WalletSummaryCardState();
}

class _WalletSummaryCardState extends State<WalletSummaryCard> {
  final _api = ApiService();
  String _balance = '0';
  String _expiring = '0';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getAuth('/api/growth/wallet/balance/');
      if (data['success'] == true && mounted) {
        setState(() {
          _balance = data['balance'] ?? '0';
          _expiring = data['expiring_soon'] ?? '0';
          _loaded = true;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final bal = double.tryParse(_balance) ?? 0;
    if (bal <= 0) return const SizedBox.shrink();
    final exp = double.tryParse(_expiring) ?? 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1DB954), Color(0xFF0F9940)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kGreen.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('💰', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '₹${double.parse(_balance).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  if (exp > 0)
                    Text(
                      '⚠️ ₹${exp.toStringAsFixed(0)} expiring soon',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CAPTAIN INVITE CARD — shown after booking is confirmed
// ═══════════════════════════════════════════════════════════════════════════

class CaptainInviteCard extends StatelessWidget {
  final int bookingId;
  final String captainReward;
  final String teammateReward;
  final VoidCallback? onInvite;

  const CaptainInviteCard({
    super.key,
    required this.bookingId,
    this.captainReward = '10',
    this.teammateReward = '20',
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "YOU'RE THE CAPTAIN!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Invite your teammates',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RewardChip(
                  icon: '💰',
                  label: 'You get',
                  value: '₹$captainReward',
                  subLabel: 'per teammate',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RewardChip(
                  icon: '🎁',
                  label: 'Teammate gets',
                  value: '₹$teammateReward',
                  subLabel: 'first booking',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Invite via WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String icon, label, value, subLabel;
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            subLabel,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
