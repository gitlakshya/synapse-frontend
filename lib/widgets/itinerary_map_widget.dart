import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/responsive.dart';

class ItineraryMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  final Function(String activityId)? onMarkerTap;
  final String? highlightedActivityId;

  const ItineraryMapWidget({
    super.key,
    required this.activities,
    this.onMarkerTap,
    this.highlightedActivityId,
  });

  @override
  State<ItineraryMapWidget> createState() => _ItineraryMapWidgetState();
}

class _ItineraryMapWidgetState extends State<ItineraryMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _center;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Delay initialization until after first frame to ensure DOM is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeMap();
      }
    });
  }

  @override
  void didUpdateWidget(ItineraryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedActivityId != oldWidget.highlightedActivityId && 
        widget.highlightedActivityId != null) {
      _centerOnActivity(widget.highlightedActivityId!);
    }
  }

  Future<void> _initializeMap() async {
    try {
      // Wait a bit more to ensure Google Maps API is loaded
      await Future.delayed(const Duration(milliseconds: 500));
      await _createMarkers();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Map initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load map';
        });
      }
    }
  }

  Future<void> _createMarkers() async {
    final markers = <Marker>{};
    double totalLat = 0;
    double totalLng = 0;
    int validCount = 0;

    for (var i = 0; i < widget.activities.length; i++) {
      final activity = widget.activities[i];
      final lat = activity['lat'] as double?;
      final lng = activity['lng'] as double?;
      
      if (lat != null && lng != null && lat != 0 && lng != 0) {
        totalLat += lat;
        totalLng += lng;
        validCount++;

        final position = LatLng(lat, lng);
        final isHighlighted = activity['id'] == widget.highlightedActivityId;
        
        markers.add(
          Marker(
            markerId: MarkerId(activity['id'] ?? 'activity_$i'),
            position: position,
            icon: isHighlighted 
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: activity['title'] ?? 'Activity',
              snippet: '₹${activity['cost'] ?? 0} • ${_formatDuration(activity['durationMins'])}',
            ),
            onTap: () {
              if (widget.onMarkerTap != null && activity['id'] != null) {
                widget.onMarkerTap!(activity['id']);
              }
            },
          ),
        );
      }
    }

    if (validCount > 0) {
      _center = LatLng(totalLat / validCount, totalLng / validCount);
    } else {
      _center = const LatLng(28.6139, 77.2090); // Default: Delhi
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    }
  }

  String _formatDuration(dynamic durationMins) {
    if (durationMins == null) return '0m';
    final mins = durationMins as int;
    final hours = mins ~/ 60;
    final remainingMins = mins % 60;
    return hours > 0 ? '${hours}h ${remainingMins}m' : '${remainingMins}m';
  }

  void _centerOnActivity(String activityId) {
    final activity = widget.activities.firstWhere(
      (a) => a['id'] == activityId,
      orElse: () => {},
    );
    
    final lat = activity['lat'] as double?;
    final lng = activity['lng'] as double?;
    
    if (lat != null && lng != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: const Color(0xFF007BFF)),
              const SizedBox(height: 16),
              Text(
                'Loading map...',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _center == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Map unavailable — please check your connection.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _center!,
          zoom: _markers.length > 1 ? 12 : 14,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
          if (isDark) {
            controller.setMapStyle(_darkMapStyle);
          }
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#181818"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3d3d3d"}]
  }
]
''';
}
