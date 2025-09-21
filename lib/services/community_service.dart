import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

class CommunityService {
  static const _storiesKey = 'travel_stories';
  static const _mentorsKey = 'mentors';
  static const _ambassadorsKey = 'ambassadors';

  static Future<List<TravelStory>> getTravelStories() async {
    try {
      final storiesJson = html.window.localStorage[_storiesKey];
      if (storiesJson != null) {
        final List<dynamic> storiesList = json.decode(storiesJson);
        return storiesList.map((s) => TravelStory.fromJson(s)).toList();
      }
    } catch (e) {
      print('Error reading stories: $e');
    }
    return _getMockStories();
  }

  static Future<void> addTravelStory(TravelStory story) async {
    final stories = await getTravelStories();
    stories.insert(0, story);
    if (stories.length > 50) stories.removeLast(); // Keep last 50 stories
    
    html.window.localStorage[_storiesKey] = json.encode(stories.map((s => s.toJson()).toList()));
  }

  static Future<List<Mentor>> getAvailableMentors(String destination) async {
    try {
      final mentorsJson = html.window.localStorage[_mentorsKey];
      if (mentorsJson != null) {
        final List<dynamic> mentorsList = json.decode(mentorsJson);
        final mentors = mentorsList.map((m) => Mentor.fromJson(m)).toList();
        return mentors.where((m) => m.specialties.contains(destination.toLowerCase())).toList();
      }
    } catch (e) {
      print('Error reading mentors: $e');
    }
    return _getMockMentors(destination);
  }

  static Future<List<LocalAmbassador>> getLocalAmbassadors(String destination) async {
    try {
      final ambassadorsJson = html.window.localStorage[_ambassadorsKey];
      if (ambassadorsJson != null) {
        final List<dynamic> ambassadorsList = json.decode(ambassadorsJson);
        final ambassadors = ambassadorsList.map((a) => LocalAmbassador.fromJson(a)).toList();
        return ambassadors.where((a) => a.location.toLowerCase().contains(destination.toLowerCase())).toList();
      }
    } catch (e) {
      print('Error reading ambassadors: $e');
    }
    return _getMockAmbassadors(destination);
  }

  static Future<void> connectWithMentor(String mentorId, String message) async {
    // Mock mentor connection
    print('Connecting with mentor $mentorId: $message');
  }

  static Future<void> bookAmbassador(String ambassadorId, DateTime date, String service) async {
    // Mock ambassador booking
    print('Booking ambassador $ambassadorId for $service on $date');
  }

  static List<TravelStory> _getMockStories() {
    final random = Random();
    return List.generate(10, (index) {
      final destinations = ['Goa', 'Kerala', 'Rajasthan', 'Himachal', 'Karnataka'];
      final authors = ['Priya S.', 'Rahul M.', 'Sarah K.', 'Amit P.', 'Neha R.'];
      
      return TravelStory(
        id: 'story_$index',
        authorName: authors[random.nextInt(authors.length)],
        authorAvatar: 'https://i.pravatar.cc/150?img=${index + 1}',
        destination: destinations[random.nextInt(destinations.length)],
        title: _getStoryTitle(destinations[random.nextInt(destinations.length)]),
        content: _getStoryContent(),
        images: List.generate(3, (i) => 'https://picsum.photos/400/300?random=${index * 3 + i}'),
        likes: random.nextInt(100),
        comments: random.nextInt(20),
        createdAt: DateTime.now().subtract(Duration(hours: random.nextInt(72))),
        tags: ['travel', 'adventure', 'photography'],
        isLive: random.nextBool(),
      );
    });
  }

  static String _getStoryTitle(String destination) {
    final titles = {
      'Goa': 'Sunset vibes at Anjuna Beach 🌅',
      'Kerala': 'Backwater bliss in Alleppey 🛶',
      'Rajasthan': 'Royal heritage in Udaipur 👑',
      'Himachal': 'Mountain magic in Manali 🏔️',
      'Karnataka': 'Coffee plantation tour ☕',
    };
    return titles[destination] ?? 'Amazing travel experience!';
  }

  static String _getStoryContent() {
    final contents = [
      'Just had the most incredible experience! The local food was amazing and the people were so welcoming. Definitely coming back soon! 🙌',
      'This place exceeded all my expectations. The views were breathtaking and the culture is so rich. Highly recommend to fellow travelers! ✨',
      'Found this hidden gem through a local recommendation. Sometimes the best experiences come from unexpected discoveries! 🗺️',
      'The perfect blend of adventure and relaxation. Every moment was worth it and created memories that will last a lifetime! 📸',
    ];
    return contents[Random().nextInt(contents.length)];
  }

