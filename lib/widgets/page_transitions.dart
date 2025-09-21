import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SharedElementTransition extends PageRouteBuilder {
  final Widget child;
  final String heroTag;
  final Duration duration;

  SharedElementTransition({
    required this.child,
    required this.heroTag,
    this.duration = const Duration(milliseconds: 600),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class StaggeredListTransition extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration itemDelay;
  final Axis direction;

  const StaggeredListTransition({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.itemDelay = const Duration(milliseconds: 100),
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredListTransition> createState() => _StaggeredListTransitionState();
}

class _StaggeredListTransitionState extends State<StaggeredListTransition>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStaggeredAnimation();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.direction == Axis.vertical
            ? const Offset(0, 0.3)
            : const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        widget.delay + Duration(milliseconds: widget.itemDelay.inMilliseconds * i),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(
            children: _buildAnimatedChildren(),
          )
        : Row(
            children: _buildAnimatedChildren(),
          );
  }

  List<Widget> _buildAnimatedChildren() {
    return List.generate(widget.children.length, (index) {
      return AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: widget.children[index],
            ),
          );
        },
      );
    });
  }
}

class PageCurlTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  PageCurlTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _PageCurlWidget(
              animation: animation,
              child: child,
            );
          },
        );
}

class _PageCurlWidget extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _PageCurlWidget({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        
        return Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(math.pi * progress * 0.5),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3 * progress),
                  blurRadius: 20 * progress,
                  offset: Offset(-10 * progress, 0),
                ),
              ],
            ),
            child: this.child,
          ),
        );
      },
      child: child,
    );
  }
}

class MorphingContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final BorderRadius? fromBorderRadius;
  final BorderRadius? toBorderRadius;
  final Color? fromColor;
  final Color? toColor;
  final EdgeInsetsGeometry? fromPadding;
  final EdgeInsetsGeometry? toPadding;
  final bool isExpanded;

  const MorphingContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.fromBorderRadius,
    this.toBorderRadius,
    this.fromColor,
    this.toColor,
    this.fromPadding,
    this.toPadding,
    required this.isExpanded,
  });

  @override
  State<MorphingContainer> createState() => _MorphingContainerState();
}

class _MorphingContainerState extends State<MorphingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<BorderRadius?> _borderRadiusAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<EdgeInsetsGeometry?> _paddingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _borderRadiusAnimation = BorderRadiusTween(
      begin: widget.fromBorderRadius ?? BorderRadius.circular(8),
      end: widget.toBorderRadius ?? BorderRadius.circular(16),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.fromColor ?? Colors.grey[800],
      end: widget.toColor ?? Colors.deepOrangeAccent,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _paddingAnimation = EdgeInsetsGeometryTween(
      begin: widget.fromPadding ?? const EdgeInsets.all(8),
      end: widget.toPadding ?? const EdgeInsets.all(16),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(MorphingContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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
        return Container(
          padding: _paddingAnimation.value,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: _borderRadiusAnimation.value,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1 * _controller.value),
                blurRadius: 10 * _controller.value,
                offset: Offset(0, 5 * _controller.value),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class RouteTransitions {
  static Route<T> slideFromRight<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> slideFromBottom<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> fadeScale<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: child,
          ),
        );
      },
    );
  }

  static Route<T> travelThemed<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Background plane animation
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Positioned(
                  right: -100 + (200 * animation.value),
                  top: 50,
                  child: Transform.rotate(
                    angle: -0.3 + (0.6 * animation.value),
                    child: Icon(
                      Icons.flight,
                      size: 60,
                      color: Colors.deepOrangeAccent.withOpacity(0.3 * animation.value),
                    ),
                  ),
                );
              },
            ),
            // Page content
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                )),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DraggableItineraryItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReorder;
  final int index;

  const DraggableItineraryItem({
    super.key,
    required this.child,
    this.onReorder,
    required this.index,
  });

  @override
  State<DraggableItineraryItem> createState() => _DraggableItineraryItemState();
}

class _DraggableItineraryItemState extends State<DraggableItineraryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
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

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: widget.index,
      onDragStarted: () {
        setState(() => _isDragging = true);
        _controller.forward();
        HapticFeedback.mediumImpact();
      },
      onDragEnd: (details) {
        setState(() => _isDragging = false);
        _controller.reverse();
      },
      feedback: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrangeAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: widget.child,
      ),
      child: DragTarget<int>(
        onAccept: (draggedIndex) {
          if (draggedIndex != widget.index) {
            widget.onReorder?.call();
            HapticFeedback.lightImpact();
          }
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: candidateData.isNotEmpty
                  ? Border.all(
                      color: Colors.deepOrangeAccent.withOpacity(0.5),
                      width: 2,
                    )
                  : null,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class ParticleSystem extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double particleSize;
  final Duration animationDuration;

  const ParticleSystem({
    super.key,
    this.particleCount = 20,
    this.particleColor = Colors.deepOrangeAccent,
    this.particleSize = 4.0,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _particles = List.generate(widget.particleCount, (index) => Particle());
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
          painter: ParticlePainter(
            particles: _particles,
            animation: _controller,
            color: widget.particleColor,
            size: widget.particleSize,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double life;
  late double decay;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.002;
    vy = (math.Random().nextDouble() - 0.5) * 0.002;
    life = 1.0;
    decay = math.Random().nextDouble() * 0.02 + 0.005;
  }

  void update() {
    x += vx;
    y += vy;
    life -= decay;

    if (life <= 0 || x < 0 || x > 1 || y < 0 || y > 1) {
      reset();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;
  final Color color;
  final double size;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update();
      
      paint.color = color.withOpacity(particle.life * 0.6);
      
      canvas.drawCircle(
        Offset(
          particle.x * canvasSize.width,
          particle.y * canvasSize.height,
        ),
        size * particle.life,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}