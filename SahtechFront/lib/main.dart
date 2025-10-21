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
import 'package:sahtech/core/auth/auth_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:sahtech/presentation/home/HistoriqueScannedProducts.dart';
import 'package:sahtech/core/CustomWidgets/HistoRecommandationPage.dart';
import 'package:sahtech/core/utils/models/product_model.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sahtech/core/l10n/generated/app_localizations.dart';

// Device preview removed as requested
// f
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize translation service
  final translationService = TranslationService();
  await translationService.init();

  // Initialize storage service
  final storageService = StorageService();

  // Check if camera permission has been requested before
  final hasRequestedCameraPermission =
      await storageService.getCameraPermissionRequested();

  // Only request camera permission if it hasn't been requested before
  if (!hasRequestedCameraPermission) {
    try {
      print('First time requesting camera permission');
      final cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        await Permission.camera.request();
        // Mark that we've requested camera permission
        await storageService.setCameraPermissionRequested(true);
      }
      print(
          'Camera permission status at app startup: ${await Permission.camera.status}');
    } catch (e) {
      print('Error requesting camera permission: $e');
    }
  } else {
    print(
        'Camera permission already requested previously, skipping request at startup');
  }

  // For debugging: Print auth status at startup
  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userId = prefs.getString('user_id');
    final userType = prefs.getString('user_type');
    final token = prefs.getString('auth_token');

    print('=== AUTH DEBUG INFO ===');
    print('Is logged in: $isLoggedIn');
    print('User ID: $userId');
    print('User type: $userType');
    print('Token exists: ${token != null && token.isNotEmpty}');
    if (token != null && token.isNotEmpty) {
      print('Token (first 10 chars): ${token.substring(0, 10)}...');
    }
    print('======================');
  } catch (e) {
    print('Error checking auth state: $e');
  }

  runApp(
    Main(
      translationService: translationService,
    ),
  );
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
            // Add localization delegates
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            // Use AuthCheck as initial widget instead of SplashScreen
            home: const AuthCheck(),
            // Routes for the app
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/getstarted': (context) => const Getstarted(),
              '/onboarding1': (context) => const OnboardingScreen1(),
              '/onboarding2': (context) => const OnboardingScreen2(),
              '/onboarding3': (context) => const OnboardingScreen3(),
              '/profile1': (context) => const ChoiceScreen(),
              '/login': (context) =>
                  SigninUser(userData: UserModel(userType: 'USER')),
              '/historique': (context) => const HistoriqueScannedProducts(),
            },
            // Handle navigation for routes that need arguments
            onGenerateRoute: (settings) {
              print('Navigating to: ${settings.name}');

              if (settings.name == '/home') {
                // Extract the user data from the arguments
                final userData = settings.arguments as UserModel?;

                if (userData != null) {
                  print('Navigating to home with user ID: ${userData.userId}');
                } else {
                  print('Warning: Navigating to home with NULL user data');
                }

                // Apply fallback data if needed
                final finalUserData = userData ??
                    UserModel(
                      userType: 'user',
                      name: 'Saleh Arafat',
                      userId: '12345',
                    );

                return MaterialPageRoute(
                  builder: (context) => HomeScreen(userData: finalUserData),
                );
              } else if (settings.name == '/recommendation') {
                // Extract the data from the arguments
                try {
                  if (settings.arguments is ProductModel) {
                    // Handle legacy style arguments (just ProductModel)
                    final productData = settings.arguments as ProductModel;
                    print(
                        'Navigating to recommendation for product: ${productData.name}');
                    return MaterialPageRoute(
                      builder: (context) =>
                          HistoRecommandationPage(product: productData),
                    );
                  } else if (settings.arguments is Map) {
                    // Handle combined arguments with both product and user data
                    final args = settings.arguments as Map;
                    final productData = args['product'] as ProductModel?;

                    if (productData == null) {
                      print(
                          'Warning: No product data in recommendation arguments');
                      return MaterialPageRoute(
                        builder: (context) => const HistoriqueScannedProducts(),
                      );
                    }

                    print(
                        'Navigating to recommendation for product: ${productData.name}');
                    return MaterialPageRoute(
                      builder: (context) =>
                          HistoRecommandationPage(product: productData),
                    );
                  } else {
                    print('Warning: Invalid arguments type for recommendation');
                    return MaterialPageRoute(
                      builder: (context) => const HistoriqueScannedProducts(),
                    );
                  }
                } catch (e) {
                  print('Error processing recommendation arguments: $e');
                  return MaterialPageRoute(
                    builder: (context) => const HistoriqueScannedProducts(),
                  );
                }
              } else if (settings.name == '/scanner') {
                // ProductScannerScreen doesn't accept userData parameter
                print('Navigating to scanner');
                return MaterialPageRoute(
                  builder: (context) => const ProductScannerScreen(),
                );
              } else if (settings.name == '/history' ||
                  settings.name == '/historique') {
                // Navigate to history with preserved user data if available
                final userData = settings.arguments as UserModel?;

                if (userData != null) {
                  print(
                      'Navigating to history with user ID: ${userData.userId}');
                  return MaterialPageRoute(
                    builder: (context) =>
                        HistoriqueScannedProducts(userData: userData),
                  );
                } else {
                  print('Navigating to history without user data');
                  return MaterialPageRoute(
                    builder: (context) => const HistoriqueScannedProducts(),
                  );
                }
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
