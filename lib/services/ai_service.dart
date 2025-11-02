import 'dart:convert';
import 'package:flutter/services.dart';
import 'api_middleware.dart';
import 'package:intl/intl.dart';
import '../utils/http_cache.dart';

/// AIService generates trip itineraries using backend AI
/// 
/// Backend Integration: Fully integrated with backend APIs
/// - POST /api/v1/plantrip: Generate itinerary
/// - POST /api/v1/chat: AI chat and recommendations
/// - POST /api/v1/smartadjust: Modify itinerary
/// 
/// Authentication: Handled automatically by ApiMiddleware
/// - Authenticated users: Bearer token in Authorization header
/// - Guest users: X-Session-ID header + sessionId in request body
/// 
/// Response Handling:
/// - Success: Returns data from response
/// - Error: Falls back to mock data for graceful degradation
class AIService {
  final _cache = HttpCache();

  /// Generate trip itinerary using backend AI
  /// 
  /// Endpoint: POST /api/v1/plantrip
  /// Request: {destination, startDate, endDate, budget, preferences, people, sessionId}
  /// Response: {success, data: {itinerary, tripId, estimatedCost, suggestions}}
  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required int days,
    required double budget,
    List<String> themes = const [],
    int people = 1,
  }) async {
    final cacheKey = 'itinerary_${destination}_${days}_$budget';
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return json.decode(cached);
    }

    try {
      // Calculate dates from days
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: days - 1));
      final dateFormat = DateFormat('yyyy-MM-dd');

      // Convert themes list to preferences map with default weight of 50
      final Map<String, dynamic> preferencesMap = {};
      if (themes.isEmpty) {
        // Default preferences if none provided
        preferencesMap['nature'] = 50;
        preferencesMap['culture'] = 50;
        preferencesMap['adventure'] = 50;
      } else {
        for (var theme in themes) {
          preferencesMap[theme.toLowerCase()] = 50;
        }
      }

      final response = await ApiMiddleware.planTrip(
        destination: destination,
        startDate: dateFormat.format(startDate),
        endDate: dateFormat.format(endDate),
        days: days,
        budget: budget.toInt(),
        preferences: preferencesMap,
        people: people,
      );

      if (response['success'] == true) {
        final result = response['data'] ?? {};
        _cache.set(cacheKey, json.encode(result), const Duration(hours: 1));
        return result;
      } else {
        throw Exception(response['error'] ?? 'Failed to generate itinerary');
      }
    } catch (e) {
      print('AI Service Error: $e - Using fallback');
    }

    // Fallback to mock on error
    return _getMockItinerary(destination, days, budget);
  }

  /// Get trip recommendations using chat endpoint
  /// 
  /// Endpoint: POST /api/v1/chat
  /// Request: {message, context, sessionId}
  /// Response: {success, data: {response, suggestions, followUpQuestions}}
  Future<String> getTripRecommendations({
    required String destination,
    required int days,
    required String budget,
    List<String> interests = const [],
  }) async {
    try {
      final message = 'Plan a $days-day trip to $destination with budget $budget. '
          'Interests: ${interests.isEmpty ? "general tourism" : interests.join(", ")}';
      
      final response = await ApiMiddleware.sendChatMessage(
        message: message,
        context: 'trip_recommendations',
      );

      if (response['success'] == true) {
        final data = response['data'];
        return data['response'] ?? data['message'] ?? 'Trip planned successfully';
      }
    } catch (e) {
      print('Trip Recommendations Error: $e');
    }

    // Fallback to mock
    return _getMockRecommendation(destination, days);
  }

  /// Adjust existing itinerary using smart adjust
  /// 
  /// Endpoint: POST /api/v1/smartadjust
  /// Request: {itinerary, adjustments, sessionId}
  /// Response: {success, data: {adjustedItinerary, changes}}
  Future<Map<String, dynamic>> adjustItinerary({
    required Map<String, dynamic> itinerary,
    required Map<String, dynamic> adjustments,
  }) async {
    try {
      final response = await ApiMiddleware.apiPost('/api/v1/smartadjust', {
        'itinerary': itinerary,
        'adjustments': adjustments,
      });

      if (response['success'] == true) {
        return response['data'] ?? itinerary;
      }
    } catch (e) {
      print('Adjust Itinerary Error: $e');
    }

    return itinerary; // Return original on error
  }

  Future<Map<String, dynamic>> _getMockItinerary(String destination, int days, double budget) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Load dummy JSON
    try {
      final jsonString = await rootBundle.loadString('lib/utils/dummy_itinerary.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Customize with user inputs
      data['destination'] = destination;
      data['days'] = days;
      data['budget'] = budget;

      return data;
    } catch (e) {
      // If dummy JSON fails, return basic structure
      return {
        'destination': destination,
        'days': days,
        'budget': budget,
        'itinerary': {},
        'budget_breakdown': {},
      };
    }
  }

  String _getMockRecommendation(String destination, int days) {
    return '''
✈️ **$days-Day Trip to $destination**

Perfect destination for a memorable vacation! Here's what makes it special:

🌟 **Highlights:**
• Rich cultural heritage and history
• Beautiful landscapes and scenic views
• Delicious local cuisine
• Friendly locals and vibrant atmosphere

📅 **Recommended Itinerary:**
Day 1-2: Explore main attractions
Day 3-4: Local experiences and cuisine
Day ${days > 4 ? '$days: ' : ''}Relax and leisure

🏨 **Where to Stay:** City center for convenience
🍽️ **Must Try:** Local specialties and street food
🚗 **Getting Around:** Public transport and taxis

Have a wonderful trip!
''';
  }
}
