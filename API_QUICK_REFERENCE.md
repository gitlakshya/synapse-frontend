# Backend API Quick Reference

## Base URL
```
https://synapse-backend-80902795823.asia-south2.run.app
```

## Authentication Headers

### For Authenticated Users:
```
Authorization: Bearer <firebase-jwt-token>
Content-Type: application/json
```

### For Guest Users:
```
X-Session-ID: <guest-session-id>
Content-Type: application/json
```

## Quick API Calls

### 1. Create Guest Session
```dart
POST /api/v1/session
Body: {
  "type": "guest",
  "deviceId": "<uuid>"
}
Response: {
  "sessionId": "sess_xxx"
}
```

### 2. Plan Trip
```dart
POST /api/v1/plantrip
Body: {
  "destination": "Jaipur",
  "startDate": "2024-12-20",
  "endDate": "2024-12-25",
  "budget": 50000,
  "preferences": ["heritage", "food"],
  "people": 2,
  "sessionId": "sess_xxx" // For guests only
}
Response: {
  "success": true,
  "data": {
    "itinerary": {...},
    "tripId": "trip_xxx",
    "estimatedCost": 45000,
    "suggestions": [...]
  }
}
```

### 3. AI Chat
```dart
POST /api/v1/chat
Body: {
  "message": "Tell me about Jaipur",
  "context": "itinerary_planning",
  "sessionId": "sess_xxx" // For guests only
}
Response: {
  "success": true,
  "data": {
    "response": "Jaipur is...",
    "suggestions": [...],
    "followUpQuestions": [...]
  }
}
```

### 4. Smart Adjust Itinerary
```dart
POST /api/v1/smartadjust
Body: {
  "itinerary": {...},
  "adjustments": {
    "budget": "reduce",
    "pace": "relaxed"
  },
  "sessionId": "sess_xxx" // For guests only
}
Response: {
  "success": true,
  "data": {
    "adjustedItinerary": {...},
    "changes": [...]
  }
}
```

### 5. Google Authentication
```dart
POST /api/v1/auth/google
Body: {
  "idToken": "<firebase-id-token>",
  "userData": {
    "uid": "firebase-uid",
    "email": "user@example.com",
    "displayName": "John Doe",
    "photoURL": "https://..."
  },
  "sessionId": "sess_xxx" // Guest session to migrate
}
Response: {
  "success": true,
  "data": {
    "token": "<backend-jwt-token>",
    "user": {...}
  }
}
```

### 6. Save Itinerary (Auth Required)
```dart
POST /api/v1/saveItinerary
Headers: Authorization: Bearer <token>
Body: {
  "tripId": "trip_xxx",
  "itinerary": {...}
}
Response: {
  "success": true,
  "data": {
    "savedTripId": "trip_xxx"
  }
}
```

### 7. Get Saved Itineraries (Auth Required)
```dart
GET /api/v1/itineraries
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": {
    "itineraries": [...]
  }
}
```

### 8. Delete Itinerary (Auth Required)
```dart
DELETE /api/v1/itineraries/<tripId>
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": {}
}
```

## Using in Flutter Code

### Import ApiMiddleware:
```dart
import 'package:your_app/services/api_middleware.dart';
```

### Example Calls:

#### Plan a Trip:
```dart
final response = await ApiMiddleware.planTrip(
  destination: 'Jaipur',
  startDate: '2024-12-20',
  endDate: '2024-12-25',
  budget: 50000,
  preferences: ['heritage', 'food'],
  people: 2,
);

if (response['success'] == true) {
  final itinerary = response['data']['itinerary'];
  print('Itinerary: $itinerary');
} else {
  print('Error: ${response['error']}');
}
```

#### Send Chat Message:
```dart
final response = await ApiMiddleware.sendChatMessage(
  message: 'Suggest activities in Jaipur',
  context: 'itinerary_planning',
);

if (response['success']) {
  print(response['data']['response']);
}
```

#### Authenticate with Google:
```dart
// After Firebase Google Sign-In
final response = await ApiMiddleware.authenticateWithGoogle(
  idToken: googleAuth.idToken!,
  userData: {
    'uid': user.uid,
    'email': user.email,
    'displayName': user.displayName,
  },
);

if (response['success']) {
  // JWT token is automatically stored
  print('Logged in successfully');
}
```

