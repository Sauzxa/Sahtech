import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class UserSuccess extends StatefulWidget {
  final UserModel userData;

  const UserSuccess({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<UserSuccess> createState() => _UserSuccessState();
}

class _UserSuccessState extends State<UserSuccess> {
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

  // Navigate to home screen
  void _goToHome() {
    // Reset navigation stack and go to home
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false,
        arguments: widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
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

                        // Success message with new text
                        Text(
                          "Votre compte a été créé avec succès",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Merci pour nous faire confiance et partager vous donner avec nous",
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
                              "Continuer",
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
      const Color(0xFF9FE870).withOpacity(0.5), // Green
      const Color(0xFFFFC107).withOpacity(0.5), // Yellow
      const Color(0xFFFF9800).withOpacity(0.5), // Orange
      const Color(0xFFE91E63).withOpacity(0.5), // Pink
      const Color(0xFF03A9F4).withOpacity(0.5), // Blue
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
