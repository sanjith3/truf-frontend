import '../models/turf.dart';
import '../features/bookings/my_bookings_screen.dart';

class TurfDataService {
  static final TurfDataService _instance = TurfDataService._internal();
  factory TurfDataService() => _instance;
  TurfDataService._internal();

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
    Turf(
      id: '4',
      name: "Chennai Mega Turf",
      location: "Adyar",
      city: "Chennai",
      distance: 1.5,
      price: 1200,
      rating: 4.7,
      images: [
        "https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=800&q=80",
      ],
      amenities: ["Flood Lights", "Locker Room", "Parking"],
      sports: ["Football", "Tennis"],
      mapLink: "https://maps.app.goo.gl/chennai1",
      address: "Adyar Main Road, Chennai",
      description: "Largest turf in Chennai with top-notch grass quality",
    ),
    Turf(
      id: '5',
      name: "Madurai Temple Turf",
      location: "Anna Nagar",
      city: "Madurai",
      distance: 2.8,
      price: 450,
      rating: 4.6,
      images: [
        "https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800&q=80",
      ],
      amenities: ["Parking", "Water", "Restroom"],
      sports: ["Cricket", "Volleyball"],
      mapLink: "https://maps.app.goo.gl/madurai1",
      address: "Anna Nagar Ext area, Madurai",
      description: "Affordable and well-maintained turf in the heart of Madurai",
    ),
  ];

  final List<Booking> _bookings = [];

  List<Turf> get turfs => List.unmodifiable(_turfs);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addTurf(Turf turf) {
    _turfs.insert(0, turf);
  }

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
  }

  // Initial bookings for demo
  void initDemoBookings() {
    if (_bookings.isNotEmpty) return;
    
    final now = DateTime.now();
    _bookings.addAll([
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
        id: '5',
        turfName: 'Premium Sports Arena',
        location: 'Singanallur',
        distance: 6.2,
        rating: 4.7,
        date: DateTime(now.year, now.month, now.day + 2),
        startTime: '20:00',
        endTime: '21:00',
        amount: 1200,
        status: BookingStatus.cancelled,
        paymentStatus: 'Refunded',
        bookingId: 'TURF-2024-005',
        amenities: ["Flood Lights", "Parking", "Water", "Showers", "Cafeteria"],
        mapLink: "https://maps.app.goo.gl/jkl345",
        address: "Singanallur Industrial Area, Coimbatore",
      ),
    ]);
  }
}
