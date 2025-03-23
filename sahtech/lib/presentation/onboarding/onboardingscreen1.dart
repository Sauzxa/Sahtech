import 'package:flutter/material.dart';
import 'onboardingscreen2.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/base/base_screen.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1>
    with TranslationMixin {
  @override
  Map<String, String> get initialTranslations => {
        'skip': 'Skip',
        'title': 'Bienvenue dans SahTech',
        'subtitle':
            'Scannez pour connaître les ingrédients de vos produits alimentaires et recevez des recommandations adaptées à votre profil.',
        'next': 'Suivant',
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.height < 700;

    // If still loading translations, show a loading indicator
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageSelectorWidget(
            onTap: () => showLanguageSelector(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.02,
          ),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen2()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.012,
                    ),
                    minimumSize: const Size(50, 40), // Increased tap target
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        translations['skip']!,
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.lightTeal,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Adaptive spacing
              SizedBox(
                  height:
                      isSmallDevice ? size.height * 0.02 : size.height * 0.03),

              // Image container without blur
              Expanded(
                flex: 4,
                child: Container(
                  width: 500,
                  height: 100,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FE870).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    'lib/assets/images/onbor2.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Adaptive spacing
              SizedBox(
                  height:
                      isSmallDevice ? size.height * 0.03 : size.height * 0.04),

              // Title text
              Text(
                translations['title']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * 0.02),

              // Subtitle text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Text(
                  translations['subtitle']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Adaptive spacing
              SizedBox(
                  height:
                      isSmallDevice ? size.height * 0.04 : size.height * 0.06),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    translations['next']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
//