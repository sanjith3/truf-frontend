import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage offer slots across the app
/// This allows admin to set offer slots and booking screen to read them
class OfferSlotService {
  static const String _offerSlotsKey = 'offer_slots';
  
  /// Get list of time slots that have offers
  static Future<List<String>> getOfferSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final String? offerSlotsJson = prefs.getString(_offerSlotsKey);
    
    if (offerSlotsJson == null || offerSlotsJson.isEmpty) {
      // Default offer slots if none are set
      return [
        '10:00 AM - 11:00 AM',
        '03:00 PM - 04:00 PM',
        '07:00 PM - 08:00 PM',
        '11:00 PM - 12:00 AM',
      ];
    }
    
    final List<dynamic> decoded = json.decode(offerSlotsJson);
    return decoded.cast<String>();
  }
  
  /// Set offer slots (admin function)
  static Future<void> setOfferSlots(List<String> offerSlots) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(offerSlots);
    await prefs.setString(_offerSlotsKey, encoded);
  }
  
  /// Check if a specific slot has an offer
  static Future<bool> isOfferSlot(String slotTime) async {
    final offerSlots = await getOfferSlots();
    return offerSlots.contains(slotTime);
  }
  
  /// Toggle offer status for a slot
  static Future<void> toggleOfferSlot(String slotTime) async {
    final offerSlots = await getOfferSlots();
    
    if (offerSlots.contains(slotTime)) {
      offerSlots.remove(slotTime);
    } else {
      offerSlots.add(slotTime);
    }
    
    await setOfferSlots(offerSlots);
  }
  
  /// Clear all offer slots
  static Future<void> clearAllOffers() async {
    await setOfferSlots([]);
  }
}
