import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Last Updated: January 1, 2024",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Introduction
            _buildSection(
              title: "1. Introduction",
              content:
                  "TurfZone respects your privacy and is committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you use our application and tell you about your privacy rights.",
            ),

            // Information We Collect
            _buildSection(
              title: "2. Information We Collect",
              content:
                  "We collect various types of information to provide and improve our services:\n\n"
                  "• Personal Information: Name, email, phone number, profile picture\n"
                  "• Booking Information: Turf preferences, booking history, payment details\n"
                  "• Device Information: IP address, device type, operating system\n"
                  "• Location Data: With your permission, to show nearby turfs",
            ),

            // How We Use Your Information
            _buildSection(
              title: "3. How We Use Your Information",
              content:
                  "We use your information for:\n\n"
                  "• Providing and maintaining our service\n"
                  "• Processing your bookings and payments\n"
                  "• Sending important updates and notifications\n"
                  "• Improving user experience and app functionality\n"
                  "• Compliance with legal obligations",
            ),

            // Data Security
            _buildSection(
              title: "4. Data Security",
              content:
                  "We implement appropriate technical and organizational measures to protect your personal data. All payment transactions are encrypted using SSL technology. We regularly review our security procedures.",
            ),

            // Third-Party Services
            _buildSection(
              title: "5. Third-Party Services",
              content:
                  "We may employ third-party companies for:\n\n"
                  "• Payment processing (Razorpay, Stripe)\n"
                  "• Analytics services (Google Analytics)\n"
                  "• Cloud storage and hosting\n"
                  "• Customer support services",
            ),

            // Your Rights
            _buildSection(
              title: "6. Your Rights",
              content:
                  "You have the right to:\n\n"
                  "• Access your personal data\n"
                  "• Rectify inaccurate data\n"
                  "• Request deletion of your data\n"
                  "• Object to processing of your data\n"
                  "• Data portability\n"
                  "• Withdraw consent at any time",
            ),

            // Contact Us
            _buildSection(
              title: "7. Contact Us",
              content:
                  "For any privacy-related questions or concerns:\n\n"
                  "Email: privacy@turfzone.com\n"
                  "Address: TurfZone Technologies Pvt. Ltd., Mumbai, India\n"
                  "Phone: +91 1800-123-4567",
            ),

            const SizedBox(height: 40),

            // Acceptance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                "By using TurfZone, you acknowledge that you have read and understood this Privacy Policy.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}