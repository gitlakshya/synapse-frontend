import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/mock_data_provider.dart';
import '../utils/image_helper.dart';
import '../l10n/app_localizations.dart';

class TrendingDestinationsWidget extends StatefulWidget {
  const TrendingDestinationsWidget({super.key});

  @override
  State<TrendingDestinationsWidget> createState() => _TrendingDestinationsWidgetState();
}

class _TrendingDestinationsWidgetState extends State<TrendingDestinationsWidget> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  final FocusNode _focusNode = FocusNode();

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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).translate('trending_destinations'),
              style: TextStyle(fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate('discover_destinations'),
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
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
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
                  label: 'Go to ${itineraries[entry.key].destination}',
                  button: true,
                  selected: _current == entry.key,
                  child: Tooltip(
                    message: itineraries[entry.key].destination,
                    child: GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: _current == entry.key ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _current == entry.key ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, itinerary, MockDataProvider mockData) {
    return Semantics(
      label: '${itinerary.destination}, ${itinerary.days} days trip, rated ${itinerary.rating} stars, costs rupees ${itinerary.totalCost.toInt()}',
      button: true,
      child: Tooltip(
        message: 'View ${itinerary.destination} itinerary',
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                image: true,
                label: '${itinerary.destination} destination image',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: cachedImage(
                    itinerary.imageUrl,
                    height: 160,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    itinerary.destination,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${itinerary.days} ${AppLocalizations.of(context).translate('days')}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                      const Spacer(),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      Text('${itinerary.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${itinerary.totalCost.toInt()}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    button: true,
                    label: 'View details for ${itinerary.destination}',
                    child: Tooltip(
                      message: 'View full itinerary',
                      child: SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () {
                            mockData.selectItinerary(itinerary.id);
                            Navigator.pushNamed(context, '/itinerary', arguments: {
                              'from': 'Selected',
                              'to': itinerary.destination,
                              'startDate': DateTime.now(),
                              'endDate': DateTime.now().add(Duration(days: itinerary.days)),
                              'travelers': 2,
                              'totalBudget': itinerary.totalCost,
                            });
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                          child: Text(AppLocalizations.of(context).translate('view_details'), style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
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
