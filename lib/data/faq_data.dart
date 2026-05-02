class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

final List<FaqItem> faqItems = [
  FaqItem(
    question: 'How do I book a turf?',
    answer:
        '1. Open the TurfSpotX app and go to Home screen\n'
        '2. Browse available turfs in your city\n'
        '3. Select your preferred turf\n'
        '4. Choose date and time slot\n'
        '5. Review booking details and apply any coupons\n'
        '6. Complete payment via Razorpay\n'
        '7. You\'ll receive confirmation via SMS and email',
  ),
  FaqItem(
    question: 'What is the cancellation policy?',
    answer:
        '• Free cancellation up to 24 hours before slot — 100% refund\n'
        '• Cancellation between 6-24 hours — 50% refund\n'
        '• Cancellation less than 6 hours — No refund\n'
        '• Owner cancellation — Full refund + ₹50 credit\n'
        '• Refunds processed within 5-7 business days',
  ),
  FaqItem(
    question: 'How do credits work?',
    answer:
        '• Earn 10 credits for every confirmed booking\n'
        '• 100 credits = 1 free booking\n'
        '• Credits expire after 30 days\n'
        '• Use credits at checkout for discounts\n'
        '• Refer friends to earn bonus credits',
  ),
  FaqItem(
    question: 'Are there membership plans?',
    answer:
        'Currently we offer pay-per-use only. '
        'Membership plans coming soon! Join our waitlist to get notified.',
  ),
  FaqItem(
    question: 'How to become a turf partner?',
    answer:
        '1. Go to Profile → Become a Partner\n'
        '2. Fill turf details (name, location, price, photos)\n'
        '3. Provide bank details for payouts\n'
        '4. Submit for verification\n'
        '5. Our team will review within 48 hours\n'
        '6. Once approved, start accepting bookings!',
  ),
];
