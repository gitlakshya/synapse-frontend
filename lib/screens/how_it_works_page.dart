import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

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
                  _buildSteps(context),
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
            Text('How It Works', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text('Plan your perfect trip in 4 simple steps', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          _buildStep(context, 1, 'Enter Your Details', 'Tell us your destination, dates, budget, and travel preferences'),
          _buildStep(context, 2, 'AI Creates Your Itinerary', 'Our AI analyzes thousands of options to build a personalized day-by-day plan'),
          _buildStep(context, 3, 'Refine & Customize', 'Adjust themes, budget allocation, and special requirements to perfect your trip'),
          _buildStep(context, 4, 'Book & Travel', 'Book flights, hotels, and activities directly through our platform'),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
