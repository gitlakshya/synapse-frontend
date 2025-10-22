import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/chat_service.dart';

// Trip Preferences State
class TripPreferences {
  final String destination;
  final DateTimeRange? dates;
  final double budget;
  final Set<String> themes;
  final int people;
  final String language;

  TripPreferences({
    this.destination = '',
    this.dates,
    this.budget = 50000,
    this.themes = const {'Heritage', 'Foodie'},
    this.people = 2,
    this.language = 'English',
  });

  TripPreferences copyWith({
    String? destination,
    DateTimeRange? dates,
    double? budget,
    Set<String>? themes,
    int? people,
    String? language,
  }) {
    return TripPreferences(
      destination: destination ?? this.destination,
      dates: dates ?? this.dates,
      budget: budget ?? this.budget,
      themes: themes ?? this.themes,
      people: people ?? this.people,
      language: language ?? this.language,
    );
  }
}

// Trip Preferences Provider using ChangeNotifier
class TripPreferencesProvider extends ChangeNotifier {
  TripPreferences _preferences = TripPreferences();

  TripPreferences get preferences => _preferences;

  void updateDestination(String destination) {
    _preferences = _preferences.copyWith(destination: destination);
    notifyListeners();
  }

  void updateDates(DateTimeRange? dates) {
    _preferences = _preferences.copyWith(dates: dates);
    notifyListeners();
  }

  void updateBudget(double budget) {
    _preferences = _preferences.copyWith(budget: budget);
    notifyListeners();
  }

  void updateThemes(Set<String> themes) {
    _preferences = _preferences.copyWith(themes: themes);
    notifyListeners();
  }

  void updatePeople(int people) {
    _preferences = _preferences.copyWith(people: people);
    notifyListeners();
  }

  void updateLanguage(String language) {
    _preferences = _preferences.copyWith(language: language);
    notifyListeners();
  }
}

// Weather Service Provider
class WeatherServiceProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherService get weatherService => _weatherService;
}

// Chat Service Provider
class ChatServiceProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService.instance;
  
  ChatService get chatService => _chatService;
}