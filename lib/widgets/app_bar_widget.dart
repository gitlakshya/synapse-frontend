import 'package:flutter/material.dart';
import 'theme_toggle_widget.dart';
import 'ai_chat_widget.dart';
import 'saved_places_widget.dart';
import 'login_button_widget.dart';
import 'language_selector.dart';
import '../l10n/app_localizations.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const SharedAppBar({super.key, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _navigateTo(BuildContext context, String route) {
    try {
      Navigator.pushNamed(context, route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 800;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flight_takeoff, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title ?? (isSmall ? 'EaseMyTrip AI' : 'EaseMyTrip AI Planner'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: isSmall ? [
        const SavedPlacesWidget(),
        const LanguageSelector(showLabel: false),
        const LoginButtonWidget(showLabel: false),
        const ThemeToggleWidget(),
        const AIChatButton(showLabel: false),
        const SizedBox(width: 8),
      ] : [
        TextButton(onPressed: () => _navigateTo(context, '/flights'), child: Text(AppLocalizations.of(context).translate('flights'))),
        TextButton(onPressed: () => _navigateTo(context, '/hotels'), child: Text(AppLocalizations.of(context).translate('hotels'))),
        TextButton(onPressed: () => _navigateTo(context, '/trains'), child: Text(AppLocalizations.of(context).translate('trains'))),
        TextButton(onPressed: () => _navigateTo(context, '/buses'), child: Text(AppLocalizations.of(context).translate('buses'))),
        TextButton(onPressed: () => _navigateTo(context, '/cabs'), child: Text(AppLocalizations.of(context).translate('cabs'))),
        TextButton(onPressed: () => _navigateTo(context, '/my-trips'), child: Text(AppLocalizations.of(context).translate('my_trips'))),
        const AIChatButton(showLabel: true),
        const SizedBox(width: 12),
        const SavedPlacesWidget(),
        const LanguageSelector(showLabel: true),
        const SizedBox(width: 8),
        const LoginButtonWidget(showLabel: true),
        const ThemeToggleWidget(),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          tooltip: 'Home',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
