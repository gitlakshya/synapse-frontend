import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class LottieAnimationWidget extends StatefulWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool reverse;
  final Duration? duration;
  final VoidCallback? onComplete;

  const LottieAnimationWidget({
    super.key,
    required this.animationPath,
    this.width,
    this.height,
    this.repeat = true,
    this.reverse = false,
    this.duration,
    this.onComplete,
  });

  @override
  State<LottieAnimationWidget> createState() => _LottieAnimationWidgetState();
}

class _LottieAnimationWidgetState extends State<LottieAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.repeat) {
      _controller.repeat(reverse: widget.reverse);
    } else {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Lottie.asset(
        widget.animationPath,
        controller: _controller,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to custom animation if Lottie fails
          return _buildFallbackAnimation();
        },
      ),
    );
  }

  Widget _buildFallbackAnimation() {
    return Container(
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrangeAccent, Colors.orange],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.flight_takeoff,
        color: Colors.white,
        size: 40,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .rotate(duration: 2000.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2));
  }
}

class PhysicsBasedAnimation extends StatefulWidget {
  final Widget child;
  final SpringDescription? spring;
  final Offset initialVelocity;
  final bool enableDrag;

  const PhysicsBasedAnimation({
    super.key,
    required this.child,
    this.spring,
    this.initialVelocity = Offset.zero,
    this.enableDrag = true,
  });

  @override
  State<PhysicsBasedAnimation> createState() => _PhysicsBasedAnimationState();
}

class _PhysicsBasedAnimationState extends State<PhysicsBasedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late SpringSimulation _simulation;
  Offset _position = Offset.zero;
  Offset _velocity = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _velocity = widget.initialVelocity;
    _startPhysicsSimulation();
  }

  void _startPhysicsSimulation() {
    final springDesc = widget.spring ?? const SpringDescription(
      mass: 1.0,
      stiffness: 100.0,
      damping: 10.0,
    );
    
    _simulation = SpringSimulation(
      springDesc,
      0.0,
      1.0,
      _velocity.distance,
    );
    
    _controller.animateWith(_simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag) return;
    
    setState(() {
      _position += details.delta;
      _velocity = details.delta;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.enableDrag) return;
    
    _velocity = details.velocity.pixelsPerSecond;
    _startPhysicsSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _position * _controller.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class MorphingShapeWidget extends StatefulWidget {
  final List<ShapeData> shapes;
  final Duration morphDuration;
  final bool autoPlay;

  const MorphingShapeWidget({
    super.key,
    required this.shapes,
    this.morphDuration = const Duration(milliseconds: 1000),
    this.autoPlay = true,
  });

  @override
  State<MorphingShapeWidget> createState() => _MorphingShapeWidgetState();
}

class _MorphingShapeWidgetState extends State<MorphingShapeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _morphAnimation;
  int _currentShapeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.morphDuration,
      vsync: this,
    );

    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoPlay && widget.shapes.length > 1) {
      _startAutoMorph();
    }
  }

  void _startAutoMorph() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentShapeIndex = (_currentShapeIndex + 1) % widget.shapes.length;
        });
        _controller.reset();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _controller.forward();
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shapes.isEmpty) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: MorphingShapePainter(
            currentShape: widget.shapes[_currentShapeIndex],
            nextShape: widget.shapes[(_currentShapeIndex + 1) % widget.shapes.length],
            progress: _morphAnimation.value,
          ),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class ShapeData {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  ShapeData({
    required this.points,
    required this.color,
    this.strokeWidth = 2.0,
  });
}

class MorphingShapePainter extends CustomPainter {
  final ShapeData currentShape;
  final ShapeData nextShape;
  final double progress;

