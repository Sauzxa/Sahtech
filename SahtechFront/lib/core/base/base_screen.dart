import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';

/// A base screen mixin that provides translation capabilities for any screen
mixin TranslationMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = true;
  Map<String, String> _translations = {};
  late TranslationService _translationService;

  // Getter for accessing translations
  Map<String, String> get translations => _translations;

  // Expose isLoading state
  bool get isLoading => _isLoading;

  // Set initial translations (to be overridden by subclasses)
  Map<String, String> get initialTranslations => {};

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _translationService.addListener(_onLanguageChanged);
    _loadTranslations();
  }

  @override
  void dispose() {
    _translationService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  // This will be called whenever the language changes
  void _onLanguageChanged() {
    if (mounted) {
      _loadTranslations();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload translations when dependencies change
    _loadTranslations();
  }

  // Load translations for the screen
  Future<void> _loadTranslations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentLanguage = _translationService.currentLanguage;
      final newTranslations = await _translationService.translateMap(
        initialTranslations,
        targetLanguage: currentLanguage,
      );

      if (mounted) {
        setState(() {
          _translations = newTranslations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading translations: $e');
    }
  }

  // Helper to translate a single string on demand
  Future<String> translate(String text) async {
    if (!mounted) return text;

    try {
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
      if (languageCode == _translationService.currentLanguageCode) return;

      setState(() => _isLoading = true);

      // Change the language
      await _translationService.setLanguage(languageCode);

      // _loadTranslations will be called automatically by the listener
    } catch (e) {
      debugPrint('Language switch error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method to show language selector
  void showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    ).then((_) {
      // Force refresh translations after dialog closes
      if (mounted) {
        _loadTranslations();
      }
    });
  }
}

/// A language selector widget that can be used in app bars
class LanguageSelectorWidget extends StatelessWidget {
  final Function() onTap;

  const LanguageSelectorWidget({super.key, required this.onTap});

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
