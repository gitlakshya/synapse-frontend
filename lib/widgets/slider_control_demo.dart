import 'package:flutter/material.dart';
import '../external_slider_controller.dart';

/// Demo widget to test slider visibility control
/// This can be temporarily added to any screen for testing
class SliderControlDemo extends StatelessWidget {
  const SliderControlDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Slider Control Demo',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => ExternalSliderController.hideAllSlidersExceptBudget(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hide Sliders', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: () => ExternalSliderController.showAllSliders(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Show Sliders', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: () => ExternalSliderController.toggleSliderVisibility(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Toggle', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}