# 🔄 Backend API Integration Analysis
## Complete Frontend-Backend Connection Documentation
 
> **Project:** Synapse Travel Planner  
> **Backend URL:** `https://synapse-backend-80902795823.asia-south2.run.app`

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Configuration System](#configuration-system)
3. [Authentication & Session Management](#authentication--session-management)
4. [API Endpoints Mapping](#api-endpoints-mapping)
5. [Service Layer Architecture](#service-layer-architecture)
6. [Data Flow Examples](#data-flow-examples)
7. [Identified Issues & Bugs](#identified-issues--bugs)
8. [Best Practices & Recommendations](#best-practices--recommendations)
9. [Implementation Guide](#implementation-guide)

---

## 🏗️ Architecture Overview

### **Three-Layer Architecture**

```
┌─────────────────────────────────────────────┐
│          UI Layer (Widgets/Screens)          │
│  - main.dart                                 │
│  - screens/*.dart                            │
│  - widgets/*.dart                            │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│       Service Layer (Business Logic)        │
│  - api_service.dart                         │
│  - authenticated_http_client.dart           │
│  - trip_planning_api_service.dart           │
│  - chat_service.dart                        │
│  - favorites_service.dart (local only)      │
│  - user_data_service.dart                   │
│  - session_service.dart                     │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│     Backend API Layer (HTTP Requests)       │
│  - AuthenticatedHttpClient                  │
│  - Firebase Auth Service                    │
│  - Storage Service (Local)                  │
└─────────────────────────────────────────────┘
```

---

## ⚙️ Configuration System

### **1. Environment Configuration**

**File Structure:**
```
lib/config/
├── app_config.dart          # Main config (gitignored, contains actual values)
├── app_config.template.dart # Template for developers
├── env_config.dart          # Environment wrapper
├── environment.dart         # Environment detection
└── api_config.dart          # API endpoint definitions
```

**Config Flow:**
```dart
app_config.dart (actual values)
    ↓
env_config.dart (getter wrapper)
    ↓
environment.dart (environment detection)
    ↓
api_config.dart (endpoint definitions)
```

### **2. API Base URL Configuration**

**Location:** `lib/config/environment.dart`
```dart
class EnvironmentConfig {
  static String get apiBaseUrl => EnvConfig.backendUrl;
  // Returns: 'https://synapse-backend-80902795823.asia-south2.run.app'
}
```

### **3. Endpoint Definitions**

**Location:** `lib/config/api_config.dart`
```dart
class ApiConfig {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // Authentication Endpoints
  static const String googleAuthEndpoint = '/api/v1/auth/google';
  static const String profileEndpoint = '/api/v1/auth/profile';
  static const String refreshTokenEndpoint = '/api/v1/auth/refresh';
  
  // Trip Planning Endpoints
  static const String planTripEndpoint = '/api/v1/plantrip';
  static const String chatEndpoint = '/api/v1/chat';
  static const String smartAdjustEndpoint = '/api/v1/smartadjust';
  
  // Itinerary Management
  static const String itinerariesEndpoint = '/api/v1/itineraries';
  static const String saveItineraryEndpoint = '/api/v1/saveItinerary';
  static const String updateItineraryEndpoint = '/api/v1/itinerary';
  
  // Session Management
  static const String sessionEndpoint = '/api/v1/session';
}
```

---

## 🔐 Authentication & Session Management

### **Dual Authentication System**

The app supports **two modes** of operation:

#### **Mode 1: Authenticated Users (Firebase Auth)**
- Uses Firebase ID Token
- Token sent in `Authorization: Bearer <token>` header
- Persistent user data on backend
- Full access to all features

#### **Mode 2: Guest Users (Session-based)**
- Uses generated session ID
- Session ID sent in `X-Session-ID` header AND request body
- Temporary data storage (24-hour expiry)
- Limited features, can upgrade to authenticated

### **Authentication Flow Diagram**

```
User Action
    ↓
Is user authenticated?
    ├─ YES → Get Firebase ID Token
    │         ↓
    │    Add to header: Authorization: Bearer <token>
    │         ↓
    │    Make API Request
    │
    └─ NO → Check for guest session
              ↓
         Session exists?
              ├─ YES → Use existing session ID
              │         ↓
              │    Add to header: X-Session-ID: <sessionId>
              │    Add to body: { sessionId: <sessionId> }
              │         ↓
              │    Make API Request
              │
              └─ NO → Create new guest session
                        ↓
                   Call /api/v1/session to register
                        ↓
                   Store session ID locally
                        ↓
                   Use session ID for requests
```

### **Implementation: AuthenticatedHttpClient**

**Location:** `lib/services/authenticated_http_client.dart`

**Key Methods:**

```dart
class AuthenticatedHttpClient {
  // Automatic auth/session handling
  Future<http.Response> post(String url, {
    Object? body,
    bool includeAuth = true,  // Auto-handles auth
    bool forceGuest = false,  // Force guest mode
  })
  
  // Helper methods
  Future<http.Response> apiPost(String endpoint, {...})
  Future<http.Response> apiGet(String endpoint, {...})
  Future<http.Response> apiPut(String endpoint, {...})
  Future<http.Response> apiDelete(String endpoint, {...})
}
```

**How It Works:**

1. **Check Authentication:**
   ```dart
   final idToken = await _authService.getIdToken();
   if (idToken != null) {
     headers['Authorization'] = 'Bearer $idToken';
   } else {
     // Add guest session
     headers['X-Session-ID'] = sessionId;
   }
   ```

2. **Build Request Body:**
   ```dart
   if (idToken == null) {
     // Guest user - add session to body
     requestData['sessionId'] = sessionId;
     requestData['authenticated'] = false;
   }
   ```

3. **Handle Token Expiry:**
   ```dart
   if (response.statusCode == 401) {
     final newToken = await _authService.refreshIdToken();
     return retryRequest();
   }
   ```

---

## 🌐 API Endpoints Mapping

### **Complete Endpoint Reference**

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| **Authentication** |
| `/api/v1/auth/google` | POST | No | Sign in with Google |
| `/api/v1/auth/profile` | GET | Yes | Get user profile |
| `/api/v1/auth/refresh` | POST | Yes | Refresh token |
| **Trip Planning** |
| `/api/v1/plantrip` | POST | Both | Generate itinerary |
| `/api/v1/chat` | POST | Both | AI chat assistant |
| `/api/v1/smartadjust` | POST | Both | AI itinerary adjustments |
| **Itinerary Management** |
| `/api/v1/itineraries` | GET | Yes | List saved itineraries |
| `/api/v1/saveItinerary` | POST | Yes | Save itinerary |
| `/api/v1/itinerary/:id` | PUT | Both | Update itinerary |
| **Session** |
| `/api/v1/session` | POST | No | Create guest session |
| `/api/v1/session/migrate` | POST | Yes | Migrate guest to user |

### **Endpoint Details**

#### **1. Authentication Endpoints**

##### `POST /api/v1/auth/google`
**Purpose:** Sign in with Google (Firebase)  
**Auth:** None  
**Request:**
```json
{
  "idToken": "firebase_id_token",
  "userData": {
    "uid": "firebase_uid",
    "email": "user@example.com",
    "displayName": "John Doe",
    "photoURL": "https://..."
  },
  "sessionId": "session_abc123",  // For migration
  "platform": "web",
  "appVersion": "1.0.0"
}
```
**Response (200):**
```json
{
  "token": "app_jwt_token",
  "user": {
    "id": "user_db_id",
    "email": "user@example.com",
    "name": "John Doe",
    "preferences": {},
    "savedTrips": []
  }
}
```

##### `GET /api/v1/auth/profile`
**Purpose:** Get current user profile  
**Auth:** Required  
**Headers:** `Authorization: Bearer <token>`  
**Response (200):**
```json
{
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "John Doe",
    "photoURL": "https://...",
    "preferences": {
      "language": "en",
      "currency": "INR",
      "favoriteDestinations": ["Goa", "Kerala"]
    }
  }
}
```

##### `POST /api/v1/auth/refresh`
**Purpose:** Refresh expired token  
**Auth:** Required (expired token)  
**Headers:** `Authorization: Bearer <expired_token>`  
**Response (200):**
```json
{
  "token": "new_jwt_token"
}
```

---

#### **2. Trip Planning Endpoints**

##### `POST /api/v1/plantrip`
**Purpose:** Generate AI-powered trip itinerary  
**Auth:** Both (authenticated or guest)  
**Headers:** `Authorization: Bearer <token>` OR `X-Session-ID: <sessionId>`  
**Request:**
```json
{
  "destination": "Goa",
  "startDate": "2025-01-15",
  "endDate": "2025-01-20",
  "days": 6,
  "budget": 50000,
  "preferences": ["Beach", "Nightlife", "Foodie"],
  "people": 2,
  "sessionId": "session_abc123"  // Only for guests
}
```
**Response (200):**
```json
{
  "itinerary": {
    "tripId": "trip_xyz789",
    "destination": "Goa",
    "startDate": "2025-01-15",
    "endDate": "2025-01-20",
    "totalBudget": 50000,
    "days": [
      {
        "day": 1,
        "date": "2025-01-15",
        "activities": [
          {
            "time": "09:00",
            "title": "Arrive at Goa Airport",
            "description": "Check into hotel",
            "duration": "2 hours",
            "cost": 5000
          }
        ]
      }
    ]
  }
}
```

##### `POST /api/v1/chat`
**Purpose:** Chat with AI travel assistant  
**Auth:** Both  
**Request:**
```json
{
  "message": "What are the best beaches in Goa?",
  "context": {
    "destination": "Goa",
    "budget": 50000,
    "conversationHistory": ["previous message 1", "previous message 2"]
  },
  "sessionId": "session_abc123"  // Only for guests
}
```
**Response (200):**
```json
{
  "response": "Here are the best beaches in Goa...",
  "conversationId": "conv_123",
  "timestamp": "2025-01-15T10:30:00Z"
}
```

##### `POST /api/v1/smartadjust`
**Purpose:** AI-powered itinerary adjustments  
**Auth:** Both  
**Request:**
```json
{
  "itinerary": { /* current itinerary */ },
  "adjustments": {
    "type": "budget",  // or "theme", "duration"
    "newBudget": 40000,
    "reason": "Reduce overall cost"
  },
  "sessionId": "session_abc123"  // Only for guests
}
```
**Response (200):**
```json
{
  "adjustedItinerary": { /* modified itinerary */ },
  "changes": [
    "Replaced luxury hotel with mid-range option",
    "Removed expensive activity"
  ]
}
```

---

#### **3. Itinerary Management Endpoints**

##### `GET /api/v1/itineraries`
**Purpose:** Get all saved itineraries for user  
**Auth:** Required  
**Headers:** `Authorization: Bearer <token>`  
**Response (200):**
```json
{
  "itineraries": [
    {
      "id": "itin_123",
      "tripId": "trip_xyz",
      "destination": "Goa",
      "startDate": "2025-01-15",
      "status": "planned",
      "isFavorite": true,
      "createdAt": "2025-01-10T12:00:00Z"
    }
  ]
}
```

##### `POST /api/v1/saveItinerary`
**Purpose:** Save itinerary to user account  
**Auth:** Required  
**Request:**
```json
{
  "itinerary": { /* full itinerary object */ },
  "tripId": "trip_xyz789",
  "userId": "user_123"
}
```
**Response (200):**
```json
{
  "success": true,
  "id": "itin_456",
  "message": "Itinerary saved successfully"
}
```

##### `PUT /api/v1/itinerary/:id`
**Purpose:** Update existing itinerary  
**Auth:** Both  
**Request:**
```json
{
  "itinerary": { /* updated itinerary */ },
  "sessionId": "session_abc123"  // Only for guests
}
```
**Response (200):**
```json
{
  "success": true,
  "updated": { /* updated itinerary */ }
}
```

---

#### **4. Session Endpoints**

##### `POST /api/v1/session`
**Purpose:** Create guest session for anonymous users  
**Auth:** None  
**Request:**
```json
{
  "type": "guest",
  "sessionId": "session_abc123",
  "deviceId": "device_xyz",
  "timestamp": "2025-01-15T10:00:00Z"
}
```
**Response (200):**
```json
{
  "sessionId": "session_abc123",
  "expireAt": "2025-01-16T10:00:00Z"
}
```

##### `POST /api/v1/session/migrate`
**Purpose:** Migrate guest session data to authenticated user  
**Auth:** Required  
**Headers:** `Authorization: Bearer <token>`  
**Request:**
```json
{
  "guestSessionId": "session_abc123"
}
```
**Response (200):**
```json
{
  "success": true,
  "migratedItems": 3
}
```

---

## 🎯 User Flows for Revamped UI

### **Flow 1: Guest User Journey**

```
Landing Page
    ↓
User browses without signing in
    ↓
[AUTO] Create guest session → POST /api/v1/session
    ↓
User fills trip form
    ↓
Click "Generate Itinerary" → POST /api/v1/plantrip (with sessionId)
    ↓
View generated itinerary
    ↓
User asks questions → POST /api/v1/chat (with sessionId)
    ↓
Make adjustments → POST /api/v1/smartadjust (with sessionId)
    ↓
Prompt: "Sign in to save" → User clicks Sign In
    ↓
Google Sign In → POST /api/v1/auth/google (includes sessionId)
    ↓
[AUTO] Migrate guest data → POST /api/v1/session/migrate
    ↓
Save itinerary → POST /api/v1/saveItinerary
```

**UI Components:**
- **Hero Section**: Browse/explore without auth
- **Trip Form**: Capture destination, dates, budget, preferences
- **Itinerary Display**: Show generated plan
- **Chat Widget**: Floating chat button
- **Sign In Prompt**: Modal when trying to save
- **Profile Icon**: Shows auth status

---

### **Flow 2: Authenticated User Journey**

```
Landing Page
    ↓
User clicks "Sign In with Google"
    ↓
Firebase Auth → POST /api/v1/auth/google
    ↓
[AUTO] Load user data → GET /api/v1/auth/profile
    ↓
Dashboard shows:
  - Previous trips → GET /api/v1/itineraries
  - Favorites
  - Quick actions
    ↓
Create new trip
    ↓
Fill form → POST /api/v1/plantrip (with auth token)
    ↓
View & customize → POST /api/v1/chat
    ↓
Make adjustments → POST /api/v1/smartadjust
    ↓
Save → POST /api/v1/saveItinerary
    ↓
View in "My Trips" → GET /api/v1/itineraries
    ↓
Edit existing → PUT /api/v1/itinerary/:id
```

**UI Components:**
- **Sign In Button**: Prominent in hero section
- **Dashboard**: Personalized with saved trips
- **My Trips**: List view with filters
- **Trip Editor**: Inline editing
- **Profile Menu**: Access to settings, logout

---

### **Flow 3: Trip Planning (Detailed)**

```
┌─────────────────────────────────────────┐
│ 1. SEARCH & DISCOVER                    │
└─────────────────────────────────────────┘
User enters destination in search bar
    ↓
[OPTIONAL] Show suggestions/autocomplete
    ↓
User selects destination
    ↓

┌─────────────────────────────────────────┐
│ 2. CUSTOMIZE PREFERENCES                │
└─────────────────────────────────────────┘
Show customization form:
  - Date picker (start/end)
  - Budget slider
  - Theme chips (Beach, Adventure, etc.)
  - Number of travelers
    ↓
User fills and clicks "Plan My Trip"
    ↓

┌─────────────────────────────────────────┐
│ 3. GENERATE ITINERARY                   │
└─────────────────────────────────────────┘
Show loading state (120s max)
    ↓
POST /api/v1/plantrip
  - Headers: Auth token OR Session ID
  - Body: { destination, startDate, endDate, budget, preferences }
    ↓
Receive response
    ↓

┌─────────────────────────────────────────┐
│ 4. DISPLAY ITINERARY                    │
└─────────────────────────────────────────┘
Show day-by-day view:
  - Timeline layout
  - Activity cards
  - Cost breakdown
  - Map integration
    ↓
User interacts:
  - Click activity for details
  - Drag to reorder
  - Delete/edit activities
    ↓

┌─────────────────────────────────────────┐
│ 5. AI CHAT ASSISTANCE                   │
└─────────────────────────────────────────┘
User clicks chat icon
    ↓
Chat panel opens
    ↓
User asks: "Add more beach activities"
    ↓
POST /api/v1/chat
  - Body: { message, context: {itinerary}, sessionId }
    ↓
Display AI response
    ↓
Apply suggestions → POST /api/v1/smartadjust
    ↓

┌─────────────────────────────────────────┐
│ 6. SAVE & SHARE                         │
└─────────────────────────────────────────┘
User clicks "Save"
    ↓
Check auth status:
  - If guest → Show sign-in modal
  - If authenticated → Save directly
    ↓
POST /api/v1/saveItinerary
    ↓
Show success message
    ↓
[OPTIONAL] Share link, export PDF
```

---

### **Flow 4: Chat Interaction**

```
User opens chat widget
    ↓
Display chat interface:
  - Input field
  - Send button
  - Conversation history
    ↓
User types message
    ↓
Show typing indicator
    ↓
POST /api/v1/chat
  Request: {
    message: "What's the weather like?",
    context: {
      destination: "Goa",
      dates: {...},
      conversationHistory: [...]
    },
    sessionId: "..." // if guest
  }
    ↓
Receive response (45s timeout)
    ↓
Display AI response with:
  - Formatted text
  - Action buttons (if applicable)
  - "Apply Changes" button
    ↓
If user clicks "Apply Changes":
    ↓
POST /api/v1/smartadjust
  Request: {
    itinerary: {...},
    adjustments: { /* from chat context */ }
  }
    ↓
Update itinerary display
    ↓
Continue conversation
```

**Chat UI Elements:**
- Floating chat button (bottom-right)
- Slide-in panel (mobile) or sidebar (desktop)
- Message bubbles (user vs AI)
- Quick reply chips
- Loading/typing indicators

---

### **Flow 5: Favorites Management** ⚠️ (Needs Backend)

```
[AUTHENTICATED USER ONLY]

My Trips Page
    ↓
Display saved itineraries → GET /api/v1/itineraries
    ↓
User clicks star icon on trip card
    ↓
POST /api/v1/favorites  ← NEEDS IMPLEMENTATION
  Request: { tripId: "trip_123" }
    ↓
Update UI (star filled)
    ↓

Favorites Tab
    ↓
GET /api/v1/favorites  ← NEEDS IMPLEMENTATION
    ↓
Display favorited trips
    ↓
User clicks filled star
    ↓
DELETE /api/v1/favorites/:id  ← NEEDS IMPLEMENTATION
    ↓
Remove from favorites
```

**⚠️ BACKEND REQUIRED:**
- `POST /api/v1/favorites` - Add to favorites
- `GET /api/v1/favorites` - List favorites
- `DELETE /api/v1/favorites/:id` - Remove favorite

---

### **Flow 6: Profile & Settings**

```
User clicks profile icon
    ↓
Dropdown menu:
  - My Profile
  - My Trips
  - Favorites
  - Settings
  - Sign Out
    ↓

Click "My Profile"
    ↓
GET /api/v1/auth/profile
    ↓
Display:
  - Name, email, photo
  - Preferences (language, currency)
  - Account stats
    ↓
User edits preferences
    ↓
PUT /api/v1/auth/profile  ← VERIFY ENDPOINT
    ↓
Show success message
    ↓

Click "Sign Out"
    ↓
[LOCAL] Clear token
[LOCAL] Optionally create new guest session
    ↓
Redirect to landing page
```

---

### **Flow 7: Session Management (Background)**

```
App Initialization
    ↓
Check: User authenticated?
    ├─ YES: Load with auth token
    │         ↓
    │    GET /api/v1/auth/profile
    │         ↓
    │    Continue as authenticated
    │
    └─ NO: Check: Valid guest session?
              ├─ YES: Continue with session
              │
              └─ NO: Create guest session
                        ↓
                   POST /api/v1/session
                        ↓
                   Store sessionId locally
                        ↓
                   Continue as guest
                        
On User Sign In
    ↓
POST /api/v1/auth/google (include sessionId)
    ↓
Backend automatically migrates data
    ↓
POST /api/v1/session/migrate (explicit call)
    ↓
Clear guest sessionId
    ↓
Continue as authenticated

On Token Expiry (401 Response)
    ↓
POST /api/v1/auth/refresh
    ↓
Store new token
    ↓
Retry original request

Session Expiry (24 hours)
    ↓
Create new guest session
    ↓
POST /api/v1/session
```

---

## 📱 UI Screen Mapping

### **Main Screens & Their Endpoints**

| Screen | Primary Endpoints | Auth Required |
|--------|------------------|---------------|
| **Landing Page** | None | No |
| **Hero/Search** | `POST /api/v1/session` (auto) | No |
| **Customize Trip** | None (local state) | No |
| **Generated Itinerary** | `POST /api/v1/plantrip` | Both |
| **Chat Widget** | `POST /api/v1/chat` | Both |
| **Itinerary Editor** | `POST /api/v1/smartadjust`<br>`PUT /api/v1/itinerary/:id` | Both |
| **My Trips** | `GET /api/v1/itineraries` | Yes |
| **Favorites** | ⚠️ Not implemented | Yes |
| **Profile** | `GET /api/v1/auth/profile` | Yes |
| **Sign In Modal** | `POST /api/v1/auth/google` | No |

---

## 🔄 Integration Checklist

### **Phase 1: Core Flows (Essential)**
- [ ] Guest session auto-creation on app load
- [ ] Trip planning form → `POST /api/v1/plantrip`
- [ ] Display generated itinerary
- [ ] Sign in with Google → `POST /api/v1/auth/google`
- [ ] Session migration after sign-in

### **Phase 2: Enhanced Features**
- [ ] AI chat widget → `POST /api/v1/chat`
- [ ] Smart adjustments → `POST /api/v1/smartadjust`
- [ ] Save itinerary → `POST /api/v1/saveItinerary`
- [ ] Load saved trips → `GET /api/v1/itineraries`
- [ ] Edit itinerary → `PUT /api/v1/itinerary/:id`

### **Phase 3: User Management**
- [ ] Profile page → `GET /api/v1/auth/profile`
- [ ] Token refresh on 401 → `POST /api/v1/auth/refresh`
- [ ] Sign out flow

### **Phase 4: Missing Features** ⚠️
- [ ] **Favorites backend** (needs implementation)
- [ ] Booking integration (flights/hotels)
- [ ] Weather integration
- [ ] Request cancellation UI

---

## 💡 Quick Implementation Tips

### **1. Service Usage Pattern**

```dart
// Always use AuthenticatedHttpClient
final httpClient = AuthenticatedHttpClient();

// For any endpoint
final response = await httpClient.apiPost(
  '/api/v1/plantrip',
  body: tripData,
  // Auto-handles auth vs guest
);

// Check request context
final context = await httpClient.getRequestContext();
print('User type: ${context['type']}'); // 'authenticated' or 'guest'
```

### **2. Error Handling**

```dart
try {
  final response = await httpClient.apiPost(...);
  
  if (response.statusCode == 200) {
    // Success
  } else if (response.statusCode == 401) {
    // Token expired - auto-refreshed by client
  } else {
    // Show user-friendly error
  }
} on TimeoutException {
  // Show timeout message
} catch (e) {
  // Show generic error
}
```

### **3. Loading States**

```dart
// Show loading for long operations
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Generating itinerary...'),
      ],
    ),
    duration: Duration(seconds: 130),
  ),
);
```

### **4. Auth State Management**

```dart
// Check auth before protected actions
final authService = FirebaseAuthService();

if (!await authService.isAuthenticated()) {
  // Show sign-in modal
  _showSignInDialog(context);
  return;
}

// Proceed with authenticated action
```

---

**Last Updated:** January 15, 2025

---

## 🛠️ Service Layer Architecture

### **1. ApiService (Legacy/Wrapper)**

**Location:** `lib/services/api_service.dart`

**Purpose:** High-level wrapper for common API operations

**Key Methods:**

```dart
class ApiService {
  // Trip Planning
  Future<ApiResponse<Map<String, dynamic>>> planTrip(Map<String, dynamic> tripData)
  
  // Chat
  Future<ApiResponse<Map<String, dynamic>>> sendChatMessage(String message, {String? context})
  
  // Itinerary Management
  Future<ApiResponse<List<dynamic>>> getItineraries()
  Future<ApiResponse<Map<String, dynamic>>> saveItinerary(Map<String, dynamic> itinerary)
  Future<ApiResponse<Map<String, dynamic>>> updateItinerary(String id, Map<String, dynamic> itinerary)
}
```

**Data Transformation:**
```dart
Future<Map<String, dynamic>> _formatTripData(Map<String, dynamic> tripData) async {
  // 1. Convert dates to YYYY-MM-DD format
  formatted['startDate'] = '2025-01-15';
  formatted['endDate'] = '2025-01-20';
  
  // 2. Calculate number of days
  formatted['days'] = endDate.difference(startDate).inDays + 1;
  
  // 3. Rename themeIntensity to preferences
  formatted['preferences'] = formatted['themeIntensity'];
  
  // 4. Add session info for guest users
  return await _addSessionToBody(formatted);
}
```

### **2. TripPlanningApiService (Recommended)**

**Location:** `lib/services/trip_planning_api_service.dart`

**Purpose:** Example service showing best practices for API integration

**Key Features:**
- Uses `AuthenticatedHttpClient` (automatic auth handling)
- Proper error handling
- Request context logging
- Support for both authenticated and guest users

**Example Usage:**

```dart
final service = TripPlanningApiService();

// Plan a trip (works for both auth and guest)
final result = await service.planTrip(
  destination: 'Goa',
  startDate: DateTime.now().add(Duration(days: 30)),
  endDate: DateTime.now().add(Duration(days: 35)),
  budget: 50000,
  interests: ['Beach', 'Nightlife'],
);

// Chat with AI
final chatResponse = await service.chatWithAI(
  message: 'What are the best beaches in Goa?',
  conversationId: 'conv_123',
);

// Save itinerary (requires authentication)
final saved = await service.saveItinerary(
  itinerary: itineraryData,
  tripId: 'trip_123',
);
```

### **3. ChatService**

**Location:** `lib/services/chat_service.dart`

**Purpose:** Handle AI chat interactions

**Features:**
- Automatic authentication via `AuthenticatedHttpClient`
- Extended timeout (45 seconds)
- Fallback responses if backend unavailable
- Context-aware responses

**Usage:**

```dart
final chatService = ChatService.instance;

// Send message
final response = await chatService.getResponse(
  'What are the best places to visit?',
  destination: 'Kerala',
  budget: 30000,
  conversationHistory: previousMessages,
);

// Check authentication
final isAuth = await chatService.isUserAuthenticated();

// Test connection
final testResult = await chatService.testConnection();
```

### **4. UserDataService**

**Location:** `lib/services/user_data_service.dart`

**Purpose:** Manage user authentication and profile data

**Key Responsibilities:**
1. Store user details after Firebase auth
2. Validate with backend
3. Migrate guest session data
4. Sync user profile

**Authentication Flow:**

```dart
// After Firebase sign-in
final userData = {
  'uid': firebaseUser.uid,
  'email': firebaseUser.email,
  'displayName': firebaseUser.displayName,
  // ... other Firebase user data
};

// Get Firebase ID token
final idToken = await firebaseUser.getIdToken();

// Validate with backend
final backendResult = await http.post(
  '${ApiConfig.baseUrl}/api/v1/auth/google',
  body: jsonEncode({
    'idToken': idToken,
    'userData': userData,
    'sessionId': guestSessionId, // For migration
  }),
);

// Backend returns app-specific token
final appToken = backendResult['token'];

// Store token locally
await storageService.storeUserToken(appToken);

// Migrate guest data
await sessionService.migrateGuestSession(appToken);
```

### **5. SessionService**

**Location:** `lib/services/session_service.dart`

**Purpose:** Manage guest sessions and session lifecycle

**Key Methods:**

```dart
class SessionService {
  // Ensure valid session exists
  Future<String?> ensureValidSession()
  
  // Create new guest session
  Future<String?> createGuestSession()
  
  // Migrate guest session to authenticated user
  Future<bool> migrateGuestSession(String token)
  
  // Check authentication status
  Future<bool> isAuthenticated()
  
  // Clear session on logout
  Future<void> handleUserLogout({bool createGuestSession = true})
}
```

**Session Lifecycle:**

```
Guest User Starts App
    ↓
ensureValidSession() called
    ↓
Check: Is user authenticated?
    ├─ YES → Return null (no guest session needed)
    │
    └─ NO → Check: Valid session exists?
              ├─ YES → Return existing sessionId
              │
              └─ NO → Create new guest session
                        ↓
                   POST /api/v1/session
                        ↓
                   Store sessionId with expiry (24 hours)
                        ↓
                   Return sessionId

Guest User Signs In
    ↓
Firebase Authentication
    ↓
Backend Validation (/api/v1/auth/google)
    ↓
Receive app token
    ↓
migrateGuestSession(token) called
    ↓
POST /api/v1/session/migrate
    ↓
Backend merges guest data with user account
    ↓
Clear guest session locally
    ↓
Use authenticated mode
```

---

## 📊 Data Flow Examples

### **Example 1: Trip Planning (Guest User)**

```
┌──────────────────────────────────────────────────────┐
│ User fills form on Customize page                    │
│ - Destination: "Goa"                                 │
│ - Dates: Jan 15 - Jan 20, 2025                       │
│ - Budget: ₹50,000                                    │
│ - Themes: ['Beach', 'Nightlife', 'Foodie']          │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ User clicks "Generate Itinerary" button              │
│ Location: lib/main.dart line 2126                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ ApiService.instance.planTrip(tripData) called        │
│ Location: lib/services/api_service.dart              │
│                                                       │
│ tripData = {                                         │
│   destination: 'Goa',                                │
│   dates: {start: '2025-01-15', end: '2025-01-20'},  │
│   budget: 50000,                                     │
│   themeIntensity: ['Beach', 'Nightlife', 'Foodie'], │
│   people: 2                                          │
│ }                                                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ _formatTripData() transforms data                    │
│                                                       │
│ formatted = {                                        │
│   destination: 'Goa',                                │
│   startDate: '2025-01-15',  // ← Reformatted        │
│   endDate: '2025-01-20',    // ← Reformatted        │
│   days: 6,                   // ← Calculated        │
│   preferences: ['Beach', 'Nightlife', 'Foodie'],    │
│   people: 2,                                         │
│   sessionId: 'session_abc123'  // ← Added           │
│ }                                                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ HttpClient.post() called                             │
│ Location: lib/services/http_client.dart              │
│                                                       │
│ POST https://synapse-backend-...run.app/api/v1/plantrip│
│                                                       │
│ Headers:                                             │
│   Content-Type: application/json                     │
│   X-Session-ID: session_abc123                       │
│                                                       │
│ Body:                                                │
│   { ...formatted data with sessionId }              │
│                                                       │
│ Timeout: 120 seconds                                 │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ Backend processes request                            │
│ - Validates session                                  │
│ - Calls AI service (Gemini/OpenAI)                  │
│ - Generates day-by-day itinerary                    │
│ - Returns structured response                        │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ Response received (200 OK)                           │
│                                                       │
│ {                                                    │
│   itinerary: {                                       │
│     tripId: 'trip_xyz789',                          │
│     destination: 'Goa',                             │
│     days: [                                          │
│       {                                              │
│         day: 1,                                      │
│         activities: [...]                            │
│       },                                             │
│       ...                                            │
│     ]                                                │
│   }                                                  │
│ }                                                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ ApiResponse.success() created                        │
│ Location: lib/models/api_response.dart               │
│                                                       │
│ ApiResponse<Map<String, dynamic>>(                   │
│   success: true,                                     │
│   data: {...itinerary data...},                      │
│   statusCode: 200                                    │
│ )                                                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ UI updates                                           │
│ - Hide loading indicator                             │
│ - Show success message                               │
│ - Navigate to Itinerary page                         │
│ - Display generated itinerary                        │
└──────────────────────────────────────────────────────┘
```

### **Example 2: User Sign-In with Data Migration**

```
User Clicks "Sign in with Google"
    ↓
Firebase Auth Dialog Opens
    ↓
User selects Google account
    ↓
FirebaseAuthService.signInWithGoogle() called
    │
    ├─ Get Google credentials
    ├─ Sign in to Firebase
    └─ Get Firebase ID Token
        ↓
┌──────────────────────────────────────────────────────┐
│ Backend Authentication                                │
│ POST /api/v1/auth/google                             │
│                                                       │
│ Headers:                                             │
│   Content-Type: application/json                     │
│                                                       │
│ Body:                                                │
│ {                                                    │
│   idToken: '<firebase_id_token>',                   │
│   userData: {                                        │
│     uid: 'firebase_uid_123',                        │
│     email: 'user@example.com',                      │
│     displayName: 'John Doe',                        │
│     photoURL: 'https://...',                        │
│   },                                                 │
│   sessionId: 'session_abc123',  // Current guest    │
│   platform: 'web',                                   │
│   appVersion: '1.0.0'                               │
│ }                                                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ Backend validates Firebase token                     │
│ - Verifies token with Firebase Admin SDK            │
│ - Creates/updates user in database                  │
│ - Migrates guest session data                       │
│ - Generates app-specific JWT token                  │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ Backend Response (200 OK)                            │
│                                                       │
│ {                                                    │
│   token: '<app_jwt_token>',                         │
│   user: {                                            │
│     id: 'user_db_id_456',                           │
│     email: 'user@example.com',                      │
│     name: 'John Doe',                               │
│     preferences: {...},                              │
│     savedTrips: [...],  // Includes migrated data   │
│   }                                                  │
│ }                                                    │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ Frontend stores authentication data                   │
│ - StorageService.storeUserToken(token)              │
│ - StorageService.storeUserProfile(user)             │
│ - SessionService.migrateGuestSession(token)         │
│ - SessionService.clearSession()  // Clear guest     │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│ UI Updates                                           │
│ - Show success message                               │
│ - Load user favorites                                │
│ - Update profile UI                                  │
│ - All future requests use auth token                 │
└──────────────────────────────────────────────────────┘
```

---

## 🐛 Identified Issues & Bugs

### **Critical Issues**

#### **1. Favorites Service Not Connected to Backend**

**Location:** `lib/services/favorites_service.dart`

**Problem:**
- FavoritesService is **completely local** (in-memory storage)
- No API calls to backend
- Data lost on app restart
- No sync between devices
- Mock data hardcoded in `loadFavorites()` method

**Current Implementation:**
```dart
class FavoritesService {
  final List<SavedTrip> _favoriteTrips = []; // ← Local only!
  
  Future<void> addToFavorites(SavedTrip trip) async {
    _favoriteTrips.add(trip);
    await _saveFavoritesLocally(); // ← Just prints to console!
  }
  
  Future<void> _saveFavoritesLocally() async {
    print('Saving ${_favoriteTrips.length} favorite trips');
    // TODO: Actual backend integration
  }
}
```

**Expected Backend Endpoints (Missing):**
```
GET  /api/v1/favorites          - Get user's favorites
POST /api/v1/favorites          - Add to favorites
DELETE /api/v1/favorites/:id    - Remove from favorites
```

**Fix Required:**
```dart
class FavoritesService {
  final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();
  
  Future<void> addToFavorites(SavedTrip trip) async {
    // Save to backend
    final response = await _httpClient.apiPost(
      '/api/v1/favorites',
      body: {'tripId': trip.id},
    );
    
    if (response.statusCode == 200) {
      _favoriteTrips.add(trip);
      _favoritesController.add(_favoriteTrips);
    }
  }
  
  Future<void> loadFavorites(String userId) async {
    final response = await _httpClient.apiGet('/api/v1/favorites');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _favoriteTrips.clear();
      _favoriteTrips.addAll(
        (data['favorites'] as List).map((f) => SavedTrip.fromJson(f))
      );
      _favoritesController.add(_favoriteTrips);
    }
  }
}
```

#### **2. Booking Service Uses Placeholder API Keys**

**Location:** `lib/services/booking_service.dart`

**Problem:**
```dart
static const String _amadeusApiKey = 'YOUR_AMADEUS_API_KEY';  // ← Placeholder!
static const String _amadeusSecret = 'YOUR_AMADEUS_SECRET';    // ← Placeholder!
static const String _bookingApiKey = 'YOUR_BOOKING_API_KEY';  // ← Placeholder!
```

**Impact:**
- All booking API calls fail
- Falls back to mock data
- No real flight/hotel searches

**Fix Required:**
- Move API keys to backend (security best practice)
- Create proxy endpoints: `/api/v1/flights/search`, `/api/v1/hotels/search`
- Backend handles external API authentication

#### **3. Inconsistent Error Handling**

**Problem:** Different services handle errors differently

**Examples:**

**ApiService** (Good):
```dart
ApiResponse<T> _processResponse<T>(http.Response response, T Function(dynamic) fromJson) {
  switch (response.statusCode) {
    case 200:
      return ApiResponse.success(fromJson(data));
    case 401:
      return ApiResponse.error('Unauthorized');
    case 500:
      return ApiResponse.error('Server error');
    default:
      return ApiResponse.error('HTTP ${response.statusCode}');
  }
}
```

**ChatService** (Inconsistent):
```dart
if (response.statusCode == 200) {
  return responseText;
} else if (response.statusCode == 401) {
  return 'Authentication failed...';  // ← Returns string, not structured error
} else {
  return 'API Error: ${response.statusCode}...';  // ← Mixes error with data
}
```

**Fix Required:** Standardize on `ApiResponse<T>` wrapper for all services

### **Medium Priority Issues**

#### **4. Session Creation Logic Issue**

**Location:** `lib/services/session_service.dart`

**Problem:** Session creation might create duplicate sessions

**Code:**
```dart
Future<String?> ensureValidSession() async {
  if (await isAuthenticated()) {
    return null;  // ← Good: No session for auth users
  }
  
  final existingSessionId = await _storageService.getSessionId();
  if (existingSessionId != null && existingSessionId.isNotEmpty) {
    _guestSessionId = existingSessionId;
    return existingSessionId;
  }
  
  // ⚠️ ISSUE: What if getSessionId() returned expired session?
  // Storage service should handle expiry, but it's not clear if it does
  return await createGuestSession();
}
```

**Potential Bug:** If `getSessionId()` doesn't check expiry properly, expired sessions might be reused

**Fix:** Verify `StorageService.getSessionId()` checks expiry and clears expired sessions

#### **5. Missing Request Cancellation**

**Location:** `lib/services/authenticated_http_client.dart`

**Problem:** Long-running requests can't be cancelled by user

**Current State:**
- Request cancellation implemented but not exposed to UI
- User can't cancel trip planning if it takes too long
- Multiple requests might stack up

**Fix Required:**
```dart
// In UI
String? _currentRequestId;

// Start request
_currentRequestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
final response = await _httpClient.apiPost(
  '/api/v1/plantrip',
  body: data,
  requestId: _currentRequestId,
);

// Cancel button
onPressed: () {
  if (_currentRequestId != null) {
    _httpClient.cancelRequest(_currentRequestId!);
  }
}
```

### **Low Priority Issues**

#### **6. Hard-Coded Timeout Values**

**Location:** `lib/services/authenticated_http_client.dart`

**Problem:**
```dart
static const Duration _defaultTimeout = Duration(seconds: 120);
static const Duration _planTripTimeout = Duration(seconds: 120);
static const Duration _chatTimeout = Duration(seconds: 120);
```

All timeouts are 120 seconds - not configurable

**Recommendation:** Move to configuration file

#### **7. Weather Service Not Integrated**

**Location:** `lib/services/weather_service.dart`

**Problem:** Weather API key is placeholder, service exists but not called from UI

**Impact:** Weather features shown in UI don't work

---

## ✅ Best Practices & Recommendations

### **1. Always Use AuthenticatedHttpClient**

**❌ BAD:**
```dart
// DON'T do this
final response = await http.post(
  Uri.parse('${ApiConfig.baseUrl}/api/v1/plantrip'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(data),
);
```

**✅ GOOD:**
```dart
// DO this
final httpClient = AuthenticatedHttpClient();
final response = await httpClient.apiPost(
  '/api/v1/plantrip',
  body: data,
);
// Automatically handles auth, sessions, token refresh
```

### **2. Use ApiResponse Wrapper**

**❌ BAD:**
```dart
Future<Map<String, dynamic>?> getData() async {
  try {
    final response = await httpClient.apiGet('/data');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;  // ← Lost error information
  } catch (e) {
    return null;  // ← Lost error information
  }
}
```

**✅ GOOD:**
```dart
Future<ApiResponse<Map<String, dynamic>>> getData() async {
  try {
    final response = await httpClient.apiGet('/data');
    if (response.statusCode == 200) {
      return ApiResponse.success(jsonDecode(response.body));
    }
    return ApiResponse.error('Failed', statusCode: response.statusCode);
  } catch (e) {
    return ApiResponse.error(e.toString());
  }
}
```

### **3. Handle Both Auth and Guest Users**

```dart
// Service method template
Future<ApiResponse<T>> yourMethod() async {
  try {
    // AuthenticatedHttpClient handles auth automatically
    final response = await _httpClient.apiPost(
      '/api/v1/endpoint',
      body: data,
      includeAuth: true,  // Auto-detects auth vs guest
    );
    
    // Log request context for debugging
    final context = await _httpClient.getRequestContext();
    print('Request from ${context['type']} user');
    
    return _processResponse(response);
  } catch (e) {
    return ApiResponse.error(e.toString());
  }
}
```

### **4. Proper Error Messages**

**❌ BAD:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: ${e.toString()}')),
);
```

**✅ GOOD:**
```dart
String _getUserFriendlyError(dynamic error) {
  if (error is TimeoutException) {
    return 'Request timed out. Please check your internet connection.';
  } else if (error.toString().contains('SocketException')) {
    return 'Network error. Please try again.';
  } else if (error.toString().contains('401')) {
    return 'Session expired. Please sign in again.';
  }
  return 'An unexpected error occurred. Please try again.';
}

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(_getUserFriendlyError(e))),
);
```

### **5. Data Transformation Documentation**

**Example from ApiService:**

```dart
/// Transforms frontend trip data format to backend API format
///
/// Frontend Format:
/// {
///   destination: String,
///   dates: {start: String, end: String},
///   themeIntensity: List<String>,
///   people: int
/// }
///
/// Backend Format:
/// {
///   destination: String,
///   startDate: 'YYYY-MM-DD',
///   endDate: 'YYYY-MM-DD',
///   days: int,
///   preferences: List<String>,
///   people: int,
///   sessionId: String (for guests)
/// }
Future<Map<String, dynamic>> _formatTripData(Map<String, dynamic> tripData) async {
  // ... transformation logic
}
```

---

## 📖 Implementation Guide

### **Step 1: Set Up Configuration**

1. **Copy template to actual config:**
   ```bash
   cp lib/config/app_config.template.dart lib/config/app_config.dart
   ```

2. **Fill in actual values:**
   ```dart
   // lib/config/app_config.dart
   class AppConfig {
     static const String backendUrl = 'https://your-backend-url.com';
     static const String firebaseApiKey = 'your-actual-api-key';
     // ... other configs
   }
   ```

3. **Verify .gitignore:**
   ```
   lib/config/app_config.dart
   ```

### **Step 2: Initialize Services**

**In main.dart:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize API Service
  ApiService.instance.initialize();
  
  // Initialize Session Service
  await SessionService().initialize();
  
  runApp(MyApp());
}
```

### **Step 3: Create a New Service (Template)**

```dart
import 'dart:convert';
import '../config/api_config.dart';
import 'authenticated_http_client.dart';
import '../models/api_response.dart';

class YourService {
  static final YourService _instance = YourService._internal();
  factory YourService() => _instance;
  YourService._internal();

  final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();

  /// Description of what this method does
  /// 
  /// Parameters:
  /// - [param1]: Description
  /// - [param2]: Description
  /// 
  /// Returns: Description of return value
  /// 
  /// Throws: Description of exceptions
  Future<ApiResponse<YourDataType>> yourMethod({
    required String param1,
    String? param2,
  }) async {
    try {
      // Prepare request data
      final requestData = {
        'param1': param1,
        if (param2 != null) 'param2': param2,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Make API request
      final response = await _httpClient.apiPost(
        ApiConfig.yourEndpoint,
        body: requestData,
        timeout: const Duration(seconds: 30),
      );

      // Process response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Log for debugging
        final context = await _httpClient.getRequestContext();
        print('Success for ${context['type']} user');
        
        return ApiResponse.success(
          YourDataType.fromJson(data),
          statusCode: 200,
        );
      } else {
        return ApiResponse.error(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return ApiResponse.error(
        'Request timed out. Please try again.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
```

### **Step 4: Use Service in UI**

```dart
class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  final YourService _service = YourService();
  bool _isLoading = false;
  String? _error;
  YourDataType? _data;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _service.yourMethod(
      param1: 'value1',
      param2: 'value2',
    );

    setState(() {
      _isLoading = false;
      if (response.success) {
        _data = response.data;
      } else {
        _error = response.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return ErrorState(
        message: _error!,
        onRetry: _loadData,
      );
    }

    if (_data == null) {
      return ElevatedButton(
        onPressed: _loadData,
        child: const Text('Load Data'),
      );
    }

    return YourDataDisplay(data: _data!);
  }
}
```

### **Step 5: Testing Backend Integration**

**Create a test widget:**

```dart
class ApiTestWidget extends StatefulWidget {
  @override
  _ApiTestWidgetState createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  final _httpClient = AuthenticatedHttpClient();
  String _status = 'Not tested';

  Future<void> _testConnection() async {
    setState(() => _status = 'Testing...');

    try {
      // Test basic connectivity
      final response = await _httpClient.apiGet('/api/v1/health');
      
      if (response.statusCode == 200) {
        setState(() => _status = '✅ Backend connected');
      } else {
        setState(() => _status = '❌ Backend returned ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    }
  }

  Future<void> _testAuth() async {
    setState(() => _status = 'Testing auth...');

    final context = await _httpClient.getRequestContext();
    setState(() => _status = 'Mode: ${context['type']}\nID: ${context['sessionId'] ?? context['userId']}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_status),
        ElevatedButton(
          onPressed: _testConnection,
          child: const Text('Test Connection'),
        ),
        ElevatedButton(
          onPressed: _testAuth,
          child: const Text('Check Auth Status'),
        ),
      ],
    );
  }
}
```

---

## 🎯 Summary

### **What's Working Well**

✅ Dual authentication system (Firebase + Guest sessions)  
✅ Automatic auth handling via `AuthenticatedHttpClient`  
✅ Proper timeout handling for long-running requests  
✅ Token refresh on expiry (401 handling)  
✅ Session migration from guest to authenticated user  
✅ Structured error handling with `ApiResponse<T>`  
✅ Environment-based configuration system  

### **What Needs Fixing**

❌ **Favorites service** - No backend integration  
❌ **Booking service** - Placeholder API keys  
❌ **Weather service** - Not integrated in UI  
⚠️ **Error handling** - Inconsistent across services  
⚠️ **Request cancellation** - Not exposed to UI  

### **Recommended Next Steps**

1. **Implement favorites backend endpoints** (Critical)
2. **Create booking proxy endpoints** on backend (Security)
3. **Standardize error handling** across all services (Maintenance)
4. **Add request cancellation UI** for long operations (UX)
5. **Integrate weather service** in itinerary planning (Feature)
6. **Add backend health check** endpoint (Monitoring)
7. **Implement retry logic** for failed requests (Reliability)

---

## 📞 Support

For questions about this documentation or API integration:

- **Configuration Issues:** Check `lib/config/README.md`
- **Backend API:** Refer to backend API documentation
- **Authentication:** See Firebase documentation
- **GitHub Issues:** Report bugs in repository

**Last Updated:** January 15, 2025  
**Maintainer:** Synapse Development Team
