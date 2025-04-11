import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_sms_verification.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sahtech/core/widgets/language_selector.dart';

class NutritionistePhone extends StatefulWidget {
  final NutritionisteModel nutritioniste;

  const NutritionistePhone({
    Key? key,
    required this.nutritioniste,
  }) : super(key: key);

  @override
  _NutritionistePhoneState createState() => _NutritionistePhoneState();
}

class _NutritionistePhoneState extends State<NutritionistePhone> {
  late Map<String, String> _translations;
  bool _isLoading = true;
  String _phoneNumber = '';
  bool _isValid = false;

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

  void _onPhoneNumberChanged(String number) {
    setState(() {
      _phoneNumber = number;
    });
  }

  void _onPhoneNumberValidated(bool isValid) {
    setState(() {
      _isValid = isValid;
    });
  }

  void _proceedToVerification() {
    if (_isValid && _phoneNumber.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionisteSmsVerification(
            phoneNumber: _phoneNumber,
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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _translations['phone_title'] ?? 'Enter Your Phone Number',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _translations['phone_subtitle'] ?? 'We\'ll send you a verification code',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // Phone number input
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: IntlPhoneField(
                                decoration: InputDecoration(
                                  labelText: _translations['phone_label'] ?? 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: AppColors.lightTeal,
                                    ),
                                  ),
                                ),
                                initialCountryCode: 'MA',
                                onChanged: (phone) => _onPhoneNumberChanged(phone.completeNumber),
                                onCountryChanged: (country) {},
                                validator: (value) {
                                  if (value == null || value.number.isEmpty) {
                                    return _translations['phone_required'] ?? 'Phone number is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom button
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValid ? _proceedToVerification : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: Text(
                          _translations['continue'] ?? 'Continue',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
} 