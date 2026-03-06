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
  final double amount; // final_price from API
  BookingStatus status;
  String paymentStatus;
  final String bookingId;
  final List<String> amenities;
  final List<String> sports;
  final String mapLink;
  final String address;
  bool? cancelledByAdmin;
  final String? cancelledReason;

  // Image from API (cover image URL)
  final String? imageUrl;

  // Financial breakdown (from API)
  final double totalPrice;
  final double discount;
  final double gstAmount;
  final double platformFee;
  final double creditsUsed;
  final bool isRedeemed;

  // Offer info
  final bool hasActiveOffer;
  final String? offerType;
  final String? offerValue;

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
    required this.sports,
    required this.mapLink,
    required this.address,
    this.cancelledByAdmin = false,
    this.cancelledReason,
    this.imageUrl,
    this.totalPrice = 0.0,
    this.discount = 0.0,
    this.gstAmount = 0.0,
    this.platformFee = 0.0,
    this.creditsUsed = 0,
    this.isRedeemed = false,
    this.hasActiveOffer = false,
    this.offerType,
    this.offerValue,
  });

  /// Parse a booking from the my_bookings API response.
  /// API fields: id, turf{name,city,address,google_maps_share_link,rating,
  ///   amenities,sports,images,cover_image,has_active_offer,max_offer_type,max_offer_value},
  ///   booking_date, start_time, end_time, final_price, total_price, discount,
  ///   gst_amount, platform_fee, credits_used, is_redeemed,
  ///   booking_status, payment_status, user{full_name,phone_number}
  factory Booking.fromJson(Map<String, dynamic> json) {
    final turf = json['turf'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};

    // Parse amenities
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

    // Parse sports
    final sportsList = <String>[];
    if (turf['sports'] is List) {
      for (final s in turf['sports'] as List) {
        if (s is Map<String, dynamic>) {
          sportsList.add(s['name']?.toString() ?? '');
        } else {
          sportsList.add(s.toString());
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

    // Parse booking_date
    DateTime bookingDate;
    try {
      bookingDate = DateTime.parse(json['booking_date'] ?? '');
    } catch (_) {
      bookingDate = DateTime.now();
    }

    // Format time strings (API sends HH:MM:SS → HH:MM)
    String formatTime(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      final parts = raw.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return raw;
    }

    // Pick best image URL: cover_image first, then images[0], then null
    String? imageUrl = turf['cover_image']?.toString();
    if ((imageUrl == null || imageUrl.isEmpty) && turf['images'] is List) {
      final imgs = turf['images'] as List;
      if (imgs.isNotEmpty && imgs[0] is Map) {
        imageUrl = (imgs[0] as Map)['image']?.toString();
      }
    }

    return Booking(
      id: json['id']?.toString() ?? '',
      turfName: turf['name']?.toString() ?? 'Unknown Turf',
      userName: user['full_name']?.toString() ?? '',
      userPhone: user['phone_number']?.toString() ?? '',
      location: turf['city']?.toString() ?? '',
      distance: 0.0,
      rating: double.tryParse(turf['rating']?.toString() ?? '') ?? 0.0,
      date: bookingDate,
      startTime: formatTime(json['start_time']?.toString()),
      endTime: formatTime(json['end_time']?.toString()),
      amount: double.tryParse(json['final_price']?.toString() ?? '') ?? 0.0,
      status: bookingStatus,
      paymentStatus: json['payment_status']?.toString() ?? '',
      bookingId: json['id']?.toString() ?? '',
      amenities: amenitiesList,
      sports: sportsList,
      mapLink: turf['google_maps_share_link']?.toString() ?? '',
      address: turf['address']?.toString() ?? '',
      cancelledByAdmin: json['cancelled_by_admin'] as bool? ?? false,
      cancelledReason: json['cancelled_reason']?.toString(),
      imageUrl: imageUrl,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '') ?? 0.0,
      platformFee:
          double.tryParse(json['platform_fee']?.toString() ?? '') ?? 0.0,
      creditsUsed:
          double.tryParse(json['credits_used']?.toString() ?? '') ?? 0.0,
      isRedeemed: json['is_redeemed'] as bool? ?? false,
      hasActiveOffer: turf['has_active_offer'] as bool? ?? false,
      offerType: turf['max_offer_type']?.toString(),
      offerValue: turf['max_offer_value']?.toString(),
    );
  }
}
