import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../utils/http_cache.dart';

class WeatherService {
  static const String _proxyUrl = 'https://your-backend.com/api/weather';
  static const bool _useProxy = false;
  final _cache = HttpCache();

  Future<Map<String, dynamic>> getWeather(String city) async {
    final cacheKey = 'weather_$city';
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return json.decode(cached);
    }

    try {
      final url = _useProxy
          ? '$_proxyUrl?city=${Uri.encodeComponent(city)}'
          : 'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=${Config.openWeatherApiKey}&units=metric';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = _parseWeatherData(data);
        _cache.set(cacheKey, json.encode(result), const Duration(minutes: 10));
        return result;
      }
    } catch (e) {
      // Return mock data on error
    }
    
    return _getMockWeather(city);
  }

  Future<Map<String, dynamic>> getWeatherByCoords(double lat, double lng, {DateTime? date}) async {
    final cacheKey = 'weather_${lat}_${lng}_${date?.toIso8601String()}';
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return json.decode(cached);
    }

    try {
      final url = _useProxy
          ? '$_proxyUrl?lat=$lat&lng=$lng'
          : 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=${Config.openWeatherApiKey}&units=metric';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = _parseWeatherData(data);
        _cache.set(cacheKey, json.encode(result), const Duration(minutes: 10));
        return result;
      }
    } catch (e) {
      // Return mock data on error
    }
    
    return _getMockWeatherByCoords(lat, lng, date);
  }

  Map<String, dynamic> _parseWeatherData(Map<String, dynamic> data) {
    final temp = data['main']['temp'].round();
    final condition = data['weather'][0]['main'];
    final icon = data['weather'][0]['icon'];
    
    return {
      'temperature': '$temp°C',
      'condition': condition,
      'description': data['weather'][0]['description'],
      'icon': icon,
      'suggestion': _getSuggestion(temp, condition),
    };
  }

  String _getSuggestion(int temp, String condition) {
    if (temp > 35) return 'Very hot! Best time: Early morning (6-9 AM) or evening (6-8 PM)';
    if (temp > 30) return 'Hot weather. Best time to explore: 9 AM–6 PM with breaks';
    if (temp < 10) return 'Cold weather. Best time: 11 AM–4 PM when it\'s warmest';
    if (condition.toLowerCase().contains('rain')) return 'Rainy day. Carry umbrella. Indoor activities recommended';
    if (condition.toLowerCase().contains('cloud')) return 'Pleasant weather. Best time: 9 AM–6 PM';
    return 'Perfect weather! Best time to explore: 9 AM–6 PM';
  }

  Map<String, dynamic> _getMockWeather(String city) {
    final hash = city.hashCode.abs();
    final temp = 20 + (hash % 15);
    final conditions = ['Clear', 'Clouds', 'Rain', 'Sunny'];
    final condition = conditions[hash % conditions.length];
    
    return {
      'temperature': '$temp°C',
      'condition': condition,
      'description': condition.toLowerCase(),
      'icon': '01d',
      'suggestion': _getSuggestion(temp, condition),
    };
  }

  Map<String, dynamic> _getMockWeatherByCoords(double lat, double lng, DateTime? date) {
    final hash = (lat * 1000 + lng * 1000).toInt().abs();
    final dayOffset = date != null ? date.difference(DateTime.now()).inDays : 0;
    final temp = 18 + (hash % 18) + (dayOffset % 5);
    final conditions = ['Clear', 'Clouds', 'Sunny', 'Rain'];
    final condition = conditions[(hash + dayOffset) % conditions.length];
    
    return {
      'temperature': '$temp°C',
      'condition': condition,
      'description': condition.toLowerCase(),
      'icon': condition == 'Clear' || condition == 'Sunny' ? '01d' : condition == 'Clouds' ? '02d' : '10d',
      'suggestion': _getSuggestion(temp, condition),
    };
  }
}
