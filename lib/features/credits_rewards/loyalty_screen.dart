import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Loyalty tier progress screen — shows current tier, perks, and next milestone.
class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final _api = ApiService();
  bool _loading = true;

  String _level = 'Newbie';
  int _totalBookings = 0;
  int _nextLevelAt = 5;
  String _nextLevel = 'Bronze';
  List<Map<String, dynamic>> _tiers = [];

  // Offer config
  List<int> _thresholds = [5, 15, 30, 50];
  List<String> _perks = [
    '5% cashback',
    '10% cashback',
    '15% cashback',
    'Free every 10th',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getAuth('/api/growth/streak-loyalty/loyalty/'),
        _api.get('/api/growth/config/'),
      ]);
      final loyalty = results[0];
      final config = results[1];

      if (config['success'] == true) {
        final lc = config['config']?['loyalty'] ?? {};
        _thresholds = List<int>.from(lc['loyalty_tiers'] ?? [5, 15, 30, 50]);
        _perks = List<String>.from(
          lc['loyalty_perks'] ??
              [
                '5% cashback',
                '10% cashback',
                '15% cashback',
                'Free every 10th',
              ],
        );
      }

      if (mounted) {
        setState(() {
          if (loyalty['success'] == true) {
            _level = loyalty['level'] ?? 'Newbie';
            _totalBookings = loyalty['total_bookings'] ?? 0;
            final needed = (loyalty['needed'] ?? 5) as int;
            _nextLevelAt = _totalBookings + needed;
          }
          _buildTiers();
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _buildTiers() {
    const names = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    const emojis = ['🥉', '🥈', '🥇', '💎', '👑'];
    const colors = [
      Color(0xFFCD7F32),
      Colors.blueGrey,
      Colors.amber,
      Colors.deepPurple,
      Color(0xFF1B0066),
    ];
    _tiers = [];
    _nextLevel = 'Platinum';
    for (int i = 0; i < _thresholds.length; i++) {
      final isReached = _totalBookings >= _thresholds[i];
      final isCurrent =
          _level.toLowerCase() ==
          (names.length > i ? names[i].toLowerCase() : '');
      if (!isReached && _nextLevel == 'Platinum') {
        _nextLevel = names.length > i ? names[i] : 'Next';
        _nextLevelAt = _thresholds[i];
      }
      _tiers.add({
        'name': names.length > i ? names[i] : 'Tier ${i + 1}',
        'emoji': emojis.length > i ? emojis[i] : '🏅',
        'color': colors.length > i ? colors[i] : Colors.grey,
        'threshold': _thresholds[i],
        'perk': _perks.length > i ? _perks[i] : '',
        'isReached': isReached,
        'isCurrent': isCurrent,
      });
    }
  }

  Color get _currentColor {
    const names = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    const colors = [
      Color(0xFFCD7F32),
      Colors.blueGrey,
      Colors.amber,
      Colors.deepPurple,
      Color(0xFF1B0066),
    ];
    final idx = names.indexOf(_level.toLowerCase());
    return idx >= 0 ? colors[idx] : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: const Text(
          'Loyalty',
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
                  // Current tier hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_currentColor, _currentColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _tiers.isEmpty
                              ? '🌱'
                              : (_tiers.firstWhere(
                                      (t) =>
                                          t['name'].toString().toLowerCase() ==
                                          _level.toLowerCase(),
                                      orElse: () => {'emoji': '🌱'},
                                    )['emoji']
                                    as String),
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_level Member',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_totalBookings bookings total',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (_totalBookings < _nextLevelAt) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_nextLevelAt - _totalBookings} more bookings to reach $_nextLevel!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _nextLevelAt > 0
                                    ? (_totalBookings / _nextLevelAt).clamp(
                                        0.0,
                                        1.0,
                                      )
                                    : 1.0,
                                minHeight: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_totalBookings / $_nextLevelAt bookings',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tier cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Tiers',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._tiers.map((tier) {
                          final reached = tier['isReached'] as bool;
                          final current = tier['isCurrent'] as bool;
                          final color = tier['color'] as Color;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: reached
                                  ? color.withOpacity(0.07)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: current
                                    ? color
                                    : (reached
                                          ? color.withOpacity(0.3)
                                          : Colors.grey.shade200),
                                width: current ? 2 : 1,
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
                                  tier['emoji'] as String,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            tier['name'] as String,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: color,
                                            ),
                                          ),
                                          if (current) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'Current',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        tier['perk'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: reached
                                              ? Colors.black87
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tier['threshold']}+ bookings',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: color.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  reached
                                      ? Icons.check_circle
                                      : Icons.lock_outline,
                                  color: reached ? color : Colors.grey.shade300,
                                  size: 24,
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
