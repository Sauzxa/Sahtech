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
                children:
                    translationService.supportedLanguages.entries.map((entry) {
                  final languageCode = entry.key;
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
                          entry.value['flag'] ?? '',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.value['name'] ?? '',
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Change the language
      await translationService.setLanguage(languageCode);

      // Notify the parent widget if callback is provided
      if (onLanguageChanged != null) {
        onLanguageChanged!(languageCode);
      }
    } finally {
      // Remove loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
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
              translationService.supportedLanguages[
                      translationService.currentLanguageCode]?['flag'] ??
                  '',
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

/// A language selector dialog that can be used throughout the app
class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);

    return AlertDialog(
      title: const Text('Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: translationService.supportedLanguages.entries.map((entry) {
          final isSelected =
              translationService.currentLanguageCode == entry.key;
          return ListTile(
            leading: Text(entry.value['flag'] ?? ''),
            title: Text(entry.value['name'] ?? ''),
            selected: isSelected,
            onTap: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Close the language selector dialog
                Navigator.pop(context);

                // Change the language
                await translationService.setLanguage(entry.key);
              } finally {
                // Make sure the loading dialog is dismissed
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
