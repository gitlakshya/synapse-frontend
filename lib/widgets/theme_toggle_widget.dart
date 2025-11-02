import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode == ThemeMode.dark
        ? 'Dark mode'
        : themeProvider.themeMode == ThemeMode.light
            ? 'Light mode'
            : 'System theme';
    
    return Semantics(
      label: 'Theme selector',
      hint: 'Current theme: $currentMode',
      button: true,
      child: Tooltip(
        message: 'Change theme',
        child: PopupMenuButton<ThemeMode>(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : themeProvider.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
            color: Theme.of(context).colorScheme.primary,
          ),
          onSelected: (mode) => themeProvider.setThemeMode(mode),
          itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              const Icon(Icons.light_mode),
              const SizedBox(width: 12),
              const Text('Light'),
              if (themeProvider.themeMode == ThemeMode.light) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              const Icon(Icons.dark_mode),
              const SizedBox(width: 12),
              const Text('Dark'),
              if (themeProvider.themeMode == ThemeMode.dark) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              const Icon(Icons.brightness_auto),
              const SizedBox(width: 12),
              const Text('System'),
              if (themeProvider.themeMode == ThemeMode.system) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ],
          ),
        ),
      ],
        ),
      ),
    );
  }
}
