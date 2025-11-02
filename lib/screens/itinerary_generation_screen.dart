import 'package:flutter/material.dart';
import 'dart:async';

class ItineraryGenerationScreen extends StatefulWidget {
  const ItineraryGenerationScreen({super.key});

  @override
  State<ItineraryGenerationScreen> createState() => _ItineraryGenerationScreenState();
}

class _ItineraryGenerationScreenState extends State<ItineraryGenerationScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Analyzing your preferences...',
    'Finding best accommodations...',
    'Planning activities & experiences...',
    'Optimizing routes & transport...',
    'Checking real-time availability...',
    'Finalizing your itinerary...',
  ];

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  void _startGeneration() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/details');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 80,
                color: Color(0xFFD32F2F),
              ),
              const SizedBox(height: 30),
              const Text(
                'AI is crafting your perfect trip',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ...List.generate(_steps.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        index <= _currentStep ? Icons.check_circle : Icons.circle_outlined,
                        color: index <= _currentStep ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _steps[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: index <= _currentStep ? Colors.black : Colors.grey,
                            fontWeight: index == _currentStep ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (index == _currentStep)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
