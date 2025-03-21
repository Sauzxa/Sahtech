import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service to manage localization in the app
class LocalizationService {
  static const String _localeKey = 'selected_locale';
  static const String _defaultLocale = 'fr'; // French as default

  // Supported locales for the app
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

  String _currentLanguageCode = _defaultLocale;

  /// Get the current language code
  String get currentLanguageCode => _currentLanguageCode;

  /// Get the current locale
  Locale get currentLocale => Locale(_currentLanguageCode);

  /// Check if current language is RTL
  bool get isCurrentLanguageRtl => rtlLanguages.contains(_currentLanguageCode);

  /// Constructor that initializes the service
  LocalizationService() {
    // Load saved locale from preferences when service is created
    _loadSavedLocale();
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

  /// Change the app locale and save to preferences
  Future<void> changeLocale(String languageCode) async {
    // Verify the language code is supported
    if (!supportedLocales
        .any((locale) => locale.languageCode == languageCode)) {
      return;
    }

    try {
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);

      // Update current language code
      _currentLanguageCode = languageCode;
    } catch (e) {
      // Handle error if needed
      debugPrint('Error saving locale: $e');
    }
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
}
