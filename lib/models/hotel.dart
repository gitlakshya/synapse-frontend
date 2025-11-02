class Hotel {
  final String id;
  final String name;
  final String destination;
  final double pricePerNight;
  final double rating;
  final String imageUrl;
  final List<String> amenities;

  Hotel({
    required this.id,
    required this.name,
    required this.destination,
    required this.pricePerNight,
    required this.rating,
    required this.imageUrl,
    required this.amenities,
  });
}
