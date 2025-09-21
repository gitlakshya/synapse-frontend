import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart' show MapMarker;

class InteractiveMapWidget extends StatefulWidget {
  final List<LatLng> routePoints;
  final Function(LatLng)? onLocationTap;
  final List<MapMarker>? markers;

  const InteractiveMapWidget({
    super.key,
    required this.routePoints,
    this.onLocationTap,
    this.markers,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  final MapController _mapController = MapController();
  int? _highlightedMarkerIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: widget.routePoints.isNotEmpty ? widget.routePoints.first : const LatLng(15.2993, 74.1240),
                zoom: 11.0,
                minZoom: 8.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) => widget.onLocationTap?.call(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.trip_planner',
                ),
                if (widget.routePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.routePoints,
                        strokeWidth: 4.0,
                        color: Colors.deepOrangeAccent,
                        isDotted: true,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
            // Map controls
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      final zoom = _mapController.zoom + 1;
                      _mapController.move(_mapController.center, zoom.clamp(8.0, 18.0));
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.add, size: 16),
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      final zoom = _mapController.zoom - 1;
                      _mapController.move(_mapController.center, zoom.clamp(8.0, 18.0));
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.remove, size: 16),
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    heroTag: 'fit_bounds',
                    onPressed: _fitBounds,
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.fit_screen, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    // Add custom markers if provided (itinerary items)
    if (widget.markers != null) {
      for (int i = 0; i < widget.markers!.length; i++) {
        final marker = widget.markers![i];
        markers.add(
          Marker(
            point: marker.position,
            child: GestureDetector(
              onTap: () {
                marker.onTap?.call();
                _showMarkerPopup(context, marker, i);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: marker.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(marker.icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      }
    }
    
    // Add route point markers (smaller, for route visualization)
    for (int i = 0; i < widget.routePoints.length; i++) {
      // Skip if we already have a custom marker at this position
      if (widget.markers != null && i < widget.markers!.length) continue;
      
      markers.add(
        Marker(
          point: widget.routePoints[i],
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _highlightedMarkerIndex == i ? Colors.red : Colors.deepOrangeAccent.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void highlightMarker(int index) {
    setState(() => _highlightedMarkerIndex = index);
    if (index < widget.routePoints.length) {
      _mapController.move(widget.routePoints[index], 15.0);
    }
  }
  
  void _showMarkerPopup(BuildContext context, MapMarker marker, int index) {
    final dayNumber = (index ~/ 3) + 1; // Assuming 3 activities per day
    final placeName = _getPlaceName(index);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(marker.icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$placeName - Day $dayNumber'),
            ),
          ],
        ),
        backgroundColor: marker.color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  String _getPlaceName(int index) {
    final placeNames = [
      'Beach Walk', 'Heritage Site', 'Local Market',
      'Temple Visit', 'Spice Garden', 'Sunset Point',
      'Fort Tour', 'Cultural Show', 'Night Market',
    ];
    return placeNames[index % placeNames.length];
  }

  void _fitBounds() {
    if (widget.routePoints.isEmpty) return;
    
    double minLat = widget.routePoints.first.latitude;
    double maxLat = widget.routePoints.first.latitude;
    double minLng = widget.routePoints.first.longitude;
    double maxLng = widget.routePoints.first.longitude;
    
    for (final point in widget.routePoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    
    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
    
    _mapController.fitBounds(bounds, options: const FitBoundsOptions(
      padding: EdgeInsets.all(50),
    ));
  }
}

