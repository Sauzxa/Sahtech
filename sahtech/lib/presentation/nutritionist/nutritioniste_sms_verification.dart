import 'package:flutter/material.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_password.dart';
import 'dart:async';
import '../widgets/custom_button.dart';

class NutritionisteSmsVerification extends StatefulWidget {
  final String phoneNumber;

  const NutritionisteSmsVerification({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<NutritionisteSmsVerification> createState() => _NutritionisteSmsVerificationState();
}

class _NutritionisteSmsVerificationState extends State<NutritionisteSmsVerification> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _timeLeft = 180; // 3 minutes in seconds

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String get formattedTime {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with opacity
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightTeal.withOpacity(0.4),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top section with back button and logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkBrown),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 40),
                            child: Image(
                              image: AssetImage('lib/assets/images/mainlogo.jpg'),
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // White card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Verification SMS',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Un SMS a etait envoyé veuillez verifier votre telephone',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Timer
                            Center(
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9FE870),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // OTP Input fields
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF9FE870),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty && index < 3) {
                                        _focusNodes[index + 1].requestFocus();
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 24),

                            // Resend code text
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Vous n\'avez pas reçu le code ? ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _timeLeft == 0 ? () {
                                      setState(() {
                                        _timeLeft = 180;
                                      });
                                      startTimer();
                                    } : null,
                                    child: Text(
                                      'Renvoyer',
                                      style: TextStyle(
                                        color: _timeLeft == 0 ? const Color(0xFF9FE870) : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 300),

                            // Submit button
                            CustomButton(
                              text: 'Envoyer',
                              onPressed: () {
                                // Get entered OTP
                                String enteredOTP = '';
                                for (var controller in _controllers) {
                                  enteredOTP += controller.text;
                                }
                                
                                // Check if OTP is complete (4 digits)
                                if (enteredOTP.length == 4) {
                                  // In a real app, you would verify the OTP with a backend service
                                  // For now, we'll just proceed to the password screen
                                  
                                  // Create a NutritionisteModel with the phone number
                                  final nutritionistData = NutritionisteModel(
                                    userType: 'nutritionist',
                                    phoneNumber: widget.phoneNumber,
                                  );
                                  
                                  // Navigate to password screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NutritionistePassword(
                                        nutritionistData: nutritionistData,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Show error for incomplete OTP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter the complete 4-digit code'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              isEnabled: true, // Enable button regardless of OTP completion
                            ),
                          ],
                        ),
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