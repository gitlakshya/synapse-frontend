import 'package:flutter/material.dart';

class AILoadingWidget extends StatefulWidget {
  const AILoadingWidget({super.key});

  @override
  State<AILoadingWidget> createState() => _AILoadingWidgetState();
}

class _AILoadingWidgetState extends State<AILoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _messageIndex = 0;
  
  final List<String> _messages = [
    'Analyzing your preferences...',
    'Finding best attractions...',
    'Optimizing routes...',
    'Calculating budget...',
    'Creating your perfect itinerary...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Cycle through messages
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated AI icon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 50),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          
          // Animated message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _messages[_messageIndex],
              key: ValueKey(_messageIndex),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          
          // Progress indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This may take a few seconds',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
