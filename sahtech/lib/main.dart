import 'package:flutter/material.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/onboarding/loading.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen1.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen2.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen3.dart';
import 'package:sahtech/presentation/profile/profile1.dart';
import 'package:sahtech/presentation/profile/getstarted.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize translation service
  final translationService = TranslationService();
  await translationService.init();

  runApp(Main(
    translationService: translationService,
  ));
}

class Main extends StatefulWidget {
  final TranslationService translationService;

  const Main({Key? key, required this.translationService}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late TranslationService _translationService;

  @override
  void initState() {
    super.initState();
    _translationService = widget.translationService;
    // Listen to language changes
    _translationService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _translationService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  // This function will be called when language changes
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine text direction for the entire app
    final isRtl = TranslationService.rtlLanguages
        .contains(_translationService.currentLanguageCode);

    return ChangeNotifierProvider<TranslationService>.value(
      value: _translationService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sahtech',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Set locale for the app
        locale: Locale(_translationService.currentLanguageCode),
        // Routes for the app
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/getstarted': (context) => const Getstarted(),
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
