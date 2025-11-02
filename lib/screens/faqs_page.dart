import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHero(context),
                  _buildFAQs(context),
                  const FooterWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          children: [
            Text('Frequently Asked Questions', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text('Find answers to common questions', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQs(BuildContext context) {
    final faqs = [
      {'q': 'How does AI trip planning work?', 'a': 'Our AI analyzes your preferences, budget, and travel dates to create a personalized itinerary. It considers thousands of destinations, activities, and accommodations to match your unique travel style.'},
      {'q': 'Can I modify the AI-generated itinerary?', 'a': 'Yes! You can refine your itinerary by adjusting budget allocations, theme preferences, and special requirements. The AI will regenerate the plan based on your changes.'},
      {'q': 'What payment methods do you accept?', 'a': 'We accept all major credit cards, debit cards, UPI, net banking, and digital wallets including Paytm, PhonePe, and Google Pay.'},
      {'q': 'Is my booking confirmed immediately?', 'a': 'Yes, most bookings are confirmed instantly. You will receive a confirmation email with all booking details within minutes.'},
      {'q': 'What is your cancellation policy?', 'a': 'Cancellation policies vary by service provider. Please check the specific cancellation terms during booking. Generally, cancellations made 48+ hours in advance receive full refunds.'},
      {'q': 'Do you offer travel insurance?', 'a': 'Yes, we partner with leading insurance providers to offer comprehensive travel insurance covering trip cancellations, medical emergencies, and lost baggage.'},
    ];

    return Container(
      padding: const EdgeInsets.all(40),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: faqs.map((faq) => _FAQItem(question: faq['q']!, answer: faq['a']!)).toList(),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(widget.question, style: Theme.of(context).textTheme.titleMedium)),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(widget.answer, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
