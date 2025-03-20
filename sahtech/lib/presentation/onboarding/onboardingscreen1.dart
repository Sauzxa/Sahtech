import 'package:flutter/material.dart';
import 'onboardingscreen2.dart';
import 'package:sahtech/core/theme/colors.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    minimumSize: Size(50, 40), // Increased tap target
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Skip",
                        style: TextStyle(
                          color: AppColors.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
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

              // Title
              Text(
                "Scanner un produit",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),

              SizedBox(height: isSmallDevice ? 10 : 20),

              // Description
              Text(
                "Avec SahTech, scannez plusieurs produits alimentaires et adoptez-les en fonction de votre profil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gray,
                  fontSize: size.width * 0.038,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),

              // Spacing for pagination dots
              SizedBox(
                  height: isSmallDevice
                      ? size.height * 0.025
                      : size.height * 0.035),

              // Pagination dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 8,
                    width: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9FE870),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              // Increased spacing for button to ensure visibility
              SizedBox(
                  height: isSmallDevice
                      ? size.height * 0.035
                      : size.height * 0.045),

              // Button with ensured visibility
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Skip to second onboarding screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB7F397),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "suivant",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//