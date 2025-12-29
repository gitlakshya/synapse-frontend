import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'places_service.dart';

/// Mobile-specific implementation using REST API
const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

/// Fetch city predictions from Google Places Autocomplete REST API
Future<List<PlacePrediction>> getCityPredictions(String query) async {
  if (query.trim().isEmpty) return [];
  
  final apiKey = Config.googleMapsApiKey;
  if (apiKey.isEmpty) {
    print('Warning: Google Maps API key not configured');
    return [];
  }
  
  try {
    final url = Uri.parse(
      '$_baseUrl/autocomplete/json?input=${Uri.encodeComponent(query)}&types=(cities)&key=$apiKey'
    );
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;
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
    print('Error fetching city predictions (mobile): $e');
    return [];
  }
}
