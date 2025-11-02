import '../config.dart';

class ApiConfig {
  // Use Config for environment-based keys
  static String get googleMapsApiKey => Config.googleMapsApiKey;
  static String get openWeatherMapApiKey => Config.openWeatherApiKey;
  static const String aiBackendUrl = 'https://api.example.com/generate-itinerary';
}
