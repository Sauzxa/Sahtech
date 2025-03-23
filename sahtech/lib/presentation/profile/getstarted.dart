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

    // Calculate responsive font sizes
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageSelectorWidget(
            onTap: () => showLanguageSelector(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top section with green background (no rounded corners)
          Container(
            height: height * 0.68, // Reduced to accommodate AppBar
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50)),
              color:
                  const Color(0xFFd9f7c2), // Light green background from Figma
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Logo image at the top with proper spacing
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.02),
                    child: Center(
                      child: Image.asset(
                        'lib/assets/images/logo2.jpg',
                        height: height * 0.06,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Illustration container - taking most of the screen
                  Expanded(
                    child: Center(
                      child: Container(
                        width: width * 0.9,
                        child: Image.asset(
                          'lib/assets/images/getstarted2.jpg', // Using correct image from assets
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom section with white background, text, and button
          Container(
            height: height * 0.25, // 25% of screen height for the white part
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Text content
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

                // Get Started button
                Container(
                  width: double.infinity,
                  height: height * 0.06,
                  margin: EdgeInsets.symmetric(vertical: height * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, 2),
                        blurRadius: 5,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
