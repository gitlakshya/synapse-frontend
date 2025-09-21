import 'package:flutter/material.dart';
import '../services/authenticated_http_client.dart';
import '../services/web_auth_service.dart';
import '../services/trip_planning_api_service.dart';
import '../services/session_service.dart';

/// Example demonstrating guest session management and authenticated user flow
class GuestSessionExampleWidget extends StatefulWidget {
  const GuestSessionExampleWidget({super.key});

  @override
  State<GuestSessionExampleWidget> createState() => _GuestSessionExampleWidgetState();
}

class _GuestSessionExampleWidgetState extends State<GuestSessionExampleWidget> {
  final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();
  final WebAuthService _authService = WebAuthService();
  final TripPlanningApiService _tripApi = TripPlanningApiService();
  final SessionService _sessionService = SessionService();
  
  String _status = 'Ready';
  Map<String, dynamic>? _requestContext;
  Map<String, dynamic>? _guestData;
  List<Map<String, dynamic>> _tripHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    setState(() => _status = 'Initializing session...');
    
    try {
      await _sessionService.initialize();
      await _updateRequestContext();
      setState(() => _status = 'Session initialized');
    } catch (e) {
      setState(() => _status = 'Session initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Session Management'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildRequestContextCard(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 16),
              if (_guestData != null) _buildGuestDataCard(),
              const SizedBox(height: 16),
              if (_tripHistory.isNotEmpty) _buildTripHistoryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestContextCard() {
    if (_requestContext == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request Context', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Type: ${_requestContext!['type']}'),
            if (_requestContext!['type'] == 'authenticated') ...[
              Text('User ID: ${_requestContext!['userId']}'),
              Text('Email: ${_requestContext!['email']}'),
            ] else ...[
              Text('Session ID: ${_requestContext!['sessionId']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Authentication actions
                if (_requestContext?['type'] == 'guest')
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
                if (_requestContext?['type'] == 'authenticated')
                  ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Sign Out'),
                  ),
                
                // API testing actions
                ElevatedButton(
                  onPressed: _planTripAsCurrentUser,
                  child: Text('Plan Trip (${_requestContext?['type'] ?? 'unknown'})'),
                ),
                ElevatedButton(
                  onPressed: _chatWithAI,
                  child: const Text('Chat with AI'),
                ),
                
                // Guest-specific actions
                ElevatedButton(
                  onPressed: _saveGuestData,
                  child: const Text('Save Guest Data'),
                ),
                ElevatedButton(
                  onPressed: _loadGuestData,
                  child: const Text('Load Guest Data'),
                ),
                
                // Public API actions
                ElevatedButton(
                  onPressed: _getPublicRecommendations,
                  child: const Text('Get Recommendations'),
                ),
                
                // Session management
                ElevatedButton(
                  onPressed: _refreshSession,
                  child: const Text('Refresh Session'),
                ),
                ElevatedButton(
                  onPressed: _clearGuestData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Clear Guest Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guest Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_guestData.toString(), style: const TextStyle(fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trip History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._tripHistory.map((trip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• ${trip['destination']} (${trip['type']})', style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestContext() async {
    final context = await _httpClient.getRequestContext();
    setState(() => _requestContext = context);
  }

  Future<void> _signIn() async {
    setState(() => _status = 'Signing in...');
    
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _updateRequestContext();
        setState(() => _status = 'Signed in successfully');
      } else {
        setState(() => _status = 'Sign in cancelled');
      }
    } catch (e) {
      setState(() => _status = 'Sign in error: $e');
    }
  }

  Future<void> _signOut() async {
    setState(() => _status = 'Signing out...');
    
    try {
      await _authService.signOut();
      await _updateRequestContext();
      setState(() => _status = 'Signed out - now using guest session');
    } catch (e) {
      setState(() => _status = 'Sign out error: $e');
    }
  }

  Future<void> _planTripAsCurrentUser() async {
    setState(() => _status = 'Planning trip...');
    
    try {
      final result = await _tripApi.planTrip(
        destination: 'Paris, France',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 37)),
        budget: 2500,
        interests: ['museums', 'food', 'architecture'],
      );
      
      if (result != null) {
        final userType = _requestContext?['type'] ?? 'unknown';
        _tripHistory.add({
          'destination': 'Paris, France',
          'type': userType,
          'timestamp': DateTime.now().toString(),
        });
        setState(() => _status = 'Trip planned successfully as $userType user');
      } else {
        setState(() => _status = 'Trip planning failed');
      }
    } catch (e) {
      setState(() => _status = 'Trip planning error: $e');
    }
  }

  Future<void> _chatWithAI() async {
    setState(() => _status = 'Chatting with AI...');
    
    try {
      final result = await _tripApi.chatWithAI(
        message: 'What are the best attractions in Tokyo?',
      );
      
      setState(() => _status = result != null ? 'AI chat successful' : 'AI chat failed');
    } catch (e) {
      setState(() => _status = 'AI chat error: $e');
    }
  }

  Future<void> _saveGuestData() async {
    setState(() => _status = 'Saving guest data...');
    
    try {
      final data = {
        'preferences': {
          'travelStyle': 'adventure',
          'budget': 2000,
          'interests': ['nature', 'culture', 'food'],
        },
        'searches': [
          'Best places to visit in Japan',
          'Budget travel tips for Europe',
        ],
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final success = await _tripApi.saveGuestData(data);
      setState(() => _status = success ? 'Guest data saved' : 'Failed to save guest data');
    } catch (e) {
      setState(() => _status = 'Save guest data error: $e');
    }
  }

  Future<void> _loadGuestData() async {
    setState(() => _status = 'Loading guest data...');
    
    try {
      final data = await _tripApi.getGuestData();
      setState(() {
        _guestData = data;
        _status = data != null ? 'Guest data loaded' : 'No guest data found';
      });
    } catch (e) {
      setState(() => _status = 'Load guest data error: $e');
    }
  }

  Future<void> _getPublicRecommendations() async {
    setState(() => _status = 'Getting recommendations...');
    
    try {
      final recommendations = await _tripApi.getPublicRecommendations(
        destination: 'Europe',
        travelStyle: 'cultural',
      );
      
      setState(() => _status = 'Found ${recommendations.length} recommendations');
    } catch (e) {
      setState(() => _status = 'Get recommendations error: $e');
    }
  }

  Future<void> _refreshSession() async {
    setState(() => _status = 'Refreshing session...');
    
    try {
      await _sessionService.renewSession();
      await _updateRequestContext();
      setState(() => _status = 'Session refreshed');
    } catch (e) {
      setState(() => _status = 'Refresh session error: $e');
    }
  }

  Future<void> _clearGuestData() async {
    setState(() => _status = 'Clearing guest data...');
    
    try {
      await _sessionService.clearSession();
      await _sessionService.initialize(); // Create new session
      await _updateRequestContext();
      setState(() {
        _guestData = null;
        _tripHistory.clear();
        _status = 'Guest data cleared - new session created';
      });
    } catch (e) {
      setState(() => _status = 'Clear guest data error: $e');
    }
  }
}