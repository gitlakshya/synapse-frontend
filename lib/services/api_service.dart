import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../services/http_client.dart';
import 'firebase_auth_service.dart';
import 'session_service.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  final HttpClient _httpClient = HttpClient();

  void initialize() {
    _httpClient.initialize();
  }

  Future<Map<String, String>> _getHeaders() async {
    return ApiConfig.headers;
  }

  Future<Map<String, dynamic>> _addSessionToBody(Map<String, dynamic> body) async {
    final authService = FirebaseAuthService();
    final isAuthenticated = await authService.isAuthenticated();
    
    if (!isAuthenticated) {
      final sessionService = SessionService();
      final sessionId = sessionService.guestSessionId;
      if (sessionId != null) {
        body['sessionId'] = sessionId;
      }
    }
    
    return body;
  }

  Future<ApiResponse<T>> _handleResponse<T>(Future<http.Response> Function() request, T Function(dynamic) fromJson) async {
    try {
      final response = await request();
      return _processResponse<T>(response, fromJson);
    } on http.ClientException catch (e) {
      return ApiResponse.error('Network error: ${e.message}', statusCode: 0);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e', statusCode: 0);
    }
  }

  ApiResponse<T> _processResponse<T>(http.Response response, T Function(dynamic) fromJson) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final data = jsonDecode(response.body);
          return ApiResponse.success(fromJson(data), statusCode: response.statusCode);
        } catch (e) {
          return ApiResponse.error('Failed to parse response', statusCode: response.statusCode);
        }
      case 400:
        return ApiResponse.error('Bad request', statusCode: 400);
      case 401:
        return ApiResponse.error('Unauthorized - please sign in again', statusCode: 401);
      case 403:
        return ApiResponse.error('Access forbidden', statusCode: 403);
      case 404:
        return ApiResponse.error('Resource not found', statusCode: 404);
      case 429:
        return ApiResponse.error('Too many requests - please try again later', statusCode: 429);
      case 500:
        return ApiResponse.error('Server error - please try again later', statusCode: 500);
      default:
        return ApiResponse.error('HTTP ${response.statusCode}: ${response.reasonPhrase}', statusCode: response.statusCode);
    }
  }

  // Trip Planning Endpoints
  Future<ApiResponse<Map<String, dynamic>>> planTrip(Map<String, dynamic> tripData) async {
    final formattedData = await _formatTripData(tripData);
    return await _handleResponse<Map<String, dynamic>>(
      () async => await _httpClient.post(
        ApiConfig.planTripEndpoint,
        headers: await _getHeaders(),
        body: jsonEncode(formattedData),
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> _formatTripData(Map<String, dynamic> tripData) async {
    final formatted = Map<String, dynamic>.from(tripData);
    
    // 1. Format dates to YYYY-MM-DD
    if (formatted.containsKey('dates') && formatted['dates'] != null) {
      final dates = formatted['dates'] as Map<String, dynamic>;
      if (dates.containsKey('start') && dates.containsKey('end')) {
        final startDate = DateTime.parse(dates['start']);
        final endDate = DateTime.parse(dates['end']);
        
        // 4. Separate startDate and endDate keys
        formatted['startDate'] = '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        formatted['endDate'] = '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
        
        // 5. Calculate number of days
        formatted['days'] = endDate.difference(startDate).inDays + 1;
      }
      formatted.remove('dates');
    }
    
    // 2. Rename themeIntensity to preferences
    if (formatted.containsKey('themeIntensity')) {
      formatted['preferences'] = formatted['themeIntensity'];
      formatted.remove('themeIntensity');
    }
    
    return await _addSessionToBody(formatted);
  }

  Future<ApiResponse<Map<String, dynamic>>> sendChatMessage(String message, {String? context}) async {
    final body = await _addSessionToBody({
      'message': message,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    return await _handleResponse<Map<String, dynamic>>(
      () async => await _httpClient.post(
        ApiConfig.chatEndpoint,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  // Itinerary Management Endpoints
  Future<ApiResponse<List<dynamic>>> getItineraries() async {
    return await _handleResponse<List<dynamic>>(
      () async => await _httpClient.get(
        ApiConfig.itinerariesEndpoint,
        headers: await _getHeaders(),
      ),
      (data) => (data['itineraries'] ?? []) as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> saveItinerary(Map<String, dynamic> itinerary) async {
    return await _handleResponse<Map<String, dynamic>>(
      () => _httpClient.post(
        ApiConfig.saveItineraryEndpoint,
        headers: ApiConfig.headers,
        body: jsonEncode(itinerary),
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateItinerary(String id, Map<String, dynamic> itinerary) async {
    final body = await _addSessionToBody(itinerary);
    
    return await _handleResponse<Map<String, dynamic>>(
      () async => await _httpClient.put(
        '${ApiConfig.updateItineraryEndpoint}/$id',
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  // Legacy endpoints for backward compatibility
  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    required List<String> preferences,
  }) async {
    final tripData = {
      'destination': destination,
      'days': days,
      'budget': budget,
      'preferences': preferences,
    };
    final result = await planTrip(tripData);
    return result.data ?? {};
  }

  Future<List<dynamic>> getRecommendations(String destination) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recommendationsEndpoint}?destination=$destination'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['recommendations'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }
}