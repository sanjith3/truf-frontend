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
}
