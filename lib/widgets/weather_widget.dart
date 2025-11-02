import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatelessWidget {
  final String city;
  final bool showSuggestion;

  const WeatherWidget({super.key, required this.city, this.showSuggestion = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: WeatherService().getWeather(city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final weather = snapshot.data!;
        return showSuggestion ? _buildDetailedView(weather) : _buildCompactView(weather);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Loading weather...', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('Weather unavailable', style: TextStyle(fontSize: 14, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildCompactView(Map<String, dynamic> weather) {
    return Semantics(
      label: 'Weather: ${weather['temperature']}, ${weather['condition']}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getWeatherIcon(weather['condition']), color: _getWeatherColor(weather['condition']), size: 24),
            const SizedBox(width: 8),
            Text(
              '${weather['temperature']} • ${weather['condition']}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView(Map<String, dynamic> weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getWeatherColor(weather['condition']).withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getWeatherColor(weather['condition']).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getWeatherIcon(weather['condition']), color: _getWeatherColor(weather['condition']), size: 48),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weather['temperature'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text(weather['condition'], style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather['suggestion'] ?? 'Perfect weather for exploring!',
                    style: const TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny': return Icons.wb_sunny;
      case 'clouds':
      case 'cloudy': return Icons.cloud;
      case 'rain':
      case 'rainy': return Icons.water_drop;
      default: return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny': return Colors.orange;
      case 'clouds':
      case 'cloudy': return Colors.grey;
      case 'rain':
      case 'rainy': return Colors.blue;
      default: return Colors.orange;
    }
  }
}
