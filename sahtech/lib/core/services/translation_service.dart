import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService extends ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String _localeKey = 'app_language';
  static const String _defaultLocale = 'fr'; // French as default

  // Current app language
  String _currentLanguageCode = _defaultLocale;

  // Cache for translations to avoid repeated API calls
  final Map<String, Map<String, String>> _translationCache = {};

  // Supported languages
  static final List<Locale> supportedLocales = [
    const Locale('fr'), // French
    const Locale('en'), // English
    const Locale('es'), // Spanish
    const Locale('ar'), // Arabic
    const Locale('de'), // German
  ];

  // Flags (emojis) for each language
  final Map<String, String> languageFlags = {
    'fr': '🇫🇷',
    'en': '🇬🇧',
    'es': '🇪🇸',
    'ar': '🇸🇦',
    'de': '🇩🇪',
  };

  // Names of each language in its native form
  final Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'es': 'Español',
    'ar': 'العربية',
    'de': 'Deutsch',
  };

  // RTL languages
  static final Set<String> rtlLanguages = {'ar'};

  // Get the current language code
  String get currentLanguageCode => _currentLanguageCode;

  // Get the current locale
  Locale get currentLocale => Locale(_currentLanguageCode);

  // Check if current language is RTL
  bool get isCurrentLanguageRtl => rtlLanguages.contains(_currentLanguageCode);

  // Initialize the translation service
  Future<void> init() async {
    await _loadSavedLocale();
  }

  /// Load the saved locale from shared preferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);

      if (savedLocale != null &&
          supportedLocales
              .any((locale) => locale.languageCode == savedLocale)) {
        _currentLanguageCode = savedLocale;
      }
    } catch (e) {
      // Fallback to default if there's an error
      _currentLanguageCode = _defaultLocale;
    }
  }

  // A centralized method to handle language changes throughout the app
  Future<bool> handleLanguageChange(BuildContext context, String languageCode,
      {Function(String)? onSuccess}) async {
    // Show a loading indicator while changing languages
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Change the app's locale
      await changeLocale(languageCode);

      // Force a UI refresh
      forceSyncRefresh();

      // Remove loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Call the success callback if provided
      if (onSuccess != null) {
        onSuccess(languageCode);
      }

      return true;
    } catch (e) {
      // Remove loading dialog in case of error
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change language: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  // Change the app language
  Future<void> changeLocale(String languageCode) async {
    // Verify the language code is supported
    if (!supportedLocales
        .any((locale) => locale.languageCode == languageCode)) {
      return;
    }

    if (_currentLanguageCode == languageCode) return;

    try {
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);

      // Update current language code
      _currentLanguageCode = languageCode;

      // Clear cache for other languages to save memory
      _translationCache.removeWhere(
          (key, _) => key != languageCode && key != _defaultLocale);

      // Notify listeners that the locale has changed
      notifyListeners();
    } catch (e) {
      // Handle error if needed
      debugPrint('Error saving locale: $e');
    }
  }

  // Force an immediate refresh of translations across the app
  void forceSyncRefresh() {
    notifyListeners();
  }

  /// Get locale name in native language
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  /// Get locale flag emoji
  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '';
  }

  /// Check if a language is RTL
  bool isRtl(String languageCode) {
    return rtlLanguages.contains(languageCode);
  }

  // Translate a specific text
  Future<String> translate(String text,
      {String? targetLanguage, String? sourceLanguage}) async {
    if (text.isEmpty) return text;

    // Use current language if target not specified
    final target = targetLanguage ?? _currentLanguageCode;
    final source = sourceLanguage ?? _defaultLocale;

    // If text is already in the target language or target is French (our default), return it
    if (source == target || target == _defaultLocale) return text;

    // Check cache first before making API call
    if (_translationCache.containsKey(target) &&
        _translationCache[target]!.containsKey(text)) {
      return _translationCache[target]![text]!;
    }

    try {
      // Using the free translation API
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$source&tl=$target&dt=t&q=${Uri.encodeComponent(text)}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response
        final jsonResponse = json.decode(response.body);
        final translatedText = jsonResponse[0][0][0] as String;

        // Cache the result
        _translationCache[target] ??= {};
        _translationCache[target]![text] = translatedText;

        return translatedText;
      }

      return text; // Return original if translation fails
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original if there's an exception
    }
  }

  // Translate a map of values
  Future<Map<String, String>> translateMap(Map<String, String> texts,
      {String? targetLanguage}) async {
    final target = targetLanguage ?? _currentLanguageCode;
    final result = <String, String>{};

    // If target is French (our default), just return the original texts
    if (target == _defaultLocale) return Map.from(texts);

    // Process each text entry
    for (var entry in texts.entries) {
      result[entry.key] = await translate(entry.value, targetLanguage: target);
    }

    return result;
  }
}
