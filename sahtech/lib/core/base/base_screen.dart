import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';

/// A base screen mixin that provides translation capabilities for any screen
mixin TranslationMixin<T extends StatefulWidget> on State<T> {
  late TranslationService _translationService;
  bool _isLoading = true;
  String _currentLanguage = '';

  // Map of strings to be translated
  Map<String, String> _translations = {};

  // Getter for accessing translations
  Map<String, String> get translations => _translations;

  // Expose isLoading state
  bool get isLoading => _isLoading;

  // Set initial translations (to be overridden by subclasses)
  Map<String, String> get initialTranslations => {};

  @override
  void initState() {
    super.initState();
    _translations = initialTranslations;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTranslations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if language has changed
    try {
      final translationService =
          Provider.of<TranslationService>(context, listen: true);
      if (_currentLanguage != translationService.currentLanguageCode) {
        _loadTranslations();
      }
    } catch (e) {
      // Provider might not be available yet
      debugPrint('TranslationMixin: Provider not ready - $e');
    }
  }

  // Load translations for the screen
  Future<void> _loadTranslations() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      _translationService =
          Provider.of<TranslationService>(context, listen: false);
      final currentLanguage = _translationService.currentLanguageCode;
      _currentLanguage = currentLanguage;

      // Only translate if not French (our default language) and if we have strings to translate
      if (currentLanguage != 'fr' && _translations.isNotEmpty) {
        final translated =
            await _translationService.translateMap(_translations);

        if (mounted) {
          setState(() {
            _translations = translated;
            _isLoading = false;
          });
        }
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper to translate a single string on demand
  Future<String> translate(String text) async {
    if (!mounted) return text;

    try {
      _translationService =
          Provider.of<TranslationService>(context, listen: false);
      return await _translationService.translate(text);
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  // Switch the app language
  Future<void> switchLanguage(String languageCode) async {
    if (!mounted) return;

    try {
      _translationService =
          Provider.of<TranslationService>(context, listen: false);
      if (languageCode == _translationService.currentLanguageCode) return;

      setState(() => _isLoading = true);
      await _translationService.changeLocale(languageCode);

      // Force app-wide refresh
      _translationService.forceSyncRefresh();

      await _loadTranslations();
    } catch (e) {
      debugPrint('Language switch error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method to show language selector
  void showLanguageSelector(BuildContext context) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
                'Choose Language'), // Could be translated but circular dependency
            children: TranslationService.supportedLocales.map((locale) {
              final languageCode = locale.languageCode;
              final isSelected =
                  _translationService.currentLanguageCode == languageCode;
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  switchLanguage(languageCode);
                },
                child: Row(
                  children: [
                    Text(_translationService.getLanguageFlag(languageCode),
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(_translationService.getLanguageName(languageCode),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.teal : Colors.black87,
                        )),
                  ],
                ),
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      debugPrint('Language selector error: $e');
    }
  }
}

/// A language selector widget that can be used in app bars
class LanguageSelectorWidget extends StatelessWidget {
  final Function() onTap;

  const LanguageSelectorWidget({Key? key, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
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
