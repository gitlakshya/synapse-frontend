import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'places_service_web.dart' if (dart.library.io) 'places_service_mobile.dart' as platform;

/// Service for Google Places Autocomplete API
/// Fetches city-level predictions only (no addresses or street-level data)
/// Uses JavaScript API on web to avoid CORS issues, REST API on mobile
class PlacesService {
  /// Fetch city predictions from Google Places Autocomplete API
  /// Restricts results to cities only using types=(cities) filter
  /// Returns list of city suggestions with name, country, and place_id
  Future<List<PlacePrediction>> getCityPredictions(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // Use platform-specific implementation
      if (kIsWeb) {
        return await platform.getCityPredictions(query);
      } else {
        return await platform.getCityPredictions(query);
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
