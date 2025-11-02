import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import '../models/waypoint.dart';
import '../widgets/itinerary_filters_widget.dart';

class TripPlannerProvider extends ChangeNotifier {
  Map<String, dynamic>? _selectedItinerary;
  bool _isGenerating = false;
  String? _error;
  Map<int, List<Map<String, dynamic>>> _itinerary = {};
  Map<String, double> _budgetBreakdown = {};
  double _totalBudget = 50000;

  Map<String, dynamic>? get selectedItinerary => _selectedItinerary;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  Map<int, List<Map<String, dynamic>>> get itinerary => _itinerary;
  Map<String, double> get budgetBreakdown => _budgetBreakdown;
  double get totalBudget => _totalBudget;
  
  List<Waypoint> get waypoints {
    if (_itinerary.isEmpty) return [];
    
    final List<Waypoint> points = [];
    final startDate = DateTime.now();
    
    for (var entry in _itinerary.entries) {
      final day = entry.key;
      final activities = entry.value;
      final date = startDate.add(Duration(days: day - 1));
      
      for (var activity in activities) {
        points.add(Waypoint(
          id: activity['id'],
          title: activity['title'],
          lat: activity['lat'],
          lng: activity['lng'],
          imageUrl: activity['imageUrl'],
          rating: activity['rating']?.toDouble(),
          cost: activity['cost']?.toString(),
          type: activity['type'],
          date: date,
          day: day,
        ));
      }
    }
    
    return points;
  }

