import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/mock_data_provider.dart';
import '../utils/image_helper.dart';
import '../l10n/app_localizations.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
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
    final slides = context.read<MockDataProvider>().heroSlides();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = min(480.0, constraints.maxHeight * 0.6);
        
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
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: slides.length,
                    options: CarouselOptions(
                      height: height,
                      viewportFraction: 1.0,
                      autoPlay: !_isHovering,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      pauseAutoPlayOnTouch: true,
                      enlargeCenterPage: false,
                      onPageChanged: (index, _) => setState(() => _current = index),
                    ),
                    itemBuilder: (context, index, _) {
                      return _SlideWidget(slide: slides[index], height: height, key: ValueKey(index));
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: slides.asMap().entries.map((entry) {
                        return Semantics(
                          label: 'Go to slide ${entry.key + 1}, ${slides[entry.key]['destination']}',
                          button: true,
                          selected: _current == entry.key,
                          child: Tooltip(
                            message: slides[entry.key]['destination']!,
                            child: GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width: _current == entry.key ? 24 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white.withValues(alpha: _current == entry.key ? 0.9 : 0.4),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlideWidget extends StatefulWidget {
  final Map<String, String> slide;
  final double height;

  const _SlideWidget({required this.slide, required this.height, super.key});

  @override
  State<_SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<_SlideWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Semantics(
      label: '${widget.slide['title']}, ${widget.slide['subtitle']}',
      image: true,
      child: SizedBox(
        height: widget.height,
        width: double.maxFinite,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRect(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: cachedHeroImage(
                  widget.slide['imageUrl']!,
                  height: widget.height,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.slide['title']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 32 : 56,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.slide['subtitle']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 16 : 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
