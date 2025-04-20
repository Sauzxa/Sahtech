import 'package:flutter/material.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/onboarding/loading.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen1.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen2.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen3.dart';
import 'package:sahtech/presentation/profile/choice_screen.dart';
import 'package:sahtech/presentation/profile/getstarted.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/presentation/home/home_screen.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/auth/SigninUser.dart';

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

  const Main({super.key, required this.translationService});

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
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X dimensions
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sahtech',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
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
              '/onboarding3': (context) => const OnboardingScreen3(),
              '/profile1': (context) => const ChoiceScreen(),
              '/login': (context) =>
                  SigninUser(userData: UserModel(userType: 'USER')),
            },
            // Handle navigation to home screen with user data
            onGenerateRoute: (settings) {
              if (settings.name == '/home') {
                // Extract the user data from the arguments
                final userData = settings.arguments as UserModel? ??
                    UserModel(
                      userType: 'user',
                      name: 'Saleh Arafat',
                      userId: '12345',
                    );

                return MaterialPageRoute(
                  builder: (context) => HomeScreen(userData: userData),
                );
              }
              return null;
            },
            // Handle RTL text direction
            builder: (context, child) {
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
