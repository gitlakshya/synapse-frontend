import 'dart:math';
import '../models/user_models.dart';

class AIRecommendationsService {
  static final AIRecommendationsService _instance = AIRecommendationsService._internal();
  factory AIRecommendationsService() => _instance;
  AIRecommendationsService._internal();

  Future<List<String>> getPersonalizedDestinations(User user) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final behavior = await _getUserBehavior(user.id);
    final profile = user.profile;
    
    // AI-based destination recommendations
    final recommendations = <String>[];
    
    // Based on travel style
    if (profile.travelStyle == 'luxury') {
      recommendations.addAll(['Dubai', 'Maldives', 'Switzerland', 'Singapore']);
    } else if (profile.travelStyle == 'adventure') {
      recommendations.addAll(['Himachal', 'Uttarakhand', 'Ladakh', 'Nepal']);
    } else if (profile.travelStyle == 'budget') {
      recommendations.addAll(['Goa', 'Rajasthan', 'Kerala', 'Himachal']);
    }
    
    // Based on past behavior
    final topDestinations = behavior.destinationViews.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in topDestinations.take(3)) {
      if (!recommendations.contains(entry.key)) {
        recommendations.add(entry.key);
      }
    }
    
    // Based on favorite destinations
    recommendations.addAll(profile.favoriteDestinations);
    
    return recommendations.take(8).toList();
  }

  Future<List<Map<String, dynamic>>> getPersonalizedActivities(User user, String destination) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final behavior = await _getUserBehavior(user.id);
    final profile = user.profile;
    
    final activities = <Map<String, dynamic>>[];
    
    // Based on activity preferences
    final sortedPreferences = profile.activityPreferences.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final pref in sortedPreferences) {
      activities.addAll(_getActivitiesByTheme(destination, pref.key));
    }
    
    // Based on past clicks
    final topActivities = behavior.activityClicks.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final activity in topActivities.take(5)) {
      activities.add({
        'title': activity.key,
        'score': activity.value * 0.1,
        'reason': 'Based on your past interests',
      });
    }
    
    return activities.take(10).toList();
  }

  Future<Map<String, double>> getPredictedBudget(User user, String destination, int days) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final behavior = await _getUserBehavior(user.id);
    final profile = user.profile;
    
    // Base budget calculation
    double baseBudget = 5000.0 * days;
    
    // Adjust based on travel style
    switch (profile.travelStyle) {
      case 'luxury':
        baseBudget *= 2.5;
        break;
      case 'budget':
        baseBudget *= 0.6;
        break;
      case 'adventure':
        baseBudget *= 1.2;
        break;
    }
    
    // Adjust based on destination
    final destinationMultipliers = {
      'goa': 1.2,
      'kerala': 1.1,
      'rajasthan': 1.0,
      'himachal': 1.3,
      'mumbai': 1.4,
      'delhi': 1.2,
    };
    
    baseBudget *= destinationMultipliers[destination.toLowerCase()] ?? 1.0;
    
    // Adjust based on past spending
    final avgSpending = behavior.bookingHistory.values.isNotEmpty
        ? behavior.bookingHistory.values.reduce((a, b) => a + b) / behavior.bookingHistory.length
        : baseBudget;
    
    baseBudget = (baseBudget + avgSpending) / 2;
    
    return {
      'accommodation': baseBudget * 0.4,
      'transport': baseBudget * 0.25,
      'food': baseBudget * 0.2,
      'activities': baseBudget * 0.1,
      'shopping': baseBudget * 0.05,
    };
  }

  Future<List<String>> getSmartAlternatives(String originalActivity, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final alternatives = <String>[];
    
    if (reason == 'weather') {
      if (originalActivity.toLowerCase().contains('beach')) {
        alternatives.addAll(['Indoor Aquarium', 'Shopping Mall', 'Museum Visit', 'Spa Treatment']);
      } else if (originalActivity.toLowerCase().contains('trek')) {
        alternatives.addAll(['Indoor Rock Climbing', 'Cultural Center', 'Local Market', 'Cooking Class']);
      }
    } else if (reason == 'closed') {
      alternatives.addAll(['Nearby Alternative', 'Similar Experience', 'Local Recommendation', 'Virtual Tour']);
    } else if (reason == 'crowded') {
      alternatives.addAll(['Off-peak Timing', 'Less Popular Spot', 'Private Tour', 'Alternative Route']);
    }
    
    return alternatives;
  }

  Future<void> trackUserBehavior(String userId, String action, String item) async {
    // Track user interactions for ML learning
    print('Tracking: $userId -> $action -> $item');
    
    // In real implementation, this would update the ML model
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<UserBehavior> _getUserBehavior(String userId) async {
    // Mock user behavior data
    return UserBehavior(
      userId: userId,
      destinationViews: {
        'Goa': 15,
        'Kerala': 12,
        'Rajasthan': 8,
        'Himachal': 6,
      },
      activityClicks: {
        'Beach Activities': 20,
        'Food Tours': 15,
        'Heritage Sites': 10,
        'Adventure Sports': 8,
      },
      themePreferences: {
        'Beach': 0.8,
        'Foodie': 0.7,
        'Heritage': 0.6,
        'Adventure': 0.4,
      },
      searchHistory: ['Goa beaches', 'Kerala backwaters', 'Rajasthan forts'],
      bookingHistory: {
        'flights': 25000,
        'hotels': 15000,
        'activities': 8000,
      },
      lastUpdated: DateTime.now(),
    );
  }

  List<Map<String, dynamic>> _getActivitiesByTheme(String destination, String theme) {
    final activities = <Map<String, dynamic>>[];
    final random = Random();
    
    final themeActivities = {
      'heritage': ['Fort Visit', 'Palace Tour', 'Museum Exploration', 'Heritage Walk'],
      'foodie': ['Food Tour', 'Cooking Class', 'Street Food Walk', 'Local Restaurant'],
      'adventure': ['Trekking', 'Water Sports', 'Rock Climbing', 'Paragliding'],
      'relaxation': ['Spa Treatment', 'Beach Lounging', 'Sunset Viewing', 'Meditation'],
    };
    
    final themeList = themeActivities[theme.toLowerCase()] ?? [];
    for (final activity in themeList) {
      activities.add({
        'title': '$activity in $destination',
        'score': 0.7 + random.nextDouble() * 0.3,
        'reason': 'Matches your $theme preferences',
      });
    }
    
    return activities;
  }
}