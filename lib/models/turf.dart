class Turf {
  final String id;
  final String name;
  final String location; // maps to 'address' or 'city' from API
  final double distance;
  final int price; // maps to 'price_per_hour' from API
  final double rating;
  final List<String> images;
  final List<String> amenities;
  final List<String> sports;

  final String city;
  final String mapLink;
  final String address;
  final String description;

  // ─── NEW: Offer fields from backend ───
  final bool hasActiveOffer;
  final String? maxOfferType; // 'percentage' or 'flat'
  final double? maxOfferValue; // e.g. 20.0 for 20%

  // ─── Owner dashboard: turf status ───
  final String turfStatus; // 'pending', 'approved', 'rejected', 'suspended'

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    this.distance = 0.0,
    required this.price,
    required this.rating,
    required this.images,
    required this.amenities,
    List<String>? sports,
    required this.mapLink,
    required this.address,
    required this.description,
    this.hasActiveOffer = false,
    this.maxOfferType,
    this.maxOfferValue,
    this.turfStatus = 'approved',
  }) : sports = sports ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'city': city,
      'distance': distance,
      'price': price,
      'rating': rating,
      'images': images,
      'amenities': amenities,
      'sports': sports,
      'mapLink': mapLink,
      'address': address,
      'description': description,
      'hasActiveOffer': hasActiveOffer,
      'maxOfferType': maxOfferType,
      'maxOfferValue': maxOfferValue,
      'turfStatus': turfStatus,
    };
  }

  /// Parse from Django REST Framework JSON (TurfListSerializer / TurfDetailSerializer)
  factory Turf.fromJson(Map<String, dynamic> json) {
    // Images: API returns list of {id, image, is_cover}
    List<String> imageUrls = [];
    if (json['images'] != null) {
      imageUrls = (json['images'] as List)
          .map((img) {
            if (img is String) return img;
            if (img is Map) return (img['image'] ?? '').toString();
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }
    // Fallback: use cover_image if no images list
    if (imageUrls.isEmpty && json['cover_image'] != null) {
      imageUrls = [json['cover_image'].toString()];
    }

    // Sports: API returns list of {id, name, icon}
    List<String> sportNames = [];
    if (json['sports'] != null) {
      sportNames = (json['sports'] as List)
          .map((s) {
            if (s is String) return s;
            if (s is Map) return (s['name'] ?? '').toString();
            return '';
          })
          .where((n) => n.isNotEmpty)
          .toList();
    }

    // Amenities: API returns list of {id, name, icon}
    List<String> amenityNames = [];
    if (json['amenities'] != null) {
      amenityNames = (json['amenities'] as List)
          .map((a) {
            if (a is String) return a;
            if (a is Map) return (a['name'] ?? '').toString();
            return '';
          })
          .where((n) => n.isNotEmpty)
          .toList();
    }

    return Turf(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['address']?.toString() ?? json['city']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      price:
          (json['price_per_hour'] as num?)?.toInt() ??
          (json['price'] as num?)?.toInt() ??
          0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      images: imageUrls,
      amenities: amenityNames,
      sports: sportNames,
      mapLink:
          json['google_maps_share_link']?.toString() ??
          json['mapLink']?.toString() ??
          '',
      address: json['address']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hasActiveOffer:
          json['has_active_offer'] ?? json['hasActiveOffer'] ?? false,
      maxOfferType:
          json['max_offer_type']?.toString() ??
          json['maxOfferType']?.toString(),
      maxOfferValue:
          (json['max_offer_value'] as num?)?.toDouble() ??
          (json['maxOfferValue'] as num?)?.toDouble(),
      turfStatus: json['status']?.toString() ?? 'approved',
    );
  }
}
