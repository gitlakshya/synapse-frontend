import 'dart:async';
import 'dart:math';
import '../models/user_models.dart';

class PriceTrackingService {
  static final PriceTrackingService _instance = PriceTrackingService._internal();
  factory PriceTrackingService() => _instance;
  PriceTrackingService._internal();

  final List<PriceAlert> _priceAlerts = [];
  final Map<String, double> _currentPrices = {};
  final StreamController<List<PriceAlert>> _alertsController = StreamController<List<PriceAlert>>.broadcast();
  Timer? _priceUpdateTimer;

  Stream<List<PriceAlert>> get alertsStream => _alertsController.stream;
  List<PriceAlert> get priceAlerts => List.unmodifiable(_priceAlerts);

  void startPriceTracking() {
    _priceUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _updatePrices();
    });
  }

  void stopPriceTracking() {
    _priceUpdateTimer?.cancel();
  }

  Future<void> createPriceAlert(String userId, String destination, String type, double targetPrice) async {
    final currentPrice = await getCurrentPrice(destination, type);
    
    final alert = PriceAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      destination: destination,
      type: type,
      targetPrice: targetPrice,
      currentPrice: currentPrice,
      createdAt: DateTime.now(),
    );
    
    _priceAlerts.add(alert);
    _alertsController.add(_priceAlerts);
    await _savePriceAlertsLocally();
  }

  Future<void> removePriceAlert(String alertId) async {
    _priceAlerts.removeWhere((alert) => alert.id == alertId);
    _alertsController.add(_priceAlerts);
    await _savePriceAlertsLocally();
  }

  Future<double> getCurrentPrice(String destination, String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final key = '${destination}_$type';
    if (_currentPrices.containsKey(key)) {
      return _currentPrices[key]!;
    }
    
    // Generate realistic prices
    final basePrices = {
      'flight': {'goa': 8500, 'kerala': 9200, 'rajasthan': 7800, 'himachal': 8900},
      'hotel': {'goa': 3500, 'kerala': 4200, 'rajasthan': 3800, 'himachal': 4500},
      'activity': {'goa': 1200, 'kerala': 1500, 'rajasthan': 1800, 'himachal': 2000},
    };
    
    final basePrice = basePrices[type]?[destination.toLowerCase()] ?? 5000;
    final variation = Random().nextDouble() * 0.3 - 0.15; // ±15% variation
    final currentPrice = basePrice * (1 + variation);
    
    _currentPrices[key] = currentPrice;
    return currentPrice;
  }

  Future<Map<String, double>> getPriceHistory(String destination, String type, int days) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final history = <String, double>{};
    final currentPrice = await getCurrentPrice(destination, type);
    final random = Random();
    
    for (int i = days; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final variation = (random.nextDouble() - 0.5) * 0.2; // ±10% daily variation
      final price = currentPrice * (1 + variation);
      history[date.toIso8601String().split('T')[0]] = price;
    }
    
    return history;
  }

  Future<Map<String, dynamic>> getPricePrediction(String destination, String type) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final currentPrice = await getCurrentPrice(destination, type);
    final random = Random();
    
    // Mock price prediction
    final prediction = {
      'next_week': currentPrice * (0.95 + random.nextDouble() * 0.1),
      'next_month': currentPrice * (0.9 + random.nextDouble() * 0.2),
      'confidence': 0.7 + random.nextDouble() * 0.2,
      'trend': random.nextBool() ? 'increasing' : 'decreasing',
      'best_time_to_book': random.nextInt(14) + 1, // days
    };
    
    return prediction;
  }

  Future<List<Map<String, dynamic>>> getPriceComparison(String destination, String type) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final platforms = ['EaseMyTrip', 'MakeMyTrip', 'Goibibo', 'Cleartrip', 'Yatra'];
    final basePrice = await getCurrentPrice(destination, type);
    final random = Random();
    
    final comparison = platforms.map((platform) {
      final variation = (random.nextDouble() - 0.5) * 0.15; // ±7.5% variation
      final price = basePrice * (1 + variation);
      
      return {
        'platform': platform,
        'price': price,
        'rating': 4.0 + random.nextDouble(),
        'features': _getPlatformFeatures(platform),
      };
    }).toList();
    
    comparison.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    return comparison;
  }

  void _updatePrices() async {
    final updatedAlerts = <PriceAlert>[];
    bool hasUpdates = false;
    
    for (final alert in _priceAlerts) {
      if (!alert.isActive) continue;
      
      final newPrice = await getCurrentPrice(alert.destination, alert.type);
      final updatedAlert = PriceAlert(
        id: alert.id,
        userId: alert.userId,
        destination: alert.destination,
        type: alert.type,
        targetPrice: alert.targetPrice,
        currentPrice: newPrice,
        isActive: alert.isActive,
        createdAt: alert.createdAt,
      );
      
      updatedAlerts.add(updatedAlert);
      
      // Check if price dropped below target
      if (newPrice <= alert.targetPrice && alert.currentPrice > alert.targetPrice) {
        _sendPriceAlert(updatedAlert);
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      _priceAlerts.clear();
      _priceAlerts.addAll(updatedAlerts);
      _alertsController.add(_priceAlerts);
    }
  }

  void _sendPriceAlert(PriceAlert alert) {
    // Send push notification
    print('🔔 Price Alert: ${alert.destination} ${alert.type} dropped to ₹${alert.currentPrice.toInt()}!');
  }

  List<String> _getPlatformFeatures(String platform) {
    final features = {
      'EaseMyTrip': ['No Convenience Fee', 'Easy Cancellation', '24/7 Support'],
      'MakeMyTrip': ['Price Match Guarantee', 'Instant Refund', 'Premium Support'],
      'Goibibo': ['goCash Rewards', 'Free Cancellation', 'Price Calendar'],
      'Cleartrip': ['Clean Interface', 'Flexible Booking', 'Express Checkout'],
      'Yatra': ['Best Price Guarantee', 'Reward Points', 'Travel Insurance'],
    };
    
    return features[platform] ?? ['Standard Features'];
  }

  Future<void> _savePriceAlertsLocally() async {
    print('Saving ${_priceAlerts.length} price alerts');
  }

  void dispose() {
    _priceUpdateTimer?.cancel();
    _alertsController.close();
  }
}