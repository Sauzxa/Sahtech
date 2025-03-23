import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/theme/colors.dart';

/// A widget that displays a language selector button and handles language selection
class LanguageSelectorButton extends StatelessWidget {
  /// Custom function to execute when language changes
  final Function(String languageCode)? onLanguageChanged;

  /// Width scaling factor for responsive design
  final double? width;

  const LanguageSelectorButton({
    Key? key,
    this.onLanguageChanged,
    this.width,
  }) : super(key: key);

  // Show the language selection dialog
  void _showLanguageDialog(BuildContext context) {
    final translationService =
        Provider.of<TranslationService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<String>(
            future: translationService.translate('Choisir une langue'),
            builder: (context, snapshot) {
              final title = snapshot.data ?? 'Choisir une langue';
              return SimpleDialog(
                title: Text(title),
                children: TranslationService.supportedLocales.map((locale) {
                  final languageCode = locale.languageCode;
                  final isSelected =
                      translationService.currentLanguageCode == languageCode;
                  return SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      _switchLanguage(context, languageCode);
                    },
                    child: Row(
                      children: [
                        Text(
                          translationService.getLanguageFlag(languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          translationService.getLanguageName(languageCode),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.lightTeal
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            });
      },
    );
  }

  // Switch language and notify the parent widget
  Future<void> _switchLanguage(
      BuildContext context, String languageCode) async {
    final translationService =
        Provider.of<TranslationService>(context, listen: false);

    if (languageCode == translationService.currentLanguageCode) return;

    // Use the centralized method for language change
    final success = await translationService
        .handleLanguageChange(context, languageCode, onSuccess: (code) {
      // Notify the parent widget if callback is provided
      if (onLanguageChanged != null) {
        onLanguageChanged!(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);
    final containerWidth = width ?? MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showLanguageDialog(context),
      child: Container(
        margin: EdgeInsets.only(right: containerWidth * 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              translationService
                  .getLanguageFlag(translationService.currentLanguageCode),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              translationService.currentLanguageCode.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
