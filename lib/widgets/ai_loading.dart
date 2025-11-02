import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AILoadingWidget extends StatefulWidget {
  final String message;

  const AILoadingWidget({
    super.key,
    this.message = 'Packing your dream trip...',
  });

  @override
  State<AILoadingWidget> createState() => _AILoadingWidgetState();
}

class _AILoadingWidgetState extends State<AILoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      color: colorScheme.surface.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Try Lottie, fallback to animated plane
            SizedBox(
              width: 250,
              height: 250,
              child: _buildAnimation(colorScheme),
            ),
            const SizedBox(height: 32),
            Text(
              widget.message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This may take a few moments',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation(ColorScheme colorScheme) {
    // Try to load Lottie animation, fallback to custom animation
    try {
      return Lottie.asset(
        'assets/animations/travel_loading.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAnimation(colorScheme),
      );
    } catch (e) {
      return _buildFallbackAnimation(colorScheme);
    }
  }

  Widget _buildFallbackAnimation(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating circle
        RotationTransition(
          turns: _rotationAnimation,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: CustomPaint(
              painter: _DottedCirclePainter(colorScheme.primary),
            ),
          ),
        ),
        // Animated plane icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -10 * (1 - value)),
              child: Icon(
                Icons.flight_takeoff,
                size: 80,
                color: colorScheme.primary,
              ),
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;

  _DottedCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (math.pi / 180);
      final x = center.dx + radius * 0.9 * math.cos(angle);
      final y = center.dy + radius * 0.9 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
