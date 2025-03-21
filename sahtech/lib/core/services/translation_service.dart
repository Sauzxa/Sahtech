import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Current app language
  String _currentLanguage = 'fr';

  // Cache for translations to avoid repeated API calls
  final Map<String, Map<String, String>> _translationCache = {};

  // Key UI text that needs translation
  final Map<String, String> _defaultTexts = {
    'chronic_disease_question': 'Avez vous une maldie chronique ?',
    'chronic_disease_explanation':
        'Pour une meilleure expérience et un scan personnalisé adapté à votre profil, nous avons besoin de connaître certaines informations sur votre état de santé',
    'yes': 'Oui',
    'no': 'Non',
    'next': 'suivant',
    'select_language': 'Choisir une langue',
    'please_select_option': 'Veuillez sélectionner une option',
    'information_saved': 'Informations enregistrées avec succès!',
  };

  // Initialize the translation service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'fr';

    // Preload translations for current language if not French
    if (_currentLanguage != 'fr') {
      await _loadTranslations(_currentLanguage);
    }
  }

  // Change the app language
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    _currentLanguage = languageCode;

    // Save language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);

    // Load translations if needed
    if (languageCode != 'fr' && !_translationCache.containsKey(languageCode)) {
      await _loadTranslations(languageCode);
    }
  }

  // Get the current language code
  String get currentLanguage => _currentLanguage;

  // Translate a specific text
  String translate(String key) {
    // Return original French text if language is French
    if (_currentLanguage == 'fr') {
      return _defaultTexts[key] ?? key;
    }

    // Return cached translation if available
    if (_translationCache.containsKey(_currentLanguage)) {
      return _translationCache[_currentLanguage]?[key] ??
          _defaultTexts[key] ??
          key;
    }

    // Return default text if translation not available
    return _defaultTexts[key] ?? key;
  }

  // Load translations for a specific language
  Future<void> _loadTranslations(String languageCode) async {
    // Skip if already loaded or it's French (default)
    if (languageCode == 'fr' || _translationCache.containsKey(languageCode)) {
      return;
    }

    _translationCache[languageCode] = {};

    // Translate each default text
    for (var entry in _defaultTexts.entries) {
      final translation = await _translateText(entry.value, 'fr', languageCode);
      if (translation != null) {
        _translationCache[languageCode]?[entry.key] = translation;
      }
    }
  }

  // Call Google Translate API
  Future<String?> _translateText(String text, String from, String to) async {
    try {
      // Using the free translation API
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$from&tl=$to&dt=t&q=${Uri.encodeComponent(text)}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response
        final jsonResponse = json.decode(response.body);
        final translatedText = jsonResponse[0][0][0];
        return translatedText;
      }

      return null;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }
}
