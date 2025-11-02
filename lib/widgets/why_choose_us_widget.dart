import 'package:flutter/material.dart';

class WhyChooseUs extends StatelessWidget {
  const WhyChooseUs({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Text(
            'Why Choose EaseMyTrip AI Planner',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureCard(
                Icons.auto_awesome,
                'Personalized AI Trips',
                'Get itineraries tailored to your interests, budget, and travel style',
              ),
              const SizedBox(width: 30),
              _buildFeatureCard(
                Icons.check_circle_outline,
                'Seamless Bookings',
                'Book your entire trip with just one click - hotels, transport, and experiences',
              ),
              const SizedBox(width: 30),
              _buildFeatureCard(
                Icons.update,
                'Smart Real-Time Adjustments',
                'AI adapts your plan based on weather, delays, and live availability',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Expanded(
      child: _FeatureCardWithHover(
        icon: icon,
        title: title,
        description: description,
      ),
    );
  }
}

class _FeatureCardWithHover extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCardWithHover({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_FeatureCardWithHover> createState() => _FeatureCardWithHoverState();
}

class _FeatureCardWithHoverState extends State<_FeatureCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(32),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.08),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: _isHovered ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 50, color: colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
