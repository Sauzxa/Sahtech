import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';

/// TranslationHelper is a utility class that helps manage translations in a consistent
/// way across different screens of the application.
class TranslationHelper {
  final BuildContext context;
  final Map<String, String> defaultTranslations;
  late TranslationService _translationService;

  TranslationHelper(this.context, this.defaultTranslations) {
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
  }

  /// Translates all the strings in the default translations map to the current language
  /// Returns a map with the translated strings
  Future<Map<String, String>> translateAll() async {
    final currentLanguage = _translationService.currentLanguageCode;

    // If current language is French (default), return the original strings
    if (currentLanguage == 'fr') {
      return Map.from(defaultTranslations);
    }

    try {
      return await _translationService.translateMap(defaultTranslations);
    } catch (e) {
      debugPrint('TranslationHelper error: $e');
      return Map.from(defaultTranslations); // Return default on error
    }
  }

  /// Translates a list of strings to the current language
  Future<List<String>> translateList(List<String> strings) async {
    final currentLanguage = _translationService.currentLanguageCode;

    // If current language is French (default), return the original strings
    if (currentLanguage == 'fr') {
      return List.from(strings);
    }

    try {
      return await _translationService.translateBatch(strings);
    } catch (e) {
      debugPrint('TranslationHelper error translating list: $e');
      return List.from(strings); // Return default on error
    }
  }

  /// Translate a single string to the current language
  Future<String> translateString(String text) async {
    final currentLanguage = _translationService.currentLanguageCode;

    // If current language is French (default), return the original string
    if (currentLanguage == 'fr') {
      return text;
    }

    try {
      return await _translationService.translate(text);
    } catch (e) {
      debugPrint('TranslationHelper error translating string: $e');
      return text; // Return original on error
    }
  }

  /// Gets the current language code
  String get currentLanguage => _translationService.currentLanguageCode;

  /// Checks if the current language is RTL
  bool get isRTL => _translationService.isRTL;

  /// Gets the text direction for the current language
  TextDirection get textDirection => _translationService.getTextDirection();
}

/// Extension method to get a translation helper instance directly from a BuildContext
extension TranslationHelperExtension on BuildContext {
  TranslationHelper translationHelper(Map<String, String> defaultTranslations) {
    return TranslationHelper(this, defaultTranslations);
  }
}
