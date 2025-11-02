import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';

class ItineraryDetailsScreen extends StatelessWidget {
  const ItineraryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SharedAppBar(),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your AI-Generated Itinerary',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Goa • 5 Days • ₹25,000 per person',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        _buildDayCard(1, 'Arrival & Beach Relaxation', [
                          'Check-in at Taj Fort Aguada Resort',
                          'Lunch at Fisherman\'s Wharf',
                          'Calangute Beach sunset',
                          'Dinner at Thalassa',
                        ], '₹4,500', '28°C Sunny'),
                        const SizedBox(height: 20),
                        _buildDayCard(2, 'North Goa Exploration', [
                          'Fort Aguada visit',
                          'Water sports at Baga Beach',
                          'Shopping at Anjuna Flea Market',
                          'Nightlife at Tito\'s',
                        ], '₹3,800', '29°C Partly Cloudy'),
                        const SizedBox(height: 20),
                        _buildDayCard(3, 'South Goa Heritage', [
                          'Old Goa Churches tour',
                          'Spice plantation visit',
                          'Palolem Beach relaxation',
                          'Seafood dinner at beach shack',
                        ], '₹4,200', '27°C Clear'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 20),
                        _buildMapPlaceholder(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/booking');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0056b3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'BOOK NOW',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(int day, String title, List<String> activities, String cost, String weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Day $day',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.wb_sunny, size: 18, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(weather, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(activity, style: const TextStyle(fontSize: 15))),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.currency_rupee, size: 18, color: Color(0xFF007BFF)),
              Text(
                cost,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007BFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Accommodation', '₹12,000'),
          _buildSummaryRow('Transport', '₹5,000'),
          _buildSummaryRow('Activities', '₹6,000'),
          _buildSummaryRow('Food', '₹2,000'),
          const Divider(height: 24),
          _buildSummaryRow('Total', '₹25,000', bold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF007BFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 60, color: Colors.grey),
            SizedBox(height: 8),
            Text('Interactive Map', style: TextStyle(color: Colors.grey)),
            Text('(Google Maps API)', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
