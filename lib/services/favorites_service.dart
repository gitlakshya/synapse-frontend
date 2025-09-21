import 'dart:async';
import '../models/user_models.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final List<SavedTrip> _favoriteTrips = [];
  final StreamController<List<SavedTrip>> _favoritesController = StreamController<List<SavedTrip>>.broadcast();
  
  Stream<List<SavedTrip>> get favoritesStream => _favoritesController.stream;
  List<SavedTrip> get favoriteTrips => List.unmodifiable(_favoriteTrips);

  Future<void> addToFavorites(SavedTrip trip) async {
    final updatedTrip = SavedTrip(
      id: trip.id,
      userId: trip.userId,
      title: trip.title,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      budget: trip.budget,
      themes: trip.themes,
      people: trip.people,
      isFavorite: true,
      isShared: trip.isShared,
      createdAt: trip.createdAt,
      updatedAt: DateTime.now(),
      collaborators: trip.collaborators,
      status: trip.status,
    );
    
    final existingIndex = _favoriteTrips.indexWhere((t) => t.id == trip.id);
    if (existingIndex >= 0) {
      _favoriteTrips[existingIndex] = updatedTrip;
    } else {
      _favoriteTrips.add(updatedTrip);
    }
    
    _favoritesController.add(_favoriteTrips);
    await _saveFavoritesLocally();
  }

  Future<void> removeFromFavorites(String tripId) async {
    _favoriteTrips.removeWhere((trip) => trip.id == tripId);
    _favoritesController.add(_favoriteTrips);
    await _saveFavoritesLocally();
  }

  bool isFavorite(String tripId) {
    return _favoriteTrips.any((trip) => trip.id == tripId);
  }

  Future<void> toggleFavorite(SavedTrip trip) async {
    if (isFavorite(trip.id)) {
      await removeFromFavorites(trip.id);
    } else {
      await addToFavorites(trip);
    }
  }

  List<SavedTrip> getFavoritesByDestination(String destination) {
    return _favoriteTrips.where((trip) => 
      trip.destination.toLowerCase().contains(destination.toLowerCase())
    ).toList();
  }

  List<SavedTrip> getFavoritesByTheme(String theme) {
    return _favoriteTrips.where((trip) => 
      trip.themes.any((t) => t.toLowerCase() == theme.toLowerCase())
    ).toList();
  }

  List<SavedTrip> getFavoritesByBudgetRange(double minBudget, double maxBudget) {
    return _favoriteTrips.where((trip) => 
      trip.budget >= minBudget && trip.budget <= maxBudget
    ).toList();
  }

  Future<void> loadFavorites(String userId) async {
    // Mock loading favorites from storage
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Add some mock favorites
    final mockFavorites = [
      SavedTrip(
        id: 'fav_1',
        userId: userId,
        title: 'Goa Beach Paradise',
        destination: 'Goa',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 35)),
        budget: 25000,
        themes: ['Beach', 'Relaxation', 'Nightlife'],
        people: 2,
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: TripStatus.planning,
      ),
      SavedTrip(
        id: 'fav_2',
        userId: userId,
        title: 'Kerala Backwaters',
        destination: 'Kerala',
        startDate: DateTime.now().add(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 67)),
        budget: 35000,
        themes: ['Nature', 'Relaxation', 'Foodie'],
        people: 4,
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: TripStatus.planning,
      ),
    ];
    
    _favoriteTrips.clear();
    _favoriteTrips.addAll(mockFavorites);
    _favoritesController.add(_favoriteTrips);
  }

  Future<void> _saveFavoritesLocally() async {
    // Mock saving to local storage
    print('Saving ${_favoriteTrips.length} favorite trips');
  }

  void dispose() {
    _favoritesController.close();
  }
}