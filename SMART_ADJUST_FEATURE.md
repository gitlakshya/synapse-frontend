# Smart Adjust Feature Implementation

## Overview
Added AI-powered Smart Adjust feature that allows users to request modifications to their generated itinerary using natural language.

## Feature Location
- **Screen**: `lib/screens/itinerary_result_page.dart`
- **API Service**: `lib/services/api_middleware.dart`
- **Backend Endpoint**: `POST /api/v1/smartadjust`

## User Flow
1. User views generated itinerary on the result page
2. User clicks **"Smart Adjust"** button (first action button)
3. Modal dialog opens with text input field
4. User enters adjustment request (20-500 characters)
5. Form validates input length
6. User clicks "Adjust Itinerary"
7. Loading dialog appears (with 60s timeout message)
8. API call to `/api/v1/smartadjust` with current itinerary + user request
9. Success: Itinerary updates on screen, changes listed in SnackBar
10. Error: Error message shown with retry option

## Implementation Details

### State Management
```dart
Map<String, dynamic>? _adjustedItinerary; // Stores adjusted itinerary
```
- When smart adjust succeeds, `_adjustedItinerary` is updated via `setState()`
- All itinerary display methods check `_adjustedItinerary ?? widget.tripConfig['itinerary']`
- User can adjust multiple times - each adjustment uses the current state

### API Integration
```dart
// Method in ApiMiddleware
static Future<Map<String, dynamic>> smartAdjust({
  required Map<String, dynamic> itinerary,
  required String userRequest,
  String? adjustmentType,
}) async
```

**Request Format**:
```json
{
  "sessionId": "guest_session_id_or_auth_token",
  "itinerary": {
    "days": [...],
    "totalCost": 50000,
    ...
  },
  "userRequest": "Add more outdoor activities"
}
```

**Response Format**:
```json
{
  "success": true,
  "data": {
    "adjustedItinerary": { ... },
    "changes": [
      "Added beach activity on Day 2",
      "Reduced budget for Day 3 dinner",
      ...
    ]
  }
}
```

### UI Components

#### Smart Adjust Button
- Icon: `Icons.auto_fix_high` (sparkle/magic wand)
- Label: "Smart Adjust"
- Position: First button in action buttons row
- Accessible via keyboard and screen readers

#### Modal Dialog
- Title: "Smart Adjust Your Itinerary"
- Hint text: "E.g., 'Add more outdoor activities' or 'Reduce accommodation budget'"
- Validation: 20-500 characters
- Error messages: Character count shown in red if invalid
- Buttons: Cancel | Adjust Itinerary

#### Loading Dialog
- Message: "AI is adjusting your itinerary..."
- Subtitle: "This may take up to 60 seconds"
- Non-dismissible (user must wait for response)

#### Success SnackBar
- Icon: Check circle (green)
- Message: "Itinerary adjusted successfully!"
- Lists all changes made by AI
- Duration: 5 seconds

#### Error Handling
- Shows error message in SnackBar
- Offers retry action
- Closes loading dialog on error
- Logs error to console

### Code Locations

#### itinerary_result_page.dart
- **Line ~31**: Added `_adjustedItinerary` state variable
- **Line ~230**: Added `_smartAdjustItinerary()` method (~200 lines)
- **Line ~555**: Added Smart Adjust button to action buttons
- **Line ~1142**: Updated `_getAllActivities()` to use adjusted itinerary
- **Line ~1225**: Updated `_buildItinerarySection()` to use adjusted itinerary
- **Line ~169**: Updated `_saveItinerary()` to save adjusted itinerary

#### api_middleware.dart
- **Line ~340**: Added `smartAdjust()` static method

## Testing Checklist
- [ ] Click Smart Adjust button opens modal
- [ ] Input validation works (min 20, max 500 chars)
- [ ] Character counter updates correctly
- [ ] Cancel button closes modal without API call
- [ ] Adjust button disabled when input invalid
- [ ] Loading dialog appears during API call
- [ ] Success updates itinerary on screen
- [ ] Changes list shows in SnackBar
- [ ] Error shows retry option
- [ ] Multiple adjustments work sequentially
- [ ] Save Trip saves the adjusted itinerary
- [ ] Maps update with adjusted activities
- [ ] Accessibility: keyboard navigation works
- [ ] Accessibility: screen reader announces changes

## Example Requests
Users can ask for various adjustments:
- "Add more outdoor activities"
- "Reduce the budget for accommodation"
- "Include vegetarian restaurants only"
- "Add a museum visit on Day 2"
- "Make the schedule less packed"
- "Focus more on local culture"
- "Remove activities after 8 PM"
- "Add shopping destinations"

## Error Scenarios
1. **Network Error**: Shows "Network error. Please check your connection." with retry
2. **Timeout**: Shows "Request timed out. Please try again." with retry
3. **Invalid Response**: Shows "Something went wrong. Please try again." with retry
4. **Empty Adjustments**: API returns success but no changes made

## Future Enhancements
- Add quick suggestion chips ("Reduce budget", "More activities", etc.)
- Show before/after comparison view
- Add undo functionality
- Animate itinerary updates
- Track adjustment history
- Allow saving multiple versions
- Add AI explanation for each change
