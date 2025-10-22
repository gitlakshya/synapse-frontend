import 'dart:convert';
import 'dart:math';
import 'package:web/web.dart' as web;

class PersonalizationService {
  static const _userProfileKey = 'user_profile';
  static const _behaviorDataKey = 'behavior_data';

  static Future<UserProfile> getUserProfile() async {
    try {
      final profileJson = web.window.localStorage.getItem(_userProfileKey);
      if (profileJson != null) {
        return UserProfile.fromJson(json.decode(profileJson));
      }
    } catch (e) {
      print('Error reading user profile: $e');
    }
    return UserProfile.defaultProfile();
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    web.window.localStorage.setItem(_userProfileKey, json.encode(profile.toJson()));
  }

  static Future<void> trackUserBehavior(UserBehavior behavior) async {
    try {
      final behaviorJson = web.window.localStorage.getItem(_behaviorDataKey);
      List<UserBehavior> behaviors = [];
      
      if (behaviorJson != null) {
        final List<dynamic> behaviorList = json.decode(behaviorJson);
        behaviors = behaviorList.map((b) => UserBehavior.fromJson(b)).toList();
      }
      
      behaviors.add(behavior);
      if (behaviors.length > 100) behaviors.removeAt(0); // Keep last 100 behaviors
      
      web.window.localStorage.setItem(_behaviorDataKey, json.encode(behaviors.map((b) => b.toJson()).toList()));
    } catch (e) {
      print('Error tracking behavior: $e');
    }
  }

  static Future<List<PersonalizedRecommendation>> getPersonalizedRecommendations(String destination) async {
    final profile = await getUserProfile();
    final behaviorJson = web.window.localStorage.getItem(_behaviorDataKey);
    
    List<UserBehavior> behaviors = [];
    if (behaviorJson != null) {
      final List<dynamic> behaviorList = json.decode(behaviorJson);
      behaviors = behaviorList.map((b) => UserBehavior.fromJson(b)).toList();
    }

    return _generateMLRecommendations(profile, behaviors, destination);
  }

  static List<PersonalizedRecommendation> _generateMLRecommendations(
    UserProfile profile, 
    List<UserBehavior> behaviors, 
    String destination
  ) {
    final recommendations = <PersonalizedRecommendation>[];
    
    // Analyze user preferences
    final budgetPreference = _analyzeBudgetPreference(behaviors);
    final activityPreference = _analyzeActivityPreference(behaviors);
    final accommodationPreference = _analyzeAccommodationPreference(behaviors);
    
    // Generate recommendations based on ML analysis
    if (budgetPreference == 'budget') {
      recommendations.add(PersonalizedRecommendation(
        type: RecommendationType.accommodation,
        title: 'Budget-Friendly Stays',
        description: 'Based on your booking history, here are affordable options',
        confidence: 0.85,
        data: {'priceRange': 'low', 'type': 'hostel'},
      ));
    }
    
    if (activityPreference.contains('adventure')) {
      recommendations.add(PersonalizedRecommendation(
        type: RecommendationType.activity,
        title: 'Adventure Activities',
        description: 'You love adventure! Try these thrilling experiences',
        confidence: 0.92,
        data: {'category': 'adventure', 'intensity': 'high'},
      ));
    }
    
    // Add more ML-based recommendations
    recommendations.addAll(_getDestinationSpecificRecommendations(destination, profile));
    
    return recommendations;
  }

  static String _analyzeBudgetPreference(List<UserBehavior> behaviors) {
    final budgetBehaviors = behaviors.where((b) => b.action == 'budget_selected').toList();
    if (budgetBehaviors.isEmpty) return 'medium';
    
    final avgBudget = budgetBehaviors.map((b) => b.data['amount'] as double).reduce((a, b) => a + b) / budgetBehaviors.length;
    return avgBudget < 20000 ? 'budget' : avgBudget > 50000 ? 'luxury' : 'medium';
  }

  static List<String> _analyzeActivityPreference(List<UserBehavior> behaviors) {
    final activityBehaviors = behaviors.where((b) => b.action == 'activity_selected').toList();
    final preferences = <String, int>{};
    
    for (final behavior in activityBehaviors) {
      final category = behavior.data['category'] as String;
      preferences[category] = (preferences[category] ?? 0) + 1;
    }
    
    return preferences.entries.where((e) => e.value > 2).map((e) => e.key).toList();
  }

  static String _analyzeAccommodationPreference(List<UserBehavior> behaviors) {
    final accommodationBehaviors = behaviors.where((b) => b.action == 'accommodation_selected').toList();
    if (accommodationBehaviors.isEmpty) return 'hotel';
    
    final preferences = <String, int>{};
    for (final behavior in accommodationBehaviors) {
      final type = behavior.data['type'] as String;
      preferences[type] = (preferences[type] ?? 0) + 1;
    }
    
    return preferences.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static List<PersonalizedRecommendation> _getDestinationSpecificRecommendations(String destination, UserProfile profile) {
    // Mock destination-specific recommendations
    return [
      PersonalizedRecommendation(
        type: RecommendationType.restaurant,
        title: 'Local Cuisine Recommendations',
        description: 'Based on your food preferences and $destination specialties',
        confidence: 0.78,
        data: {'cuisine': 'local', 'dietary': profile.dietaryPreferences},
      ),
    ];
  }
}

class UserProfile {
  final String userId;
  final List<String> interests;
  final List<String> dietaryPreferences;
  final String budgetRange;
  final String travelStyle;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.userId,
    required this.interests,
    required this.dietaryPreferences,
    required this.budgetRange,
    required this.travelStyle,
    required this.preferences,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      userId: 'default',
      interests: ['sightseeing', 'food'],
      dietaryPreferences: [],
      budgetRange: 'medium',
      travelStyle: 'balanced',
      preferences: {},
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      interests: List<String>.from(json['interests']),
      dietaryPreferences: List<String>.from(json['dietaryPreferences']),
      budgetRange: json['budgetRange'],
      travelStyle: json['travelStyle'],
      preferences: Map<String, dynamic>.from(json['preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'interests': interests,
      'dietaryPreferences': dietaryPreferences,
      'budgetRange': budgetRange,
      'travelStyle': travelStyle,
      'preferences': preferences,
    };
  }
}

class UserBehavior {
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  UserBehavior({
    required this.action,
    required this.data,
    required this.timestamp,
  });

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      action: json['action'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class PersonalizedRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> data;

  PersonalizedRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.data,
  });
}

enum RecommendationType {
  accommodation,
  activity,
  restaurant,
  transport,
  destination,
}