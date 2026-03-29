import 'package:flutter/material.dart';

class LoyaltyTier {
  final String name;
  final String displayName;
  final int minBookings;
  final int maxBookings;
  final String icon;
  final Color color;
  final List<String> benefits;

  const LoyaltyTier({
    required this.name,
    required this.displayName,
    required this.minBookings,
    required this.maxBookings,
    required this.icon,
    required this.color,
    required this.benefits,
  });

  static const List<LoyaltyTier> allTiers = [
    LoyaltyTier(
      name: 'newbie',
      displayName: 'Newbie',
      minBookings: 0,
      maxBookings: 4,
      icon: '🌱',
      color: Color(0xFF6B7280), // Gray
      benefits: [
        'Basic access to all turfs',
        'Standard customer support',
        'Earn 10 credits per booking',
      ],
    ),
    LoyaltyTier(
      name: 'bronze',
      displayName: 'Bronze',
      minBookings: 5,
      maxBookings: 14,
      icon: '🥉',
      color: Color(0xFFCD7F32), // Bronze
      benefits: [
        '5% extra cashback on all bookings',
        'Priority email support',
        'Early access to weekend slots',
        'Monthly exclusive offers',
      ],
    ),
    LoyaltyTier(
      name: 'silver',
      displayName: 'Silver',
      minBookings: 15,
      maxBookings: 29,
      icon: '🥈',
      color: Color(0xFFC0C0C0), // Silver
      benefits: [
        '10% extra cashback on all bookings',
        'Priority phone support',
        '48-hour early booking window',
        'Free cancellation up to 12 hours',
        'Birthday bonus credits',
      ],
    ),
    LoyaltyTier(
      name: 'gold',
      displayName: 'Gold',
      minBookings: 30,
      maxBookings: 49,
      icon: '🥇',
      color: Color(0xFFFFD700), // Gold
      benefits: [
        '15% extra cashback on all bookings',
        'Dedicated support line',
        '7-day early booking window',
        'Free booking every 10th booking',
        'Exclusive Gold-only offers',
        'Priority dispute resolution',
      ],
    ),
    LoyaltyTier(
      name: 'platinum',
      displayName: 'Platinum',
      minBookings: 50,
      maxBookings: 999,
      icon: '💎',
      color: Color(0xFFE5E4E2), // Platinum
      benefits: [
        '20% extra cashback on all bookings',
        'Personal account manager',
        '14-day early booking window',
        'Free booking every 5th booking',
        'VIP event invitations',
        'Partner restaurant discounts',
        'No cancellation fees',
      ],
    ),
  ];

  static LoyaltyTier getTierForBookings(int bookings) {
    for (final tier in allTiers) {
      if (bookings >= tier.minBookings && bookings <= tier.maxBookings) {
        return tier;
      }
    }
    return allTiers.first; // Newbie
  }
}
