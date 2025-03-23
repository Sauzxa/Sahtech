import 'package:flutter/material.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/onboarding/loading.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen1.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen2.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen3.dart';
import 'package:sahtech/presentation/profile/profile1.dart';

// Global key to access the Main state from anywhere
final GlobalKey<_Main> mainNavigatorKey = GlobalKey<_Main>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize translation service
  final translationService = TranslationService();
  await translationService.init();

  runApp(Main(
    translationService: translationService,
    key: mainNavigatorKey,
  ));
}

class Main extends StatefulWidget {
  final TranslationService translationService;

  const Main({super.key, required this.translationService});

  // Static method to change language from anywhere in the app
  static void changeLanguage(BuildContext context, String languageCode) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get translation service
      final translationService =
          Provider.of<TranslationService>(context, listen: false);

      // Change locale
      await translationService.changeLocale(languageCode);

      // Force app-wide refresh
      translationService.forceSyncRefresh();

      // Hide loading indicator
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      // Hide loading indicator
      if (context.mounted) Navigator.pop(context);

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change language: $e')),
        );
      }
    }
  }

  @override
  State<Main> createState() => _Main();
}

class _Main extends State<Main> {
  late TranslationService _translationService;
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _translationService = widget.translationService;
    _currentLocale = _translationService.currentLocale;
  }

  // This function will be used to change language by code
  Future<void> setLanguageByCode(String languageCode) async {
    await _translationService.changeLocale(languageCode);
    setState(() {
      _currentLocale = _translationService.currentLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine text direction for the entire app
    final isRtl = _translationService.isRtl(_currentLocale.languageCode);

    return ChangeNotifierProvider<TranslationService>.value(
      value: _translationService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Set locale for the app
        locale: _currentLocale,
        // Routes for the app
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding1': (context) => const OnboardingScreen1(),
          '/onboarding2': (context) => const OnboardingScreen2(),
          '/onboarding3': (context) => const Onboardingscreen3(),
          '/profile1': (context) => const Profile1(),
        },
        // Handle RTL text direction
        builder: (context, child) {
          return Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          );
        },
      ),
    );
  }
}