#### Save Itinerary:
```dart
final response = await ApiMiddleware.saveItinerary(
  tripId: 'trip_123',
  itinerary: itineraryData,
);
```

#### Get Saved Trips:
```dart
final response = await ApiMiddleware.apiGet('/api/v1/itineraries');
if (response['success']) {
  final trips = response['data']['itineraries'];
}
```

## Error Handling

### Standard Response Structure:
```dart
{
  "success": bool,
  "data": dynamic,
  "error": String?,
  "statusCode": int
}
```

### Checking for Errors:
```dart
final response = await ApiMiddleware.planTrip(...);

if (response['success'] == true) {
  // Success
  final data = response['data'];
} else {
  // Error
  final errorMsg = response['error'] ?? 'Unknown error';
  final statusCode = response['statusCode'];
  print('API Error ($statusCode): $errorMsg');
}
```

### Common Status Codes:
- `200-299`: Success
- `400`: Bad request (validation error)
- `401`: Unauthorized (session/token expired)
- `404`: Not found
- `500`: Server error
- `0`: Network/timeout error

## Session Management

### Check if Authenticated:
```dart
final isAuth = await ApiMiddleware.isAuthenticated();
if (isAuth) {
  print('User is authenticated');
} else {
  print('Guest mode');
}
```

### Logout:
```dart
await ApiMiddleware.logout();
// This clears token and creates new guest session
```

## Testing with curl

### Create Guest Session:
```bash
curl -X POST https://synapse-backend-80902795823.asia-south2.run.app/api/v1/session \
  -H "Content-Type: application/json" \
  -d '{"type":"guest","deviceId":"test-device-123"}'
```

### Plan Trip (Guest):
```bash
curl -X POST https://synapse-backend-80902795823.asia-south2.run.app/api/v1/plantrip \
  -H "Content-Type: application/json" \
  -H "X-Session-ID: sess_xxx" \
  -d '{
    "destination": "Jaipur",
    "startDate": "2024-12-20",
    "endDate": "2024-12-25",
    "budget": 50000,
    "preferences": ["heritage"],
    "people": 2,
    "sessionId": "sess_xxx"
  }'
```

### Chat (Guest):
```bash
curl -X POST https://synapse-backend-80902795823.asia-south2.run.app/api/v1/chat \
  -H "Content-Type: application/json" \
  -H "X-Session-ID: sess_xxx" \
  -d '{
    "message": "Tell me about Jaipur",
    "context": "itinerary_planning",
    "sessionId": "sess_xxx"
  }'
```

### Get Itineraries (Authenticated):
```bash
curl -X GET https://synapse-backend-80902795823.asia-south2.run.app/api/v1/itineraries \
  -H "Authorization: Bearer <your-jwt-token>"
```

## Date Formatting

### Required Format: YYYY-MM-DD

```dart
import 'package:intl/intl.dart';

// Convert DateTime to API format
final dateFormat = DateFormat('yyyy-MM-dd');
final startDateStr = dateFormat.format(DateTime.now());
// Result: "2024-12-20"

// Convert API string to DateTime
final date = DateTime.parse('2024-12-20');
```

## Important Notes

1. **Session ID is auto-injected** by ApiMiddleware for guest users
2. **JWT tokens are auto-stored** by ApiMiddleware after authentication
3. **401 errors trigger auto-retry** with refreshed session/token
4. **Network timeouts** set to 30 seconds
5. **All dates must be** YYYY-MM-DD format
6. **Fallback to mock data** on network errors for graceful degradation

## Debugging

### Enable Verbose Logging:
```dart
// In api_middleware.dart
print('Request: ${method} ${endpoint}');
print('Headers: ${headers}');
print('Body: ${body}');
print('Response: ${response.statusCode} ${response.body}');
```

### Check Network Tab in Browser:
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Filter by "Fetch/XHR"
4. Look for requests to `synapse-backend`
5. Check request headers, body, and response

### Common Issues:
- **No sessionId**: Check if guest session was created
- **401 Unauthorized**: Token/session expired, check retry logic
- **CORS error**: Backend CORS configuration issue
- **Timeout**: Network slow or backend down
- **Empty response**: Backend returned no data

## Support Files

- Full Documentation: `API_INTEGRATION_ANALYSIS.md`
- Implementation Details: `BACKEND_INTEGRATION_COMPLETE.md`
- Middleware Code: `lib/services/api_middleware.dart`
