import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

// ─── DATA MODELS ──────────────────────────────────────────────────────────

class OfferConfig {
  final bool isActive;
  final double? discountAmount;
  final int? discountPercent;
  final double? minOrderValue;
  final int expiryDays;
  final List<int> streakThresholds;
  final List<int> streakRewards;
  final List<int> loyaltyTiers;
  final List<String> loyaltyPerks;
  final Map<String, dynamic> referralRewards;
  final List<List<int>> lastMinuteWindows;

  const OfferConfig({
    this.isActive = false,
    this.discountAmount,
    this.discountPercent,
    this.minOrderValue,
    this.expiryDays = 30,
    this.streakThresholds = const [],
    this.streakRewards = const [],
    this.loyaltyTiers = const [],
    this.loyaltyPerks = const [],
    this.referralRewards = const {},
    this.lastMinuteWindows = const [],
  });

  factory OfferConfig.fromJson(Map<String, dynamic> json) {
    return OfferConfig(
      isActive: json['is_active'] ?? false,
      discountAmount: json['discount_amount'] != null
          ? double.tryParse(json['discount_amount'].toString())
          : null,
      discountPercent: json['discount_percent'],
      minOrderValue: json['min_order_value'] != null
          ? double.tryParse(json['min_order_value'].toString())
          : null,
      expiryDays: json['expiry_days'] ?? 30,
      streakThresholds: List<int>.from(json['streak_thresholds'] ?? []),
      streakRewards: List<int>.from(json['streak_rewards'] ?? []),
      loyaltyTiers: List<int>.from(json['loyalty_tiers'] ?? []),
      loyaltyPerks: List<String>.from(json['loyalty_perks'] ?? []),
      referralRewards: Map<String, dynamic>.from(
        json['referral_rewards'] ?? {},
      ),
      lastMinuteWindows: (json['last_minute_windows'] as List<dynamic>? ?? [])
          .map((w) => List<int>.from(w))
          .toList(),
    );
  }

  /// For last-minute: given hours until slot, return discount rate (0 if none)
  int getLastMinuteRate(double hoursUntil) {
    for (final w in lastMinuteWindows) {
      if (w.length >= 3 && hoursUntil >= w[0] && hoursUntil < w[1]) {
        return w[2];
      }
    }
    return 0;
  }
}

class AllOfferConfigs {
  final OfferConfig firstBooking;
  final OfferConfig referral;
  final OfferConfig lastMinute;
  final OfferConfig streak;
  final OfferConfig loyalty;
  final OfferConfig captain;
  final OfferConfig wallet;

  const AllOfferConfigs({
    this.firstBooking = const OfferConfig(),
    this.referral = const OfferConfig(),
    this.lastMinute = const OfferConfig(),
    this.streak = const OfferConfig(),
    this.loyalty = const OfferConfig(),
    this.captain = const OfferConfig(),
    this.wallet = const OfferConfig(),
  });

  factory AllOfferConfigs.fromJson(Map<String, dynamic> json) {
    OfferConfig _parse(String key) {
      final d = json[key];
      return d != null ? OfferConfig.fromJson(d) : const OfferConfig();
    }

    return AllOfferConfigs(
      firstBooking: _parse('first_booking'),
      referral: _parse('referral'),
      lastMinute: _parse('last_minute'),
      streak: _parse('streak'),
      loyalty: _parse('loyalty'),
      captain: _parse('captain'),
      wallet: _parse('wallet'),
    );
  }
}

// ─── OFFER SERVICE ────────────────────────────────────────────────────────

class OfferService {
  static const _cacheKey = 'offer_config_cache';
  static const _cacheTtlKey = 'offer_config_cache_ts';
  static const _cacheTtlMinutes = 30;

  final ApiService _api = ApiService();
  static AllOfferConfigs? _cachedConfig;

  Future<AllOfferConfigs> fetchConfig({bool force = false}) async {
    // Memory-level cache first
    if (!force && _cachedConfig != null) return _cachedConfig!;

    // Disk cache (30-minute TTL)
    if (!force) {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_cacheTtlKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age < _cacheTtlMinutes * 60 * 1000) {
        final raw = prefs.getString(_cacheKey);
        if (raw != null) {
          try {
            final json = Map<String, dynamic>.from(
              await Future.value(Map.from({})..addAll(_jsonDecode(raw))),
            );
            _cachedConfig = AllOfferConfigs.fromJson(json);
            return _cachedConfig!;
          } catch (_) {}
        }
      }
    }

    try {
      final resp = await _api.get('/api/growth/config/');
      if (resp['success'] == true && resp['config'] != null) {
        final raw = resp['config'] as Map<String, dynamic>;
        _cachedConfig = AllOfferConfigs.fromJson(raw);

        // Persist to disk
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(_cacheKey, raw.toString());
        prefs.setInt(_cacheTtlKey, DateTime.now().millisecondsSinceEpoch);

        return _cachedConfig!;
      }
    } catch (e) {
      debugPrint('OfferService.fetch error: $e');
    }
    return _cachedConfig ?? const AllOfferConfigs();
  }

  Map<String, dynamic> _jsonDecode(String s) {
    // Simple disk cache fallback — use in-memory if decode fails
    return {};
  }

  void invalidateCache() {
    _cachedConfig = null;
  }
}

// ─── OFFER PROVIDER ───────────────────────────────────────────────────────

class OfferProvider extends ChangeNotifier {
  AllOfferConfigs _config = const AllOfferConfigs();
  bool _isLoading = false;
  final OfferService _service = OfferService();

  AllOfferConfigs get config => _config;
  bool get isLoading => _isLoading;

  Future<void> loadConfig({bool force = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _config = await _service.fetchConfig(force: force);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Should show first-booking offer for a new user?
  bool shouldShowFirstBooking(int totalBookings) {
    return _config.firstBooking.isActive && totalBookings == 0;
  }

  /// Get last-minute discount rate for a slot (hours from now)
  int getLastMinuteRate(double hoursUntil) {
    if (!_config.lastMinute.isActive) return 0;
    return _config.lastMinute.getLastMinuteRate(hoursUntil);
  }

  /// Get loyalty tier name & perk for a given booking count
  Map<String, String> getLoyaltyInfo(int bookingCount) {
    final tiers = _config.loyalty.loyaltyTiers;
    final perks = _config.loyalty.loyaltyPerks;
    final tierNames = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    String tier = 'Newbie', perk = 'No perks yet';
    for (int i = tiers.length - 1; i >= 0; i--) {
      if (bookingCount >= tiers[i]) {
        tier = tierNames.length > i ? tierNames[i] : 'Tier ${i + 1}';
        perk = perks.length > i ? perks[i] : '';
        break;
      }
    }
    return {'tier': tier, 'perk': perk};
  }

  /// Get next loyalty milestone info
  Map<String, dynamic>? getNextLoyaltyMilestone(int bookingCount) {
    final tiers = _config.loyalty.loyaltyTiers;
    final tierNames = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    for (int i = 0; i < tiers.length; i++) {
      if (bookingCount < tiers[i]) {
        return {
          'nextTier': tierNames.length > i ? tierNames[i] : 'Tier ${i + 1}',
          'neededBookings': tiers[i] - bookingCount,
          'threshold': tiers[i],
        };
      }
    }
    return null; // Reached maximum tier
  }
}