  Future<void> fetchItinerary({
    required String destination,
    required int days,
    required double budget,
    List<String> themes = const [],
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AIService().generateItinerary(
        destination: destination,
        days: days,
        budget: budget,
        themes: themes,
      );

      _selectedItinerary = result;
      _isGenerating = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clearItinerary() {
    _selectedItinerary = null;
    _error = null;
    notifyListeners();
  }

  void initializeMockItinerary() {
    _itinerary = {
      1: [
        {'id': 'act_1', 'title': 'City Palace', 'time': '10:00 AM', 'cost': 500, 'type': 'heritage', 'imageUrl': 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=400', 'lat': 26.9258, 'lng': 75.8237, 'rating': 4.7},
        {'id': 'act_2', 'title': 'Hawa Mahal', 'time': '2:00 PM', 'cost': 200, 'type': 'heritage', 'imageUrl': 'https://images.unsplash.com/photo-1524230572899-a752b3835840?w=400', 'lat': 26.9239, 'lng': 75.8267, 'rating': 4.6},
        {'id': 'act_3', 'title': 'Chokhi Dhani Dinner', 'time': '7:00 PM', 'cost': 800, 'type': 'food', 'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400', 'lat': 26.8515, 'lng': 75.7923, 'rating': 4.5},
      ],
      2: [
        {'id': 'act_4', 'title': 'Amber Fort', 'time': '9:00 AM', 'cost': 600, 'type': 'heritage', 'imageUrl': 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=400', 'lat': 26.9855, 'lng': 75.8513, 'rating': 4.8},
        {'id': 'act_5', 'title': 'Jal Mahal', 'time': '4:00 PM', 'cost': 0, 'type': 'nature', 'imageUrl': 'https://images.unsplash.com/photo-1597074866923-dc0589150358?w=400', 'lat': 26.9539, 'lng': 75.8461, 'rating': 4.4},
        {'id': 'act_6', 'title': 'Bar Palladio', 'time': '8:00 PM', 'cost': 1500, 'type': 'nightlife', 'imageUrl': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400', 'lat': 26.9124, 'lng': 75.7873, 'rating': 4.6},
      ],
      3: [
        {'id': 'act_7', 'title': 'Jantar Mantar', 'time': '10:00 AM', 'cost': 200, 'type': 'heritage', 'imageUrl': 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=400', 'lat': 26.9246, 'lng': 75.8247, 'rating': 4.5},
        {'id': 'act_8', 'title': 'Nahargarh Fort', 'time': '3:00 PM', 'cost': 300, 'type': 'adventure', 'imageUrl': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=400', 'lat': 26.9361, 'lng': 75.8153, 'rating': 4.7},
        {'id': 'act_9', 'title': 'Local Market Shopping', 'time': '6:00 PM', 'cost': 1000, 'type': 'food', 'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400', 'lat': 26.9196, 'lng': 75.7878, 'rating': 4.3},
      ],
      4: [
        {'id': 'act_10', 'title': 'Jaigarh Fort', 'time': '9:00 AM', 'cost': 400, 'type': 'adventure', 'imageUrl': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=400', 'lat': 26.9856, 'lng': 75.8515, 'rating': 4.6},
        {'id': 'act_11', 'title': 'Albert Hall Museum', 'time': '2:00 PM', 'cost': 300, 'type': 'heritage', 'imageUrl': 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=400', 'lat': 26.9124, 'lng': 75.8187, 'rating': 4.5},
        {'id': 'act_12', 'title': 'Rooftop Dining', 'time': '7:30 PM', 'cost': 1200, 'type': 'food', 'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400', 'lat': 26.9196, 'lng': 75.7878, 'rating': 4.7},
      ],
      5: [
        {'id': 'act_13', 'title': 'Sisodia Rani Garden', 'time': '10:00 AM', 'cost': 100, 'type': 'nature', 'imageUrl': 'https://images.unsplash.com/photo-1597074866923-dc0589150358?w=400', 'lat': 26.8515, 'lng': 75.8923, 'rating': 4.4},
        {'id': 'act_14', 'title': 'Birla Mandir', 'time': '4:00 PM', 'cost': 0, 'type': 'heritage', 'imageUrl': 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=400', 'lat': 26.8983, 'lng': 75.8006, 'rating': 4.5},
        {'id': 'act_15', 'title': 'Farewell Dinner', 'time': '7:00 PM', 'cost': 1500, 'type': 'food', 'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400', 'lat': 26.9124, 'lng': 75.7873, 'rating': 4.8},
      ],
    };
    _updateBudgetBreakdown();
  }

  void _updateBudgetBreakdown() {
    double travel = 0, food = 0, accommodation = 0, experiences = 0;
    for (var activities in _itinerary.values) {
      for (var activity in activities) {
        final cost = (activity['cost'] as num).toDouble();
        final type = activity['type'] as String;
        if (type == 'food') {
          food += cost;
        } else if (type == 'heritage' || type == 'nature') {
          experiences += cost;
        } else {
          experiences += cost;
        }
      }
    }
    travel = 5000;
    accommodation = 15000;
    _budgetBreakdown = {'Travel': travel, 'Food': food, 'Accommodation': accommodation, 'Experiences': experiences};
    _totalBudget = travel + food + accommodation + experiences;
  }

  Future<void> refineItinerary(ItineraryFilters filters) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      final allActivities = <Map<String, dynamic>>[];
      for (var activities in _itinerary.values) {
        allActivities.addAll(activities);
      }

      var filteredActivities = List<Map<String, dynamic>>.from(allActivities);

      if (filters.vegetarianOnly) {
        filteredActivities = filteredActivities.where((a) => a['type'] != 'food' || a['title'].contains('Vegetarian') || !a['title'].contains('Non-Veg')).toList();
      }

      final themeActivities = <Map<String, dynamic>>[];
      for (var entry in filters.themePercentages.entries) {
        final theme = entry.key.toLowerCase();
        final percent = entry.value;
        final count = (filteredActivities.length * percent / 100).round();
        final matching = filteredActivities.where((a) => a['type'] == theme).take(count).toList();
        themeActivities.addAll(matching);
      }

      if (themeActivities.isNotEmpty) {
        filteredActivities = themeActivities;
      }

      final daysCount = _itinerary.length;
      final activitiesPerDay = (filteredActivities.length / daysCount).ceil();
      _itinerary = {};
      for (var i = 0; i < daysCount; i++) {
        final start = i * activitiesPerDay;
        final end = (start + activitiesPerDay).clamp(0, filteredActivities.length);
        _itinerary[i + 1] = filteredActivities.sublist(start, end < filteredActivities.length ? end : filteredActivities.length);
      }

      _totalBudget = filters.mainBudget;
      _budgetBreakdown = {
        'Travel': filters.travelBudget,
        'Food': filters.foodBudget,
        'Accommodation': filters.accommodationBudget,
        'Experiences': filters.experiencesBudget,
      };

      _isGenerating = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
    }
  }
}
