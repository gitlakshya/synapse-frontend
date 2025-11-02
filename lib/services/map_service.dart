import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../utils/http_cache.dart';

/// MapService handles map-related operations
/// 
/// SECURITY NOTE: For production, use a server-side proxy to hide API keys:
/// 1. Create backend endpoint: GET /api/maps/geocode?address=...
/// 2. Backend calls Google Maps API with server-stored key
/// 3. Client calls your backend instead of Google directly
/// 
/// Example proxy implementation:
/// ```
/// // Backend (Node.js/Express)
/// app.get('/api/maps/geocode', async (req, res) => {
///   const response = await fetch(
///     `https://maps.googleapis.com/maps/api/geocode/json?address=${req.query.address}&key=${process.env.GOOGLE_MAPS_KEY}`
///   );
///   res.json(await response.json());
/// });
/// ```
class MapService {
  static const String _proxyUrl = 'https://your-backend.com/api/maps';
  static const bool _useProxy = false;
  final _cache = HttpCache();
  
  Future<Map<String, double>?> geocodeAddress(String address) async {
    if (Config.googleMapsApiKey.isEmpty) {
      return _getMockCoordinates(address);
    }

    final cacheKey = 'geocode_$address';
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      final decoded = json.decode(cached) as Map<String, dynamic>;
      return {'lat': (decoded['lat'] as num).toDouble(), 'lng': (decoded['lng'] as num).toDouble()};
    }
    
    try {
      final url = _useProxy
          ? '$_proxyUrl/geocode?address=${Uri.encodeComponent(address)}'
          : 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${Config.googleMapsApiKey}';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final result = {'lat': (location['lat'] as num).toDouble(), 'lng': (location['lng'] as num).toDouble()};
          _cache.set(cacheKey, json.encode(result), const Duration(hours: 24));
          return result;
        }
      }
    } catch (e) {
      // Fallback to mock data on error
    }
    
    return _getMockCoordinates(address);
  }
  
  /// Mock coordinates for development/testing
  Map<String, double> _getMockCoordinates(String address) {
    final hash = address.hashCode.abs();
    return {
      'lat': 28.6139 + (hash % 100) / 1000, // Delhi area
      'lng': 77.2090 + (hash % 100) / 1000,
    };
  }
  
  /// Get static map image URL (fallback when interactive map fails)
  String getStaticMapUrl({
    required double lat,
    required double lng,
    int zoom = 13,
    int width = 600,
    int height = 400,
  }) {
    if (_useProxy) {
      return '$_proxyUrl/static?lat=$lat&lng=$lng&zoom=$zoom&width=$width&height=$height';
    }
    
    // Note: This exposes API key in URL - use proxy in production
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=$zoom&size=${width}x$height&key=${Config.googleMapsApiKey}';
  }
}
