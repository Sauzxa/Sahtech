import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import 'dart:math';
import 'package:sahtech/core/widgets/language_selector.dart';

class NutritionisteSuccess extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const NutritionisteSuccess({
    super.key,
    required this.nutritionistData,
  });

  @override
  State<NutritionisteSuccess> createState() => _NutritionisteSuccessState();
}

class _NutritionisteSuccessState extends State<NutritionisteSuccess> {
  late Map<String, String> _translations;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);
    _translations = await TranslationService.getTranslations();
    setState(() => _isLoading = false);
  }

  void _handleLanguageChanged(String newLanguage) {
    _loadTranslations();
  }

  // Navigate to home screen
  void _goToHome() {
    // Reset navigation stack and go to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 45.w,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTeal,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: 15.w),
        ),
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          LanguageSelectorButton(
            width: 1.sw,
            onLanguageChanged: _handleLanguageChanged,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : Stack(
              children: [
                // Confetti Background with programmatically drawn pattern
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: ConfettiPainter(),
                  ),
                ),
                
                // Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black87,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Main Content with better vertical centering
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success icon
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.lightTeal,
                          size: 120.w,
                        ),
                        SizedBox(height: 32.h),

                        // Success message
                        Text(
                          _translations['success_title'] ?? 'Registration Successful!',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _translations['success_message'] ?? 'Your account has been created successfully. You can now start using the app.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 48.h),

                        // Get started button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightTeal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Text(
                              _translations['get_started'] ?? 'Get Started',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
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
    );
  }
}

// Custom painter for confetti pattern
class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final confettiColors = [
      const Color(0xFF9FE870).withOpacity(0.5),  // Green
      const Color(0xFFFFC107).withOpacity(0.5),  // Yellow
      const Color(0xFFFF9800).withOpacity(0.5),  // Orange
      const Color(0xFFE91E63).withOpacity(0.5),  // Pink
      const Color(0xFF03A9F4).withOpacity(0.5),  // Blue
    ];
    
    // Draw around 100 confetti pieces
    for (int i = 0; i < 100; i++) {
      final color = confettiColors[random.nextInt(confettiColors.length)];
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      // Randomly choose shape: 0=circle, 1=rectangle, 2=line
      final shape = random.nextInt(3);
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      switch (shape) {
        case 0: // Circle
          final radius = 2.0 + random.nextDouble() * 6.0;
          canvas.drawCircle(Offset(x, y), radius, paint);
          break;
        case 1: // Rectangle
          final width = 4.0 + random.nextDouble() * 10.0;
          final height = 2.0 + random.nextDouble() * 5.0;
          final angle = random.nextDouble() * pi;
          
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(angle);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: width,
              height: height,
            ),
            paint,
          );
          canvas.restore();
          break;
        case 2: // Line
          final length = 5.0 + random.nextDouble() * 15.0;
          final strokeWidth = 1.0 + random.nextDouble() * 3.0;
          final angle = random.nextDouble() * pi;
          
          paint.strokeWidth = strokeWidth;
          
          final dx = cos(angle) * length / 2;
          final dy = sin(angle) * length / 2;
          
          canvas.drawLine(
            Offset(x - dx, y - dy),
            Offset(x + dx, y + dy),
            paint,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 