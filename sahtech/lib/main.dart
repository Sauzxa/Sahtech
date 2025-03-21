import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sahtech/core/services/localization_service.dart';
import 'package:sahtech/presentation/onboarding/loading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Global key to access the Main state from anywhere
final GlobalKey<_Main> mainNavigatorKey = GlobalKey<_Main>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization service
  final localizationService = LocalizationService();
  // No need to explicitly load saved locale, as it's done in the constructor

  runApp(Main(
    localizationService: localizationService,
    key: mainNavigatorKey,
  ));
}

class Main extends StatefulWidget {
  final LocalizationService localizationService;

  const Main({super.key, required this.localizationService});

  // Static method to change locale from anywhere in the app
  static void changeLocale(BuildContext context, String languageCode) {
    final _Main? mainState = mainNavigatorKey.currentState;
    if (mainState != null) {
      mainState.setLocaleByCode(languageCode);
    }
  }

  @override
  State<Main> createState() => _Main();
}

class _Main extends State<Main> {
  late LocalizationService _localizationService;
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _localizationService = widget.localizationService;
    _currentLocale = _localizationService.currentLocale;
  }

  // This function will be passed down to children to update app locale
  void setLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  // This function will be used to change locale by language code
  Future<void> setLocaleByCode(String languageCode) async {
    await _localizationService.changeLocale(languageCode);
    setState(() {
      _currentLocale = _localizationService.currentLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine text direction for the entire app
    final isRtl = _localizationService.isRtl(_currentLocale.languageCode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Localization config
      locale: _currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      // Handle RTL text direction
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: SplashScreen(),
    );
  }
}
