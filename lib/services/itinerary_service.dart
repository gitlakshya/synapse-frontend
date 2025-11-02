import '../utils/api_cache.dart';
import 'api_middleware.dart';
import 'package:intl/intl.dart';

/// Itinerary Service - Handles trip planning and itinerary generation
/// 
/// Backend Integration:
/// - POST /api/v1/plantrip: Generate new itinerary
/// - GET /api/v1/itineraries: List saved trips (auth required)
/// - POST /api/v1/saveItinerary: Save trip (auth required)
/// - POST /api/v1/smartadjust: Modify existing itinerary
class ItineraryService {
  final _cache = ApiCache();

  /// Generate a new itinerary using backend AI
  /// 
  /// Endpoint: POST /api/v1/plantrip
  /// Request: {destination, startDate, endDate, budget, preferences, people, sessionId}
  /// Response: {success, data: {itinerary, tripId, estimatedCost, suggestions}}
  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    required List<String> themes,
    int people = 1,
  }) async {
    final days = endDate.difference(startDate).inDays + 1;
    final cacheKey = 'itinerary_${destination}_${days}_${budget}_${themes.join('_')}';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    try {
      // Format dates as YYYY-MM-DD per API spec
      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDateStr = dateFormat.format(startDate);
      final endDateStr = dateFormat.format(endDate);

      // Convert themes list to preferences map with default weight of 50
      final Map<String, dynamic> preferencesMap = {};
      if (themes.isEmpty) {
        preferencesMap['nature'] = 50;
        preferencesMap['culture'] = 50;
        preferencesMap['adventure'] = 50;
      } else {
        for (var theme in themes) {
          preferencesMap[theme.toLowerCase()] = 50;
        }
      }

      final response = await ApiMiddleware.planTrip(
        destination: destination,
        startDate: startDateStr,
        endDate: endDateStr,
        days: days,
        budget: budget.toInt(),
        preferences: preferencesMap,
        people: people,
      );

      if (response['success'] == true) {
        final result = response['data'] ?? {};
        _cache.set(cacheKey, result, ttl: const Duration(hours: 1));
        return result;
      } else {
        throw Exception(response['error'] ?? 'Failed to generate itinerary');
      }
    } catch (e) {
      // Fallback to mock on error
      print('Itinerary API error: $e - Using fallback');
      final result = _getMockItinerary(destination, days);
      _cache.set(cacheKey, result, ttl: const Duration(minutes: 30));
      return result;
    }
  }

  /// Save itinerary to backend (requires authentication)
  /// 
  /// Endpoint: POST /api/v1/saveItinerary
  /// Request: {tripId, itinerary, sessionId}
  /// Response: {success, data: {savedTripId}}
  Future<String> saveItinerary({
    required String tripId,
    required Map<String, dynamic> itinerary,
  }) async {
    try {
      final response = await ApiMiddleware.saveItinerary(
        tripId: tripId,
        itinerary: itinerary,
      );

      if (response['success'] == true) {
        return response['data']?['savedTripId'] ?? tripId;
      } else {
        throw Exception(response['error'] ?? 'Failed to save itinerary');
      }
    } catch (e) {
      throw Exception('Save itinerary error: ${e.toString()}');
    }
  }

  /// Get list of saved itineraries (requires authentication)
  /// 
  /// Endpoint: GET /api/v1/itineraries
  /// Response: {success, data: {itineraries: []}}
  Future<List<Map<String, dynamic>>> getSavedItineraries() async {
    try {
      final response = await ApiMiddleware.apiGet('/api/v1/itineraries');

      if (response['success'] == true) {
        final data = response['data'];
        final itineraries = data['itineraries'] as List?;
        return itineraries?.cast<Map<String, dynamic>>() ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Get itineraries error: $e');
      return [];
    }
  }

  /// Adjust existing itinerary using smart adjust
  /// 
  /// Endpoint: POST /api/v1/smartadjust
  /// Request: {itinerary, adjustments, sessionId}
  /// Response: {success, data: {adjustedItinerary, changes}}
  Future<Map<String, dynamic>> adjustItinerary({
    required Map<String, dynamic> itinerary,
    required Map<String, dynamic> adjustments,
  }) async {
    try {
      final response = await ApiMiddleware.apiPost('/api/v1/smartadjust', {
        'itinerary': itinerary,
        'adjustments': adjustments,
      });

      if (response['success'] == true) {
        return response['data'] ?? itinerary;
      } else {
        throw Exception(response['error'] ?? 'Failed to adjust itinerary');
      }
    } catch (e) {
      print('Adjust itinerary error: $e');
      return itinerary; // Return original on error
    }
  }

  Map<String, dynamic> _getMockItinerary(String destination, int days) {
    return {
      'destination': destination,
      'days': days,
      'itinerary': {
        '1': [
          {
            'title': 'Check-in at Taj Rambagh Palace',
            'time': '2:00 PM',
            'cost': '₹8,000',
            'rating': 4.8,
            'description': 'Luxury heritage hotel',
            'lat': 26.9124,
            'lng': 75.7873,
            'type': 'hotel'
          },
          {
            'title': 'Visit City Palace',
            'time': '4:00 PM',
            'cost': '₹700',
            'rating': 4.7,
            'description': 'Royal palace complex',
            'lat': 26.9255,
            'lng': 75.8237,
            'type': 'attraction'
          },
          {
            'title': 'Dinner at Chokhi Dhani',
            'time': '8:00 PM',
            'cost': '₹1,200',
            'rating': 4.6,
            'description': 'Traditional Rajasthani village',
            'lat': 26.7606,
            'lng': 75.7339,
            'type': 'restaurant'
          }
        ],
        '2': [
          {
            'title': 'Amber Fort Tour',
            'time': '9:00 AM',
            'cost': '₹500',
            'rating': 4.9,
            'description': 'Majestic hilltop fort',
            'lat': 26.9855,
            'lng': 75.8513,
            'type': 'attraction'
          },
          {
            'title': 'Lunch at LMB',
            'time': '1:00 PM',
            'cost': '₹600',
            'rating': 4.5,
            'description': 'Famous local restaurant',
            'lat': 26.9196,
            'lng': 75.7878,
            'type': 'restaurant'
          }
        ],
        '3': [
          {
            'title': 'Hawa Mahal Visit',
            'time': '8:00 AM',
            'cost': '₹200',
            'rating': 4.6,
            'description': 'Palace of Winds',
            'lat': 26.9239,
            'lng': 75.8267,
            'type': 'attraction'
          }
        ]
      },
      'budget_breakdown': {
        'Hotels': 24000.0,
        'Travel': 8000.0,
        'Food': 6000.0,
        'Experiences': 5000.0
      },
      'weather': {
        'temperature': '28°C',
        'condition': 'Sunny',
        'best_time': '9 AM - 6 PM'
      }
    };
  }
}
