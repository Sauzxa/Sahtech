import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';
import 'package:sahtech/presentation/profile/objectif_screen.dart';

class PhysicalActivityQuestionScreen extends StatefulWidget {
  final UserModel? userData;
  final NutritionisteModel? nutritionistData;

  const PhysicalActivityQuestionScreen(
      {super.key, this.userData, this.nutritionistData})
      : assert(userData != null || nutritionistData != null,
            'Either userData or nutritionistData must be provided');

  @override
  State<PhysicalActivityQuestionScreen> createState() =>
      _PhysicalActivityQuestionScreenState();
}

class _PhysicalActivityQuestionScreenState
    extends State<PhysicalActivityQuestionScreen> {
  bool? _doesExercise;
  late TranslationService _translationService;
  bool _isLoading = false;
  late final String userType;

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    userType = widget.nutritionistData?.userType ??
        widget.userData?.userType ??
        'user';
  }

  void _handleLanguageChanged(String languageCode) {
    setState(() => _isLoading = true);
    Future.delayed(Duration.zero, () async {
      try {
        if (userType == 'nutritionist') {
          widget.nutritionistData!.preferredLanguage = languageCode;
        } else {
          widget.userData!.preferredLanguage = languageCode;
        }
      } catch (e) {
        debugPrint('Error handling language change: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    String? currentPreferredLanguage;

    if (userType == 'nutritionist') {
      currentPreferredLanguage = widget.nutritionistData!.preferredLanguage;
    } else {
      currentPreferredLanguage = widget.userData!.preferredLanguage;
    }

    if (currentPreferredLanguage != null &&
        currentPreferredLanguage != _translationService.currentLanguageCode) {
      Navigator.pop(context, 'language_changed');
    }
    super.dispose();
  }

  void _continueToNextScreen() async {
    if (_doesExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate('Veuillez sélectionner une option')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update the appropriate model based on user type
    if (userType == 'nutritionist') {
      widget.nutritionistData!.doesExercise = _doesExercise;
      widget.nutritionistData!.preferredLanguage =
          _translationService.currentLanguageCode;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate('Informations enregistrées avec succès!')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate to Profile5
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                ObjectifScreen(nutritionistData: widget.nutritionistData)),
      );
    } else {
      // Handle regular user flow
      widget.userData!.doesExercise = _doesExercise;
      widget.userData!.preferredLanguage =
          _translationService.currentLanguageCode;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate('Informations enregistrées avec succès!')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate to Profile5
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ObjectifScreen(userData: widget.userData)),
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.sp),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: 12.w),
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
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.lightTeal,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Progress Bar (40%)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 1.sw * 0.4 - 3.2.w, // 40% progress
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.lightTeal,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 32.h),
                            FutureBuilder<String>(
                              future: _translationService.translate(
                                  'Pratiquez-vous une activité physique ?'),
                              builder: (context, snapshot) {
                                final text = snapshot.data ??
                                    'Pratiquez-vous une activité physique ?';
                                return Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 12.h),
                            FutureBuilder<String>(
                              future: _translationService.translate(
                                  'Pour un suivi plus précis, veuillez spécifier si vous faites de l\'activité physique'),
                              builder: (context, snapshot) {
                                final text = snapshot.data ?? '';
                                return Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 70.h),
                            // OUI button
                            FutureBuilder<String>(
                              future: _translationService.translate('Oui'),
                              builder: (context, snapshot) {
                                final yesText = snapshot.data ?? 'Oui';
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _doesExercise = true),
                                  child: Container(
                                    width: double.infinity,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: _doesExercise == true
                                          ? AppColors.lightTeal.withOpacity(0.2)
                                          : const Color(0xFFEFF9E8),
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        color: _doesExercise == true
                                            ? AppColors.lightTeal
                                            : Colors.transparent,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        yesText,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: _doesExercise == true
                                              ? AppColors.lightTeal
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 15.h),
                            // NON button
                            FutureBuilder<String>(
                              future: _translationService.translate('Non'),
                              builder: (context, snapshot) {
                                final noText = snapshot.data ?? 'Non';
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _doesExercise = false),
                                  child: Container(
                                    width: double.infinity,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: _doesExercise == false
                                          ? AppColors.lightTeal.withOpacity(0.2)
                                          : const Color(0xFFEFF9E8),
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        color: _doesExercise == false
                                            ? AppColors.lightTeal
                                            : Colors.transparent,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        noText,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: _doesExercise == false
                                              ? AppColors.lightTeal
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: CustomButton(
                        text: 'suivant',
                        onPressed: _continueToNextScreen,
                        width: 1.sw - 32.w, // Full width minus padding
                        height: 50.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
