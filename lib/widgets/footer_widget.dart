import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildFooterColumn(AppLocalizations.of(context).translate('about_us'), [
                  'About EaseMyTrip AI',
                  'How It Works',
                  'Careers',
                  'Press & Media',
                  'Blog',
                ], context),
              ),
              Expanded(
                child: _buildFooterColumn(AppLocalizations.of(context).translate('contact'), [
                  'Help Center',
                  'FAQs',
                  'Contact Us',
                  'Feedback',
                  'Report Issue',
                ], context),
              ),
              Expanded(
                child: _buildFooterColumn('Useful Links', [
                  'Privacy Policy',
                  'Terms & Conditions',
                  'Cancellation Policy',
                  'Refund Policy',
                  'Sitemap',
                ], context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('follow_us'),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Social media links - Update URLs here if EaseMyTrip rebrands or changes handles
                        _buildSocialIcon(Icons.facebook, 'https://www.facebook.com/EaseMyTrip', context, 'Facebook'),
                        _buildSocialIcon(Icons.camera_alt, 'https://www.instagram.com/easemytrip', context, 'Instagram'),
                        _buildSocialIcon(Icons.chat, 'https://twitter.com/easemytrip', context, 'Twitter/X'),
                        _buildSocialIcon(Icons.video_library, 'https://www.youtube.com/c/EaseMyTripOfficial', context, 'YouTube'),
                        _buildSocialIcon(Icons.business, 'https://www.linkedin.com/company/easemytrip-com/', context, 'LinkedIn'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Download App',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening App Store...')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.onSurface),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.apple, color: colorScheme.onSurface, size: 20),
                                const SizedBox(width: 6),
                                Text('App Store', style: TextStyle(color: colorScheme.onSurface, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Play Store...')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.onSurface),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.android, color: colorScheme.onSurface, size: 20),
                                const SizedBox(width: 6),
                                Text('Play Store', style: TextStyle(color: colorScheme.onSurface, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© ${DateTime.now().year} EaseMyTrip.com. ${AppLocalizations.of(context).translate('all_rights_reserved')}',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              Row(
                children: [
                  Icon(Icons.language, color: colorScheme.onSurfaceVariant, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'English (India)',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> links, BuildContext context) {
    final linkRoutes = {
      'About EaseMyTrip AI': '/about',
      'How It Works': '/how-it-works',
      'Careers': '/careers',
      'Blog': '/blog',
      'Help Center': '/support',
      'FAQs': '/faqs',
      'Contact Us': '/support',
      'Privacy Policy': '/privacy',
      'Terms & Conditions': '/terms',
      'Cancellation Policy': '/cancellation-policy',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  final route = linkRoutes[link];
                  if (route != null) {
                    Navigator.pushNamed(context, route);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$link - Coming soon')),
                    );
                  }
                },
                child: Text(
                  link,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  /// Social media icon with hover effect and external link launch
  /// Opens link in new tab, shows error toast if launch fails
  Widget _buildSocialIcon(IconData icon, String url, BuildContext context, String tooltip) {
    return _HoverSocialIcon(
      icon: icon,
      url: url,
      tooltip: tooltip,
    );
  }
}

/// Stateful widget for hover scale animation on social media icons
class _HoverSocialIcon extends StatefulWidget {
  final IconData icon;
  final String url;
  final String tooltip;

  const _HoverSocialIcon({
    required this.icon,
    required this.url,
    required this.tooltip,
  });

  @override
  State<_HoverSocialIcon> createState() => _HoverSocialIconState();
}

class _HoverSocialIconState extends State<_HoverSocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(widget.url);
            try {
              // Open in new tab without reloading current page
              final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!launched) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to open link. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
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
          },
          child: AnimatedScale(
            scale: _isHovered ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: _isHovered ? 0.15 : 0.1),
                shape: BoxShape.circle,
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(widget.icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
