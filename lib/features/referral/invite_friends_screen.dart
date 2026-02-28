import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

/// Referral tracking dashboard — invite friends, view stats, see who joined.
class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  String _referralLink = '';
  int _clicks = 0;
  int _installs = 0;
  int _qualified = 0;
  String _cashbackEarned = '0';
  List<dynamic> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load stats and friends in parallel
      final statsData = await _api.getAuth('/api/growth/referral/stats/');
      final friendsData = await _api.getAuth('/api/growth/referral/friends/');

      if (mounted) {
        setState(() {
          _referralLink = statsData['link'] ?? '';
          _clicks = statsData['clicks'] ?? 0;
          _installs = statsData['installs'] ?? 0;
          _qualified = statsData['qualified'] ?? 0;
          _cashbackEarned = statsData['cashback_earned'] ?? '0';
          _friends = friendsData['friends'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading referral data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareOnWhatsApp() async {
    final message =
        'Join me on TurfZone! Install app and get ₹30 cashback '
        'on your first booking: $_referralLink';
    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: message));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message copied! Share with friends')),
        );
      }
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _referralLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied! 🔗'),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Invite Friends'),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF1DB954),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ─── Share Card ───
                  _buildShareCard(),
                  const SizedBox(height: 20),

                  // ─── Stats Grid ───
                  _buildStatsGrid(),
                  const SizedBox(height: 20),

                  // ─── Cashback Progress ───
                  _buildCashbackProgress(),
                  const SizedBox(height: 20),

                  // ─── Friends List ───
                  _buildFriendsList(),
                  const SizedBox(height: 20),

                  // ─── How It Works ───
                  _buildHowItWorks(),
                ],
              ),
            ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '📢 Your Referral Link',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _referralLink,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _copyLink,
                  child: const Icon(Icons.copy, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareOnWhatsApp,
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Share on WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _copyLink,
                icon: const Icon(Icons.link, size: 18),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _statTile(
          'Clicks',
          '$_clicks',
          Icons.touch_app,
          const Color(0xFF2196F3),
        ),
        const SizedBox(width: 10),
        _statTile(
          'Installs',
          '$_installs',
          Icons.download,
          const Color(0xFFFF9800),
        ),
        const SizedBox(width: 10),
        _statTile(
          'Booked',
          '$_qualified',
          Icons.check_circle,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashbackProgress() {
    final nextMilestone = ((_qualified ~/ 3) + 1) * 3;
    final progress = _qualified > 0 ? (_qualified % 3) / 3 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
              const Text(
                '💰 Cashback Earned',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹$_cashbackEarned',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1DB954),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Progress to next ₹50: $_qualified/$nextMilestone friends',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No friends yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Share your link to start earning!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👥 Friends Who Joined',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._friends.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: f['status'] == 'booked'
                        ? const Color(0xFF1DB954).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    child: Icon(
                      f['status'] == 'booked'
                          ? Icons.check_circle
                          : Icons.person,
                      color: f['status'] == 'booked'
                          ? const Color(0xFF1DB954)
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['name'] ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          f['status'] == 'booked'
                              ? 'Booked ✅'
                              : 'Installed, not yet booked',
                          style: TextStyle(
                            fontSize: 12,
                            color: f['status'] == 'booked'
                                ? const Color(0xFF1DB954)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (f['cashback_earned'] != null &&
                      f['cashback_earned'] != '0' &&
                      f['cashback_earned'] != '0.00')
                    Text(
                      '+₹${f['cashback_earned']}',
                      style: const TextStyle(
                        color: Color(0xFF1DB954),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _stepItem('1', 'Friend installs via your link', '→ you get ₹10'),
          _stepItem('2', 'Friend books first turf', '→ you get ₹40 more'),
          _stepItem('3', 'Total ₹50 per friend who books', ''),
          _stepItem('4', 'Your friend gets ₹30', 'on first booking'),
        ],
      ),
    );
  }

  Widget _stepItem(String num, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              num,
              style: const TextStyle(
                color: Color(0xFF1DB954),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13)),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
