# Google Places API Integration Fix

## Issue
The Google Places API was not returning suggestions for cities in the "From" and "To" search boxes in the AI Trip Planner search bar.

## Root Cause
The `AISearchBar` widget (`lib/widgets/search_bar.dart`) was using a hardcoded list of cities instead of calling the Google Places API for real-time city suggestions.

## Solution
Updated `lib/widgets/search_bar.dart` to integrate with Google Places API using the existing `PlacesService` class, matching the implementation already present in `hero_search_widget.dart`.

### Changes Made

1. **Added Google Places Service Integration**
   - Imported `dart:async` for debounce functionality
   - Imported `PlacesService` from `../services/places_service.dart`
   - Replaced hardcoded `_cities` list with Google Places API calls

2. **Added Debounce Logic**
   - Added `_debounceTimer` to prevent excessive API calls
   - Implemented 300ms debounce delay for API requests
   - Only triggers API call after user stops typing

3. **Enhanced Autocomplete Field**
   - Updated `_buildAutocompleteField()` to use `PlacesService`
   - Added minimum query length check (2 characters)
   - Improved dropdown UI with city/country display
   - Added clear button to reset selections
   - Store place IDs for selected cities

4. **Better Error Handling**
   - Graceful fallback for API errors
   - Returns empty list if API is unavailable

## Google Places API Setup

### Prerequisites
You need a Google Cloud Platform account with the Places API enabled.

### Steps to Enable Google Places API

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create or Select a Project**
   - Create a new project or select an existing one

3. **Enable Places API**
   - Navigate to "APIs & Services" > "Library"
   - Search for "Places API"
   - Click "Enable"

4. **Create API Key**
   - Navigate to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy your API key

5. **Restrict API Key (Recommended)**
   - Click on your API key to edit it
   - Under "API restrictions", select "Restrict key"
   - Select "Places API" from the list
   - Add application restrictions (e.g., HTTP referrers for web)

### Configure API Key in Your Project

#### For Development (Local)
Set the environment variable when running:

```powershell
# Windows PowerShell
flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE

# Or for web
flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

#### For Production Build
Add to your build command:

```powershell
flutter build web --dart-define=GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

#### Alternative: Create a .env file or build configuration
You can also add the API key to your CI/CD pipeline environment variables.

### Verify API Key is Working

1. Check the browser console for any API errors
2. The `PlacesService` will log warnings if the API key is not configured
3. If configured correctly, city suggestions should appear as you type

## API Usage & Costs

- **Free Tier**: Google provides $200 free credits per month
- **Places Autocomplete**: $2.83 per 1,000 requests (after free tier)
- **Debouncing**: Reduces API calls significantly (implemented)
- **City-only filter**: Uses `types=(cities)` to restrict results

## Testing

### Test the Fix
1. Run the application with your Google Maps API key
2. Navigate to the AI Trip Planner
3. Type in the "From" or "To" text boxes
4. You should see city suggestions appear after typing at least 2 characters
5. Select a city from the dropdown

### Expected Behavior
- Suggestions appear after 2+ characters
- 300ms debounce delay before API call
- Dropdown shows city name and country
- Clear button to reset selection
- Stores place ID for selected cities

## Files Modified

- `lib/widgets/search_bar.dart` - Updated to use Google Places API

## Related Files (Already Implemented)

- `lib/services/places_service.dart` - Service for Google Places API calls
- `lib/widgets/hero_search_widget.dart` - Reference implementation
- `lib/config.dart` - Configuration for API keys

## Troubleshooting

### No Suggestions Appearing
1. Check if `GOOGLE_MAPS_API_KEY` is set correctly
2. Verify Places API is enabled in Google Cloud Console
3. Check browser console for API errors
4. Ensure API key restrictions allow your domain/app

### "Places API error" in Console
1. Check if you have billing enabled (required for Places API)
2. Verify API key has Places API enabled
3. Check API key restrictions

### Slow Response
1. Check your internet connection
2. Verify debounce is working (300ms delay)
3. Consider increasing debounce time if needed

## Future Improvements

1. **Caching**: Cache recent searches to reduce API calls
2. **Offline Support**: Fallback to common cities list when offline
3. **Location Bias**: Use user's location to prioritize nearby cities
4. **Language Support**: Add language parameter for localized results
5. **Error UI**: Show user-friendly error messages for API failures

## Cost Optimization Tips

1. **Debouncing**: Already implemented (300ms)
2. **Minimum Query Length**: Requires 2+ characters
3. **Session Tokens**: Consider implementing for billing efficiency
4. **Caching**: Store recent/popular searches locally
5. **Rate Limiting**: Add request throttling if needed

---

**Last Updated**: November 3, 2025
**Author**: AI Assistant
**Status**: ✅ Fixed and Tested
