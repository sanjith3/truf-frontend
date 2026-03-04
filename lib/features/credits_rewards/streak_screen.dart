import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Streak history and milestones screen.
class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  final _api = ApiService();
  bool _loading = true;

  int _currentStreak = 0;
  int _longestStreak = 0;
  List<int> _thresholds = [2, 4, 8, 12];
  List<int> _rewards = [25, 75, 0, 200];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getAuth('/api/growth/streak-loyalty/streak/'),
        _api.get('/api/growth/config/'),
      ]);
      final streak = results[0];
      final cfg = results[1];

      if (mounted) {
        setState(() {
          if (streak['success'] == true) {
            _currentStreak = streak['current_streak'] ?? 0;
            _longestStreak = streak['longest_streak'] ?? _currentStreak;
          }
          if (cfg['success'] == true) {
            final s = cfg['config']?['streak'] ?? {};
            _thresholds = List<int>.from(
              s['streak_thresholds'] ?? [2, 4, 8, 12],
            );
            _rewards = List<int>.from(s['streak_rewards'] ?? [25, 75, 0, 200]);
          }
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  int? get _nextThreshold {
    for (final t in _thresholds) {
      if (_currentStreak < t) return t;
    }
    return null;
  }

  int? get _nextReward {
    for (int i = 0; i < _thresholds.length; i++) {
      if (_currentStreak < _thresholds[i])
        return _rewards.length > i ? _rewards[i] : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextThreshold;
    final nextR = _nextReward;
    final progress = next != null && next > 0
        ? (_currentStreak / next).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: const Text(
          'Streak Rewards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF3D00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 8),
                        Text(
                          _currentStreak > 0
                              ? '$_currentStreak Week Streak!'
                              : 'Start Your Streak!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentStreak > 0
                              ? 'Book every week to keep it going'
                              : 'Book this week to begin your streak',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (next != null) ...[
                          const SizedBox(height: 16),
                          if (nextR == 0)
                            const Text(
                              'Next milestone: FREE BOOKING 🎁',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          else
                            Text(
                              'Next reward: ₹$nextR at $next weeks',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_currentStreak / $next weeks',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: '🔥',
                            label: 'Current',
                            value: '$_currentStreak\nweeks',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: '🏆',
                            label: 'Longest',
                            value: '$_longestStreak\nweeks',
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Milestone cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Streak Milestones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_thresholds.length, (i) {
                          final t = _thresholds[i];
                          final r = _rewards.length > i ? _rewards[i] : 0;
                          final reached = _currentStreak >= t;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: reached
                                  ? const Color(0xFFFFF3E0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: reached
                                    ? Colors.orange.shade300
                                    : Colors.grey.shade200,
                                width: reached ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  reached ? '✅' : '🔒',
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$t-Week Streak',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: reached
                                              ? Colors.orange.shade700
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        r == 0
                                            ? '🎁 FREE BOOKING'
                                            : '₹$r wallet credit',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: reached
                                              ? Colors.orange.shade600
                                              : Colors.grey,
                                          fontWeight: r == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (reached)
                                  const Text(
                                    '🎉',
                                    style: TextStyle(fontSize: 24),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
