import 'services/slider_visibility_service.dart';

/// External controller that can be integrated later to control slider visibility
/// This file demonstrates how an external system can hide/show sliders
class ExternalSliderController {
  static final SliderVisibilityService _sliderService = SliderVisibilityService();
  
  /// Hide all sliders except the main budget slider
  static void hideAllSlidersExceptBudget() {
    _sliderService.hideSliders();
  }
  
  /// Show all sliders
  static void showAllSliders() {
    _sliderService.showSliders();
  }
  
  /// Toggle slider visibility
  static void toggleSliderVisibility() {
    _sliderService.toggleSliders();
  }
  
  /// Get current visibility state
  static bool get areSlidersVisible => _sliderService.showAllSliders;
  
  /// Example method that could be called by external integration
  /// This simulates receiving a command from an external file/system
  static void processExternalCommand(String command) {
    switch (command.toLowerCase()) {
      case 'hide_sliders':
      case 'hide_all_except_budget':
        hideAllSlidersExceptBudget();
        break;
      case 'show_sliders':
      case 'show_all':
        showAllSliders();
        break;
      case 'toggle':
        toggleSliderVisibility();
        break;
      default:
        print('Unknown command: $command');
    }
  }
}