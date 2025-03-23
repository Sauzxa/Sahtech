import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translationService =
        Provider.of<TranslationService>(context, listen: false);
    final currentLanguage = translationService.currentLanguageCode;

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      offset: const Offset(0, 40),
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translationService.getLanguageFlag(currentLanguage),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.grey[700],
          ),
        ],
      ),
      onSelected: (languageCode) {
        if (languageCode != currentLanguage) {
          // Update the app's language
          _changeLanguage(context, languageCode);
        }
      },
      itemBuilder: (context) {
        return TranslationService.supportedLocales.map((locale) {
          final languageCode = locale.languageCode;
          final isSelected = languageCode == currentLanguage;

          return PopupMenuItem<String>(
            value: languageCode,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Language flag and name
                Row(
                  children: [
                    Text(
                      translationService.getLanguageFlag(languageCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      translationService.getLanguageName(languageCode),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.lightTeal : Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Selected checkmark
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: AppColors.lightTeal,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    // Get translation service
    final translationService =
        Provider.of<TranslationService>(context, listen: false);

    // Use the centralized language change method
    await translationService.handleLanguageChange(context, languageCode);
  }
}
