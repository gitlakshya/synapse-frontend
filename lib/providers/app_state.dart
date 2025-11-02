import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/itinerary_service.dart';
import '../services/weather_service.dart';

class AppState extends ChangeNotifier {
  String? _from;
  String? _to;
  DateTime? _startDate;
  DateTime? _endDate;
  double _budget = 50000;
  List<String> _selectedThemes = [];
  String _language = 'English';
  String? _destination;
  int _tripDuration = 0;
  String _selectedTransport = 'Flight';
  List<String> _savedPlaces = [];
  
  Map<String, dynamic>? _itinerary;
  Map<String, dynamic>? _weatherCache;
  DateTime? _weatherCacheTime;
  String? _weatherCacheCity;
  Map<String, dynamic>? _bookingInfo;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  String? get from => _from;
  String? get to => _to;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double get budget => _budget;
  List<String> get selectedThemes => _selectedThemes;
  String get language => _language;
  String? get destination => _destination;
  int get tripDuration => _tripDuration;
  Map<String, dynamic>? get itinerary => _itinerary;
  Map<String, dynamic>? get weatherCache => _weatherCache;
  Map<String, dynamic>? get bookingInfo => _bookingInfo;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get selectedTransport => _selectedTransport;
  List<String> get savedPlaces => _savedPlaces;

  AppState() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPlaces = prefs.getStringList('saved_places') ?? [];
    _selectedTransport = prefs.getString('selected_transport') ?? 'Flight';
    notifyListeners();
  }

  // Setters
  void setFrom(String value) {
    _from = value;
    notifyListeners();
  }

  void setTo(String value) {
    _to = value;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    _calculateDuration();
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    _calculateDuration();
    notifyListeners();
  }

  void setBudget(double value) {
    _budget = value;
    notifyListeners();
  }

  void toggleTheme(String theme) {
    if (_selectedThemes.contains(theme)) {
      _selectedThemes.remove(theme);
    } else {
      _selectedThemes.add(theme);
    }
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setDestination(String value) {
    _destination = value;
    notifyListeners();
  }

  Future<void> setTransport(String transport) async {
    _selectedTransport = transport;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_transport', transport);
    notifyListeners();
  }

  Future<void> addSavedPlace(String place) async {
    if (!_savedPlaces.contains(place)) {
      _savedPlaces.add(place);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_places', _savedPlaces);
      notifyListeners();
    }
  }

  Future<void> removeSavedPlace(String place) async {
    _savedPlaces.remove(place);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_places', _savedPlaces);
    notifyListeners();
  }

  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      _tripDuration = _endDate!.difference(_startDate!).inDays;
    }
  }

  Future<void> fetchItinerary() async {
    if (_to == null || _startDate == null || _endDate == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _itinerary = await ItineraryService().generateItinerary(
        destination: _to!,
        startDate: _startDate!,
        endDate: _endDate!,
        budget: _budget,
        themes: _selectedThemes,
      );
    } catch (e) {
      _itinerary = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setBookingInfo(Map<String, dynamic> info) {
    _bookingInfo = info;
    notifyListeners();
  }

  Future<void> updateWeatherCache(String destination) async {
    // Return cached data if less than 10 minutes old
    if (_weatherCacheCity == destination &&
        _weatherCacheTime != null &&
        DateTime.now().difference(_weatherCacheTime!).inMinutes < 10) {
      return;
    }

    try {
      _weatherCache = await WeatherService().getWeather(destination);
      _weatherCacheCity = destination;
      _weatherCacheTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _weatherCache = null;
    }
  }

  void setUserProfile(Map<String, dynamic> profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void reset() {
    _from = null;
    _to = null;
    _startDate = null;
    _endDate = null;
    _budget = 50000;
    _selectedThemes = [];
    _language = 'English';
    _destination = null;
    _tripDuration = 0;
    _itinerary = null;
    _weatherCache = null;
    _bookingInfo = null;
    _isLoading = false;
    notifyListeners();
  }
}
