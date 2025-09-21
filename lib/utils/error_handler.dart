import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// We'll get the navigatorKey from the current context
class ErrorHandler {
  static void handleError(dynamic error, {String? context}) {
    print('Error in $context: $error');
    
    if (error is NetworkException) {
      _showNetworkError();
    } else if (error is ValidationException) {
      _showValidationError(error.message);
    } else if (error is AuthException) {
      _showAuthError(error.message);
    } else {
      _showGenericError(error.toString());
    }
  }

  static void _showNetworkError() {
    _showErrorSnackBar(
      'Network Error',
      'Please check your internet connection and try again.',
      Icons.wifi_off,
      Colors.red,
    );
  }

  static void _showValidationError(String message) {
    _showErrorSnackBar(
      'Validation Error',
      message,
      Icons.error_outline,
      Colors.orange,
    );
  }

  static void _showAuthError(String message) {
    _showErrorSnackBar(
      'Authentication Error',
      message,
      Icons.lock_outline,
      Colors.red,
    );
  }

  static void _showGenericError(String message) {
    _showErrorSnackBar(
      'Error',
      'Something went wrong. Please try again.',
      Icons.error,
      Colors.red,
    );
  }

  static void _showErrorSnackBar(String title, String message, IconData icon, Color color) {
    // Get context from the current navigator
    final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      HapticFeedback.mediumImpact();
    }
  }

  static void showSuccess(String message) {
    final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      HapticFeedback.lightImpact();
    }
  }

  static void showInfo(String message) {
    final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  static void showLoadingDialog({String message = 'Loading...'}) {
    final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0E1620),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepOrangeAccent),
              const SizedBox(width: 16),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
  }

  static void hideLoadingDialog() {
    final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (context != null) {
      Navigator.of(context).pop();
    }
  }
}



class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}