import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class IntegrationService {
  
  // Calendar Integration
  static Future<void> addToCalendar({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
    String? location,
  }) async {
    final startFormatted = _formatDateForCalendar(startDate);
    final endFormatted = _formatDateForCalendar(endDate);
    
    final calendarUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=${Uri.encodeComponent(title)}'
        '&dates=$startFormatted/$endFormatted'
        '&details=${Uri.encodeComponent(description)}'
        '${location != null ? '&location=${Uri.encodeComponent(location)}' : ''}';
    
    await _launchUrl(calendarUrl);
  }
  
  static String _formatDateForCalendar(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}'
           'T${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}00Z';
  }
  
  // Social Media Integration
  static Future<void> shareToSocialMedia({
    required String platform,
    required String text,
    String? imageUrl,
    String? url,
  }) async {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        await _shareToWhatsApp(text, url);
        break;
      case 'twitter':
        await _shareToTwitter(text, url);
        break;
      case 'facebook':
        await _shareToFacebook(text, url);
        break;
      case 'instagram':
        await _shareToInstagram(text, imageUrl);
        break;
      default:
        await Share.share('$text ${url ?? ''}');
    }
  }
  
  static Future<void> _shareToWhatsApp(String text, String? url) async {
    final message = Uri.encodeComponent('$text ${url ?? ''}');
    await _launchUrl('https://wa.me/?text=$message');
  }
  
  static Future<void> _shareToTwitter(String text, String? url) async {
    final tweet = Uri.encodeComponent('$text ${url ?? ''}');
    await _launchUrl('https://twitter.com/intent/tweet?text=$tweet');
  }
  
  static Future<void> _shareToFacebook(String text, String? url) async {
    final shareUrl = Uri.encodeComponent(url ?? '');
    await _launchUrl('https://www.facebook.com/sharer/sharer.php?u=$shareUrl');
  }
  
  static Future<void> _shareToInstagram(String text, String? imageUrl) async {
    // Instagram doesn't support direct sharing via URL, so we use the share sheet
    await Share.share('$text\n\nShared via AI Trip Planner');
  }
  
  // Ride-sharing Integration
  static Future<void> bookRide({
    required String service,
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? fromAddress,
    String? toAddress,
  }) async {
    switch (service.toLowerCase()) {
      case 'uber':
        await _bookUber(fromLat, fromLng, toLat, toLng);
        break;
      case 'ola':
        await _bookOla(fromLat, fromLng, toLat, toLng);
        break;
      default:
        throw Exception('Unsupported ride service: $service');
    }
  }
  
  static Future<void> _bookUber(double fromLat, double fromLng, double toLat, double toLng) async {
    final uberUrl = 'uber://?action=setPickup'
        '&pickup[latitude]=$fromLat'
        '&pickup[longitude]=$fromLng'
        '&dropoff[latitude]=$toLat'
        '&dropoff[longitude]=$toLng';
    
    final fallbackUrl = 'https://m.uber.com/ul/?action=setPickup'
        '&pickup[latitude]=$fromLat'
        '&pickup[longitude]=$fromLng'
        '&dropoff[latitude]=$toLat'
        '&dropoff[longitude]=$toLng';
    
    if (!await _launchUrl(uberUrl)) {
      await _launchUrl(fallbackUrl);
    }
  }
  
  static Future<void> _bookOla(double fromLat, double fromLng, double toLat, double toLng) async {
    final olaUrl = 'olacabs://app/launch'
        '?lat=$fromLat'
        '&lng=$fromLng'
        '&drop_lat=$toLat'
        '&drop_lng=$toLng';
    
    final fallbackUrl = 'https://book.olacabs.com/'
        '?serviceType=p2p'
        '&lat=$fromLat'
        '&lng=$fromLng'
        '&drop_lat=$toLat'
        '&drop_lng=$toLng';
    
    if (!await _launchUrl(olaUrl)) {
      await _launchUrl(fallbackUrl);
    }
  }
  
  // Food Delivery Integration
  static Future<void> orderFood({
    required String service,
    required String restaurantId,
    String? location,
  }) async {
    switch (service.toLowerCase()) {
      case 'zomato':
        await _orderFromZomato(restaurantId, location);
        break;
      case 'swiggy':
        await _orderFromSwiggy(restaurantId, location);
        break;
      default:
        throw Exception('Unsupported food service: $service');
    }
  }
  
  static Future<void> _orderFromZomato(String restaurantId, String? location) async {
    final zomatoUrl = 'zomato://restaurant/$restaurantId';
    final fallbackUrl = 'https://www.zomato.com/restaurant/$restaurantId';
    
    if (!await _launchUrl(zomatoUrl)) {
      await _launchUrl(fallbackUrl);
    }
  }
  
  static Future<void> _orderFromSwiggy(String restaurantId, String? location) async {
    final swiggyUrl = 'swiggy://restaurant/$restaurantId';
    final fallbackUrl = 'https://www.swiggy.com/restaurants/$restaurantId';
    
    if (!await _launchUrl(swiggyUrl)) {
      await _launchUrl(fallbackUrl);
    }
  }
  
  // Multi-Currency Support
  static Future<CurrencyConversion> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // Mock currency conversion - in real app, integrate with exchange rate API
    final exchangeRates = {
      'USD': {'INR': 83.12, 'EUR': 0.85, 'GBP': 0.73},
      'INR': {'USD': 0.012, 'EUR': 0.010, 'GBP': 0.009},
      'EUR': {'USD': 1.18, 'INR': 98.45, 'GBP': 0.86},
      'GBP': {'USD': 1.37, 'INR': 114.23, 'EUR': 1.16},
    };
    
    if (fromCurrency == toCurrency) {
      return CurrencyConversion(
        originalAmount: amount,
        convertedAmount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        exchangeRate: 1.0,
        lastUpdated: DateTime.now(),
      );
    }
    
    final rate = exchangeRates[fromCurrency]?[toCurrency] ?? 1.0;
    final convertedAmount = amount * rate;
    
    return CurrencyConversion(
      originalAmount: amount,
      convertedAmount: convertedAmount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      exchangeRate: rate,
      lastUpdated: DateTime.now(),
    );
  }
  
  // Accessibility Features
  static Future<void> enableAccessibilityFeatures({
    required bool screenReader,
    required bool highContrast,
    required bool largeText,
  }) async {
    // Mock accessibility settings - in real app, integrate with system settings
    print('Accessibility features enabled:');
    print('Screen Reader: $screenReader');
    print('High Contrast: $highContrast');
    print('Large Text: $largeText');
  }
  
  static Future<List<AccessibleVenue>> getAccessibleVenues({
    required double latitude,
    required double longitude,
    required List<String> accessibilityNeeds,
  }) async {
    // Mock accessible venues data
    return [
      AccessibleVenue(
        name: 'Accessible Hotel Paradise',
        address: '123 Main Street, City Center',
        latitude: latitude + 0.001,
        longitude: longitude + 0.001,
        accessibilityFeatures: [
          'Wheelchair accessible entrance',
          'Accessible bathrooms',
          'Braille signage',
          'Audio announcements',
        ],
        rating: 4.5,
        distance: 0.5,
      ),
      AccessibleVenue(
        name: 'Inclusive Restaurant',
        address: '456 Food Street, Downtown',
        latitude: latitude - 0.002,
        longitude: longitude + 0.001,
        accessibilityFeatures: [
          'Wheelchair accessible',
          'Menu in Braille',
          'Sign language support',
        ],
        rating: 4.3,
        distance: 1.2,
      ),
    ];
  }
  
  // Helper method for launching URLs
  static Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }
}

class CurrencyConversion {
  final double originalAmount;
  final double convertedAmount;
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final DateTime lastUpdated;
  
  CurrencyConversion({
    required this.originalAmount,
    required this.convertedAmount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.lastUpdated,
  });
}

class AccessibleVenue {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> accessibilityFeatures;
  final double rating;
  final double distance;
  
  AccessibleVenue({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.accessibilityFeatures,
    required this.rating,
    required this.distance,
  });
}