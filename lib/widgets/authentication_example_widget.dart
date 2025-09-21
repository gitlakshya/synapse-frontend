import 'package:flutter/material.dart';
import '../services/authenticated_http_client.dart';
import '../services/web_auth_service.dart';
import '../services/trip_planning_api_service.dart';

/// Example widget showing how to use the new ID Token-based authentication
class AuthenticationExampleWidget extends StatefulWidget {
  const AuthenticationExampleWidget({super.key});

  @override
  State<AuthenticationExampleWidget> createState() => _AuthenticationExampleWidgetState();
}

class _AuthenticationExampleWidgetState extends State<AuthenticationExampleWidget> {
  final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();
  final WebAuthService _authService = WebAuthService();
  final TripPlanningApiService _tripApi = TripPlanningApiService();
  
  String _status = 'Ready';
  String? _idToken;
  Map<String, dynamic>? _userProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Example'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            if (_idToken != null) ...[
              const Text('ID Token (first 50 chars):'),
              Text(_idToken!.substring(0, 50) + '...', style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 16),
            ],
            
            if (_userProfile != null) ...[
              const Text('User Profile:'),
              Text(_userProfile.toString(), style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 16),
            ],
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('Sign In with Google'),
                ),
                ElevatedButton(
                  onPressed: _checkToken,
                  child: const Text('Check ID Token'),
                ),
                ElevatedButton(
                  onPressed: _refreshToken,
                  child: const Text('Refresh Token'),
                ),
                ElevatedButton(
                  onPressed: _testAuthenticatedRequest,
                  child: const Text('Test Auth Request'),
                ),
                ElevatedButton(
                  onPressed: _testGuestRequest,
                  child: const Text('Test Guest Request'),
                ),
                ElevatedButton(
                  onPressed: _planTrip,
                  child: const Text('Plan Trip'),
                ),
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _status = 'Signing in...');
    
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        setState(() => _status = 'Signed in successfully: ${user.email}');
        await _checkToken();
      } else {
        setState(() => _status = 'Sign in cancelled');
      }
    } catch (e) {
      setState(() => _status = 'Sign in error: $e');
    }
  }

  Future<void> _checkToken() async {
    setState(() => _status = 'Checking token...');
    
    try {
      final token = await _authService.getIdToken();
      setState(() {
        _idToken = token;
        _status = token != null ? 'Token found' : 'No token stored';
      });
    } catch (e) {
      setState(() => _status = 'Token check error: $e');
    }
  }

  Future<void> _refreshToken() async {
    setState(() => _status = 'Refreshing token...');
    
    try {
      final newToken = await _authService.refreshIdToken();
      setState(() {
        _idToken = newToken;
        _status = newToken != null ? 'Token refreshed' : 'Failed to refresh token';
      });
    } catch (e) {
      setState(() => _status = 'Token refresh error: $e');
    }
  }

  Future<void> _testAuthenticatedRequest() async {
    setState(() => _status = 'Testing authenticated request...');
    
    try {
      // Example: Get user profile (this endpoint should be implemented in your backend)
      final response = await _httpClient.apiGet('/api/v1/auth/profile');
      
      setState(() {
        _status = 'Auth request status: ${response.statusCode}';
        if (response.statusCode == 200) {
          // Parse and display response
          _userProfile = {'response': response.body};
        }
      });
    } catch (e) {
      setState(() => _status = 'Auth request error: $e');
    }
  }

  Future<void> _testGuestRequest() async {
    setState(() => _status = 'Testing guest request...');
    
    try {
      // Example: Get public data without authentication
      final response = await _httpClient.apiGet(
        '/api/v1/public/destinations',
        includeAuth: false, // Explicitly disable auth for this request
      );
      
      setState(() => _status = 'Guest request status: ${response.statusCode}');
    } catch (e) {
      setState(() => _status = 'Guest request error: $e');
    }
  }

  Future<void> _planTrip() async {
    setState(() => _status = 'Planning trip...');
    
    try {
      final result = await _tripApi.planTrip(
        destination: 'Tokyo, Japan',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 37)),
        budget: 3000,
        interests: ['culture', 'food', 'temples'],
      );
      
      setState(() {
        _status = result != null ? 'Trip planned successfully' : 'Trip planning failed';
        if (result != null) {
          _userProfile = result;
        }
      });
    } catch (e) {
      setState(() => _status = 'Trip planning error: $e');
    }
  }

  Future<void> _signOut() async {
    setState(() => _status = 'Signing out...');
    
    try {
      await _authService.signOut();
      setState(() {
        _status = 'Signed out successfully';
        _idToken = null;
        _userProfile = null;
      });
    } catch (e) {
      setState(() => _status = 'Sign out error: $e');
    }
  }
}