  MorphingShapePainter({
    required this.currentShape,
    required this.nextShape,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lerpDouble(
        currentShape.strokeWidth,
        nextShape.strokeWidth,
        progress,
      ) ?? 2.0
      ..color = Color.lerp(currentShape.color, nextShape.color, progress) ?? Colors.blue;

    final path = Path();
    final morphedPoints = _morphPoints(
      currentShape.points,
      nextShape.points,
      progress,
    );

    if (morphedPoints.isNotEmpty) {
      path.moveTo(morphedPoints.first.dx, morphedPoints.first.dy);
      for (int i = 1; i < morphedPoints.length; i++) {
        path.lineTo(morphedPoints[i].dx, morphedPoints[i].dy);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  List<Offset> _morphPoints(List<Offset> from, List<Offset> to, double t) {
    final maxLength = math.max(from.length, to.length);
    final morphed = <Offset>[];

    for (int i = 0; i < maxLength; i++) {
      final fromPoint = i < from.length ? from[i] : from.last;
      final toPoint = i < to.length ? to[i] : to.last;
      
      morphed.add(Offset.lerp(fromPoint, toPoint, t) ?? Offset.zero);
    }

    return morphed;
  }

  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AdvancedParticleSystem extends StatefulWidget {
  final int particleCount;
  final ParticleType type;
  final Color baseColor;
  final Size emissionArea;
  final Duration lifetime;

  const AdvancedParticleSystem({
    super.key,
    this.particleCount = 50,
    this.type = ParticleType.sparkle,
    this.baseColor = Colors.deepOrangeAccent,
    this.emissionArea = const Size(300, 300),
    this.lifetime = const Duration(seconds: 5),
  });

  @override
  State<AdvancedParticleSystem> createState() => _AdvancedParticleSystemState();
}

enum ParticleType { sparkle, smoke, fire, confetti }

class _AdvancedParticleSystemState extends State<AdvancedParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<AdvancedParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.lifetime,
      vsync: this,
    )..repeat();

    _initializeParticles();
  }

  void _initializeParticles() {
    _particles = List.generate(
      widget.particleCount,
      (index) => AdvancedParticle(
        type: widget.type,
        baseColor: widget.baseColor,
        emissionArea: widget.emissionArea,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AdvancedParticlePainter(
            particles: _particles,
            animation: _controller,
          ),
          size: widget.emissionArea,
        );
      },
    );
  }
}

class AdvancedParticle {
  late double x, y;
  late double vx, vy;
  late double life, maxLife;
  late double size;
  late Color color;
  late double rotation;
  late double rotationSpeed;
  final ParticleType type;
  final Color baseColor;
  final Size emissionArea;

  AdvancedParticle({
    required this.type,
    required this.baseColor,
    required this.emissionArea,
  }) {
    reset();
  }

  void reset() {
    final random = math.Random();
    
    x = random.nextDouble() * emissionArea.width;
    y = random.nextDouble() * emissionArea.height;
    
    switch (type) {
      case ParticleType.sparkle:
        vx = (random.nextDouble() - 0.5) * 2;
        vy = (random.nextDouble() - 0.5) * 2;
        size = random.nextDouble() * 4 + 1;
        break;
      case ParticleType.smoke:
        vx = (random.nextDouble() - 0.5) * 0.5;
        vy = -random.nextDouble() * 2 - 1;
        size = random.nextDouble() * 8 + 4;
        break;
      case ParticleType.fire:
        vx = (random.nextDouble() - 0.5) * 1;
        vy = -random.nextDouble() * 3 - 2;
        size = random.nextDouble() * 6 + 2;
        break;
      case ParticleType.confetti:
        vx = (random.nextDouble() - 0.5) * 4;
        vy = random.nextDouble() * 2 + 1;
        size = random.nextDouble() * 6 + 3;
        break;
    }
    
    maxLife = life = random.nextDouble() * 100 + 50;
    rotation = random.nextDouble() * 2 * math.pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
    
    color = _generateColor(random);
  }

