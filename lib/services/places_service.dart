import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

/// Service for Google Places Autocomplete API
/// Fetches city-level predictions only (no addresses or street-level data)
class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  /// Fetch city predictions from Google Places Autocomplete API
  /// Restricts results to cities only using types=(cities) filter
  /// Returns list of city suggestions with name, country, and place_id
  Future<List<PlacePrediction>> getCityPredictions(String query) async {
    if (query.trim().isEmpty) return [];
    
    final apiKey = Config.googleMapsApiKey;
    if (apiKey.isEmpty) {
      print('Warning: Google Maps API key not configured');
      return [];
    }
    
    try {
      // Build API URL with city-level restriction
      // types=(cities) ensures only city-level results are returned
      final url = Uri.parse(
        '$_baseUrl/autocomplete/json?input=${Uri.encodeComponent(query)}&types=(cities)&key=$apiKey'
      );
      
      // Make API request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check API response status
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          
          // Parse predictions into PlacePrediction objects
          return predictions.map((p) => PlacePrediction.fromJson(p)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          print('Places API error: ${data['status']}');
          return [];
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching city predictions: $e');
      return [];
    }
  }
}

/// Model for Place Prediction
/// Contains city name, country, and place_id
class PlacePrediction {
  final String placeId;
  final String description; // Full description (e.g., "Paris, France")
  final String mainText;    // City name only (e.g., "Paris")
  final String secondaryText; // Country/region (e.g., "France")
  
  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
  
  /// Parse from Google Places API JSON response
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? json['description'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}
