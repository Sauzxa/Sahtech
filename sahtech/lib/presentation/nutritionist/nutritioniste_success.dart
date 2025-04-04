import 'package:flutter/material.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import 'dart:math';

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
  late TranslationService _translationService;
  bool _isLoading = false;

  // Translations
  Map<String, String> _translations = {
    'title': 'Donné rempli avec Scucceé',
    'subtitle': 'Est ce que vous voulez publier ces données pour être affiché dans la liste des nutritionistes en ligne',
    'continue': 'Continue',
  };

  @override
  void initState() {
    super.initState();
    _translationService = Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings = await _translationService.translateMap(_translations);
        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigate to home screen
  void _goToHome() {
    // Reset navigation stack and go to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: const Color(0xFF9FE870)))
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
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 3), // Push content lower from the top
                        
                        // Centered content
                        Center(
                          child: Column(
                            children: [
                              // Check Icon in Circle
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF9FE870),
                                    width: 3,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Color(0xFF9FE870),
                                    size: 55,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Success Title
                              Text(
                                _translations['title']!,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              
                              // Success Message
                              Text(
                                _translations['subtitle']!,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(flex: 4), // More space at the bottom for better centering
                        
                        // Continue Button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: CustomButton(
                            text: _translations['continue']!,
                            onPressed: _goToHome,
                            isEnabled: true,
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