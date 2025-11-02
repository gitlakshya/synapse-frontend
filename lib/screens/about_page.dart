import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                  _buildContent(context),
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
            Text('About EaseMyTrip AI', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text('Revolutionizing travel planning with artificial intelligence', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our Mission', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('EaseMyTrip AI is dedicated to making travel planning effortless and personalized. We leverage cutting-edge artificial intelligence to create custom itineraries that match your preferences, budget, and travel style.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 32),
          Text('What We Offer', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          _buildFeature(context, 'AI-Powered Itineraries', 'Get personalized day-by-day plans based on your interests'),
          _buildFeature(context, 'Smart Budget Planning', 'Optimize your spending across travel, food, and experiences'),
          _buildFeature(context, 'Real-Time Weather', 'Plan activities with accurate weather forecasts'),
          _buildFeature(context, 'Seamless Booking', 'Book flights, hotels, and activities in one place'),
          const SizedBox(height: 32),
          Text('Our Story', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('Founded in 2024, EaseMyTrip AI emerged from a simple idea: travel planning should be exciting, not exhausting. Our team of travel experts and AI engineers came together to build a platform that understands your unique travel needs and creates perfect itineraries in minutes.', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildFeature(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
