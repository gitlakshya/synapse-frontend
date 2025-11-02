/// Chat service - Handles AI chat message processing with backend integration
/// 
/// Backend Integration: POST /api/v1/chat
/// Request: {message, context, sessionId (auto-injected)}
/// Response: {success, data: {response, suggestions, followUpQuestions}}
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_middleware.dart';

/// Message model for chat
class ChatMessage {
  final String id;
  final String sender; // 'user' or 'ai'
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  /// Convert to JSON for API/Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    sender: json['sender'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'],
  );
}

/// Chat service interface
abstract class IChatService {
  Future<String> sendMessage(String message, {String? userId, String? sessionId});
  Future<List<ChatMessage>> getChatHistory({String? userId, String? sessionId});
  Future<void> clearHistory({String? userId, String? sessionId});
}

/// Chat Service with Backend API Integration via ApiMiddleware
class ChatService implements IChatService {
  final List<ChatMessage> _messageCache = [];

  @override
  Future<String> sendMessage(String message, {String? userId, String? sessionId}) async {
    try {
      // Use ApiMiddleware which handles auth and session automatically
      final response = await ApiMiddleware.sendChatMessage(
        message: message,
        context: 'itinerary_planning',
      );

      if (response['success'] == true) {
        final data = response['data'];
        final aiResponse = data['response'] ?? data['message'] ?? 'I understand. How can I help you plan your trip?';
        
        // Cache message locally
        _messageCache.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: 'user',
          message: message,
          timestamp: DateTime.now(),
        ));
        
        _messageCache.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: 'ai',
          message: aiResponse,
          timestamp: DateTime.now(),
          metadata: {
            'suggestions': data['suggestions'],
            'followUpQuestions': data['followUpQuestions'],
          },
        ));

        return aiResponse;
      } else {
        throw Exception(response['error'] ?? 'Chat service unavailable');
      }
    } catch (e) {
      print('Chat API error: $e');
      // Fallback to mock on error
      await Future.delayed(const Duration(milliseconds: 800));
      final mockResponse = _getMockResponse(message.toLowerCase());
      
      _messageCache.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'user',
        message: message,
        timestamp: DateTime.now(),
      ));
      
      _messageCache.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'ai',
        message: mockResponse,
        timestamp: DateTime.now(),
      ));
      
      return mockResponse;
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory({String? userId, String? sessionId}) async {
    // Return cached messages
    // TODO: Fetch from backend or Firestore for persistence
    return List.from(_messageCache);
  }

  @override
  Future<void> clearHistory({String? userId, String? sessionId}) async {
    _messageCache.clear();
    // TODO: Clear from backend/Firestore
  }

  /// Mock response logic - Fallback when backend unavailable
  String _getMockResponse(String message) {
    if (message.contains('budget') || message.contains('cost') || message.contains('price')) {
      return 'I can help you plan a budget-friendly trip! The average cost depends on your destination and duration. Would you like suggestions for affordable destinations?';
    } else if (message.contains('weather') || message.contains('climate')) {
      return 'I can provide weather information for your destination. Which city are you planning to visit?';
    } else if (message.contains('hotel') || message.contains('accommodation')) {
      return 'I can recommend hotels based on your budget and preferences. What\'s your destination and preferred price range?';
    } else if (message.contains('food') || message.contains('restaurant')) {
      return 'I\'d be happy to suggest local cuisine and restaurants! Which destination are you interested in?';
    } else if (message.contains('activity') || message.contains('things to do')) {
      return 'There are many exciting activities depending on your destination! Are you interested in adventure, culture, relaxation, or nightlife?';
    } else if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! I\'m here to help you plan an amazing trip. What would you like to know?';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! Feel free to ask me anything else about your trip planning.';
    } else {
      return 'That\'s a great question! I can help you with trip planning, budget estimates, destination recommendations, weather info, and activity suggestions. What would you like to explore?';
    }
  }
}
