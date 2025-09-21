import 'dart:convert';
import '../config/api_config.dart';
import '../services/web_auth_service.dart';
import '../services/user_data_service.dart';
import '../services/authenticated_http_client.dart';

/// Example service showing how to make authenticated API calls
class TripPlanningApiService {
  final WebAuthService _authService = WebAuthService();
  final UserDataService _userDataService = UserDataService();
  final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();

  /// Plan a trip with user authentication (works for both authenticated and guest users)
  Future<Map<String, dynamic>?> planTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    int? budget,
    List<String>? interests,
  }) async {
    try {
      // Prepare request data
      final requestData = {
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'budget': budget,
        'interests': interests ?? [],
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Make API request - automatically handles auth/guest session
      final response = await _httpClient.apiPost(
        ApiConfig.planTripEndpoint,
        body: requestData,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Log request context for debugging
        final context = await _httpClient.getRequestContext();
        print('Trip planned for ${context['type']} user: ${context['type'] == 'authenticated' ? context['email'] : context['sessionId']}');
        
        return result;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Trip planning API error: $e');
      return null;
    }
  }

  /// Save itinerary (requires authentication)
  Future<bool> saveItinerary({
    required Map<String, dynamic> itinerary,
    required String tripId,
  }) async {
    try {
      // Check authentication
      if (!await _authService.isAuthenticated()) {
        print('User must be signed in to save itinerary');
        return false;
      }

      final requestData = {
        'itinerary': itinerary,
        'tripId': tripId,
        'userId': _authService.currentUser?.uid,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _httpClient.apiPost(
        ApiConfig.saveItineraryEndpoint,
        body: requestData,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Save itinerary error: $e');
      return false;
    }
  }

  /// Get user's saved itineraries
  Future<List<Map<String, dynamic>>> getUserItineraries() async {
    try {
      if (!await _authService.isAuthenticated()) {
        return [];
      }

      final response = await _httpClient.apiGet(ApiConfig.itinerariesEndpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['itineraries'] is List) {
          return List<Map<String, dynamic>>.from(data['itineraries']);
        }
      }
      
      return [];
    } catch (e) {
      print('Get itineraries error: $e');
      return [];
    }
  }

  /// Chat with AI (works for both authenticated and guest users)
  Future<Map<String, dynamic>?> chatWithAI({
    required String message,
    String? conversationId,
  }) async {
    try {
      final requestData = {
        'message': message,
        'conversationId': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Automatically handles authenticated/guest session
      final response = await _httpClient.apiPost(
        ApiConfig.chatEndpoint,
        body: requestData,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Log request context
        final context = await _httpClient.getRequestContext();
        print('Chat request from ${context['type']} user');
        
        return result;
      }
      
      return null;
    } catch (e) {
      print('Chat API error: $e');
      return null;
    }
  }

  /// Get trip recommendations for guest users (public endpoint)
  Future<List<Map<String, dynamic>>> getPublicRecommendations({
    String? destination,
    String? travelStyle,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (destination != null) queryParams['destination'] = destination;
      if (travelStyle != null) queryParams['style'] = travelStyle;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/public/recommendations')
          .replace(queryParameters: queryParams);
      
      // Public endpoint - no authentication needed
      final response = await _httpClient.get(
        uri.toString(),
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['recommendations'] is List) {
          return List<Map<String, dynamic>>.from(data['recommendations']);
        }
      }
      
      return [];
    } catch (e) {
      print('Get recommendations error: $e');
      return [];
    }
  }

  /// Get guest user's temporary data (works with session)
  Future<Map<String, dynamic>?> getGuestData() async {
    try {
      // Ensure guest session exists
      await _httpClient.ensureGuestSession();
      
      // Force guest session even if user is authenticated
      final response = await _httpClient.apiGet(
        '/api/v1/session/data',
        forceGuest: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      print('Get guest data error: $e');
      return null;
    }
  }

  /// Save data for guest users (temporary storage)
  Future<bool> saveGuestData(Map<String, dynamic> data) async {
    try {
      await _httpClient.ensureGuestSession();
      
      final response = await _httpClient.apiPost(
        '/api/v1/session/save',
        body: data,
        forceGuest: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Save guest data error: $e');
      return false;
    }
  }
}