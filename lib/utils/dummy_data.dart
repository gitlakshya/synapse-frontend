class Destination {
  final String name;
  final String subtitle;
  final double rating;
  final int reviews;
  final String imageUrl;

  Destination(this.name, this.subtitle, this.rating, this.reviews, this.imageUrl);
}

class Activity {
  final String title;
  final String time;
  final String cost;
  final double rating;
  final String description;
  final double? lat;
  final double? lng;
  final String? type;

  Activity(this.title, this.time, this.cost, this.rating, this.description, {this.lat, this.lng, this.type});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      json['title'],
      json['time'],
      json['cost'],
      json['rating'].toDouble(),
      json['description'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      type: json['type'],
    );
  }
}

class DummyData {
  static List<Destination> trendingDestinations = [
    Destination('Jaipur', 'The Pink City', 4.7, 1234, 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=400'),
    Destination('Goa', 'Beach Paradise', 4.8, 2156, 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400'),
    Destination('Kerala', 'God\'s Own Country', 4.9, 1876, 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=400'),
    Destination('Manali', 'Mountain Escape', 4.6, 1543, 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=400'),
    Destination('Udaipur', 'City of Lakes', 4.8, 1321, 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400'),
  ];

  static Map<int, List<Activity>> itineraryActivities = {
    1: [
      Activity('Check-in at Taj Rambagh Palace', '2:00 PM', '₹8,000', 4.8, 'Luxury heritage hotel', lat: 26.9124, lng: 75.7873, type: 'hotel'),
      Activity('Visit City Palace', '4:00 PM', '₹700', 4.7, 'Royal palace complex', lat: 26.9255, lng: 75.8237, type: 'attraction'),
      Activity('Dinner at Chokhi Dhani', '8:00 PM', '₹1,200', 4.6, 'Traditional Rajasthani village', lat: 26.7606, lng: 75.7339, type: 'restaurant'),
    ],
    2: [
      Activity('Amber Fort Tour', '9:00 AM', '₹500', 4.9, 'Majestic hilltop fort', lat: 26.9855, lng: 75.8513, type: 'attraction'),
      Activity('Lunch at LMB', '1:00 PM', '₹600', 4.5, 'Famous local restaurant', lat: 26.9196, lng: 75.7878, type: 'restaurant'),
      Activity('Johari Bazaar Shopping', '3:00 PM', '₹2,000', 4.4, 'Traditional jewelry market', lat: 26.9196, lng: 75.7878, type: 'attraction'),
    ],
    3: [
      Activity('Hawa Mahal Visit', '8:00 AM', '₹200', 4.6, 'Palace of Winds', lat: 26.9239, lng: 75.8267, type: 'attraction'),
      Activity('Jantar Mantar', '10:00 AM', '₹200', 4.7, 'Ancient observatory', lat: 26.9246, lng: 75.8246, type: 'attraction'),
      Activity('Rajasthani Thali', '1:00 PM', '₹800', 4.8, 'Authentic local cuisine', lat: 26.9196, lng: 75.7878, type: 'restaurant'),
    ],
  };

  static List<String> themes = ['Heritage', 'Adventure', 'Nightlife', 'Food', 'Nature', 'Spiritual'];
  static List<String> languages = ['English', 'Hindi', 'Tamil', 'Bengali', 'Telugu', 'Marathi'];
}