  Color _generateColor(math.Random random) {
    switch (type) {
      case ParticleType.sparkle:
        return Color.lerp(baseColor, Colors.white, random.nextDouble() * 0.5) ?? baseColor;
      case ParticleType.smoke:
        return Color.lerp(Colors.grey, Colors.white, random.nextDouble()) ?? Colors.grey;
      case ParticleType.fire:
        final colors = [Colors.red, Colors.orange, Colors.yellow];
        return colors[random.nextInt(colors.length)];
      case ParticleType.confetti:
        final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
        return colors[random.nextInt(colors.length)];
    }
  }

  void update() {
    x += vx;
    y += vy;
    life--;
    rotation += rotationSpeed;
    
    // Apply gravity for some particle types
    if (type == ParticleType.confetti) {
      vy += 0.1;
    }
    
    // Reset if particle is dead or out of bounds
    if (life <= 0 || x < -size || x > emissionArea.width + size || 
        y < -size || y > emissionArea.height + size) {
      reset();
    }
  }

  double get opacity => (life / maxLife).clamp(0.0, 1.0);
}

class AdvancedParticlePainter extends CustomPainter {
  final List<AdvancedParticle> particles;
  final Animation<double> animation;

  AdvancedParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);

      switch (particle.type) {
        case ParticleType.sparkle:
          _drawSparkle(canvas, paint, particle.size);
          break;
        case ParticleType.smoke:
          _drawSmoke(canvas, paint, particle.size);
          break;
        case ParticleType.fire:
          _drawFire(canvas, paint, particle.size);
          break;
        case ParticleType.confetti:
          _drawConfetti(canvas, paint, particle.size);
          break;
      }

      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final x = math.cos(angle) * size;
      final y = math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSmoke(Canvas canvas, Paint paint, double size) {
    canvas.drawCircle(Offset.zero, size, paint);
  }

  void _drawFire(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size);
    path.quadraticBezierTo(size * 0.5, -size * 0.5, size * 0.3, 0);
    path.quadraticBezierTo(0, size * 0.5, -size * 0.3, 0);
    path.quadraticBezierTo(-size * 0.5, -size * 0.5, 0, -size);
    canvas.drawPath(path, paint);
  }

  void _drawConfetti(Canvas canvas, Paint paint, double size) {
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VisualFeedbackWidget extends StatefulWidget {
  final Widget child;
  final FeedbackType feedbackType;
  final Duration duration;

  const VisualFeedbackWidget({
    super.key,
    required this.child,
    this.feedbackType = FeedbackType.ripple,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<VisualFeedbackWidget> createState() => _VisualFeedbackWidgetState();
}

enum FeedbackType { ripple, glow, pulse, shake }

class _VisualFeedbackWidgetState extends State<VisualFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerFeedback(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    
    _controller.reset();
    _controller.forward();
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _triggerFeedback,
      child: Stack(
        children: [
          widget.child,
          if (_tapPosition != null)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildFeedbackEffect();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackEffect() {
    switch (widget.feedbackType) {
      case FeedbackType.ripple:
        return _buildRippleEffect();
      case FeedbackType.glow:
        return _buildGlowEffect();
      case FeedbackType.pulse:
        return _buildPulseEffect();
      case FeedbackType.shake:
        return _buildShakeEffect();
    }
  }

  Widget _buildRippleEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: RipplePainter(
          center: _tapPosition!,
          radius: _animation.value * 100,
          opacity: 1.0 - _animation.value,
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrangeAccent.withOpacity(
                (1.0 - _animation.value) * 0.5,
              ),
              blurRadius: _animation.value * 20,
              spreadRadius: _animation.value * 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseEffect() {
    return Transform.scale(
      scale: 1.0 + (_animation.value * 0.1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.deepOrangeAccent.withOpacity(1.0 - _animation.value),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildShakeEffect() {
    final shake = math.sin(_animation.value * math.pi * 8) * 5;
    return Transform.translate(
      offset: Offset(shake, 0),
      child: const SizedBox.shrink(),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;

  RipplePainter({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrangeAccent.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}