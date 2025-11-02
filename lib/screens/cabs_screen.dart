import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';

class CabsScreen extends StatelessWidget {
  const CabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cabs = [
      {'type': 'Sedan', 'from': 'Airport', 'to': 'City Center', 'price': '₹600', 'time': '45m'},
      {'type': 'SUV', 'from': 'Railway Station', 'to': 'Hotel', 'price': '₹800', 'time': '30m'},
      {'type': 'Hatchback', 'from': 'City', 'to': 'Mall', 'price': '₹300', 'time': '20m'},
    ];

    return Scaffold(
      appBar: const SharedAppBar(title: 'Cabs'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cabs.length,
        itemBuilder: (context, index) {
          final cab = cabs[index];
          // Flexible layout prevents overflow
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cab icon
                    Icon(Icons.local_taxi, size: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    // Cab info (flexible to wrap long text)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cab['type']!,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${cab['from']} → ${cab['to']} • ${cab['time']}',
                            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price and button
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          cab['price']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF007BFF)),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/booking', arguments: cab);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Booking ${cab['type']} cab')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            minimumSize: const Size(80, 32),
                          ),
                          child: const Text('Book', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

