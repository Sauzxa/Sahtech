import 'package:flutter/material.dart';
import 'onboardingscreen2.dart';
import 'package:sahtech/core/theme/colors.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.03,
          ),
          child: Column(
            children: [
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
                      vertical: size.height * 0.01,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Skip",
                        style: TextStyle(
                          color: AppColors.gray,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        ">",
                        style: TextStyle(
                          color: AppColors.lightTeal,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FE870).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    '../lib/assets/images/onbor2.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                "Scanner un produit",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.09,
                  fontWeight: FontWeight.w600,
                  height: 16 / 36,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Avec SahTech, scannez plusieurs produits alimentaires et adoptez-les en fonction de votre profil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gray,
                  fontSize: size.width * 0.04,
                  height: 1.5,
                ),
              ),
              SizedBox(height: size.height * 0.04),
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
              SizedBox(height: size.height * 0.03),
              // Button
              SizedBox(
                width: double.infinity,
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
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "suivant",
                    style: TextStyle(
                      fontSize: size.width * 0.04,
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
