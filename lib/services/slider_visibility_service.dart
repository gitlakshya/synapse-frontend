import 'dart:async';

/// Service to control slider visibility in the customize section
class SliderVisibilityService {
  static final SliderVisibilityService _instance = SliderVisibilityService._internal();
  factory SliderVisibilityService() => _instance;
  SliderVisibilityService._internal();

  final StreamController<bool> _visibilityController = StreamController<bool>.broadcast();
  
  /// Stream to listen for slider visibility changes
  Stream<bool> get visibilityStream => _visibilityController.stream;
  
  bool _showAllSliders = true;
  
  /// Get current visibility state
  bool get showAllSliders => _showAllSliders;
  
  /// Hide all sliders except budget slider
  void hideSliders() {
    _showAllSliders = false;
    _visibilityController.add(false);
  }
  
  /// Show all sliders
  void showSliders() {
    _showAllSliders = true;
    _visibilityController.add(true);
  }
  
  /// Toggle slider visibility
  void toggleSliders() {
    _showAllSliders = !_showAllSliders;
    _visibilityController.add(_showAllSliders);
  }
  
  void dispose() {
    _visibilityController.close();
  }
}