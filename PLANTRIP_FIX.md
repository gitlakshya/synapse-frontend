# Plan Trip API Fix - 422 Error Resolution ✅

## Issues Fixed

### 1. Missing `days` Field ✅
**Problem:** API expects `days` field but only `startDate` and `endDate` were sent.

**Fix Applied:** Added `days` calculation and parameter throughout the codebase.

### 2. Preferences Case Issue ✅
**Problem:** Preferences were being converted to lowercase but API expects proper case.

**Before:**
```dart
.map((entry) => entry.key.toLowerCase())  // ❌ "nature", "culture"
```

**After:**
```dart
.map((entry) => entry.key)  // ✅ "Nature", "Culture"
```

## Files Modified

### 1. `lib/screens/itinerary_setup_page.dart`
```dart
// Calculate number of days from date difference
final days = endDate.difference(startDate).inDays + 1;

// Keep original case for preferences
final selectedPreferences = _themeWeights.entries
    .where((entry) => entry.value > 0)
    .map((entry) => entry.key)  // Keep "Nature", "Culture", etc.
    .toList();

// Pass days to API
final response = await ApiMiddleware.planTrip(
  destination: widget.tripData['to'],
  startDate: startDateStr,
  endDate: endDateStr,
  days: days,  // ✅ NEW PARAMETER
  budget: budgetInt,
  preferences: selectedPreferences,
  people: _peopleCount,
);
```

### 2. `lib/services/api_middleware.dart`
```dart
// Added days as required parameter
static Future<Map<String, dynamic>> planTrip({
  required String destination,
  required String startDate,
  required String endDate,
  required int days,  // ✅ NEW PARAMETER
  required int budget,
  required List<String> preferences,
  required int people,
}) async {
  return await apiPost('/api/v1/plantrip', {
    'destination': destination,
    'startDate': startDate,
    'endDate': endDate,
    'days': days,  // ✅ NOW INCLUDED IN REQUEST
    'budget': budget,
    'preferences': preferences,
    'people': people,
  });
}
```

### 3. `lib/services/ai_service.dart`
```dart
// Added days parameter when calling ApiMiddleware.planTrip()
final response = await ApiMiddleware.planTrip(
  destination: destination,
  startDate: dateFormat.format(startDate),
  endDate: dateFormat.format(endDate),
  days: days,  // ✅ ADDED
  budget: budget.toInt(),
  preferences: themes,
  people: people,
);
```

### 4. `lib/services/gemini_service.dart`
```dart
// Calculate days from dates before calling API
final start = DateTime.parse(startDate);
final end = DateTime.parse(endDate);
final days = end.difference(start).inDays + 1;

final response = await ApiMiddleware.planTrip(
  destination: destination,
  startDate: startDate,
  endDate: endDate,
  days: days,  // ✅ ADDED
  budget: budget,
  preferences: preferences,
  people: people,
);
```

### 5. `lib/services/itinerary_service.dart`
```dart
// Added days parameter
final response = await ApiMiddleware.planTrip(
  destination: destination,
  startDate: startDateStr,
  endDate: endDateStr,
  days: days,  // ✅ ADDED
  budget: budget.toInt(),
  preferences: themes,
  people: people,
);
```

### 6. `lib/services/api_middleware_examples.dart`
```dart
// Updated both examples to include days parameter
final response = await ApiMiddleware.planTrip(
  destination: 'Goa',
  startDate: '2025-01-15',
  endDate: '2025-01-20',
  days: 6,  // ✅ ADDED
  budget: 50000,
  preferences: ['Beach', 'Nightlife', 'Foodie'],
  people: 2,
);
```

## Expected Request Format (After Fix)

### Before (422 Error):
```json
{
  "destination": "Kashmir",
  "startDate": "2025-11-02",
  "endDate": "2025-11-08",
  "budget": 80000,
  "preferences": ["nature", "nightlife", "adventure", "leisure", "culture", "food"],
  "people": 2,
  "sessionId": "sess_6f637e8ec1"
}
```

### After (Should Work):
```json
{
  "destination": "Kashmir",
  "startDate": "2025-11-02",
  "endDate": "2025-11-08",
  "days": 7,  // ✅ NOW INCLUDED
  "budget": 80000,
  "preferences": ["Nature", "Nightlife", "Adventure", "Leisure", "Culture", "Food"],  // ✅ Proper case
  "people": 2,
  "sessionId": "sess_6f637e8ec1"
}
```

## Testing Checklist

- [ ] App compiles without errors (Only test error remaining)
- [ ] Fill trip form with dates Nov 2-8, 2025 (7 days)
- [ ] Select multiple themes using sliders
- [ ] Click "Generate Itinerary"
- [ ] Verify request body in Network tab:
  - [ ] `days: 7` is present
  - [ ] `preferences` have proper case (e.g., "Nature" not "nature")
  - [ ] `destination`, `startDate`, `endDate`, `budget`, `people` all present
- [ ] Should receive 200 Success instead of 422 Error
- [ ] Itinerary should display correctly

## Potential Theme Validation Issue ⚠️

If 422 error still persists after these fixes, the backend might be validating against a specific list of allowed themes:

**UI Themes:**
- Nature ✅ (likely accepted)
- Nightlife ✅ (confirmed in docs)
- Adventure ✅ (likely accepted)
- Leisure ⚠️ (might not be recognized)
- Heritage ⚠️ (might not be recognized)
- Culture ✅ (likely accepted)
- Food ✅ (likely accepted as "Foodie" variant)
- Shopping ⚠️ (might not be recognized)
- Unexplored ⚠️ (might not be recognized)

**API Example Themes:** (from docs)
- Beach
- Nightlife
- Foodie
- Adventure
- Culture

**Solution if theme validation fails:**
1. Get exact list of allowed themes from backend team
2. Create mapping in UI: `{'Food': 'Foodie', 'Heritage': 'Culture', ...}`
3. Or update UI theme names to match backend expectations

## Debug Output

Console will now show:
```
Calling /api/v1/plantrip with:
  Destination: Kashmir
  Start: 2025-11-02, End: 2025-11-08
  Days: 7  // ✅ NEW
  Budget: 80000
  People: 2
  Preferences: [Nature, Nightlife, Adventure, Leisure, Culture, Food]  // ✅ Proper case
```

## Compilation Status

✅ **All compilation errors fixed**
- Only remaining error is in `test/widget_test.dart` (unrelated to our changes)
- All 6 files using `ApiMiddleware.planTrip()` updated with `days` parameter
- All preferences now use proper case (not lowercase)

## Status: ✅ Ready to Test

All code changes complete. Please restart the app and test the plan trip flow.

