import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/itinerary.dart';

Future<void> shareItinerary(BuildContext context, Itinerary itinerary) async {
  final shareUrl = 'https://easemytrip.com/trip/${itinerary.id}';

  try {
    // Fallback to clipboard for web
    await Clipboard.setData(ClipboardData(text: shareUrl));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
