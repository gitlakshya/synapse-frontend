import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/skeleton_loader.dart';
import '../l10n/app_localizations.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  bool _isLoading = true;
  List<Map<String, String>>? _flights;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _flights = [
        {'from': 'Delhi', 'to': 'Mumbai', 'price': '₹3,500', 'time': '2h 15m'},
        {'from': 'Bangalore', 'to': 'Goa', 'price': '₹2,800', 'time': '1h 30m'},
        {'from': 'Chennai', 'to': 'Kolkata', 'price': '₹4,200', 'time': '2h 45m'},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(title: AppLocalizations.of(context).translate('flights')),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const ListItemSkeleton(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _flights!.length,
              itemBuilder: (context, index) {
                final flight = _flights![index];
                // Use flexible layout to prevent overflow
                // IntrinsicHeight ensures card expands to fit content
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Flight info (flexible to wrap long text)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Allow text wrapping for long city names
                                Text(
                                  '${flight['from']} → ${flight['to']}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${AppLocalizations.of(context).translate('duration')}: ${flight['time']}',
                                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right side: Price and button (fixed width for alignment)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                flight['price']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF007BFF)),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/booking', arguments: flight);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Booking ${flight['from']} to ${flight['to']}')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  minimumSize: const Size(80, 32),
                                ),
                                child: Text(AppLocalizations.of(context).translate('book'), style: const TextStyle(fontSize: 13)),
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

