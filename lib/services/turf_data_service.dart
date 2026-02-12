import '../models/turf.dart';
import '../models/booking.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TurfDataService extends ChangeNotifier {
  static final TurfDataService _instance = TurfDataService._internal();
  factory TurfDataService() => _instance;

  TurfDataService._internal() {
    _loadSavedTurfs();
    _loadCustomSlots();
    initDemoBookings();
  }

  // ============================================================
  // SLOT STORAGE
  // Key: "turfName_YYYY-MM-DD" -> List of slot maps
  // ============================================================
  final Map<String, List<Map<String, dynamic>>> _customSlots = {};

  String _slotKey(String turfName, DateTime date) =>
      "${turfName}_${date.year}-${date.month}-${date.day}";

  /// SAVE single slot (USED BY SlotManagementScreen)
  Future<void> saveSlotData(
    String turfName,
    DateTime date,
    String slotTime,
    Map<String, dynamic> data,
  ) async {
    final key = _slotKey(turfName, date);

    if (!_customSlots.containsKey(key)) {
      _customSlots[key] = [];
    }

    final index = _customSlots[key]!.indexWhere((s) => s['time'] == slotTime);

    if (index != -1) {
      _customSlots[key]![index] = data;
    } else {
      _customSlots[key]!.add(data);
    }

    await _persistCustomSlots();
    notifyListeners();
  }

  /// SAVE full day slots (existing method kept)
  Future<void> saveSlots(
    String turfName,
    DateTime date,
    List<Map<String, dynamic>> slots,
  ) async {
    _customSlots[_slotKey(turfName, date)] = slots;
    await _persistCustomSlots();
    notifyListeners();
  }

  /// GET saved slots
  List<Map<String, dynamic>>? getSavedSlots(String turfName, DateTime date) {
    return _customSlots[_slotKey(turfName, date)];
  }

  Future<void> _persistCustomSlots() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_slots_data', jsonEncode(_customSlots));
  }

  Future<void> _loadCustomSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('custom_slots_data');

    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          _customSlots[key] = List<Map<String, dynamic>>.from(
            (value as List).map((i) => Map<String, dynamic>.from(i)),
          );
        });
      } catch (e) {
        debugPrint("Error loading custom slots: $e");
      }
    }
  }

  // ============================================================
  // TURF DATA
  // ============================================================
  final List<Turf> _turfs = [
    Turf(
      id: '1',
      name: "Green Field Arena",
      location: "PN Pudur",
      city: "Coimbatore",
      distance: 2.5,
      price: 500,
      rating: 4.8,
      images: [
        "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800&q=80",
      ],
      amenities: ["Flood Lights", "Parking", "Water", "Showers", "Cafeteria"],
      sports: ["Cricket", "Football", "Basketball"],
      mapLink: "https://maps.app.goo.gl/xyz123",
      address: "123 Sports Complex, PN Pudur, Coimbatore",
      description: "Premium turf with professional-grade facilities",
    ),
    Turf(
      id: '2',
      name: "City Sports Turf",
      location: "Gandhipuram",
      city: "Coimbatore",
      distance: 4.2,
      price: 650,
      rating: 4.5,
      images: [
        "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800&q=80",
      ],
      amenities: ["Cafeteria", "Parking", "Flood Lights", "Changing Rooms"],
      sports: ["Football", "Volleyball"],
      mapLink: "https://maps.app.goo.gl/abc456",
      address: "45 Main Road, Gandhipuram, Coimbatore",
      description: "City center turf with excellent amenities",
    ),
    Turf(
      id: '3',
      name: "Elite Football Ground",
      location: "Race Course",
      city: "Coimbatore",
      distance: 3.1,
      price: 800,
      rating: 4.9,
      images: [
        "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80",
      ],
      amenities: ["Flood Lights", "Gym", "Parking", "WiFi", "Showers"],
      sports: ["Football", "Cricket"],
      mapLink: "https://maps.app.goo.gl/def789",
      address: "Race Course Road, Coimbatore",
      description: "Professional football ground with international standards",
    ),
  ];

  /// REQUIRED by SlotManagementScreen
  Future<List<Turf>> getAllTurfs() async {
    return List.unmodifiable(_turfs);
  }

  List<Turf> get turfs => List.unmodifiable(_turfs);

  void addTurf(Turf turf) {
    _turfs.insert(0, turf);
    _saveTurfs();
    notifyListeners();
  }

  Future<void> _saveTurfs() async {
    final prefs = await SharedPreferences.getInstance();

    final dynamicTurfs = _turfs
        .where((t) => int.tryParse(t.id) == null)
        .toList();

    final turfJsonList = dynamicTurfs
        .map((t) => jsonEncode(t.toJson()))
        .toList();

    await prefs.setStringList('dynamic_turfs', turfJsonList);
  }

  Future<void> _loadSavedTurfs() async {
    final prefs = await SharedPreferences.getInstance();
    final turfJsonList = prefs.getStringList('dynamic_turfs');

    if (turfJsonList != null) {
      for (final turfJson in turfJsonList) {
        try {
          final turf = Turf.fromJson(jsonDecode(turfJson));
          if (!_turfs.any((t) => t.id == turf.id)) {
            _turfs.add(turf);
          }
        } catch (e) {
          debugPrint("Error loading turf: $e");
        }
      }
    }
  }

  // ============================================================
  // BOOKINGS
  // ============================================================
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  /// Demo data
  void initDemoBookings() {
    if (_bookings.isNotEmpty) return;

    final now = DateTime.now();

    _bookings.add(
      Booking(
        id: '1',
        turfName: 'Green Field Arena',
        userName: 'Arjun Kumar',
        userPhone: '9876543210',
        location: 'PN Pudur',
        distance: 2.5,
        rating: 4.8,
        date: DateTime(now.year, now.month, now.day),
        startTime: '18:00',
        endTime: '19:00',
        amount: 500,
        status: BookingStatus.upcoming,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-001',
        amenities: ["Lights", "Parking", "Water"],
        mapLink: "https://maps.app.goo.gl/xyz123",
        address: "123 Sports Complex, PN Pudur, Coimbatore",
      ),
    );
  }
}
