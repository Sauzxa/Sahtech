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
  bool _isLoading = false;

  // Cache for translations to avoid repeated API calls
  final Map<String, Map<String, String>> _translationCache = {};

  // Supported languages with their flags and names
  final Map<String, Map<String, String>> supportedLanguages = {
    'fr': {'flag': '🇫🇷', 'name': 'Français'},
    'en': {'flag': '🇬🇧', 'name': 'English'},
    'ar': {'flag': '🇸🇦', 'name': 'العربية'},
  };

  // RTL languages
  static final Set<String> rtlLanguages = {'ar'};

  // Get the current language code
  String get currentLanguageCode => _currentLanguageCode;
  String get currentLanguage => _currentLanguageCode;
  bool get isLoading => _isLoading;

  // Initialize the translation service
  Future<void> init() async {
    await _loadSavedLocale();
  }

  /// Load the saved locale from shared preferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);

      if (savedLocale != null && supportedLanguages.containsKey(savedLocale)) {
        _currentLanguageCode = savedLocale;
        notifyListeners();
      }
    } catch (e) {
      // Fallback to default if there's an error
      _currentLanguageCode = _defaultLocale;
    }
  }

  // Change the app language
  Future<void> changeLocale(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      return;
    }

    if (_currentLanguageCode == languageCode) return;

    _isLoading = true;
    notifyListeners();

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
      debugPrint('Error saving locale: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force an immediate refresh of translations across the app
  void forceSyncRefresh() {
    notifyListeners();
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
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    return text; // Return original if translation fails
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

  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLanguageCode) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      _currentLanguageCode = languageCode;

      // Clear any cached translations to force refresh
      _translationCache.clear();

      // Notify listeners immediately to trigger UI updates
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
