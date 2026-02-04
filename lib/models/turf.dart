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

    // ✅ NOT required
    List<String>? sports,

    required this.mapLink,
    required this.address,
    required this.description,
  }) : sports = sports ?? [];
}
