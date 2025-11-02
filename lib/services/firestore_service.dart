import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/dummy_data.dart';
import 'api_middleware.dart';

/// Firestore Service - Handles local caching and backend synchronization
/// 
/// Dual Storage Strategy:
/// 1. Firestore: Local caching for fast access
/// 2. Backend API: Authoritative source via POST /api/v1/saveItinerary
/// 
/// Flow:
/// - Save: Send to backend first, then cache in Firestore
/// - Load: Try Firestore cache first, fallback to backend GET /api/v1/itineraries
/// - Delete: Delete from both Firestore and backend
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save trip to backend and Firestore
  /// 
  /// Backend: POST /api/v1/saveItinerary
  /// Request: {tripId, itinerary, sessionId}
  /// Response: {success, data: {savedTripId}}
  Future<void> saveTrip({
    required String userId,
    required String tripId,
    required String destination,
    required int days,
    required double budget,
    required Map<int, List<Activity>> itinerary,
    required Map<String, double> budgetBreakdown,
  }) async {
    final itineraryData = {
      'destination': destination,
      'days': days,
      'budget': budget,
      'itinerary': itinerary.map((key, value) => MapEntry(
        key.toString(),
        value.map((activity) => {
          'title': activity.title,
          'time': activity.time,
          'cost': activity.cost,
          'rating': activity.rating,
          'description': activity.description,
          'lat': activity.lat,
          'lng': activity.lng,
          'type': activity.type,
        }).toList(),
      )),
      'budgetBreakdown': budgetBreakdown,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // Save to backend first (authoritative)
      await ApiMiddleware.saveItinerary(
        tripId: tripId,
        itinerary: itineraryData,
      );
    } catch (e) {
      print('Backend save failed: $e - Saving to Firestore only');
    }

    // Cache in Firestore for fast access
    await _firestore.collection('users').doc(userId).collection('trips').doc(tripId).set({
      ...itineraryData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user trips from Firestore cache
  /// 
  /// For backend sync, use getSavedTripsFromBackend()
  Stream<QuerySnapshot> getUserTrips(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get saved trips from backend
  /// 
  /// Backend: GET /api/v1/itineraries
  /// Response: {success, data: {itineraries: []}}
  Future<List<Map<String, dynamic>>> getSavedTripsFromBackend() async {
    try {
      final response = await ApiMiddleware.apiGet('/api/v1/itineraries');
      
      if (response['success'] == true) {
        final data = response['data'];
        final itineraries = data['itineraries'] as List?;
        return itineraries?.cast<Map<String, dynamic>>() ?? [];
      }
    } catch (e) {
      print('Backend fetch failed: $e');
    }
    return [];
  }

  /// Delete trip from both Firestore and backend
  Future<void> deleteTrip(String userId, String tripId) async {
    try {
      // Delete from backend
      await ApiMiddleware.apiDelete('/api/v1/itineraries/$tripId');
    } catch (e) {
      print('Backend delete failed: $e');
    }

    // Delete from Firestore cache
    await _firestore.collection('users').doc(userId).collection('trips').doc(tripId).delete();
  }

  /// Get trip from Firestore cache
  Future<Map<String, dynamic>?> getTrip(String userId, String tripId) async {
    final doc = await _firestore.collection('users').doc(userId).collection('trips').doc(tripId).get();
    return doc.data();
  }
}
