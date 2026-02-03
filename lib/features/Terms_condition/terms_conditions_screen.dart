import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Important Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        "Important Notice",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please read these terms carefully before using our services. By accessing or using TurfZone, you agree to be bound by these terms.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Terms Sections
            _buildTermSection(
              number: "1",
              title: "Acceptance of Terms",
              content:
                  "By accessing and using TurfZone, you accept and agree to be bound by these Terms. If you do not agree, you must not use our services.",
            ),

            _buildTermSection(
              number: "2",
              title: "User Account",
              content:
                  "• You must be at least 18 years old to create an account\n"
                  "• You are responsible for maintaining account security\n"
                  "• You must provide accurate and complete information\n"
                  "• You are responsible for all activities under your account",
            ),

            _buildTermSection(
              number: "3",
              title: "Booking and Payments",
              content:
                  "• All bookings are subject to turf availability\n"
                  "• Payment must be completed to confirm booking\n"
                  "• Refunds are processed per our cancellation policy\n"
                  "• We use secure third-party payment gateways",
            ),

            _buildTermSection(
              number: "4",
              title: "Cancellation Policy",
              content:
                  "• Full refund if cancelled 24+ hours before booking\n"
                  "• 50% refund if cancelled 12-24 hours before\n"
                  "• No refund if cancelled less than 12 hours before\n"
                  "• Weather-related cancellations are fully refundable",
            ),

            _buildTermSection(
              number: "5",
              title: "User Conduct",
              content:
                  "You agree not to:\n"
                  "• Use the service for illegal purposes\n"
                  "• Harm, threaten, or harass others\n"
                  "• Attempt to hack or disrupt our services\n"
                  "• Share inappropriate content\n"
                  "• Violate turf facility rules",
            ),

            _buildTermSection(
              number: "6",
              title: "Intellectual Property",
              content:
                  "All content, logos, and software are owned by TurfZone. You may not copy, modify, or distribute any content without explicit permission.",
            ),

            _buildTermSection(
              number: "7",
              title: "Limitation of Liability",
              content:
                  "TurfZone is not liable for:\n"
                  "• Injuries during turf usage\n"
                  "• Property damage at turf facilities\n"
                  "• Technical issues beyond our control\n"
                  "• Third-party actions or services",
            ),

            _buildTermSection(
              number: "8",
              title: "Modifications to Terms",
              content:
                  "We reserve the right to modify these terms at any time. Continued use after changes constitutes acceptance. We will notify users of significant changes.",
            ),

            _buildTermSection(
              number: "9",
              title: "Governing Law",
              content:
                  "These terms are governed by Indian law. Any disputes shall be subject to the exclusive jurisdiction of courts in Mumbai, Maharashtra.",
            ),

            const SizedBox(height: 40),

            // Agreement Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF1DB954)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "I have read and agree to the Terms & Conditions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}