import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/presentation/profile/getstarted.dart';
import 'onboardingscreen2.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/base/base_screen.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  Map<String, String> translations = {
    'skip': 'Skip',
    'title': 'Bienvenue a SahTech',
    'subtitle':
        'Scannez pour connaître les ingrédients de vos produits alimentaires et recevez des recommandations adaptées à votre profil.',
    'next': 'Suivant',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 24.w, top: 16.h),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Getstarted(),
                      ),
                    );
                  },
                  child: Text(
                    translations['skip']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Image without background container
            Expanded(
              child: Center(
                child: Image.asset(
                  'lib/assets/images/onbor2.jpg',
                  width: 300.w,
                  height: 300.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Title text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                translations['title']!,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 16.h),

            // Subtitle text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                translations['subtitle']!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 48.h),

            // Pagination dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            // Next button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(
                text: translations['next']!,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const OnboardingScreen2(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                width: 1.sw,
                height: 56.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//