import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'How do I book a trip?', 'a': 'Use our AI Trip Planner to generate personalized itineraries, then click Book Trip.'},
      {'q': 'What payment methods are accepted?', 'a': 'We accept UPI, Credit/Debit Cards, Net Banking, and Wallets.'},
      {'q': 'Can I cancel my booking?', 'a': 'Yes, cancellation policies vary by service. Check your booking details.'},
      {'q': 'How does AI trip planning work?', 'a': 'Our AI analyzes your preferences and creates optimized itineraries using Gemini AI.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...faqs.map((faq) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(faq['q']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(faq['a']!),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening chat support...')),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat with Us'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Call: 1800-123-4567')),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Us'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
