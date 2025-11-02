import 'dart:html' as html;
import '../config.dart';

class MapInitService {
  static bool _isInjected = false;
  static bool _isLoading = false;
  
  static void injectGoogleMapsApiKey() {
    if (_isInjected || _isLoading) return;
    
    final apiKey = Config.googleMapsApiKey;
    if (apiKey.isEmpty) {
      print('Warning: Google Maps API key is empty');
      return;
    }
    
    // Check if script already exists
    final existingScript = html.document.getElementById('google-maps-api');
    if (existingScript != null) {
      _isInjected = true;
      return;
    }
    
    _isLoading = true;
    
    // Create and inject Google Maps script with async loading (best practice)
    // Using loading=async parameter as recommended by Google
    final script = html.ScriptElement()
      ..id = 'google-maps-api'
      ..type = 'text/javascript'
      ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&loading=async'
      ..async = true
      ..defer = true;
    
    // Add load event listener to track when the script is ready
    script.onLoad.listen((_) {
      _isInjected = true;
      _isLoading = false;
      print('Google Maps API script loaded successfully (async)');
    });
    
    // Add error event listener
    script.onError.listen((_) {
      _isLoading = false;
      print('Error loading Google Maps API script');
    });
    
    html.document.head?.append(script);
    print('Google Maps API script injection started (async mode)');
  }
}
