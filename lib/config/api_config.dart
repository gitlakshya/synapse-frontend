import '../config/environment.dart';

class ApiConfig {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // Authentication Endpoints
  static const String googleAuthEndpoint = '/api/v1/auth/google';
  static const String profileEndpoint = '/api/v1/auth/profile';
  static const String refreshTokenEndpoint = '/api/v1/auth/refresh';
  
  // Trip Planning Endpoints
  static const String planTripEndpoint = '/api/v1/plantrip';
  static const String chatEndpoint = '/api/v1/chat';
  
  // Itinerary Management Endpoints
  static const String itinerariesEndpoint = '/api/v1/itineraries';
  static const String saveItineraryEndpoint = '/api/v1/saveItinerary';
  static const String updateItineraryEndpoint = '/api/v1/itinerary';
  
  // Session Management
  static const String sessionEndpoint = '/api/v1/session';
  
  // Legacy endpoints
  static const String itineraryEndpoint = '/api/itinerary';
  static const String recommendationsEndpoint = '/api/recommendations';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get headers with authentication token
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  /// Get headers with session info for guest users
  static Map<String, String> sessionHeaders(String sessionId) => {
    ...headers,
    'X-Session-ID': sessionId,
  };
}