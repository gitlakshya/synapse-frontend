import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mock_data_provider.dart';
import '../widgets/app_bar_widget.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = context.watch<MockDataProvider>();
    final bookings = mockData.getBookings();

    return Scaffold(
      appBar: const SharedAppBar(title: 'My Trips'),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.luggage, size: 80, color: Color(0xFF007BFF)),
                  const SizedBox(height: 24),
                  const Text('No bookings yet', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Start planning your dream trip!', style: TextStyle(color: Color(0xFF666666))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    child: const Text('Plan a Trip'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final itinerary = mockData.mockItineraries().firstWhere(
                  (i) => i.id == booking.itineraryId,
                  orElse: () => mockData.mockItineraries().first,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.place, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${itinerary.days}-Day Trip to ${itinerary.destination}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Booking ID: ${booking.id}', style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                                  Text('Amount: ₹${booking.amount.toInt()}', style: const TextStyle(color: Color(0xFF666666))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
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
                                child: const Text('View Details'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


