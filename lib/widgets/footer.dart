import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  void _handleLinkTap(BuildContext context, String link) async {
    // Social media URLs - Update here if EaseMyTrip rebrands
    final socialMediaUrls = {
      'Facebook': 'https://www.facebook.com/EaseMyTrip',
      'Instagram': 'https://www.instagram.com/easemytrip',
      'Twitter': 'https://twitter.com/easemytrip',
      'LinkedIn': 'https://www.linkedin.com/company/easemytrip-com/',
    };

    final routes = {
      'Privacy Policy': '/privacy',
      'Terms & Conditions': '/terms',
      'Careers': '/careers',
      'Help Center': '/support',
      'Contact Us': '/support',
      'Feedback': '/support',
    };

    // Handle social media links
    if (socialMediaUrls.containsKey(link)) {
      final url = Uri.parse(socialMediaUrls[link]!);
      try {
        final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open link. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open link. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      return;
    }

    if (routes.containsKey(link)) {
      Navigator.pushNamed(context, routes[link]!);
    } else if (link == 'About Us' || link == 'How It Works' || link == 'Blog') {
      Navigator.pushNamed(context, '/partners');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$link - Coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    _buildColumn('About', ['About Us', 'How It Works', 'Careers', 'Blog']),
                    const SizedBox(height: 20),
                    _buildColumn('Support', ['Help Center', 'FAQs', 'Contact Us', 'Feedback']),
                    const SizedBox(height: 20),
                    _buildColumn('Useful Links', ['Privacy Policy', 'Terms & Conditions', 'Cancellation Policy']),
                    const SizedBox(height: 20),
                    _buildColumn('Social Media', ['Facebook', 'Twitter', 'Instagram', 'LinkedIn']),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildColumn('About', ['About Us', 'How It Works', 'Careers', 'Blog'])),
                  Expanded(child: _buildColumn('Support', ['Help Center', 'FAQs', 'Contact Us', 'Feedback'])),
                  Expanded(child: _buildColumn('Useful Links', ['Privacy Policy', 'Terms & Conditions', 'Cancellation Policy'])),
                  Expanded(child: _buildColumn('Social Media', ['Facebook', 'Twitter', 'Instagram', 'LinkedIn'])),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Text('© ${DateTime.now().year} EaseMyTrip.com. All rights reserved.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<String> links) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _handleLinkTap(context, link),
                  child: Text(link, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
                ),
              )),
        ],
      ),
    );
  }


}
