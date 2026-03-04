import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

/// Captain invite screen — shown post-booking so the captain can invite teammates.
class CaptainInviteScreen extends StatefulWidget {
  final int bookingId;
  const CaptainInviteScreen({super.key, required this.bookingId});

  @override
  State<CaptainInviteScreen> createState() => _CaptainInviteScreenState();
}

class _CaptainInviteScreenState extends State<CaptainInviteScreen> {
  final _api = ApiService();
  bool _loading = true;

  String _inviteLink = '';
  int _captainReward = 10;
  int _teammateReward = 20;
  int _joinedCount = 0;
  int _maxSlots = 6;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getAuth(
          '/api/growth/captain/invite-link/?booking_id=${widget.bookingId}',
        ),
        _api.get('/api/growth/config/'),
      ]);
      final invite = results[0];
      final config = results[1];

      setState(() {
        if (invite['success'] == true) {
          _inviteLink = invite['invite_link'] ?? '';
          _joinedCount = invite['joined_count'] ?? 0;
          _maxSlots = invite['max_slots'] ?? 6;
        }
        if (config['success'] == true) {
          final r = config['config']?['captain']?['referral_rewards'] ?? {};
          _captainReward = r['captain'] ?? 10;
          _teammateReward = r['teammate'] ?? 20;
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _shareWhatsApp() {
    final msg = Uri.encodeComponent(
      '👑 I just booked a turf on TurfZone! Join my game and get ₹$_teammateReward off YOUR first booking. '
      'Join here 👉 $_inviteLink',
    );
    launchUrl(Uri.parse('whatsapp://send?text=$msg'));
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite link copied!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Invite Teammates',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Crown hero
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 10),
                        const Text(
                          "YOU'RE THE CAPTAIN!",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Invite more teammates to earn ₹$_captainReward each',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reward chips
                  Row(
                    children: [
                      Expanded(
                        child: _RewardCard(
                          emoji: '💰',
                          label: 'You earn',
                          amount: '₹$_captainReward',
                          sub: 'per teammate who joins',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RewardCard(
                          emoji: '🎁',
                          label: 'Teammate gets',
                          amount: '₹$_teammateReward',
                          sub: 'off first booking',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Slots progress
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Teammates joined',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$_joinedCount / $_maxSlots',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                            _maxSlots,
                            (i) => Expanded(
                              child: Container(
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: i < _joinedCount
                                      ? Colors.amber
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_joinedCount < _maxSlots)
                          Text(
                            '${_maxSlots - _joinedCount} slots remaining',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CTA buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareWhatsApp,
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text(
                        'Invite via WhatsApp',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _copyLink,
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Copy Team Link',
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String emoji, label, amount, sub;
  const _RewardCard({
    required this.emoji,
    required this.label,
    required this.amount,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
