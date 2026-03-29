import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/faq_data.dart';
import '../../services/api_service.dart';
import '../../screens/support/chat_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<FaqItem> _faqItems = faqItems; // from data/faq_data.dart
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: 20),

            // Common Issues
            _buildCommonIssues(),

            const SizedBox(height: 24),

            // FAQs
            _buildFAQSection(),

            const SizedBox(height: 24),

            // Contact Us
            _buildContactSection(),

            const SizedBox(height: 24),

            // Message Form
            _buildMessageForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for help...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1DB954)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCommonIssues() {
    final commonIssues = [
      {'title': 'Booking Cancellation', 'icon': Icons.cancel},
      {'title': 'Payment Failed/Refund', 'icon': Icons.payment},
      {'title': 'Turf Availability', 'icon': Icons.sports_soccer},
      {'title': 'Account Login Issues', 'icon': Icons.account_circle},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📋 COMMON ISSUES',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...commonIssues.map((issue) => _buildIssueTile(issue)),
      ],
    );
  }

  Widget _buildIssueTile(Map<String, dynamic> issue) {
    return ListTile(
      leading: Icon(issue['icon'], color: const Color(0xFF1DB954)),
      title: Text(issue['title']),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        // Feature coming soon or scroll to FAQ logic
      },
    );
  }

  Widget _buildFAQSection() {
    final filteredFaqs = _faqItems.where((faq) {
      return faq.question.toLowerCase().contains(_searchQuery) ||
          faq.answer.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredFaqs.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No results found for "$_searchQuery"'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '❓ FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...filteredFaqs.map((faq) => _buildFaqItem(faq)),
      ],
    );
  }

  Widget _buildFaqItem(FaqItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                faq.answer,
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📞 CONTACT US',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1DB954),
            ),
          ),
          const SizedBox(height: 16),

          _buildContactRow(
            icon: Icons.phone,
            label: 'Call Support',
            value: '+91 8825934519',
            onTap: () => _launchURL('tel:+918825934519'),
          ),
          _buildContactRow(
            icon: Icons.email,
            label: 'Email Support',
            value: 'support@turfzone.com',
            onTap: () => _launchURL('mailto:support@turfzone.com'),
          ),
          _buildContactRow(
            icon: Icons.chat,
            label: 'Live Chat',
            value: 'Available 24/7',
            onTap: () => _openLiveChat(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1DB954), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF1DB954)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✉️ SEND US A MESSAGE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: 'Subject',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _messageController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
            ),
            child: const Text('📤 Send Message'),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Our support team will respond within 24 hours',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  void _openLiveChat() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Live chat coming soon!')));
  }

  Future<void> _sendMessage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final focusScope = FocusScope.of(context);

    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await ApiService().postAuth(
        '/api/support/tickets/create/',
        body: {
          'subject': _subjectController.text,
          'message': _messageController.text,
        },
      );

      if (!mounted) return;

      final ticketId = response['ticket_id'] ?? '';

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Ticket created! Chat with us now.'),
          backgroundColor: Colors.green,
        ),
      );

      _subjectController.clear();
      _messageController.clear();
      focusScope.unfocus();

      if (ticketId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupportChatScreen(ticketId: ticketId),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
