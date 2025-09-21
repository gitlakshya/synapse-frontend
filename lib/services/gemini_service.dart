import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = '';
  GenerativeModel? _model;
  
  GeminiService() {
    if (_apiKey.isNotEmpty && !_apiKey.contains('Dummy')) {
      try {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
        );
        print('Gemini AI initialized successfully with key: ${_apiKey.substring(0, 10)}...');
        _testConnection();
      } catch (e) {
        print('Failed to initialize Gemini: $e');
      }
    } else {
      print('Gemini API key not configured - using mock responses');
    }
  }
  
  void _testConnection() async {
    try {
      print('Testing Gemini connection...');
      final response = await _model!.generateContent([Content.text('Hello')]);
      print('Connection test successful: ${response.text?.substring(0, 20) ?? 'No response'}');
    } catch (e) {
      print('Connection test failed: $e');
    }
  }
  
  bool get isConfigured => _model != null;
  
  Future<String> getResponse(String message, {String? destination, double? budget, List<String>? conversationHistory}) async {
    if (_model == null) {
      print('Model is null - using fallback');
      return _getFallbackResponse(message);
    }
    
    try {
      print('Sending request to Gemini API...');
      final prompt = _buildTravelPrompt(message, destination: destination, budget: budget, conversationHistory: conversationHistory);
      print('Prompt: $prompt');
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final responseText = response.text;
      if (responseText != null && responseText.isNotEmpty) {
        print('Gemini response received: ${responseText.substring(0, responseText.length > 50 ? 50 : responseText.length)}...');
        return responseText;
      } else {
        print('Empty response from Gemini');
        return 'Sorry, I couldn\'t generate a response. Please try again.';
      }
    } catch (e) {
      print('Gemini API error: $e');
      return 'API Error: ${e.toString()}. Using fallback response: ${_getFallbackResponse(message)}';
    }
  }
  
  String _buildTravelPrompt(String userMessage, {String? destination, double? budget, List<String>? conversationHistory}) {
    final context = StringBuffer();
    context.write('You are a helpful AI travel assistant for Indian destinations. ');
    
    if (destination != null && destination.isNotEmpty) {
      context.write('The user is planning a trip to $destination. ');
    }
    
    if (budget != null && budget > 0) {
      context.write('Their budget is ₹${budget.toInt()}. ');
    }
    
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      context.write('Previous conversation: ');
      context.write(conversationHistory.join(' '));
      context.write(' ');
    }
    
    context.write('Provide concise, helpful travel advice in 2-3 sentences. ');
    context.write('Focus on practical tips, local experiences, and budget-friendly options. ');
    context.write('Current question: $userMessage');
    
    return context.toString();
  }
  
  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('weather')) {
      return '🌤️ I recommend checking the weather forecast before your trip. Pack accordingly and have indoor alternatives ready!';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('restaurant')) {
      return '🍽️ Try local street food and authentic restaurants. Ask locals for recommendations - they know the best hidden gems!';
    } else if (lowerMessage.contains('budget') || lowerMessage.contains('money')) {
      return '💰 Book in advance, use local transport, and try local eateries to save money. Negotiate prices at markets!';
    } else {
      return '🤖 I\'m here to help with your travel planning! Ask me about destinations, food, budget tips, or activities.';
    }
  }
}