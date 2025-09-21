import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class AnimatedBudgetSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final String label;

  const AnimatedBudgetSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
  });

  @override
  State<AnimatedBudgetSlider> createState() => _AnimatedBudgetSliderState();
}

class _AnimatedBudgetSliderState extends State<AnimatedBudgetSlider>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _breakdownController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isDragging = false;
  Map<String, double> _budgetBreakdown = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _breakdownController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _updateBudgetBreakdown();
    _breakdownController.forward();
  }

  void _updateBudgetBreakdown() {
    _budgetBreakdown = {
      'Accommodation': widget.value * 0.4,
      'Food & Dining': widget.value * 0.25,
      'Transport': widget.value * 0.2,
      'Activities': widget.value * 0.15,
    };
  }

  @override
  void didUpdateWidget(AnimatedBudgetSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateBudgetBreakdown();
      _breakdownController.reset();
      _breakdownController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _breakdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrangeAccent.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepOrangeAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrangeAccent.withOpacity(
                              0.4 * _glowAnimation.value,
                            ),
                            blurRadius: 10 * _glowAnimation.value,
                            spreadRadius: 2 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: Text(
                        '₹${(widget.value / 1000).toStringAsFixed(0)}K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: _CustomSliderThumb(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: Colors.deepOrangeAccent,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.deepOrangeAccent,
              overlayColor: Colors.deepOrangeAccent.withOpacity(0.2),
            ),
            child: Slider(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              divisions: 59,
              onChangeStart: (value) {
                setState(() => _isDragging = true);
                _controller.forward();
                HapticFeedback.selectionClick();
              },
              onChangeEnd: (value) {
                setState(() => _isDragging = false);
                _controller.reverse();
              },
              onChanged: (value) {
                widget.onChanged(value);
                HapticFeedback.selectionClick();
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildBudgetBreakdown(),
        ],
      ),
    );
  }

  Widget _buildBudgetBreakdown() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return AnimatedBuilder(
      animation: _breakdownController,
      builder: (context, child) {
        return Column(
          children: _budgetBreakdown.entries.map((entry) {
            final index = _budgetBreakdown.keys.toList().indexOf(entry.key);
            final color = colors[index % colors.length];
            final percentage = entry.value / widget.value;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '₹${entry.value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage * _breakdownController.value,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CustomSliderThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    
    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.deepOrangeAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 16, glowPaint);
    
    // Main thumb
    final thumbPaint = Paint()
      ..color = Colors.deepOrangeAccent
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 12, thumbPaint);
    
    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 6, highlightPaint);
  }
}

class WeatherAnimationWidget extends StatefulWidget {
  final String weatherType;
  final int temperature;
  final String condition;

  const WeatherAnimationWidget({
    super.key,
    required this.weatherType,
    required this.temperature,
    required this.condition,
  });

  @override
  State<WeatherAnimationWidget> createState() => _WeatherAnimationWidgetState();
}

class _WeatherAnimationWidgetState extends State<WeatherAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;
  
  List<WeatherParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_particleController);

    _initializeParticles();
  }

  void _initializeParticles() {
    _particles = List.generate(20, (index) => WeatherParticle());
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColor().withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Particle effects
          if (widget.weatherType == 'rain' || widget.weatherType == 'snow')
            _buildParticleEffect(),
          
          // Main weather icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_bounceAnimation.value),
                      child: _buildWeatherIcon(),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.temperature}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.condition,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon() {
    IconData icon;
    switch (widget.weatherType.toLowerCase()) {
      case 'sunny':
        icon = Icons.wb_sunny;
        break;
      case 'rain':
        icon = Icons.grain;
        break;
      case 'snow':
        icon = Icons.ac_unit;
        break;
      case 'cloudy':
        icon = Icons.cloud;
        break;
      default:
        icon = Icons.wb_sunny;
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.weatherType == 'sunny' ? _rotationAnimation.value : 0,
          child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildParticleEffect() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: WeatherParticlePainter(
            particles: _particles,
            animation: _particleController,
            weatherType: widget.weatherType,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  LinearGradient _getWeatherGradient() {
    switch (widget.weatherType.toLowerCase()) {
      case 'sunny':
        return const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        );
      case 'rain':
        return const LinearGradient(
          colors: [Colors.blue, Colors.indigo],
        );
      case 'snow':
        return const LinearGradient(
          colors: [Colors.lightBlue, Colors.blue],
        );
      case 'cloudy':
        return const LinearGradient(
          colors: [Colors.grey, Colors.blueGrey],
        );
      default:
        return const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        );
    }
  }

  Color _getWeatherColor() {
    switch (widget.weatherType.toLowerCase()) {
      case 'sunny':
        return Colors.orange;
      case 'rain':
        return Colors.blue;
      case 'snow':
        return Colors.lightBlue;
      case 'cloudy':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

class WeatherParticle {
  late double x;
  late double y;
  late double speed;
  late double size;

  WeatherParticle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = -0.1;
    speed = math.Random().nextDouble() * 0.02 + 0.01;
    size = math.Random().nextDouble() * 3 + 1;
  }

  void update() {
    y += speed;
    if (y > 1.1) {
      reset();
    }
  }
}

class WeatherParticlePainter extends CustomPainter {
  final List<WeatherParticle> particles;
  final Animation<double> animation;
  final String weatherType;

  WeatherParticlePainter({
    required this.particles,
    required this.animation,
    required this.weatherType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = weatherType == 'rain' ? Colors.blue : Colors.white
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update();
      
      if (weatherType == 'rain') {
        // Draw rain drops
        canvas.drawLine(
          Offset(particle.x * size.width, particle.y * size.height),
          Offset(
            particle.x * size.width,
            (particle.y * size.height) + particle.size * 3,
          ),
          paint..strokeWidth = particle.size,
        );
      } else if (weatherType == 'snow') {
        // Draw snowflakes
        canvas.drawCircle(
          Offset(particle.x * size.width, particle.y * size.height),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}