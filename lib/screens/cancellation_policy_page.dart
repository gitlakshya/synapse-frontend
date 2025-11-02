import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';

class CancellationPolicyPage extends StatelessWidget {
  const CancellationPolicyPage({super.key});

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
            Text('Cancellation Policy', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text('Understand our cancellation and refund terms', style: Theme.of(context).textTheme.titleLarge),
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
          _buildSection(context, 'General Policy', 'Cancellations are subject to the terms and conditions of individual service providers (airlines, hotels, activity operators). EaseMyTrip AI acts as a booking facilitator and follows the cancellation policies set by these providers.'),
          _buildSection(context, 'Flight Cancellations', '• 48+ hours before departure: Full refund minus service fee (₹500)\n• 24-48 hours: 50% refund\n• Less than 24 hours: No refund\n• Airlines may charge additional cancellation fees'),
          _buildSection(context, 'Hotel Cancellations', '• 7+ days before check-in: Full refund\n• 3-7 days: 50% refund\n• Less than 3 days: No refund\n• Non-refundable bookings cannot be cancelled'),
          _buildSection(context, 'Activity & Experience Cancellations', '• 48+ hours before activity: Full refund\n• 24-48 hours: 50% refund\n• Less than 24 hours: No refund'),
          _buildSection(context, 'Refund Processing', 'Approved refunds are processed within 7-10 business days. The amount will be credited to the original payment method. Bank processing times may vary.'),
          _buildSection(context, 'Force Majeure', 'In case of natural disasters, pandemics, or government-imposed travel restrictions, special cancellation terms may apply. Please contact our support team for assistance.'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('For cancellation requests, please contact our support team at support@easemytrip.com or call 1800-123-4567', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
