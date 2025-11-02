import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../utils/analytics.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  void initState() {
    super.initState();
    logRouteVisit('/terms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Terms & Conditions', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Last updated: ${DateTime.now().year}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 30),
            _buildSection('1. Acceptance of Terms', 'By accessing and using EaseMyTrip AI Planner ("the Service"), you accept and agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our Service.\n\nThese terms constitute a legally binding agreement between you and EaseMyTrip.com.'),
            _buildSection('2. Use of Service', 'You agree to:\n\n• Use our Service only for lawful purposes\n• Provide accurate and complete information\n• Maintain the security of your account credentials\n• Not interfere with or disrupt the Service\n• Not use automated systems to access the Service without permission\n• Comply with all applicable laws and regulations\n\nWe reserve the right to suspend or terminate accounts that violate these terms.'),
            _buildSection('3. AI-Generated Content', 'Our AI-powered trip planning feature generates itineraries based on your preferences and available data. Please note:\n\n• AI-generated content is for informational purposes only\n• Recommendations should be verified before booking\n• We do not guarantee accuracy, completeness, or suitability\n• Actual prices, availability, and conditions may vary\n• We are not liable for decisions made based on AI recommendations\n\nAlways confirm details with service providers before finalizing bookings.'),
            _buildSection('4. Booking and Payments', 'All bookings made through our platform are subject to:\n\n• Availability and confirmation from service providers\n• Acceptance of the provider\'s terms and conditions\n• Payment of applicable fees and charges\n• Verification of traveler information\n\nPayment processing is handled securely through third-party payment gateways. We do not store complete payment card information.'),
            _buildSection('5. Cancellation and Refund Policy', 'Cancellation terms vary by service provider and booking type:\n\n• Review specific cancellation policies before booking\n• Cancellation fees may apply as per provider policies\n• Refunds are processed according to provider terms\n• Processing time for refunds may vary (typically 7-14 business days)\n• Some bookings may be non-refundable\n\nContact customer support for cancellation assistance.'),
            _buildSection('6. Intellectual Property', 'All content on the Service, including text, graphics, logos, images, and software, is the property of EaseMyTrip.com or its licensors and is protected by copyright and intellectual property laws.\n\nYou may not reproduce, distribute, or create derivative works without our written permission.'),
            _buildSection('7. Limitation of Liability', 'To the maximum extent permitted by law:\n\n• We are not liable for indirect, incidental, or consequential damages\n• Our total liability shall not exceed the amount paid for the booking\n• We are not responsible for third-party service provider actions\n• We do not guarantee uninterrupted or error-free service\n• Force majeure events are beyond our control'),
            _buildSection('8. Indemnification', 'You agree to indemnify and hold harmless EaseMyTrip.com, its affiliates, and employees from any claims, damages, or expenses arising from:\n\n• Your use of the Service\n• Violation of these Terms\n• Violation of any third-party rights\n• Your travel activities'),
            _buildSection('9. Dispute Resolution', 'Any disputes arising from these Terms shall be:\n\n• First attempted to be resolved through good-faith negotiation\n• Subject to binding arbitration if negotiation fails\n• Governed by the laws of India\n• Subject to the exclusive jurisdiction of courts in New Delhi, India'),
            _buildSection('10. Changes to Terms', 'We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting. Your continued use of the Service constitutes acceptance of the modified Terms.\n\nWe recommend reviewing these Terms periodically.'),
            _buildSection('11. Contact Information', 'For questions about these Terms and Conditions, please contact us at:\n\nEmail: legal@easemytrip.com\nAddress: EaseMyTrip.com, New Delhi, India\nPhone: +91-11-4444-5555\nCustomer Support: Available 24/7'),
            const SizedBox(height: 40),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/'),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}

