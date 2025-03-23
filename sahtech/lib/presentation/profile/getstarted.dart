import 'package:flutter/material.dart';
import 'package:sahtech/presentation/profile/profile1.dart';
import 'package:sahtech/core/base/base_screen.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';

class Getstarted extends StatefulWidget {
  const Getstarted({Key? key}) : super(key: key);

  @override
  State<Getstarted> createState() => _GetstartedState();
}

class _GetstartedState extends State<Getstarted> with TranslationMixin {
  @override
  Map<String, String> get initialTranslations => {
        'title': 'Votre santé est notre priorité',
        'subtitle': 'Soyez plus saine avec notre application sahtech',
        'getStarted': 'Get started',
      };

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final safeAreaBottom = bottomPadding;

    // Calculate responsive font sizes based on screen width
    final titleSize = width * 0.055;
    final subtitleSize = width * 0.035;
    final buttonTextSize = width * 0.045;

    // If still loading translations, show a loading indicator
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      // No AppBar to match Figma design
      body: SafeArea(
        child: Column(
          children: [
            // Top section with green background (with rounded bottom corners)
            Expanded(
              flex: 7, // 70% of the available height
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  color: Color(0xFFd9f7c2), // Light green background from Figma
                ),
                child: Column(
                  children: [
                    // Language selector and logo at the top
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          width * 0.05, height * 0.02, width * 0.05, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          LanguageSelectorWidget(
                            onTap: () => showLanguageSelector(context),
                          ),
                        ],
                      ),
                    ),

                    // Sahtech logo
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.01),
                      child: Image.asset(
                        'lib/assets/images/logo2.jpg',
                        height: height * 0.05,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Illustration - taking most of the space
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                        child: Image.asset(
                          'lib/assets/images/getstarted2.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Small bottom padding for rounded corners
                    SizedBox(height: height * 0.01),
                  ],
                ),
              ),
            ),

            // Bottom section with white background
            Expanded(
              flex: 3, // 30% of the available height
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                    width * 0.08,
                    height * 0.02,
                    width * 0.08,
                    safeAreaBottom > 0 ? safeAreaBottom : height * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and subtitle text
                    Column(
                      children: [
                        Text(
                          translations['title']!,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          translations['subtitle']!,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // Get Started button - positioned at the bottom with padding
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.01),
                      child: SizedBox(
                        width: double.infinity,
                        height: height * 0.055, // Responsive height
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to profile1.dart
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Profile1(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB7F397),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            translations['getStarted']!,
                            style: TextStyle(
                              fontSize: buttonTextSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
