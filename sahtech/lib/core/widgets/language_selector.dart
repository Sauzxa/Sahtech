import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/translation_helper.dart';

/// A widget that displays a language selector button and handles language selection
class LanguageSelectorButton extends StatelessWidget {
  /// Custom function to execute when language changes
  final Function(String languageCode)? onLanguageChanged;

  /// Width scaling factor for responsive design
  final double? width;

  const LanguageSelectorButton({
    super.key,
    this.onLanguageChanged,
    this.width,
  });

  // Show the language selection dialog
  void _showLanguageDialog(BuildContext context) async {
    final translationService =
        Provider.of<TranslationService>(context, listen: false);

    // Create translation helper with dialog translations
    final helper = TranslationHelper(context, {
      'dialog_title': 'Choisir une langue',
      'select_language': 'Sélectionner',
      'cancel': 'Annuler',
    });

    // Get translations
    final translations = await helper.translateAll();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(translations['dialog_title']!),
          children: translationService.supportedLanguages.entries.map((entry) {
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
                      color: isSelected ? AppColors.lightTeal : Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.lightTeal,
                        size: 20,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
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
    } catch (e) {
      debugPrint('Error switching language: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing language. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
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
  final Function(String)? onLanguageChanged;

  const LanguageSelectorDialog({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);

    // Create translation helper with dialog translations
    final helper = TranslationHelper(context, {
      'dialog_title': 'Choisir une langue',
      'select_language': 'Sélectionner',
      'cancel': 'Annuler',
    });

    // Instead of using async/await in build, use FutureBuilder
    return FutureBuilder<Map<String, String>>(
      future: helper.translateAll(),
      builder: (context, snapshot) {
        // Show loading indicator while translations are loading
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final translations = snapshot.data!;

        return AlertDialog(
          title: Text(translations['dialog_title']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                translationService.supportedLanguages.entries.map((entry) {
              final isSelected =
                  translationService.currentLanguageCode == entry.key;
              return ListTile(
                leading: Text(entry.value['flag'] ?? ''),
                title: Text(entry.value['name'] ?? ''),
                selected: isSelected,
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppColors.lightTeal)
                    : null,
                onTap: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.lightTeal,
                      ),
                    ),
                  );

                  try {
                    // Close the language selector dialog
                    Navigator.pop(context);

                    // Change the language
                    await translationService.setLanguage(entry.key);

                    // Call the callback if provided
                    if (onLanguageChanged != null) {
                      onLanguageChanged!(entry.key);
                    }
                  } catch (e) {
                    debugPrint('Error switching language: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Error changing language. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translations['cancel']!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        );
      },
    );
  }
}
