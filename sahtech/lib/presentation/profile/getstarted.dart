import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';

class Getstarted extends StatelessWidget {
  const Getstarted({super.key});

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

    return Scaffold(
      body: Column(
        children: [
          // Top section with green background (no rounded corners)
          Container(
            height: height * 0.75, // 75% of screen height for the green part
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightTeal, // Light green background from Figma
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo image at the top with proper spacing
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.05),
                    child: Center(
                      child: Image.asset(
                        'lib/assets/images/logo2.png', // Update with your actual logo path
                        height: height * 0.05, // Adjust based on your logo
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
                          'lib/assets/images/logo2.jpg',
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
                      'Votre santé est notre priorité',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Soyez plus saine avec notre application sahtech',
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
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to the next screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightTeal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Get started',
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
