class Waypoint {
  final String id;
  final String title;
  final double lat;
  final double lng;
  final String? imageUrl;
  final double? rating;
  final String? cost;
  final String type; // hotel, restaurant, attraction
  final DateTime? date;
  final int? day;

  const Waypoint({
    required this.id,
    required this.title,
    required this.lat,
    required this.lng,
    this.imageUrl,
    this.rating,
    this.cost,
    this.type = 'attraction',
    this.date,
    this.day,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      cost: json['cost'],
      type: json['type'] ?? 'attraction',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lng': lng,
      'imageUrl': imageUrl,
      'rating': rating,
      'cost': cost,
      'type': type,
      'date': date?.toIso8601String(),
      'day': day,
    };
  }
}
