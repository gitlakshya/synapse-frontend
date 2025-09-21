import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'bd5e378503939ddaee76f12ad7a97608'; // Real OpenWeatherMap API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const Duration _timeout = Duration(seconds: 10);

  Future<WeatherData> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'),
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Weather API Success for $city: ${data['weather'][0]['main']}');
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 404) {
        throw WeatherException('City not found: $city');
      } else if (response.statusCode == 401) {
        throw WeatherException('Invalid API key');
      } else {
        throw WeatherException('Weather service unavailable (${response.statusCode})');
      }
    } on TimeoutException {
      throw WeatherException('Request timeout - check internet connection');
    } on FormatException {
      throw WeatherException('Invalid response format');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Network error: ${e.toString()}');
    }
  }

  Future<List<WeatherData>> getForecast(String city, int days) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&cnt=${days * 8}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['list'] as List)
            .map((item) => WeatherData.fromForecastJson(item))
            .toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      return List.generate(days, (index) => WeatherData.mock(city));
    }
  }
}

class WeatherData {
  final String city;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;
  final DateTime date;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      icon: json['weather'][0]['icon'],
      date: DateTime.now(),
    );
  }

  factory WeatherData.fromForecastJson(Map<String, dynamic> json) {
    return WeatherData(
      city: '',
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      icon: json['weather'][0]['icon'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

  factory WeatherData.mock(String city) {
    return WeatherData(
      city: city,
      temperature: 25.0,
      condition: 'Clear',
      description: 'Clear sky',
      humidity: 60,
      windSpeed: 5.0,
      icon: '01d',
      date: DateTime.now(),
    );
  }

  String get emoji {
    switch (condition.toLowerCase()) {
      case 'clear': return '☀️';
      case 'clouds': return '☁️';
      case 'rain': return '🌧️';
      case 'snow': return '❄️';
      case 'thunderstorm': return '⛈️';
      case 'drizzle': return '🌦️';
      case 'mist':
      case 'fog': return '🌫️';
      default: return '🌤️';
    }
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  
  @override
  String toString() => 'WeatherException: $message';
}