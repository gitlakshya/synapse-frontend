import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/waypoint.dart';
import '../services/map_service.dart';
import '../services/weather_service.dart';
import '../config.dart';
import '../utils/image_helper.dart';

class MapWidget extends StatefulWidget {
  final List<Waypoint> waypoints;
  final double? centerLat;
  final double? centerLng;
  final String? highlightedDay;

  const MapWidget({
    super.key,
    required this.waypoints,
    this.centerLat,
    this.centerLng,
    this.highlightedDay,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  String? _selectedMarkerId;
  bool _mapError = false;
  Map<String, Map<String, dynamic>> _weatherCache = {};

  @override
  void initState() {
    super.initState();
    _loadWeatherForWaypoints();
  }

  void _loadWeatherForWaypoints() async {
    for (var waypoint in widget.waypoints) {
      final weather = await WeatherService().getWeatherByCoords(waypoint.lat, waypoint.lng, date: waypoint.date);
      if (mounted) {
        setState(() => _weatherCache[waypoint.id] = weather);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always use fallback map if API key is empty or there's an error
    if (Config.googleMapsApiKey.isEmpty || _mapError) {
      return _buildFallbackMap();
    }

    final center = LatLng(
      widget.centerLat ?? widget.waypoints.firstOrNull?.lat ?? 28.6139,
      widget.centerLng ?? widget.waypoints.firstOrNull?.lng ?? 77.2090,
    );

    return Container(
      height: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Wrap GoogleMap in error handler
            Builder(
              builder: (context) {
                try {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(target: center, zoom: 13),
                    markers: _buildMarkers(),
                    onMapCreated: (controller) {
                      if (mounted) {
                        _controller = controller;
                      }
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    onTap: (_) {
                      if (mounted) {
                        setState(() => _selectedMarkerId = null);
                      }
                    },
                  );
                } catch (e) {
                  print('Google Maps error: $e');
                  // Switch to fallback on error
                  Future.microtask(() {
                    if (mounted) {
                      setState(() => _mapError = true);
                    }
                  });
                  return _buildFallbackMap();
                }
              },
            ),
            if (_selectedMarkerId != null) _buildMarkerCard(),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return widget.waypoints.map((waypoint) {
      final isHighlighted = widget.highlightedDay != null && waypoint.day?.toString() == widget.highlightedDay;
      final color = isHighlighted
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)
          : waypoint.type == 'hotel'
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : waypoint.type == 'food'
                  ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                  : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

      return Marker(
        markerId: MarkerId(waypoint.id),
        position: LatLng(waypoint.lat, waypoint.lng),
        icon: color,
        onTap: () {
          if (mounted) {
            setState(() => _selectedMarkerId = waypoint.id);
          }
        },
      );
    }).toSet();
  }

  Widget _buildMarkerCard() {
    final waypoint = widget.waypoints.firstWhere((w) => w.id == _selectedMarkerId);
    final weather = _weatherCache[waypoint.id];

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (waypoint.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: cachedThumbnail(
                    waypoint.imageUrl!,
                    size: 80,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(waypoint.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (waypoint.rating != null) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${waypoint.rating}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 12),
                        ],
                        if (weather != null) ...[
                          Icon(_getWeatherIcon(weather['condition']), size: 16, color: _getWeatherColor(weather['condition'])),
                          const SizedBox(width: 4),
                          Text(weather['temperature'], style: const TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                    if (waypoint.cost != null)
                      Text(waypoint.cost!, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedMarkerId = null),
              ),
            ],
          ),
        ),
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

  Widget _buildFallbackMap() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: const Color(0xFFE8F4F8),
      ),
      child: Stack(
        children: [
          if (widget.waypoints.isNotEmpty)
            cachedImage(
              MapService().getStaticMapUrl(
                lat: widget.centerLat ?? widget.waypoints.first.lat,
                lng: widget.centerLng ?? widget.waypoints.first.lng,
                width: 600,
                height: 600,
              ),
              width: 600,
              height: 600,
              fit: BoxFit.cover,
            )
          else
            _buildCustomMap(),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Static Map View', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Add GOOGLE_MAPS_API_KEY', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('for interactive map', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMap() {
    return CustomPaint(
      painter: _MapPainter(widget.waypoints),
      child: const SizedBox.expand(),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _MapPainter extends CustomPainter {
  final List<Waypoint> waypoints;

  const _MapPainter(this.waypoints);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    for (int i = 1; i < 10; i++) {
      canvas.drawLine(Offset(0, size.height * i / 10), Offset(size.width, size.height * i / 10), gridPaint);
      canvas.drawLine(Offset(size.width * i / 10, 0), Offset(size.width * i / 10, size.height), gridPaint);
    }

    for (int i = 0; i < waypoints.length; i++) {
      final x = 100.0 + (i % 3) * 150;
      final y = 100.0 + (i ~/ 3) * 120;
      final color = waypoints[i].type == 'hotel'
          ? const Color(0xFF007BFF)
          : waypoints[i].type == 'restaurant'
              ? Colors.red
              : Colors.green;

      canvas.drawCircle(Offset(x, y), 20, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 20, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => oldDelegate.waypoints != waypoints;
}
