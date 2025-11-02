import 'package:flutter/material.dart';

class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {'title': 'Senior Flutter Developer', 'location': 'Bangalore', 'type': 'Full-time'},
      {'title': 'AI/ML Engineer', 'location': 'Remote', 'type': 'Full-time'},
      {'title': 'Product Manager', 'location': 'Mumbai', 'type': 'Full-time'},
      {'title': 'UI/UX Designer', 'location': 'Delhi', 'type': 'Contract'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Careers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Join Our Team', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Build the future of AI-powered travel planning', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            ...jobs.map((job) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(job['title']!),
                subtitle: Text('${job['location']} • ${job['type']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Applying for ${job['title']}')),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
