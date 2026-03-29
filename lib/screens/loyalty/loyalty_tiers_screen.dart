import 'package:flutter/material.dart';
import '../../models/loyalty_tier.dart';
import '../../services/api_service.dart';

class LoyaltyTiersScreen extends StatefulWidget {
  const LoyaltyTiersScreen({super.key});

  @override
  State<LoyaltyTiersScreen> createState() => _LoyaltyTiersScreenState();
}

class _LoyaltyTiersScreenState extends State<LoyaltyTiersScreen> {
  bool _isLoading = true;
  String? _error;

  String _currentTierId = 'newbie';
  int _totalBookings = 0;
  int _freeBookingCounter = 0;
  bool _freeBookingAvailable = false;
  int _freeBookingEvery = 0;

  @override
  void initState() {
    super.initState();
    _fetchLoyaltyData();
  }

  Future<void> _fetchLoyaltyData() async {
    try {
      final response = await ApiService().getAuth(
        '/api/users/user-profile/loyalty/',
      );
      if (response['success'] == true) {
        final data = response['loyalty'];
        setState(() {
          _currentTierId = data['current_tier'] ?? 'newbie';
          _totalBookings = data['total_bookings'] ?? 0;
          _freeBookingCounter = data['free_booking_counter'] ?? 0;
          _freeBookingAvailable = data['free_booking_available'] ?? false;
          _freeBookingEvery = data['free_booking_every'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load loyalty data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loyalty Program'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loyalty Program'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(_error!)),
      );
    }

    final currentTier = LoyaltyTier.allTiers.firstWhere(
      (t) => t.name == _currentTierId,
      orElse: () => LoyaltyTier.allTiers.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Program'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current tier summary
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    currentTier.color,
                    currentTier.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR CURRENT TIER',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(currentTier.icon, style: TextStyle(fontSize: 40)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTier.displayName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$_totalBookings total bookings',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Action buttons and dynamic benefits rendering
                  if (_freeBookingEvery > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Free Booking Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_freeBookingCounter / $_freeBookingEvery',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _freeBookingEvery > 0
                                ? _freeBookingCounter / _freeBookingEvery
                                : 0,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          if (_freeBookingAvailable) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // This is informative - user redeems during checkout preview
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Free booking will be applied automatically at checkout!',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: currentTier.color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('REDEEM YOUR FREE BOOKING'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 24),

            Text(
              'All Tiers & Benefits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // List all tiers
            ...LoyaltyTier.allTiers.map((tier) => _buildTierCard(tier)),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(LoyaltyTier tier) {
    final isCurrentTier = tier.name == _currentTierId;
    final isUnlocked = _totalBookings >= tier.minBookings;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentTier ? tier.color : Colors.grey[300]!,
          width: isCurrentTier ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Tier header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentTier
                  ? tier.color.withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tier.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(tier.icon, style: TextStyle(fontSize: 24)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentTier) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tier.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'CURRENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${tier.minBookings}+ bookings',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked && tier.minBookings > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Locked',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),

          // Benefits list
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: tier.benefits.map((benefit) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: tier.color),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
