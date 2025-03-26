import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/presentation/profile/getstarted.dart';
import 'package:sahtech/core/base/base_screen.dart';

class Onboardingscreen3 extends StatefulWidget {
  const Onboardingscreen3({Key? key}) : super(key: key);

  @override
  State<Onboardingscreen3> createState() => _Onboardingscreen3State();
}

class _Onboardingscreen3State extends State<Onboardingscreen3>
    with TranslationMixin {
  @override
  Map<String, String> get initialTranslations => {
        'title': 'Consulter nutritioniste',
        'subtitle':
            'Vous pouvez contacter des nutritionnistes qui vous guideront pour améliorer votre hygiène de vie',
        'next': 'suivant',
      };

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;

    // Calculate responsive font sizes
    final titleSize = width * 0.06; // Larger title size
    final subtitleSize = width * 0.04; // More readable subtitle size
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
      backgroundColor: Colors.grey[50], // Light background like in Figma
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
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  children: [
                    // Flexible spacing that adapts to different screens
                    SizedBox(height: height * 0.08),

                    // Illustration container with green background circle
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Container(
                          width: width * 0.8,
                          height: width * 0.8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF9E8),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'lib/assets/images/getstarted.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Text content - properly sized and spaced
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            translations['title']!,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.015),
                          Container(
                            width: width * 0.8, // Constrain text width
                            child: Text(
                              translations['subtitle']!,
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: Colors.grey[600],
                                height: 1.3, // Better line spacing
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Page indicator dots - properly sized
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPageIndicator(false),
                          _buildPageIndicator(false),
                          _buildPageIndicator(true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation button - properly styled like Figma
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.05,
                right: width * 0.05,
                bottom: height * 0.03,
              ),
              child: SizedBox(
                width: double.infinity,
                height: height * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Getstarted screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Getstarted(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB7F397),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    translations['next']!,
                    style: TextStyle(
                      fontSize: buttonTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the page indicator dots
  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 20.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightTeal : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
