import 'dart:async';
import 'dart:js' as js;
import 'places_service.dart';

/// Web-specific implementation of Places Service using Google Maps JavaScript API
/// This avoids CORS issues by using the browser's native JavaScript API

bool _initialized = false;
bool _isLoading = false;
final List<Function> _pendingCallbacks = [];

/// Initialize Google Maps JavaScript API
Future<void> _ensureInitialized() async {
  if (_initialized) return;
  
  if (_isLoading) {
    // Wait for initialization to complete
    final completer = Completer<void>();
    _pendingCallbacks.add(() => completer.complete());
    return completer.future;
  }

  _isLoading = true;

  // Check if google.maps.places is already available
  if (js.context.hasProperty('google') && 
      js.context['google'].hasProperty('maps') &&
      js.context['google']['maps'].hasProperty('places')) {
    _initialized = true;
    _isLoading = false;
    _notifyPendingCallbacks();
    return;
  }

  // Wait a bit for the script to load (it's loaded in index.html)
  await Future.delayed(const Duration(milliseconds: 500));

  if (js.context.hasProperty('google') && 
      js.context['google'].hasProperty('maps') &&
      js.context['google']['maps'].hasProperty('places')) {
    _initialized = true;
    _isLoading = false;
    _notifyPendingCallbacks();
    return;
  }

  // If still not available, it's not loaded
  print('Warning: Google Maps JavaScript API not loaded');
  _isLoading = false;
  _notifyPendingCallbacks();
}

void _notifyPendingCallbacks() {
  for (var callback in _pendingCallbacks) {
    callback();
  }
  _pendingCallbacks.clear();
}

/// Fetch city predictions using Google Maps JavaScript API
/// Uses AutocompleteService (legacy but still supported)
Future<List<PlacePrediction>> getCityPredictions(String query) async {
  if (query.trim().isEmpty) return [];

  try {
    await _ensureInitialized();

    if (!_initialized) {
      print('Google Maps API not initialized, returning empty results');
      return [];
    }

    final completer = Completer<List<PlacePrediction>>();

    try {
      // Use AutocompleteService (still supported, just legacy)
      // The new AutocompleteSuggestion API requires Places (New) library
      // which needs additional setup. Using legacy API for simplicity.
      final service = js.JsObject(
        js.context['google']['maps']['places']['AutocompleteService'],
      );

      final request = js.JsObject.jsify({
        'input': query,
        'types': ['(cities)'],
      });

      void callback(dynamic predictions, String status) {
        if (status == 'OK' && predictions != null) {
          final List<PlacePrediction> results = [];
          
          for (var i = 0; i < predictions.length; i++) {
            final prediction = predictions[i];
            
            results.add(PlacePrediction(
              placeId: prediction['place_id'] ?? '',
              description: prediction['description'] ?? '',
              mainText: prediction['structured_formatting']?['main_text'] ?? prediction['description'] ?? '',
              secondaryText: prediction['structured_formatting']?['secondary_text'] ?? '',
            ));
          }
          
          completer.complete(results);
        } else if (status == 'ZERO_RESULTS') {
          completer.complete([]);
        } else {
          print('Places API status: $status');
          completer.complete([]);
        }
      }

      service.callMethod('getPlacePredictions', [
        request,
        js.allowInterop(callback),
      ]);
    } catch (e) {
      print('Error calling Places API: $e');
      completer.complete([]);
    }

    return await completer.future;
  } catch (e) {
    print('Error fetching city predictions (web): $e');
    return [];
  }
}
