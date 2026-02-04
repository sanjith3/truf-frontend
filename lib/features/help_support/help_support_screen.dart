import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email?subject=Support Request&body=Hi Support Team,');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ... (Search Bar, Common Issues, FAQ Sections remain the same)
          // Note: To keep code clean, only showing the updated Contact Us section logic
          
          _buildTopContent(),

          const SizedBox(height: 30),

          // FAQ Section
          Text(
            "Frequently Asked Questions",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ..._buildFAQItems(),

          const SizedBox(height: 30),

          // Contact Options
          Text(
            "Contact Us",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildContactOptions(context),

          const SizedBox(height: 40),

          // Feedback Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Still need help?",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Our support team is available 24/7 to assist you with any issues.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LiveChatScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Send Message"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to keep the layout consistent while simplifying edits
  Widget _buildTopContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search for help...",
              border: InputBorder.none,
              icon: const Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Common Issues",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ..._buildCommonIssues(),
      ],
    );
  }

  List<Widget> _buildCommonIssues() {
    final issues = [
      {
        'title': 'Booking Cancellation',
        'subtitle': 'How to cancel a booking and refund policy',
        'icon': Icons.cancel_outlined,
      },
      {
        'title': 'Payment Issues',
        'subtitle': 'Payment failed or refund not received',
        'icon': Icons.payment_outlined,
      },
      {
        'title': 'Turf Availability',
        'subtitle': 'Check real-time turf availability',
        'icon': Icons.schedule_outlined,
      },
      {
        'title': 'Account Issues',
        'subtitle': 'Login, password reset, profile update',
        'icon': Icons.person_outline,
      },
    ];

    return issues.map((issue) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(
            issue['icon'] as IconData,
            color: const Color(0xFF1DB954),
          ),
          title: Text(issue['title'] as String),
          subtitle: Text(issue['subtitle'] as String),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Handle tap
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildFAQItems() {
    final faqs = [
      {
        'question': 'How do I book a turf?',
        'answer':
            'Navigate to the Home screen, select your preferred turf, choose date and time, and proceed to payment.',
      },
      {
        'question': 'What is the cancellation policy?',
        'answer':
            'Cancellations are allowed up to 24 hours before booking for a full refund. Late cancellations may incur charges.',
      },
      {
        'question': 'How do credits work?',
        'answer':
            'Earn credits by completing bookings. 1 credit = ₹1. Use credits for future bookings or transfer to wallet.',
      },
      {
        'question': 'Are there membership plans?',
        'answer':
            'Yes! We offer monthly and yearly plans with exclusive benefits including discounts and priority booking.',
      },
      {
        'question': 'How to become a turf partner?',
        'answer':
            'Go to Profile → Become a Turf Partner and submit your turf details. Our team will contact you within 24 hours.',
      },
    ];

    return faqs.map((faq) {
      return ExpansionTile(
        title: Text(faq['question'] as String),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(faq['answer'] as String),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildContactOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.phone, color: Color(0xFF1DB954)),
          title: const Text('Call Support'),
          subtitle: const Text('+91 8825934519'),
          onTap: () => _launchCaller('+918825934519'),
          trailing: const Icon(Icons.call, size: 20, color: Colors.grey),
        ),
        ListTile(
          leading: const Icon(Icons.email, color: Color(0xFF1DB954)),
          title: const Text('Email Support'),
          subtitle: const Text('support@turfzone.com'),
          onTap: () => _launchEmail('support@turfzone.com'),
          trailing: const Icon(Icons.email_outlined, size: 20, color: Colors.grey),
        ),
        ListTile(
          leading: const Icon(Icons.chat, color: Color(0xFF1DB954)),
          title: const Text('Live Chat'),
          subtitle: const Text('Available 24/7'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LiveChatScreen()),
            );
          },
          trailing: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
        ),
      ],
    );
  }
}
