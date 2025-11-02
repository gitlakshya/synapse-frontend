import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _localizedStrings;

  AppLocalizations(this.locale);
  
  Future<void> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      String jsonString = await rootBundle.loadString('assets/lang/en.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    }
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Supported Indian regional languages
  // Add new languages here by adding Locale('code', '')
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('hi', ''), // Hindi
    Locale('te', ''), // Telugu
    Locale('ta', ''), // Tamil
    Locale('kn', ''), // Kannada
    Locale('ml', ''), // Malayalam
    Locale('bn', ''), // Bengali
    Locale('mr', ''), // Marathi
    Locale('gu', ''), // Gujarati
    Locale('pa', ''), // Punjabi
    Locale('ur', ''), // Urdu
    Locale('as', ''), // Assamese
    Locale('or', ''), // Odia
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'EaseMyTrip AI Planner',
      'flights': 'Flights',
      'hotels': 'Hotels',
      'trains': 'Trains',
      'buses': 'Buses',
      'cabs': 'Cabs',
      'my_trips': 'My Trips',
      'ai_trip_planner': 'AI Trip Planner',
      'login_signup': 'Login / Sign Up',
      'trending_destinations': 'Top Trending Destinations',
      'explore_now': 'Explore Now',
      'view_details': 'View Details',
      'why_choose_us': 'Why Choose EaseMyTrip AI Planner',
      'personalized_trips': 'Personalized AI Trips',
      'seamless_bookings': 'Seamless Bookings',
      'smart_adjustments': 'Smart Real-Time Adjustments',
      'generate_my_trip': 'GENERATE MY TRIP',
      'booking': 'Booking',
      'book_now': 'Book Now',
      'book_trip': 'Book Trip',
      'traveler_details': 'Traveler Details',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'payment_method': 'Payment Method',
      'booking_confirmed': 'Booking Confirmed!',
      'download_pdf': 'Download Itinerary PDF',
      'back_to_home': 'Back to Home',
      'your_itinerary': 'Your AI-Generated Itinerary',
      'edit_inputs': 'Edit Inputs',
      'share': 'Share',
      'save_trip': 'Save Trip',
      'view_map': 'View Map',
      'budget_summary': 'Budget Summary',
      'total': 'Total',
      'day': 'Day',
      'language': 'Language',
      'search': 'Search',
      'from': 'From',
      'to': 'To',
      'select_city': 'Select a city',
      'select_date': 'Select date',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'trip_duration': 'Trip Duration',
      'auto_calculated': 'Auto-calculated from start date and end date',
      'days': 'days',
    },
    'hi': {
      'app_title': 'EaseMyTrip AI योजनाकार',
      'flights': 'उड़ानें',
      'hotels': 'होटल',
      'trains': 'ट्रेनें',
      'buses': 'बसें',
      'cabs': 'कैब',
      'my_trips': 'मेरी यात्राएं',
      'ai_trip_planner': 'AI यात्रा योजनाकार',
      'login_signup': 'लॉगिन / साइन अप',
      'language': 'भाषा',
      'from': 'से',
      'to': 'तक',
      'select_city': 'शहर चुनें',
      'select_date': 'तिथि चुनें',
      'start_date': 'प्रारंभ तिथि',
      'end_date': 'समाप्ति तिथि',
      'trip_duration': 'यात्रा अवधि',
      'auto_calculated': 'प्रारंभ तिथि और समाप्ति तिथि से स्वतः गणना',
      'days': 'दिन',
    },
    'te': {
      'app_title': 'EaseMyTrip AI ప్లానర్',
      'flights': 'విమానాలు',
      'hotels': 'హోటళ్ళు',
      'trains': 'రైళ్లు',
      'buses': 'బస్సులు',
      'cabs': 'క్యాబ్‌లు',
      'my_trips': 'నా ప్రయాణాలు',
      'ai_trip_planner': 'AI ట్రిప్ ప్లానర్',
      'login_signup': 'లాగిన్ / సైన్ అప్',
      'language': 'భాష',
    },
    'ta': {
      'app_title': 'EaseMyTrip AI திட்டமிடுபவர்',
      'flights': 'விமானங்கள்',
      'hotels': 'ஹோட்டல்கள்',
      'trains': 'ரயில்கள்',
      'buses': 'பேருந்துகள்',
      'cabs': 'வண்டிகள்',
      'my_trips': 'எனது பயணங்கள்',
      'ai_trip_planner': 'AI பயண திட்டமிடுபவர்',
      'login_signup': 'உள்நுழைவு / பதிவு',
      'language': 'மொழி',
    },
    'kn': {
      'app_title': 'EaseMyTrip AI ಯೋಜಕ',
      'flights': 'ವಿಮಾನಗಳು',
      'hotels': 'ಹೋಟೆಲ್‌ಗಳು',
      'trains': 'ರೈಲುಗಳು',
      'buses': 'ಬಸ್‌ಗಳು',
      'cabs': 'ಕ್ಯಾಬ್‌ಗಳು',
      'my_trips': 'ನನ್ನ ಪ್ರಯಾಣಗಳು',
      'ai_trip_planner': 'AI ಟ್ರಿಪ್ ಪ್ಲಾನರ್',
      'login_signup': 'ಲಾಗಿನ್ / ಸೈನ್ ಅಪ್',
      'language': 'ಭಾಷೆ',
    },
    'ml': {
      'app_title': 'EaseMyTrip AI ആസൂത്രകൻ',
      'flights': 'വിമാനങ്ങൾ',
      'hotels': 'ഹോട്ടലുകൾ',
      'trains': 'തീവണ്ടികൾ',
      'buses': 'ബസുകൾ',
      'cabs': 'ക്യാബുകൾ',
      'my_trips': 'എന്റെ യാത്രകൾ',
      'ai_trip_planner': 'AI ട്രിപ്പ് പ്ലാനർ',
      'login_signup': 'ലോഗിൻ / സൈൻ അപ്പ്',
      'language': 'ഭാഷ',
    },
    'bn': {
      'app_title': 'EaseMyTrip AI পরিকল্পনাকারী',
      'flights': 'ফ্লাইট',
      'hotels': 'হোটেল',
      'trains': 'ট্রেন',
      'buses': 'বাস',
      'cabs': 'ক্যাব',
      'my_trips': 'আমার ভ্রমণ',
      'ai_trip_planner': 'AI ট্রিপ প্ল্যানার',
      'login_signup': 'লগইন / সাইন আপ',
      'language': 'ভাষা',
    },
    'mr': {
      'app_title': 'EaseMyTrip AI नियोजक',
      'flights': 'उड्डाणे',
      'hotels': 'हॉटेल्स',
      'trains': 'ट्रेन्स',
      'buses': 'बसेस',
      'cabs': 'कॅब्स',
      'my_trips': 'माझे प्रवास',
      'ai_trip_planner': 'AI ट्रिप प्लॅनर',
      'login_signup': 'लॉगिन / साइन अप',
      'language': 'भाषा',
    },
    'gu': {
      'app_title': 'EaseMyTrip AI આયોજક',
      'flights': 'ફ્લાઇટ્સ',
      'hotels': 'હોટેલ્સ',
      'trains': 'ટ્રેનો',
      'buses': 'બસો',
      'cabs': 'કેબ્સ',
      'my_trips': 'મારી યાત્રાઓ',
      'ai_trip_planner': 'AI ટ્રિપ પ્લાનર',
      'login_signup': 'લોગિન / સાઇન અપ',
      'language': 'ભાષા',
    },
    'pa': {
      'app_title': 'EaseMyTrip AI ਯੋਜਨਾਕਾਰ',
      'flights': 'ਫਲਾਈਟਾਂ',
      'hotels': 'ਹੋਟਲਾਂ',
      'trains': 'ਰੇਲਗੱਡੀਆਂ',
      'buses': 'ਬੱਸਾਂ',
      'cabs': 'ਕੈਬਾਂ',
      'my_trips': 'ਮੇਰੀਆਂ ਯਾਤਰਾਵਾਂ',
      'ai_trip_planner': 'AI ਟ੍ਰਿਪ ਪਲੈਨਰ',
      'login_signup': 'ਲੌਗਇਨ / ਸਾਈਨ ਅੱਪ',
      'language': 'ਭਾਸ਼ਾ',
    },
    'ur': {
      'app_title': 'EaseMyTrip AI منصوبہ ساز',
      'flights': 'پروازیں',
      'hotels': 'ہوٹل',
      'trains': 'ٹرینیں',
      'buses': 'بسیں',
      'cabs': 'کیبیں',
      'my_trips': 'میرے سفر',
      'ai_trip_planner': 'AI ٹرپ پلانر',
      'login_signup': 'لاگ ان / سائن اپ',
      'language': 'زبان',
    },
    'as': {
      'app_title': 'EaseMyTrip AI পৰিকল্পক',
      'flights': 'বিমান',
      'hotels': 'হোটেল',
      'trains': 'ৰেল',
      'buses': 'বাছ',
      'cabs': 'কেব',
      'my_trips': 'মোৰ যাত্ৰা',
      'ai_trip_planner': 'AI ট্ৰিপ প্লেনাৰ',
      'login_signup': 'লগইন / চাইন আপ',
      'language': 'ভাষা',
    },
    'or': {
      'app_title': 'EaseMyTrip AI ଯୋଜନାକାରୀ',
      'flights': 'ବିମାନ',
      'hotels': 'ହୋଟେଲ',
      'trains': 'ଟ୍ରେନ୍',
      'buses': 'ବସ୍',
      'cabs': 'କ୍ୟାବ୍',
      'my_trips': 'ମୋର ଯାତ୍ରା',
      'ai_trip_planner': 'AI ଟ୍ରିପ୍ ପ୍ଲାନର୍',
      'login_signup': 'ଲଗଇନ୍ / ସାଇନ୍ ଅପ୍',
      'language': 'ଭାଷା',
    },
  };

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
    'en', 'hi', 'te', 'ta', 'kn', 'ml', 'bn', 'mr', 'gu', 'pa', 'ur', 'as', 'or'
  ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
