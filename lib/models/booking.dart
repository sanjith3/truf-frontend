enum BookingStatus { pending, confirmed, upcoming, completed, cancelled }

class Booking {
  final String id;
  final String turfName;
  final String userName;
  final String userPhone;
  final String location;
  final double distance;
  final double rating;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double amount; // Using double for flexibility and currency
  BookingStatus status;
  String paymentStatus;
  final String bookingId;
  final List<String> amenities;
  final String mapLink;
  final String address;
  bool? cancelledByAdmin;

  Booking({
    required this.id,
    required this.turfName,
    required this.userName,
    required this.userPhone,
    required this.location,
    required this.distance,
    required this.rating,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.bookingId,
    required this.amenities,
    required this.mapLink,
    required this.address,
    this.cancelledByAdmin = false,
  });

  /// Parse a booking from the my_bookings API response.
  /// API fields: id, turf{name,city,address,google_maps_share_link,rating,amenities},
  ///   booking_date, start_time, end_time, final_price, booking_status, payment_status,
  ///   user{full_name,phone_number}
  factory Booking.fromJson(Map<String, dynamic> json) {
    final turf = json['turf'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};

    // Parse amenities from turf.amenities list
    final amenitiesList = <String>[];
    if (turf['amenities'] is List) {
      for (final a in turf['amenities'] as List) {
        if (a is Map<String, dynamic>) {
          amenitiesList.add(a['name']?.toString() ?? '');
        } else {
          amenitiesList.add(a.toString());
        }
      }
    }

    // Map booking_status string to BookingStatus enum
    BookingStatus bookingStatus;
    final statusStr = (json['booking_status'] ?? '').toString().toLowerCase();
    switch (statusStr) {
      case 'confirmed':
        bookingStatus = BookingStatus.confirmed;
        break;
      case 'pending':
        bookingStatus = BookingStatus.pending;
        break;
      case 'cancelled':
        bookingStatus = BookingStatus.cancelled;
        break;
      case 'completed':
        bookingStatus = BookingStatus.completed;
        break;
      default:
        bookingStatus = BookingStatus.pending;
    }

    // Parse booking_date (YYYY-MM-DD)
    DateTime bookingDate;
    try {
      bookingDate = DateTime.parse(json['booking_date'] ?? '');
    } catch (_) {
      bookingDate = DateTime.now();
    }

    // Format time strings (API sends HH:MM:SS, display as HH:MM)
    String formatTime(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      final parts = raw.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return raw;
    }

    return Booking(
      id: json['id']?.toString() ?? '',
      turfName: turf['name']?.toString() ?? 'Unknown Turf',
      userName: user['full_name']?.toString() ?? '',
      userPhone: user['phone_number']?.toString() ?? '',
      location: turf['city']?.toString() ?? '',
      distance: 0.0, // Not available from API
      rating: double.tryParse(turf['rating']?.toString() ?? '') ?? 0.0,
      date: bookingDate,
      startTime: formatTime(json['start_time']?.toString()),
      endTime: formatTime(json['end_time']?.toString()),
      amount: double.tryParse(json['final_price']?.toString() ?? '') ?? 0.0,
      status: bookingStatus,
      paymentStatus: json['payment_status']?.toString() ?? '',
      bookingId: json['id']?.toString() ?? '',
      amenities: amenitiesList,
      mapLink: turf['google_maps_share_link']?.toString() ?? '',
      address: turf['address']?.toString() ?? '',
      cancelledByAdmin: json['cancelled_by_admin'] as bool? ?? false,
    );
  }
}
