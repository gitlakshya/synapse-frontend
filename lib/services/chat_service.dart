import 'dart:convert';
import '../config/api_config.dart';
import 'authenticated_http_client.dart';
import 'firebase_auth_service.dart';

class ChatService {
  static ChatService? _instance;
  late String _backendUrl;
  late AuthenticatedHttpClient _httpClient;
  late FirebaseAuthService _authService;
  
  ChatService._internal() {
    _backendUrl = ApiConfig.baseUrl;
    _httpClient = AuthenticatedHttpClient();
    _authService = FirebaseAuthService();
    print('ChatService initialized with backend URL: $_backendUrl');
  }
  
  static ChatService get instance {
    _instance ??= ChatService._internal();
    return _instance!;
  }
  
  bool get isConfigured => _backendUrl.isNotEmpty;
  
  Future<String> getResponse(String message, {
    String? destination, 
    double? budget, 
    List<String>? conversationHistory
  }) async {
    if (!isConfigured) {
      print('Backend URL not configured - using fallback');
      return _getFallbackResponse(message);
    }
    
    try {
      print('Sending request to backend chat API...');
      
      final requestBody = {
        'message': message,
        'context': {
          if (destination != null && destination.isNotEmpty) 'destination': destination,
          if (budget != null && budget > 0) 'budget': budget,
          if (conversationHistory != null && conversationHistory.isNotEmpty) 
            'conversationHistory': conversationHistory,
        }
      };
      
      print('Request body: ${jsonEncode(requestBody)}');
      
      // Use AuthenticatedHttpClient which handles auth automatically
      final response = await _httpClient.post(
        '$_backendUrl${ApiConfig.chatEndpoint}',
        body: requestBody,
        includeAuth: true, // This ensures proper authentication handling
        timeout: const Duration(seconds: 45), // Extended timeout for chat API
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final responseText = responseData['response'] ?? responseData['message'] ?? '';
        
        if (responseText.isNotEmpty) {
          print('Backend response received: ${responseText.substring(0, responseText.length > 50 ? 50 : responseText.length)}...');
          return responseText;
        } else {
          print('Empty response from backend');
          return 'Sorry, I couldn\'t generate a response. Please try again.';
        }
      } else if (response.statusCode == 401) {
        print('Authentication failed: ${response.body}');
        return 'Authentication failed. Please log in again to use the chat feature.';
      } else if (response.statusCode == 403) {
        print('Access forbidden: ${response.body}');
        return 'Access denied. You don\'t have permission to use this feature.';
      } else {
        print('Backend API error: ${response.statusCode} - ${response.body}');
        return 'API Error: ${response.statusCode}. Using fallback response: ${_getFallbackResponse(message)}';
      }
    } catch (e) {
      print('Chat API error: $e');
      if (e.toString().contains('timeout')) {
        return 'Connection timeout. Please check your internet connection and try again.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        return 'Network error. Please check your internet connection and try again.';
      } else {
        return 'Connection Error: ${e.toString()}. Using fallback response: ${_getFallbackResponse(message)}';
      }
    }
  }
  
  /// Check if user is authenticated for chat API access
  Future<bool> isUserAuthenticated() async {
    try {
      return await _authService.isAuthenticated();
    } catch (e) {
      print('Error checking authentication status: $e');
      return false;
    }
  }
  
  /// Get authentication status and token validity
  Future<Map<String, dynamic>> getAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      final token = await _authService.getToken();
      
      return {
        'isAuthenticated': isAuth,
        'hasToken': token != null && token.isNotEmpty,
        'backendUrl': _backendUrl,
        'chatEndpoint': ApiConfig.chatEndpoint,
        'usingAuthenticatedClient': true, // Now using the proper authenticated client
      };
    } catch (e) {
      print('Error getting auth status: $e');
      return {
        'isAuthenticated': false,
        'hasToken': false,
        'error': e.toString(),
        'backendUrl': _backendUrl,
        'chatEndpoint': ApiConfig.chatEndpoint,
        'usingAuthenticatedClient': true,
      };
    }
  }
  
  /// Test chat API connectivity and authentication
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await _httpClient.post(
        '$_backendUrl${ApiConfig.chatEndpoint}',
        body: {
          'message': 'Connection test',
          'context': {'isTest': true}
        },
        includeAuth: true,
      ).timeout(const Duration(seconds: 10));
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'authenticated': response.statusCode != 401,
        'message': response.statusCode == 200 
            ? 'Chat API connection successful' 
            : 'Chat API returned status ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to connect to chat API',
      };
    }
  }
  
  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('weather')) {
      return '🌤️ I recommend checking the weather forecast before your trip. Pack accordingly and have indoor alternatives ready!';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('restaurant')) {
      return '🍽️ Try local street food and authentic restaurants. Ask locals for recommendations - they know the best hidden gems!';
    } else if (lowerMessage.contains('budget') || lowerMessage.contains('money')) {
      return '💰 Book in advance, use local transport, and try local eateries to save money. Negotiate prices at markets!';
    } else if (lowerMessage.contains('place') || lowerMessage.contains('destination')) {
      return '🗺️ Research your destination beforehand. Look for must-visit spots, local customs, and hidden attractions!';
    } else if (lowerMessage.contains('transport') || lowerMessage.contains('travel')) {
      return '🚗 Compare transport options - trains, buses, and local transport. Book early for better deals!';
    } else if (lowerMessage.contains('hotel') || lowerMessage.contains('stay')) {
      return '🏨 Check reviews, location, and amenities. Consider homestays for authentic experiences!';
    } else {
      return '🤖 I\'m here to help with your travel planning! Ask me about destinations, food, budget tips, or activities. (Backend AI currently unavailable - using local responses)';
    }
  }
}