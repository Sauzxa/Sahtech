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

  // Cache for batch translations
  final Map<String, Map<String, String>> _batchTranslationCache = {};

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
      debugPrint('Error loading locale: $e');
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
      _batchTranslationCache.removeWhere(
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

    // Add retry mechanism
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Using the free translation API
        final url = Uri.parse(
            'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$source&tl=$target&dt=t&q=${Uri.encodeComponent(text)}');

        final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Translation request timed out');
          },
        );

        if (response.statusCode == 200) {
          // Parse the response
          final jsonResponse = json.decode(response.body);
          if (jsonResponse != null &&
              jsonResponse is List &&
              jsonResponse.isNotEmpty &&
              jsonResponse[0] is List &&
              jsonResponse[0].isNotEmpty &&
              jsonResponse[0][0] is List &&
              jsonResponse[0][0].isNotEmpty) {
            final translatedText = jsonResponse[0][0][0] as String;

            // Cache the result
            _translationCache[target] ??= {};
            _translationCache[target]![text] = translatedText;

            return translatedText;
          } else {
            throw Exception('Invalid response format from translation API');
          }
        } else {
          throw Exception(
              'Translation API returned status code ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Translation error (attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          debugPrint('Translation failed after $maxRetries attempts: $e');
          return text; // Return original text after all retries failed
        }

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }

    return text; // This should not be reached, but return original as fallback
  }

  // Batch translate a list of strings for better performance
  Future<List<String>> translateBatch(List<String> texts,
      {String? targetLanguage}) async {
    if (texts.isEmpty) return [];

    final target = targetLanguage ?? _currentLanguageCode;
    final source = _defaultLocale;

    // If target is French (our default), just return the original texts
    if (target == _defaultLocale) return List.from(texts);

    // Create a cache key from all texts
    final cacheKey = texts.join('||');

    // Check batch cache first
    if (_batchTranslationCache.containsKey(target) &&
        _batchTranslationCache[target]!.containsKey(cacheKey)) {
      final cachedResult = _batchTranslationCache[target]![cacheKey]!;
      return cachedResult.split('||');
    }

    // Otherwise translate each text individually
    final List<String> translatedTexts = [];
    for (final text in texts) {
      translatedTexts.add(await translate(text, targetLanguage: target));
    }

    // Cache the batch result
    _batchTranslationCache[target] ??= {};
    _batchTranslationCache[target]![cacheKey] = translatedTexts.join('||');

    return translatedTexts;
  }

  // Translate a map of values
  Future<Map<String, String>> translateMap(Map<String, String> texts,
      {String? targetLanguage}) async {
    final target = targetLanguage ?? _currentLanguageCode;
    final result = <String, String>{};

    // If target is French (our default), just return the original texts
    if (target == _defaultLocale) return Map.from(texts);

    // Collect all texts into a list for batch translation
    final List<String> allTexts = texts.values.toList();
    final List<String> allKeys = texts.keys.toList();

    // Perform batch translation
    final List<String> translatedTexts =
        await translateBatch(allTexts, targetLanguage: target);

    // Map the results back to original keys
    for (int i = 0; i < allKeys.length; i++) {
      if (i < translatedTexts.length) {
        result[allKeys[i]] = translatedTexts[i];
      } else {
        // Fallback if for some reason translation list is shorter
        result[allKeys[i]] = texts[allKeys[i]]!;
      }
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
      _batchTranslationCache.clear();

      // Notify listeners immediately to trigger UI updates
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get direction for current language (LTR or RTL)
  TextDirection getTextDirection() {
    return rtlLanguages.contains(_currentLanguageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  // Check if current language is RTL
  bool get isRTL => rtlLanguages.contains(_currentLanguageCode);

  // Default translations map
  static final Map<String, String> _defaultTranslations = {
    'phone_title': 'Ajouter votre numero de telephone',
    'phone_subtitle': 'We\'ll send you a verification code',
    'phone_label': 'Veuillez entrer votre numéro de téléphone',
    'phone_required': 'Phone number is required',
    'continue': 'Continue',
    'availability_title': 'Set Your Availability',
    'availability_subtitle': 'Choose your working hours',
    'working_days': 'Working Days',
    'working_hours': 'Working Hours',
    'start_time': 'Start Time',
    'end_time': 'End Time',
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
    'success_title': 'Donné rempli avec Scucceé',
    'success_message':
        'Est ce que vous voulez publier ces données pour être affiché dans la liste des nutritionistes en ligne',
    'get_started': 'Commencer',
    'verification_title': 'Verification SMS',
    'verification_subtitle':
        'Un SMS a etait envoyé veuillez verifier votre telephone',
    'resend_code': 'Renvoyer',
    'password_title': 'Veuillez choisir un mot de passe pour votre compte',
    'password_subtitle':
        'Assurez-vous que le mot de passe contient au moins 8 caractères, incluant des lettres majuscules et minuscules, des chiffres et des caractères spéciaux',
    'password_label': 'Mot de passe',
    'password_hint': 'Entrer votre mot de passe',
    'confirm_label': 'Confirmation',
    'confirm_hint': 'Entrer votre confirmation',
    'create_account': 'Créer le compte',
    'password_requirements':
        'Le mot de passe doit contenir au moins 8 caractères, incluant des lettres majuscules et minuscules, des chiffres et des caractères spéciaux',
    'password_mismatch': 'Les mots de passe ne correspondent pas',
  };

  // Get translations for the current language
  static Future<Map<String, String>> getTranslations() async {
    final service = TranslationService();
    if (service.currentLanguageCode == _defaultLocale) {
      return _defaultTranslations;
    }

    final translatedMap = <String, String>{};
    for (final entry in _defaultTranslations.entries) {
      translatedMap[entry.key] = await service.translate(
        entry.value,
        targetLanguage: service.currentLanguageCode,
      );
    }
    return translatedMap;
  }
}
