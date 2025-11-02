class Itinerary {
  final String id;
  final String destination;
  final int days;
  final double totalCost;
  final String imageUrl;
  final double rating;
  final List<DayPlan> dayPlans;
  final String? fromCity;

  Itinerary({
    required this.id,
    required this.destination,
    required this.days,
    required this.totalCost,
    required this.imageUrl,
    required this.rating,
    required this.dayPlans,
    this.fromCity,
  });
}

class DayPlan {
  final int day;
  final String title;
  final List<Activity> activities;

  DayPlan({
    required this.day,
    required this.title,
    required this.activities,
  });
}

class Activity {
  final String id;
  final String title;
  final String time;
  final double cost;
  final double rating;
  final String type;
  final String imageUrl;
  final double lat;
  final double lng;

  Activity({
    required this.id,
    required this.title,
    required this.time,
    required this.cost,
    required this.rating,
    required this.type,
    required this.imageUrl,
    required this.lat,
    required this.lng,
  });
}
