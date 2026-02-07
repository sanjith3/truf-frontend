class Turf {
  final String id;
  final String name;
  final String location;
  final double distance;
  final int price;
  final double rating;
  final List<String> images;
  final List<String> amenities;
  final List<String> sports;

  final String city;
  final String mapLink;
  final String address;
  final String description;

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.distance,
    required this.price,
    required this.rating,
    required this.images,
    required this.amenities,
    List<String>? sports,
    required this.mapLink,
    required this.address,
    required this.description,
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
    };
  }

  factory Turf.fromJson(Map<String, dynamic> json) {
    return Turf(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      city: json['city'] ?? "Coimbatore",
      distance: (json['distance'] as num).toDouble(),
      price: (json['price'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      images: List<String>.from(json['images']),
      amenities: List<String>.from(json['amenities']),
      sports: List<String>.from(json['sports'] ?? []),
      mapLink: json['mapLink'] ?? "",
      address: json['address'] ?? "",
      description: json['description'] ?? "",
    );
  }
}
