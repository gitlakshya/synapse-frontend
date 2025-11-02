import 'package:flutter/material.dart';

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partners = [
      {'name': 'Airlines', 'count': '50+ Partners'},
      {'name': 'Hotels', 'count': '10,000+ Properties'},
      {'name': 'Car Rentals', 'count': '200+ Providers'},
      {'name': 'Tour Operators', 'count': '500+ Operators'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Partners')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Our Partners', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Trusted by leading travel brands worldwide', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
              ),
              itemCount: partners.length,
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(partner['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(partner['count']!, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partner inquiry submitted')),
                  );
                },
                child: const Text('Become a Partner'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
