# CORS Fix for Google Places API - Summary

## Issue Fixed
**Problem**: Google Places API was returning CORS errors when called directly from the browser using HTTP REST API.

**Error Message**:
```
Access to fetch at 'https://maps.googleapis.com/maps/api/place/autocomplete/json...' 
from origin 'http://localhost:54183' has been blocked by CORS policy: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## Root Cause
The Google Places **REST API** doesn't allow direct calls from browsers due to CORS restrictions. Web applications must use the **Google Maps JavaScript API** instead.

## Solution Implemented

### 1. Platform-Specific Implementation
Created separate implementations for web and mobile platforms:

- **`places_service.dart`**: Main service that detects platform
- **`places_service_web.dart`**: Web implementation using JavaScript API
- **`places_service_mobile.dart`**: Mobile implementation using REST API

### 2. Google Maps JavaScript API Integration
Updated `web/index.html` to load Google Maps JavaScript API with Places library:

```html
<script>
  window.initGoogleMaps = function() {
    console.log('Google Maps API script loaded successfully');
    window.googleMapsLoaded = true;
  };
  
  function loadGoogleMapsAPI(apiKey) {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places&callback=initGoogleMaps`;
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
  }
  
  loadGoogleMapsAPI('AIzaSyDtOV162bzCWFOsjJHEs5IvRXNr0aebhLQ');
</script>
```

### 3. JavaScript Interop
Used Dart's `js` package to interact with Google Maps JavaScript API:

```dart
// Create AutocompleteService
final service = js.JsObject(
  js.context['google']['maps']['places']['AutocompleteService'],
);

// Call getPlacePredictions
service.callMethod('getPlacePredictions', [request, callback]);
```

### 4. Added js Package
Updated `pubspec.yaml`:
```yaml
dependencies:
  js: ^0.7.1
```

## How It Works Now

### Web Platform
1. Google Maps JavaScript API loads in `index.html`
2. Flutter uses `js` package to call JavaScript functions
3. `PlacesServiceWeb.getCityPredictions()` uses `AutocompleteService` from JavaScript
4. No CORS issues because JavaScript API is designed for browsers

### Mobile Platform
1. Uses REST API directly (no CORS restrictions on mobile)
2. `PlacesServiceMobile.getCityPredictions()` makes HTTP requests
3. Works the same as before

### Platform Detection
```dart
if (kIsWeb) {
  return await PlacesServiceWeb.getCityPredictions(query);
} else {
  return await PlacesServiceMobile.getCityPredictions(query);
}
```

## Data Flow to Backend

### What's Sent to `/api/v1/plantrip`
✅ **CONFIRMED**: Only the destination city name is sent, NOT the place ID.

```dart
ApiMiddleware.planTrip(
  destination: widget.tripData['to'], // ✅ Just city name (e.g., "Paris")
  startDate: startDateStr,
  endDate: endDateStr,
  days: days,
  budget: budgetInt,
  preferences: preferencesMap,
  people: _peopleCount,
  specialRequirements: additionalPrefs,
)
```

### Request Body Example
```json
{
  "destination": "Paris",
  "startDate": "2025-11-10",
  "endDate": "2025-11-15",
  "days": 5,
  "budget": 80000,
  "preferences": {
    "nature": 50,
    "nightlife": 50,
    "adventure": 50,
    "leisure": 50,
    "heritage": 50,
    "culture": 50,
    "food": 50,
    "shopping": 50,
    "unexplored": 50
  },
  "people": 2,
  "specialRequirements": ""
}
```

### Place ID Handling
- Place IDs are stored locally in widget state (`_fromPlaceId`, `_toPlaceId`)
- Place IDs are **NOT** passed to backend
- Only the city name (mainText) is passed in the `destination` field

## Files Modified

1. **lib/services/places_service.dart** - Platform detection
2. **lib/services/places_service_web.dart** - Web implementation (NEW)
3. **lib/services/places_service_mobile.dart** - Mobile implementation (NEW)
4. **web/index.html** - Google Maps JavaScript API loader
5. **pubspec.yaml** - Added `js: ^0.7.1` dependency

## Testing

### Run the Application
```powershell
.\run.bat
```

Or manually:
```powershell
flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyDtOV162bzCWFOsjJHEs5IvRXNr0aebhLQ
```

### Expected Behavior
1. ✅ No CORS errors in console
2. ✅ City suggestions appear as you type (2+ characters)
3. ✅ Dropdown shows "City, Country" format
4. ✅ Selection stores city name only
5. ✅ Backend receives only destination name (no place ID)

### Console Messages
You should see:
```
Google Maps API script loaded successfully
```

Instead of:
```
❌ Access to fetch ... has been blocked by CORS policy
```

## API Key Configuration

The Google Maps API key needs to have:
- ✅ **Places API** enabled
- ✅ **JavaScript API** restrictions (for web)
- ✅ HTTP referrer restrictions configured

Current key: `AIzaSyDtOV162bzCWFOsjJHEs5IvRXNr0aebhLQ`

## Performance

- **Debouncing**: 300ms delay before API calls
- **Minimum query**: 2 characters required
- **Async loading**: Maps API loads asynchronously
- **Fallback**: Empty results if API unavailable

## Troubleshooting

### If suggestions still don't appear:
1. Check browser console for "Google Maps API script loaded successfully"
2. Verify Places API is enabled in Google Cloud Console
3. Check API key restrictions allow your domain
4. Try hard refresh (Ctrl+Shift+R)

### If CORS errors persist:
1. Clear browser cache
2. Check that `index.html` was properly updated
3. Verify `js` package is installed (`flutter pub get`)
4. Restart the development server

## Future Improvements

1. **Dynamic API Key Loading**: Load API key from Flutter config instead of hardcoding
2. **Better Error Handling**: Show user-friendly messages for API failures
3. **Offline Fallback**: Provide common cities list when offline
4. **Caching**: Store recent searches to reduce API calls

---

**Status**: ✅ Fixed and Tested
**Date**: November 3, 2025
**Platform**: Web (with mobile support)
