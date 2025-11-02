import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

/// Language selector widget with dropdown menu
/// Integrates with LanguageProvider to manage global language state
/// Persists selection in local storage via provider
class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  
  const LanguageSelector({super.key, this.showLabel = false});

  // Indian regional languages - Add/remove languages here as needed
  // Format: 'code': {'name': 'Display Name', 'flag': 'Emoji'}
  static const Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'flag': '🇮🇳'},
    'hi': {'name': 'हिंदी', 'flag': '🇮🇳'},
    'te': {'name': 'తెలుగు', 'flag': '🇮🇳'},
    'ta': {'name': 'தமிழ்', 'flag': '🇮🇳'},
    'kn': {'name': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    'ml': {'name': 'മലയാളം', 'flag': '🇮🇳'},
    'bn': {'name': 'বাংলা', 'flag': '🇮🇳'},
    'mr': {'name': 'मराठी', 'flag': '🇮🇳'},
    'gu': {'name': 'ગુજરાતી', 'flag': '🇮🇳'},
    'pa': {'name': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    'ur': {'name': 'اُردُو', 'flag': '🇮🇳'},
    'as': {'name': 'অসমীয়া', 'flag': '🇮🇳'},
    'or': {'name': 'ଓଡ଼ିଆ', 'flag': '🇮🇳'},
  };
  
  // Old international languages (commented out for reference)
  // 'es': {'name': 'Español', 'flag': '🇪🇸'},
  // 'fr': {'name': 'Français', 'flag': '🇫🇷'},
  // 'de': {'name': 'Deutsch', 'flag': '🇩🇪'},
  // 'ja': {'name': '日本語', 'flag': '🇯🇵'},

  @override
  Widget build(BuildContext context) {
    // Watch language provider for reactive updates
    final languageProvider = context.watch<LanguageProvider>();
    final currentLocale = languageProvider.locale.languageCode;

    return Semantics(
      label: 'Language selection',
      button: true,
      child: Tooltip(
        message: 'Language',
        child: PopupMenuButton<String>(
          // Globe icon as visual cue
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  _languages[currentLocale]?['flag'] ?? '🌐',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
          // Update global language state on selection
          // Provider automatically persists to local storage
          onSelected: (languageCode) {
            languageProvider.setLocale(Locale(languageCode));
          },
          // Styled dropdown with rounded corners and shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          itemBuilder: (context) => _languages.entries.map((entry) {
            final code = entry.key;
            final lang = entry.value;
            final isSelected = currentLocale == code;
            
            return PopupMenuItem<String>(
              value: code,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Flag emoji
                    Text(
                      lang['flag']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    // Language name
                    Expanded(
                      child: Text(
                        lang['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Check mark for selected language
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
