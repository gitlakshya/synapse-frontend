/// API Middleware Usage Examples
/// 
/// This file demonstrates how to use the ApiMiddleware for various operations.
/// The middleware automatically handles authentication, guest sessions, and error handling.

import 'api_middleware.dart';

/// Example 1: Plan a trip (works for both guest and authenticated users)
Future<void> examplePlanTrip() async {
  final response = await ApiMiddleware.planTrip(
    destination: 'Goa',
    startDate: '2025-01-15',
    endDate: '2025-01-20',
    days: 6,
    budget: 50000,
    preferences: {
      'beach': 80,
      'nightlife': 70,
      'foodie': 90,
    },
    people: 2,
  );

  if (response['success']) {
    final itinerary = response['data']['itinerary'];
    print('Trip planned successfully: ${itinerary['tripId']}');
    // Use itinerary data in UI
  } else {
    print('Error: ${response['error']}');
    // Show error toast to user
  }
}

/// Example 2: Send chat message
Future<void> exampleSendChat() async {
  final response = await ApiMiddleware.sendChatMessage(
    message: 'What are the best beaches in Goa?',
    context: 'itinerary_planning',
  );

  if (response['success']) {
    final chatResponse = response['data']['response'];
    final conversationId = response['data']['conversationId'];
    print('AI Response: $chatResponse');
    // Display in chat UI
  } else {
    print('Chat error: ${response['error']}');
  }
}

/// Example 3: Google Sign-In
Future<void> exampleGoogleLogin(String firebaseIdToken, Map<String, dynamic> userData) async {
  final response = await ApiMiddleware.authenticateWithGoogle(
    idToken: firebaseIdToken,
    userData: userData,
  );

  if (response['success']) {
    final user = response['data']['user'];
    print('Logged in as: ${user['name']}');
    // Token is automatically stored, subsequent requests will use it
    // Navigate to authenticated home screen
  } else {
    print('Login failed: ${response['error']}');
  }
}

/// Example 4: Save itinerary (authenticated users only)
Future<void> exampleSaveItinerary() async {
  final response = await ApiMiddleware.saveItinerary(
    tripId: 'trip_xyz789',
    itinerary: {
      'days': [
        {'day': 1, 'activities': ['Beach visit', 'Sunset cruise']},
        {'day': 2, 'activities': ['Water sports', 'Local market']},
      ],
    },
  );

  if (response['success']) {
    final savedId = response['data']['id'];
    print('Itinerary saved: $savedId');
    // Show success message
  } else {
    print('Save failed: ${response['error']}');
  }
}

/// Example 5: Generic POST request
Future<void> exampleGenericPost() async {
  final response = await ApiMiddleware.apiPost('/api/v1/custom-endpoint', {
    'key1': 'value1',
    'key2': 123,
  });

  if (response['success']) {
    print('Success: ${response['data']}');
  } else {
    print('Error: ${response['error']} (Status: ${response['statusCode']})');
  }
}

/// Example 6: Generic GET request
Future<void> exampleGenericGet() async {
  final response = await ApiMiddleware.apiGet('/api/v1/trips/trip_xyz789');

  if (response['success']) {
    final tripData = response['data'];
    print('Trip details: $tripData');
  } else {
    print('Error: ${response['error']}');
  }
}

/// Example 7: Check authentication status
Future<void> exampleCheckAuth() async {
  final isAuth = await ApiMiddleware.isAuthenticated();
  if (isAuth) {
    print('User is logged in');
    // Show authenticated UI
  } else {
    print('User is in guest mode');
    // Show guest UI with login prompt
  }
}

/// Example 8: Logout
Future<void> exampleLogout() async {
  await ApiMiddleware.logout();
  print('Logged out, reverted to guest mode');
  // Navigate to login screen
}

/// Example 9: Error handling pattern
Future<void> exampleErrorHandling() async {
  final response = await ApiMiddleware.planTrip(
    destination: 'Invalid',
    startDate: '2025-01-15',
    endDate: '2025-01-20',
    days: 6,
    budget: 50000,
    preferences: {
      'nature': 50,
      'culture': 50,
    },
    people: 2,
  );

  // Unified response structure makes error handling consistent
  if (response['success']) {
    // Handle success
    final data = response['data'];
    print('Success: $data');
  } else {
    // Handle error based on status code
    switch (response['statusCode']) {
      case 401:
        print('Session expired: ${response['error']}');
        // Middleware already attempted refresh, show login prompt
        break;
      case 400:
        print('Invalid request: ${response['error']}');
        // Show validation error to user
        break;
      case 0:
        print('Network error: ${response['error']}');
        // Show offline message
        break;
      default:
        print('Error: ${response['error']}');
        // Show generic error
    }
  }
}

/// Example 10: Integration with Flutter UI
/// 
/// ```dart
/// class TripPlannerScreen extends StatefulWidget {
///   @override
///   _TripPlannerScreenState createState() => _TripPlannerScreenState();
/// }
/// 
/// class _TripPlannerScreenState extends State<TripPlannerScreen> {
///   bool _isLoading = false;
/// 
///   Future<void> _planTrip() async {
///     setState(() => _isLoading = true);
///     
///     final response = await ApiMiddleware.planTrip(
///       destination: _destinationController.text,
///       startDate: _startDate.toIso8601String(),
///       endDate: _endDate.toIso8601String(),
///       budget: _budget,
///       preferences: _selectedPreferences,
///       people: _peopleCount,
///     );
///     
///     setState(() => _isLoading = false);
///     
///     if (response['success']) {
///       Navigator.push(
///         context,
///         MaterialPageRoute(
///           builder: (_) => ItineraryScreen(data: response['data']),
///         ),
///       );
///     } else {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(response['error'] ?? 'Failed to plan trip')),
///       );
///     }
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: _isLoading
///           ? Center(child: CircularProgressIndicator())
///           : TripPlannerForm(onSubmit: _planTrip),
///     );
///   }
/// }
/// ```
