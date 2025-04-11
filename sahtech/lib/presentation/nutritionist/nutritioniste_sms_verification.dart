import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_password.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'dart:async';
import '../widgets/custom_button.dart';

class NutritionisteSmsVerification extends StatefulWidget {
  final String phoneNumber;

  const NutritionisteSmsVerification({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _NutritionisteSmsVerificationState createState() => _NutritionisteSmsVerificationState();
}

class _NutritionisteSmsVerificationState extends State<NutritionisteSmsVerification> {
  late Map<String, String> _translations;
  bool _isLoading = true;
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _timeLeft = 180; // 3 minutes in seconds

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    startTimer();
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);
    _translations = await TranslationService.getTranslations();
    setState(() => _isLoading = false);
  }

  void _handleLanguageChanged(String newLanguage) {
    _loadTranslations();
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

  void _onCodeComplete() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      // Verify the code here
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionistePassword(
            nutritionistData: NutritionisteModel(
              userType: 'nutritionist',
              phoneNumber: widget.phoneNumber,
            ),
          ),
        ),
      );
    }
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
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translations['verification_title'] ?? 'SMS Verification',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _translations['verification_subtitle'] ?? 'Enter the verification code sent to your phone',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Timer
                    Center(
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTeal,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // OTP Input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          width: 60.w,
                          height: 60.w,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.lightTeal,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 3) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _onCodeComplete();
                                }
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 32.h),

                    // Resend code text
                    Center(
                      child: TextButton(
                        onPressed: _timeLeft == 0 ? () {
                          setState(() {
                            _timeLeft = 180;
                          });
                          startTimer();
                          // Implement resend code logic here
                        } : null,
                        child: Text(
                          _translations['resend_code'] ?? 'Resend Code',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _timeLeft == 0 ? AppColors.lightTeal : Colors.grey,
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