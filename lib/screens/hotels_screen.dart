import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';
import '../providers/mock_data_provider.dart';
import '../models/hotel.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_widget.dart';
import '../utils/image_helper.dart';
import '../utils/animations_helper.dart';
import '../l10n/app_localizations.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  List<Hotel>? _hotels;
  String _selectedDestination = 'All'; // Default shows all hotels

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  /// Load hotels from mock data provider
  /// To integrate live API: Replace provider.fetchHotels() with your API call
  /// Example: final response = await http.get('https://api.example.com/hotels');
  Future<void> _loadHotels() async {
    final provider = context.read<MockDataProvider>();
    // Load hotels from multiple destinations to show variety
    final destinations = ['Goa', 'Kerala', 'Rajasthan', 'Mumbai', 'Delhi', 'Bangalore', 'Jaipur', 'Agra', 'Hyderabad'];
    final allHotels = <Hotel>[];
    for (final dest in destinations) {
      final hotels = await provider.fetchHotels(dest);
      allHotels.addAll(hotels);
    }
    setState(() => _hotels = allHotels);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MockDataProvider>();

    return Scaffold(
      appBar: SharedAppBar(title: AppLocalizations.of(context).translate('hotels')),
      body: provider.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const ListItemSkeleton(),
            )
          : provider.error != null
              ? ErrorDisplay(
                  message: provider.error!,
                  onRetry: () {
                    provider.clearError();
                    _loadHotels();
                  },
                )
              : _hotels == null || _hotels!.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).translate('no_hotels_available'),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _hotels!.length,
                      itemBuilder: (context, index) {
                        final hotel = _hotels![index];
                        // Each hotel card follows the same layout as other transport cards
                        return StaggeredListAnimation(
                          index: index,
                          child: HoverScaleCard(
                            scale: 1.01,
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                              // IntrinsicHeight prevents overflow by allowing flexible height
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Hotel details (flexible width to prevent overflow)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              hotel.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hotel.destination,
                                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${hotel.rating} ${AppLocalizations.of(context).translate('rating')}',
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Price and Book button (fixed width for alignment)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${hotel.pricePerNight}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF007BFF)),
                                          ),
                                          Text(
                                            AppLocalizations.of(context).translate('per_night'),
                                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Booking ${hotel.name}...')),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                              minimumSize: const Size(90, 36),
                                            ),
                                            child: Text(AppLocalizations.of(context).translate('book'), style: const TextStyle(fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

