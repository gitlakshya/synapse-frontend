import 'dart:convert';
import 'api_middleware.dart';

/// AIService - Backend proxy for AI features
/// 
/// This service routes AI requests to the backend API.
/// The backend handles API keys securely.
class AIService {
  /// Generate trip itinerary using backend AI
  /// 
  /// Endpoint: POST /api/v1/plantrip
  /// Request body: {destination, startDate, endDate, budget, preferences, people, sessionId (auto-injected for guests)}
  /// Response: {success, data: {itinerary, tripId, estimatedCost, suggestions}}
  static Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required String startDate,
    required String endDate,
    required int budget,
    required List<String> preferences,
    required int people,
  }) async {
    try {
      // Calculate days from dates
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final days = end.difference(start).inDays + 1;

      // Convert preferences list to map with default weight of 50
      final Map<String, dynamic> preferencesMap = {};
      if (preferences.isEmpty) {
        preferencesMap['nature'] = 50;
        preferencesMap['culture'] = 50;
        preferencesMap['adventure'] = 50;
      } else {
        for (var pref in preferences) {
          preferencesMap[pref.toLowerCase()] = 50;
        }
      }

      final response = await ApiMiddleware.planTrip(
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        days: days,
        budget: budget,
        preferences: preferencesMap,
        people: people,
      );

      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['error'] ?? 'Failed to generate itinerary');
      }
    } catch (e) {
      // Return error response
      throw Exception('AI Service Error: ${e.toString()}');
    }
  }

  /// Get trip recommendations using chat endpoint
  /// 
  /// Endpoint: POST /api/v1/chat
  /// Request body: {message, context, sessionId (auto-injected for guests)}
  /// Response: {success, data: {response, suggestions, followUpQuestions}}
  static Future<String> getTripRecommendations({
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
      } else {
        return _getMockRecommendation(destination, days);
      }
    } catch (e) {
      // Fallback to mock on error
      return _getMockRecommendation(destination, days);
    }
  }

  /// Adjust existing itinerary using smart adjust endpoint
  /// 
  /// Endpoint: POST /api/v1/smartadjust
  /// Request body: {itinerary, adjustments, sessionId (auto-injected)}
  /// Response: {success, data: {adjustedItinerary, changes}}
  static Future<Map<String, dynamic>> adjustItinerary({
    required Map<String, dynamic> itinerary,
    required Map<String, dynamic> adjustments,
  }) async {
    try {
      final response = await ApiMiddleware.apiPost('/api/v1/smartadjust', {
        'itinerary': itinerary,
        'adjustments': adjustments,
      });

      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['error'] ?? 'Failed to adjust itinerary');
      }
    } catch (e) {
      throw Exception('Smart Adjust Error: ${e.toString()}');
    }
  }

  /// Send a message and get AI response
  Future<String> sendMessage(String message, String tripContext) async {
    try {
      final response = await ApiMiddleware.sendChatMessage(
        message: message,
        context: tripContext,
      );

      if (response['success'] == true) {
        final data = response['data'];
        return data['response'] ?? data['message'] ?? 'No response from AI';
      } else {
        throw Exception(response['error'] ?? 'Chat service unavailable');
      }
    } catch (e) {
      print('AI Service error: $e');
      return _getMockResponse(message, tripContext);
    }
  }

  /// Stream AI responses (for typing effect)
  Stream<String> sendMessageStream(String message, String tripContext) async* {
    try {
      // Get full response from backend
      final response = await ApiMiddleware.sendChatMessage(
        message: message,
        context: tripContext,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final text = data['response'] ?? data['message'] ?? '';
        
        // Simulate streaming by yielding word by word
        final words = text.split(' ');
        for (final word in words) {
          yield '$word ';
          await Future.delayed(const Duration(milliseconds: 50));
        }
      } else {
        yield 'Error: ${response['error']}';
      }
    } catch (e) {
      print('AI Stream error: $e');
      // Mock streaming response on error
      final mockResponse = _getMockResponse(message, tripContext);
      final words = mockResponse.split(' ');
      for (final word in words) {
        yield '$word ';
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  /// Mock response for development/testing
  String _getMockResponse(String message, String context) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('budget') || lowerMessage.contains('cost')) {
      return 'Based on your trip context, I can suggest ways to optimize your budget. Consider visiting during off-season for better deals, using local transportation, and trying street food for authentic experiences at lower costs.';
    } else if (lowerMessage.contains('hotel') || lowerMessage.contains('accommodation')) {
      return 'For accommodations, I recommend booking in advance for better rates. Consider areas slightly away from tourist hotspots for more affordable options while maintaining good connectivity.';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('restaurant')) {
      return 'The local cuisine offers amazing experiences! I suggest trying both popular restaurants and local street food. Would you like specific recommendations for breakfast, lunch, or dinner?';
    } else if (lowerMessage.contains('activity') || lowerMessage.contains('things to do')) {
      return 'There are many exciting activities based on your preferences! From cultural sites to adventure sports, I can help you create a balanced itinerary. What type of experiences interest you most?';
    } else if (lowerMessage.contains('weather') || lowerMessage.contains('climate')) {
      return 'Weather is an important factor for planning. Based on your travel dates, I recommend packing light layers and checking forecasts a few days before departure. Would you like specific weather information?';
    } else if (lowerMessage.contains('modify') || lowerMessage.contains('change')) {
      return 'I can help you modify your itinerary! What would you like to change? You can adjust destinations, activities, budget, or duration. Just let me know what you\'d like to update.';
    } else {
      return 'I\'m here to help with your trip planning! You can ask me about destinations, activities, budget optimization, local recommendations, or any other travel-related questions. How can I assist you?';
    }
  }

  static String _getMockRecommendation(String destination, int days) {
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
