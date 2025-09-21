import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CollaborationService extends ChangeNotifier {
  static final CollaborationService _instance = CollaborationService._internal();
  factory CollaborationService() => _instance;
  CollaborationService._internal();

  final Map<String, TripCollaboration> _activeTrips = {};
  final StreamController<CollaborationEvent> _eventController = StreamController.broadcast();
  
  Stream<CollaborationEvent> get eventStream => _eventController.stream;

  Future<String> createCollaborativeTrip(String tripId, String creatorId) async {
    final collaboration = TripCollaboration(
      tripId: tripId,
      creatorId: creatorId,
      participants: [creatorId],
      createdAt: DateTime.now(),
    );
    
    _activeTrips[tripId] = collaboration;
    _broadcastEvent(CollaborationEvent(
      type: CollaborationEventType.tripCreated,
      tripId: tripId,
      userId: creatorId,
      timestamp: DateTime.now(),
    ));
    
    return tripId;
  }

  Future<void> joinTrip(String tripId, String userId) async {
    final trip = _activeTrips[tripId];
    if (trip != null && !trip.participants.contains(userId)) {
      trip.participants.add(userId);
      _broadcastEvent(CollaborationEvent(
        type: CollaborationEventType.userJoined,
        tripId: tripId,
        userId: userId,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<void> updateTripData(String tripId, String userId, Map<String, dynamic> data) async {
    final trip = _activeTrips[tripId];
    if (trip != null && trip.participants.contains(userId)) {
      trip.lastModified = DateTime.now();
      trip.lastModifiedBy = userId;
      
      _broadcastEvent(CollaborationEvent(
        type: CollaborationEventType.dataUpdated,
        tripId: tripId,
        userId: userId,
        data: data,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void _broadcastEvent(CollaborationEvent event) {
    _eventController.add(event);
  }

  List<String> getTripParticipants(String tripId) {
    return _activeTrips[tripId]?.participants ?? [];
  }
}

class TripCollaboration {
  final String tripId;
  final String creatorId;
  final List<String> participants;
  final DateTime createdAt;
  DateTime lastModified;
  String? lastModifiedBy;

  TripCollaboration({
    required this.tripId,
    required this.creatorId,
    required this.participants,
    required this.createdAt,
  }) : lastModified = DateTime.now();
}

class CollaborationEvent {
  final CollaborationEventType type;
  final String tripId;
  final String userId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  CollaborationEvent({
    required this.type,
    required this.tripId,
    required this.userId,
    this.data,
    required this.timestamp,
  });
}

enum CollaborationEventType {
  tripCreated,
  userJoined,
  userLeft,
  dataUpdated,
  messageAdded,
}