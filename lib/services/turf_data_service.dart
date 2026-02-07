import '../models/turf.dart';
import '../features/bookings/my_bookings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TurfDataService extends ChangeNotifier {
  static final TurfDataService _instance = TurfDataService._internal();
  factory TurfDataService() => _instance;
  TurfDataService._internal() {
    _loadSavedTurfs();
  }

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

  final List<Booking> _bookings = [];

  List<Turf> get turfs => List.unmodifiable(_turfs);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addTurf(Turf turf) {
    _turfs.insert(0, turf);
    _saveTurfs();
    notifyListeners();
  }

  Future<void> _saveTurfs() async {
    final prefs = await SharedPreferences.getInstance();
    // Only save the dynamic turfs (those not in the static list, or just save all if you prefer)
    // For simplicity, let's save all turfs adding a flag or just save the dynamic ones.
    // Actually, it's safer to save all and filter or just save dynamic.
    // Let's save dynamic turfs in a separate key.
    List<Turf> dynamicTurfs = _turfs.where((t) => int.tryParse(t.id) == null || int.parse(t.id) > 10).toList();
    List<String> turfJsonList = dynamicTurfs.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('dynamic_turfs', turfJsonList);
  }

  Future<void> _loadSavedTurfs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? turfJsonList = prefs.getStringList('dynamic_turfs');
    if (turfJsonList != null) {
      for (String turfJson in turfJsonList) {
        try {
          Turf turf = Turf.fromJson(jsonDecode(turfJson));
          if (!_turfs.any((t) => t.id == turf.id)) {
            _turfs.add(turf);
          }
        } catch (e) {
          debugPrint("Error loading turf: $e");
        }
      }
      notifyListeners();
    }
  }

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  // Initial bookings for demo
  void initDemoBookings() {
    if (_bookings.isNotEmpty) return;
    
    final now = DateTime.now();
    
    // Add multiple demo bookings for better analytics visualization
    _bookings.addAll([
      // Bookings for Green Field Arena
      Booking(
        id: '1',
        turfName: 'Green Field Arena',
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
      Booking(
        id: '2',
        turfName: 'Green Field Arena',
        location: 'PN Pudur',
        distance: 2.5,
        rating: 4.8,
        date: DateTime(now.year, now.month, now.day - 1),
        startTime: '10:00',
        endTime: '11:00',
        amount: 500,
        status: BookingStatus.completed,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-002',
        amenities: ["Lights", "Parking", "Water"],
        mapLink: "https://maps.app.goo.gl/xyz123",
        address: "123 Sports Complex, PN Pudur, Coimbatore",
      ),
      Booking(
        id: '3',
        turfName: 'Green Field Arena',
        location: 'PN Pudur',
        distance: 2.5,
        rating: 4.8,
        date: DateTime(now.year, now.month, now.day - 2),
        startTime: '21:00',
        endTime: '22:00',
        amount: 500,
        status: BookingStatus.completed,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-003',
        amenities: ["Lights", "Parking", "Water"],
        mapLink: "https://maps.app.goo.gl/xyz123",
        address: "123 Sports Complex, PN Pudur, Coimbatore",
      ),
      // Bookings for City Sports Turf
      Booking(
        id: '4',
        turfName: 'City Sports Turf',
        location: 'Gandhipuram',
        distance: 4.2,
        rating: 4.5,
        date: DateTime(now.year, now.month, now.day),
        startTime: '19:00',
        endTime: '20:00',
        amount: 650,
        status: BookingStatus.upcoming,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-004',
        amenities: ["Cafeteria", "Parking"],
        mapLink: "https://maps.app.goo.gl/abc456",
        address: "45 Main Road, Gandhipuram, Coimbatore",
      ),
      Booking(
        id: '5',
        turfName: 'City Sports Turf',
        location: 'Gandhipuram',
        distance: 4.2,
        rating: 4.5,
        date: DateTime(now.year, now.month, now.day - 3),
        startTime: '16:00',
        endTime: '17:00',
        amount: 650,
        status: BookingStatus.completed,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-005',
        amenities: ["Cafeteria", "Parking"],
        mapLink: "https://maps.app.goo.gl/abc456",
        address: "45 Main Road, Gandhipuram, Coimbatore",
      ),
      // Bookings for Elite Football Ground
      Booking(
        id: '6',
        turfName: 'Elite Football Ground',
        location: 'Race Course',
        distance: 3.1,
        rating: 4.9,
        date: DateTime(now.year, now.month, now.day - 4),
        startTime: '18:00',
        endTime: '19:00',
        amount: 800,
        status: BookingStatus.completed,
        paymentStatus: 'Paid',
        bookingId: 'TURF-2024-006',
        amenities: ["Locker Room", "WiFi"],
        mapLink: "https://maps.app.goo.gl/def789",
        address: "Race Course Road, Coimbatore",
      ),
    ]);
    notifyListeners();
  }
}
