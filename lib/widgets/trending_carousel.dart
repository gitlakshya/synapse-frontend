import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/mock_data_provider.dart';
import '../utils/image_helper.dart';

class TrendingCarousel extends StatefulWidget {
  const TrendingCarousel({super.key});

  @override
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  final FocusNode _focusNode = FocusNode();
  int _current = 0;
  bool _isHovering = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockData = context.watch<MockDataProvider>();
    final itineraries = mockData.mockItineraries();
    final isSmall = MediaQuery.of(context).size.width < 600;
    final isMedium = MediaQuery.of(context).size.width < 1000;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _controller.previousPage();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _controller.nextPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Top Trending Destinations',
                style: TextStyle(fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Discover local secrets and taste the soul of India',
                style: TextStyle(fontSize: isSmall ? 14 : 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 380,
                child: CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: itineraries.length,
                  itemBuilder: (context, index, realIndex) {
                    final itinerary = itineraries[index];
                    return _buildCard(context, itinerary, mockData);
                  },
                  options: CarouselOptions(
                    height: 380,
                    viewportFraction: isSmall ? 0.85 : isMedium ? 0.45 : 0.3,
                    enlargeCenterPage: true,
                    autoPlay: !_isHovering,
                    autoPlayInterval: const Duration(seconds: 3),
                    pauseAutoPlayOnTouch: true,
                    onPageChanged: (index, reason) {
                      setState(() => _current = index);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: itineraries.asMap().entries.map((entry) {
                  return Semantics(
                    label: 'Destination ${entry.key + 1} of ${itineraries.length}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: _current == entry.key ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _current == entry.key 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, itinerary, MockDataProvider mockData) {
    return _HoverCard(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
          child: SizedBox(
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with hover zoom effect and destination overlay
                _ImageWithOverlay(
                  imageUrl: itinerary.imageUrl,
                  title: itinerary.destination,
                  height: 180,
                ),
                Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          itinerary.destination,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (itinerary.fromCity != null)
                          Row(
                            children: [
                              Icon(Icons.flight_takeoff, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text('From ${itinerary.fromCity}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${itinerary.days} Days', style: Theme.of(context).textTheme.bodySmall),
                            const Spacer(),
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            Text('${itinerary.rating}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          button: true,
                          label: 'View details for ${itinerary.destination}',
                          child: SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/generate', arguments: {
                                  'from': itinerary.fromCity ?? 'Your City',
                                  'to': itinerary.destination,
                                  'startDate': DateTime.now(),
                                  'endDate': DateTime.now().add(Duration(days: itinerary.days)),
                                  'duration': itinerary.days,
                                });
                              },
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              child: const Text('View Details', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hover card wrapper with scale and shadow animation
/// Animation duration: 250ms for smooth transition
/// To adjust: Change duration in AnimatedContainer
class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0, // Zoom effect on hover
        duration: const Duration(milliseconds: 250), // Smooth transition
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Enhanced shadow on hover
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
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

/// Image with text overlay and hover zoom effect
/// Overlay position: Bottom-left corner
/// To change overlay color: Modify Colors.black.withValues(alpha: 0.7)
/// To change text position: Adjust Positioned left/bottom values
class _ImageWithOverlay extends StatefulWidget {
  final String imageUrl;
  final String title;
  final double height;

  const _ImageWithOverlay({
    required this.imageUrl,
    required this.title,
    required this.height,
  });

  @override
  State<_ImageWithOverlay> createState() => _ImageWithOverlayState();
}

class _ImageWithOverlayState extends State<_ImageWithOverlay> {
  bool _isHovered = false;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _isHovered = false);
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with zoom animation on hover
              AnimatedScale(
                scale: _isHovered ? 1.1 : 1.0, // Zoom in on hover
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _isLoaded ? 1.0 : 0.0, // Fade-in effect when loaded
                  duration: const Duration(milliseconds: 400),
                  child: cachedHeroImage(
                    widget.imageUrl,
                    height: widget.height,
                    onLoadComplete: () {
                      if (mounted) setState(() => _isLoaded = true);
                    },
                  ),
                ),
              ),
              // Destination name overlay at bottom-left
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7), // Semi-transparent dark background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Slightly larger font
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
