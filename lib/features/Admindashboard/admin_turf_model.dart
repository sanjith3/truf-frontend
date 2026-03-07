/// Shared data model for turf management screens.
/// Imported by both admin_screen.dart and edit_turf_screen.dart to avoid
/// type-mismatch errors from case-sensitive import path differences.

class AdminTurf {
  final String id;
  final String name;
  final String location;
  final double distance;
  final int price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> amenities;
  final List<String> sports;
  final String mapLink;
  final String address;
  final String description;
  // Today / all-time stats
  final int todayBookings;
  final double todayRevenue;
  final int totalBookings;
  final double totalRevenue;
  final int slotsCount;
  final double avgRating;
  // Weekly stats (populated from weekly_stats endpoint)
  final double weeklyRevenue;
  final double lastWeekRevenue;
  final int weeklyBookings;
  final int lastWeekBookings;
  final double revenueChangePct;
  final int bookingChange;
  // Shutdown state
  final bool isShutdown;
  final String? shutdownStart;
  final String? shutdownEnd;
  final String shutdownReason;

  bool isActive;

  AdminTurf({
    required this.id,
    required this.name,
    required this.location,
    this.distance = 0,
    this.price = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.images = const [],
    this.amenities = const [],
    this.sports = const [],
    this.mapLink = '',
    this.address = '',
    this.description = '',
    this.todayBookings = 0,
    this.todayRevenue = 0,
    this.totalBookings = 0,
    this.totalRevenue = 0,
    this.slotsCount = 0,
    this.avgRating = 0,
    this.weeklyRevenue = 0,
    this.lastWeekRevenue = 0,
    this.weeklyBookings = 0,
    this.lastWeekBookings = 0,
    this.revenueChangePct = 0,
    this.bookingChange = 0,
    this.isShutdown = false,
    this.shutdownStart,
    this.shutdownEnd,
    this.shutdownReason = '',
    this.isActive = true,
  });

  AdminTurf copyWith({
    bool? isShutdown,
    String? shutdownStart,
    String? shutdownEnd,
    String? shutdownReason,
    bool? isActive,
    double? weeklyRevenue,
    double? lastWeekRevenue,
    int? weeklyBookings,
    int? lastWeekBookings,
    double? revenueChangePct,
    int? bookingChange,
  }) {
    return AdminTurf(
      id: id,
      name: name,
      location: location,
      distance: distance,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      images: images,
      amenities: amenities,
      sports: sports,
      mapLink: mapLink,
      address: address,
      description: description,
      todayBookings: todayBookings,
      todayRevenue: todayRevenue,
      totalBookings: totalBookings,
      totalRevenue: totalRevenue,
      slotsCount: slotsCount,
      avgRating: avgRating,
      weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
      lastWeekRevenue: lastWeekRevenue ?? this.lastWeekRevenue,
      weeklyBookings: weeklyBookings ?? this.weeklyBookings,
      lastWeekBookings: lastWeekBookings ?? this.lastWeekBookings,
      revenueChangePct: revenueChangePct ?? this.revenueChangePct,
      bookingChange: bookingChange ?? this.bookingChange,
      isShutdown: isShutdown ?? this.isShutdown,
      shutdownStart: shutdownStart ?? this.shutdownStart,
      shutdownEnd: shutdownEnd ?? this.shutdownEnd,
      shutdownReason: shutdownReason ?? this.shutdownReason,
      isActive: isActive ?? this.isActive,
    );
  }
}