  static List<Mentor> _getMockMentors(String destination) {
    return [
      Mentor(
        id: 'mentor_1',
        name: 'Rajesh Kumar',
        avatar: 'https://i.pravatar.cc/150?img=10',
        bio: 'Travel photographer with 10+ years experience across India',
        specialties: ['photography', 'adventure', destination.toLowerCase()],
        rating: 4.9,
        reviewCount: 127,
        responseTime: '< 2 hours',
        languages: ['English', 'Hindi'],
        isVerified: true,
        pricePerSession: 500,
      ),
      Mentor(
        id: 'mentor_2',
        name: 'Priya Sharma',
        avatar: 'https://i.pravatar.cc/150?img=20',
        bio: 'Solo female traveler and safety expert',
        specialties: ['solo travel', 'safety', 'budget travel'],
        rating: 4.8,
        reviewCount: 89,
        responseTime: '< 1 hour',
        languages: ['English', 'Hindi', 'Tamil'],
        isVerified: true,
        pricePerSession: 400,
      ),
      Mentor(
        id: 'mentor_3',
        name: 'Arjun Patel',
        avatar: 'https://i.pravatar.cc/150?img=30',
        bio: 'Cultural enthusiast and heritage guide',
        specialties: ['culture', 'heritage', 'local experiences'],
        rating: 4.7,
        reviewCount: 156,
        responseTime: '< 3 hours',
        languages: ['English', 'Gujarati', 'Hindi'],
        isVerified: true,
        pricePerSession: 600,
      ),
    ];
  }

  static List<LocalAmbassador> _getMockAmbassadors(String destination) {
    return [
      LocalAmbassador(
        id: 'ambassador_1',
        name: 'Maya Singh',
        avatar: 'https://i.pravatar.cc/150?img=40',
        location: destination,
        bio: 'Born and raised local with deep knowledge of hidden gems',
        services: ['City Tours', 'Food Tours', 'Shopping Guide'],
        rating: 4.9,
        reviewCount: 234,
        languages: ['English', 'Hindi', 'Local Language'],
        isVerified: true,
        pricePerHour: 800,
        availability: ['Morning', 'Evening'],
        specialties: ['Local Cuisine', 'Historical Sites', 'Markets'],
      ),
      LocalAmbassador(
        id: 'ambassador_2',
        name: 'Vikram Reddy',
        avatar: 'https://i.pravatar.cc/150?img=50',
        location: destination,
        bio: 'Adventure sports instructor and nature guide',
        services: ['Adventure Tours', 'Trekking Guide', 'Photography Tours'],
        rating: 4.8,
        reviewCount: 178,
        languages: ['English', 'Telugu', 'Hindi'],
        isVerified: true,
        pricePerHour: 1200,
        availability: ['Full Day', 'Morning'],
        specialties: ['Adventure Sports', 'Nature Photography', 'Trekking'],
      ),
    ];
  }
}

class TravelStory {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String destination;
  final String title;
  final String content;
  final List<String> images;
  int likes;
  int comments;
  final DateTime createdAt;
  final List<String> tags;
  final bool isLive;

  TravelStory({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.destination,
    required this.title,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.tags,
    required this.isLive,
  });

  factory TravelStory.fromJson(Map<String, dynamic> json) {
    return TravelStory(
      id: json['id'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      destination: json['destination'],
      title: json['title'],
      content: json['content'],
      images: List<String>.from(json['images']),
      likes: json['likes'],
      comments: json['comments'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags']),
      isLive: json['isLive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'destination': destination,
      'title': title,
      'content': content,
      'images': images,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'isLive': isLive,
    };
  }
}

class Mentor {
  final String id;
  final String name;
  final String avatar;
  final String bio;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final String responseTime;
  final List<String> languages;
  final bool isVerified;
  final double pricePerSession;

  Mentor({
    required this.id,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.responseTime,
    required this.languages,
    required this.isVerified,
    required this.pricePerSession,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      bio: json['bio'],
      specialties: List<String>.from(json['specialties']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      responseTime: json['responseTime'],
      languages: List<String>.from(json['languages']),
      isVerified: json['isVerified'],
      pricePerSession: json['pricePerSession'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'specialties': specialties,
      'rating': rating,
      'reviewCount': reviewCount,
      'responseTime': responseTime,
      'languages': languages,
      'isVerified': isVerified,
      'pricePerSession': pricePerSession,
    };
  }
}

class LocalAmbassador {
  final String id;
  final String name;
  final String avatar;
  final String location;
  final String bio;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final List<String> languages;
  final bool isVerified;
  final double pricePerHour;
  final List<String> availability;
  final List<String> specialties;

  LocalAmbassador({
    required this.id,
    required this.name,
    required this.avatar,
    required this.location,
    required this.bio,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.languages,
    required this.isVerified,
    required this.pricePerHour,
    required this.availability,
    required this.specialties,
  });

  factory LocalAmbassador.fromJson(Map<String, dynamic> json) {
    return LocalAmbassador(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      location: json['location'],
      bio: json['bio'],
      services: List<String>.from(json['services']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      languages: List<String>.from(json['languages']),
      isVerified: json['isVerified'],
      pricePerHour: json['pricePerHour'].toDouble(),
      availability: List<String>.from(json['availability']),
      specialties: List<String>.from(json['specialties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'location': location,
      'bio': bio,
      'services': services,
      'rating': rating,
      'reviewCount': reviewCount,
      'languages': languages,
      'isVerified': isVerified,
      'pricePerHour': pricePerHour,
      'availability': availability,
      'specialties': specialties,
    };
  }
}
