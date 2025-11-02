import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../utils/analytics.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  void initState() {
    super.initState();
    logRouteVisit('/privacy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy Policy', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Last updated: ${DateTime.now().year}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 30),
            _buildSection('1. Information We Collect', 'We collect information you provide directly to us when you create an account, make a booking, or use our AI trip planning services. This includes:\n\n• Personal identification information (name, email address, phone number)\n• Travel preferences and booking history\n• Payment information (processed securely through third-party providers)\n• Device information and usage data\n• Location data when you use our mobile applications'),
            _buildSection('2. How We Use Your Information', 'We use the information we collect to:\n\n• Provide, maintain, and improve our AI-powered trip planning services\n• Process your bookings and transactions\n• Send you confirmations, updates, and customer support messages\n• Personalize your experience and provide tailored recommendations\n• Analyze usage patterns to enhance our services\n• Comply with legal obligations and prevent fraud'),
            _buildSection('3. Information Sharing and Disclosure', 'We may share your information with:\n\n• Service providers who assist in our operations (hotels, airlines, payment processors)\n• Business partners for joint offerings\n• Law enforcement when required by law\n• Other parties with your consent\n\nWe do not sell your personal information to third parties.'),
            _buildSection('4. Data Security', 'We implement industry-standard security measures to protect your personal information, including:\n\n• Encryption of data in transit and at rest\n• Regular security audits and assessments\n• Access controls and authentication mechanisms\n• Secure payment processing through PCI-DSS compliant providers\n\nHowever, no method of transmission over the Internet is 100% secure.'),
            _buildSection('5. Your Rights and Choices', 'You have the right to:\n\n• Access and update your personal information\n• Request deletion of your data\n• Opt-out of marketing communications\n• Disable cookies through your browser settings\n• Request a copy of your data\n\nTo exercise these rights, contact us at privacy@easemytrip.com'),
            _buildSection('6. Cookies and Tracking Technologies', 'We use cookies and similar technologies to:\n\n• Remember your preferences and settings\n• Analyze site traffic and usage patterns\n• Provide personalized content and advertisements\n• Improve site functionality\n\nYou can control cookies through your browser settings.'),
            _buildSection('7. Children\'s Privacy', 'Our services are not directed to children under 13. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.'),
            _buildSection('8. Changes to This Policy', 'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date. Continued use of our services constitutes acceptance of the updated policy.'),
            _buildSection('9. Contact Us', 'If you have questions about this Privacy Policy or our data practices, please contact us at:\n\nEmail: privacy@easemytrip.com\nAddress: EaseMyTrip.com, New Delhi, India\nPhone: +91-11-4444-5555'),
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

