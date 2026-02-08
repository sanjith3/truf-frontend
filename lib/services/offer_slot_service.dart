class OfferSlotService {
  // in-memory storage
  static final List<String> _offerSlots = [];

  /// Get all offer slot times
  static Future<List<String>> getOfferSlots() async {
    return _offerSlots;
  }

  /// Add an offer slot
  static Future<void> addOfferSlot(
    String time,
    int offerPrice,
    int originalPrice,
  ) async {
    if (!_offerSlots.contains(time)) {
      _offerSlots.add(time);
    }
  }

  /// Remove an offer slot
  static Future<void> removeOfferSlot(String time) async {
    _offerSlots.remove(time);
  }
}
