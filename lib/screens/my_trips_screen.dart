import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';
import '../providers/mock_data_provider.dart';
import '../utils/image_helper.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MockDataProvider>(context);
    final bookings = provider.getBookings();
    final itineraries = provider.mockItineraries();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SharedAppBar(),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Trips',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View and manage your AI-generated itineraries',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  if (bookings.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.luggage, size: 80, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings yet',
                            style: TextStyle(fontSize: 20, color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start planning your next adventure!',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/'),
                            child: const Text('Explore Destinations'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...bookings.map((booking) {
                      final itinerary = itineraries.firstWhere(
                        (i) => i.id == booking.itineraryId,
                        orElse: () => itineraries.first,
                      );
                      return _buildTripCard(
                        context,
                        booking,
                        itinerary,
                        colorScheme,
                      );
                    }),
                ],
              ),
            ),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }

  // Added 'Book This Trip' button and booking persistence in My Trips section
  Widget _buildTripCard(BuildContext context, booking, itinerary, ColorScheme colorScheme) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final bookingDate = dateFormat.format(booking.timestamp);
    
    // Extract destination from itineraryId if itinerary not found
    final destination = itinerary?.destination ?? _extractDestinationFromId(booking.itineraryId);
    final days = itinerary?.days ?? 5;
    final imageUrl = itinerary?.imageUrl ?? 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cachedThumbnail(
              imageUrl,
              size: 120,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$days-Day $destination Trip',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Booked on $bookingDate', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 20),
                    Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('$days Days', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${booking.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: ${booking.id}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            children: [
              // FIX: "View Details" in My Trips now opens a read-only summary instead of editable itinerary page.
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trip-summary', arguments: {
                    'booking': booking,
                    'destination': destination,
                    'days': days,
                    'imageUrl': imageUrl,
                  });
                },
                child: const Text('View Details'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/'),
                child: const Text('Replan'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading itinerary PDF')),
                ),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _extractDestinationFromId(String itineraryId) {
    final parts = itineraryId.split('_');
    if (parts.length > 1) {
      return parts[1].replaceFirst(parts[1][0], parts[1][0].toUpperCase());
    }
    return 'Unknown';
  }
}
