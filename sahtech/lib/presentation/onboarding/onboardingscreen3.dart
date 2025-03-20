import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/presentation/profile/getstarted.dart';

class Onboardingscreen3 extends StatelessWidget {
  const Onboardingscreen3({Key? key}) : super(key: key);

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

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background like in Figma
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  children: [
                    // Flexible spacing that adapts to different screens
                    SizedBox(height: height * 0.05),

                    // Illustration container with green background circle
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Container(
                          width: width * 0.8,
                          height: width * 0.8,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal.withOpacity(0.2),
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
                            'Consulter nutritioniste',
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
                              'Vous pouvez contacter des nutritionnistes qui vous guideront pour améliorer votre hygiène de vie',
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Getstarted()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTeal, // Light green color
                    elevation: 0, // No shadow, flat design like Figma
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Rounded corners like Figma
                    ),
                  ),
                  child: Text(
                    'suivant',
                    style: TextStyle(
                      fontSize: buttonTextSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBrown,
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
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightTeal : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
