import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, child) {
        final currentLang = LocalizationService.supportedLanguages
            .firstWhere((lang) => lang['code'] == localization.currentLanguage);
        
        return PopupMenuButton<String>(
          onSelected: (String languageCode) {
            HapticFeedback.selectionClick();
            localization.setLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) {
            return LocalizationService.supportedLanguages.map((language) {
              final isSelected = language['code'] == localization.currentLanguage;
              return PopupMenuItem<String>(
                value: language['code'],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        language['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.deepOrangeAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.deepOrangeAccent, size: 16),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLang['name']!,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}