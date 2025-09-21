// Disabled due to missing dependencies
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Service temporarily disabled due to missing dependencies
  
  static Future<void> initialize() async {
    // Disabled - flutter_local_notifications and timezone packages not installed
    return;
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Disabled - flutter_local_notifications package not installed
    return;
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Disabled - flutter_local_notifications package not installed
    return;
  }
}