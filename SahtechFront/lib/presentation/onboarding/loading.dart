import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sahtech/presentation/onboarding/onboardingscreen1.dart';
import 'package:sahtech/core/base/base_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/presentation/profile/getstarted.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, TranslationMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  Map<String, String> get initialTranslations => {
        'loading': 'Chargement...',
      };

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Create fade-in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation
    _controller.forward();

    // Navigate to onboarding screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen1()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // If loading translations, show only the logo
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            'lib/assets/images/mainlogo.jpg',
            width: width * 0.8,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with fade-in animation
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sahtech logo - using Image.asset for the logo image
                        Image.asset(
                          'lib/assets/images/mainlogo.jpg',
                          width: width * 0.8, // 80% of screen width
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading text at bottom
              Padding(
                padding: EdgeInsets.only(bottom: height * 0.05),
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      translations['loading'] ?? 'Loading...',
                      textStyle: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w300,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  ],
                  isRepeatingAnimation: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
