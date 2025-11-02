import 'package:flutter/material.dart';

class OffersCarousel extends StatelessWidget {
  const OffersCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Exclusive Offers',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              _buildOfferCard('Up to 20% OFF on Flights', 'Book now and save big', Colors.blue),
              _buildOfferCard('Flat ₹1000 OFF on Hotels', 'Use code: HOTEL1000', Colors.orange),
              _buildOfferCard('Holiday Packages from ₹9,999', 'Limited time offer', Colors.green),
              _buildOfferCard('Extra 10% Cashback', 'On all bookings', Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(String title, String subtitle, Color color) {
    return _HoverOfferCard(
      color: color,
      child: Builder(
        builder: (context) => Container(
        width: 320,
        height: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Book Now'),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

/// Hover effect for offer cards with scale and shadow animation
/// Animation duration: 250ms
class _HoverOfferCard extends StatefulWidget {
  final Widget child;
  final Color color;
  const _HoverOfferCard({required this.child, required this.color});

  @override
  State<_HoverOfferCard> createState() => _HoverOfferCardState();
}

class _HoverOfferCardState extends State<_HoverOfferCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
