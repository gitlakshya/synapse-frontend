import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/skeleton_loader.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  bool _isLoading = true;
  List<Map<String, String>>? _buses;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _buses = [
        {'operator': 'Volvo AC', 'from': 'Delhi', 'to': 'Jaipur', 'price': '₹800', 'time': '6h'},
        {'operator': 'Sleeper Coach', 'from': 'Mumbai', 'to': 'Pune', 'price': '₹500', 'time': '4h'},
        {'operator': 'Semi-Sleeper', 'from': 'Bangalore', 'to': 'Goa', 'price': '₹1,200', 'time': '12h'},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Buses'),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const ListItemSkeleton(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _buses!.length,
              itemBuilder: (context, index) {
                final bus = _buses![index];
                // Flexible layout prevents overflow
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bus info (flexible to wrap long text)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  bus['operator']!,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${bus['from']} → ${bus['to']} • ${bus['time']}',
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
                                bus['price']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF007BFF)),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/booking', arguments: bus);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Booking ${bus['operator']}')),
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

