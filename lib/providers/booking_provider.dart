import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingProvider extends ChangeNotifier {
  String? _bookingId;
  Map<String, dynamic>? _lastBooking;

  String? get bookingId => _bookingId;
  Map<String, dynamic>? get lastBooking => _lastBooking;

  /// Confirm booking and store in local storage (demo mode)
  /// NOTE: No real payment processing or card storage
  Future<void> confirmBooking({
    required String name,
    required String email,
    required String phone,
    required String idProof,
    required String paymentMethod,
    required String destination,
    required int days,
    required dynamic amount,
  }) async {
    _bookingId = 'EMT${DateTime.now().millisecondsSinceEpoch}';
    
    _lastBooking = {
      'bookingId': _bookingId,
      'name': name,
      'email': email,
      'phone': phone,
      'idProof': idProof, // Stored for demo only
      'paymentMethod': paymentMethod,
      'destination': destination,
      'days': days,
      'amount': amount.toString(),
      'status': 'confirmed',
      'timestamp': DateTime.now().toIso8601String(),
      // NOTE: No card details stored - only payment method type
    };

    // Store in local storage for demo
    await _saveToLocalStorage();
    
    notifyListeners();
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookings = prefs.getStringList('demo_bookings') ?? [];
      bookings.add(json.encode(_lastBooking));
      await prefs.setStringList('demo_bookings', bookings);
    } catch (e) {
      // Silently fail for demo
    }
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookings = prefs.getStringList('demo_bookings') ?? [];
      return bookings.map((b) => json.decode(b) as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  void resetBooking() {
    _bookingId = null;
    _lastBooking = null;
    notifyListeners();
  }
}
