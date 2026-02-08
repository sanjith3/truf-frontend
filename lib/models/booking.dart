enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking {
  final String id;
  final String turfName;
  final DateTime date;
  final double amount;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.turfName,
    required this.date,
    required this.amount,
    required this.status,
  });
}
