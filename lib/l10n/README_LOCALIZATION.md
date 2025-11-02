# Localization Quick Reference

## Import
```dart
import '../l10n/app_localizations.dart';
```

## Usage
```dart
// Get localization instance
final l10n = AppLocalizations.of(context);

// Use translations
Text(l10n.translate('flights'))
Text(l10n.translate('booking_confirmed'))
```

## Language Selector
```dart
// Add to any widget
import '../widgets/language_selector.dart';

const LanguageSelector()
```

## Common Translations

### Navigation
- `flights` - Flights / उड़ानें
- `hotels` - Hotels / होटल
- `my_trips` - My Trips / मेरी यात्राएं
- `ai_trip_planner` - AI Trip Planner / AI यात्रा योजनाकार

### Actions
- `generate_my_trip` - GENERATE MY TRIP / मेरी यात्रा बनाएं
- `book_now` - Book Now / अभी बुक करें
- `view_details` - View Details / विवरण देखें
- `share` - Share / साझा करें
- `save_trip` - Save Trip / यात्रा सहेजें

### Status
- `booking_confirmed` - Booking Confirmed! / बुकिंग की पुष्टि हो गई!
- `your_itinerary` - Your AI-Generated Itinerary / आपका AI-जनित यात्रा कार्यक्रम

## Adding New Translations

1. Edit `lib/l10n/app_localizations.dart`
2. Add key to both 'en' and 'hi' maps
3. Use in widgets: `l10n.translate('your_key')`

## Supported Languages
- English (en) 🇬🇧
- Hindi (hi) 🇮🇳
