import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';
import 'package:sahtech/presentation/nutritionist/Attest_nutri_screnn.dart';
import 'package:sahtech/presentation/nutritionist/proveAttestation.dart';

class SexespecialiteNutriScreen extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const SexespecialiteNutriScreen({
    Key? key,
    required this.nutritionistData,
  }) : super(key: key);

  @override
  State<SexespecialiteNutriScreen> createState() =>
      _SexespecialiteNutriScreenState();
}

class _SexespecialiteNutriScreenState extends State<SexespecialiteNutriScreen> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedSpeciality;
  String? _selectedGender;

  // For dropdown state
  bool _isGenderExpanded = false;
  bool _isSpecialityExpanded = false;

  // Translations
  Map<String, String> _translations = {
    'title': 'Soyez les Bienvennu a Sahtech !',
    'subtitle':
        'Veuillez remplir vos informations afin que nous puissions créer votre carte, qui sera publiée dans notre application.',
    'gender_label': 'Choisir votre Sexe',
    'speciality_label': 'Choisir votre Specialité',
    'next': 'suivant',
    'select_option': 'Veuillez sélectionner une option',
  };

  // Gender options
  final List<String> _genderOptions = ['Homme', 'Femme'];

  // Speciality options
  final List<String> _specialityOptions = [
    'Nutrition Clinique',
    'Nutrition Sportive',
    'Nutrition Pédiatrique',
    'Nutrition Gériatrique',
    'Nutrition et Maladies Chroniques',
    'Nutrition et Perte de Poids',
    'Nutrition et Santé Digestive',
    'Diététique'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if available
    _selectedSpeciality = widget.nutritionistData.specialization;
    _selectedGender = widget.nutritionistData.gender;

    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (default language)
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

        // Translate gender options
        List<String> translatedGenderOptions = [];
        for (final gender in _genderOptions) {
          translatedGenderOptions
              .add(await _translationService.translate(gender));
        }

        // Translate speciality options
        List<String> translatedSpecialityOptions = [];
        for (final speciality in _specialityOptions) {
          translatedSpecialityOptions
              .add(await _translationService.translate(speciality));
        }

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            // Uncommenting these would enable translation of options
            // _genderOptions = translatedGenderOptions;
            // _specialityOptions = translatedSpecialityOptions;
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

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Update nutritionist model with the new language
    widget.nutritionistData.preferredLanguage = languageCode;

    // Reload translations with the new language
    _loadTranslations();
  }

  void _continueToNextScreen() {
    if (_selectedGender == null || _selectedSpeciality == null) {
      // Show error if either selection is missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['select_option']!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // Save the data to the nutritionist model
    widget.nutritionistData.specialization = _selectedSpeciality;
    widget.nutritionistData.gender = _selectedGender;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Informations enregistrées avec succès!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProveAttestationScreen(
          nutritionistData: widget.nutritionistData,
          currentStep: 2,
          totalSteps: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.lightTeal),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: AppColors.lightTeal, size: 20.sp),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.only(left: 12.w),
              ),
              actions: [
                // Language selector button
                LanguageSelectorButton(
                  onLanguageChanged: _handleLanguageChanged,
                  width: 1.sw, // Screen width using ScreenUtil
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Add extra top margin
                            SizedBox(height: 20.h),

                            // Sahtech logo
                            Image.asset(
                              'lib/assets/images/mainlogo.jpg',
                              height: 50.h,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: 30.h),
                            // Page title
                            Text(
                              _translations['title']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Page subtitle
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                _translations['subtitle']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ),
                            SizedBox(height: 50.h),

                            // Gender dropdown (without label as per Figma)
                            _buildDropdownWithCheckbox(
                              hint: _translations['gender_label']!,
                              value: _selectedGender,
                              options: _genderOptions,
                              isExpanded: _isGenderExpanded,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                  _isGenderExpanded = false;
                                  widget.nutritionistData.gender = value;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _isGenderExpanded = !_isGenderExpanded;
                                  if (_isGenderExpanded) {
                                    _isSpecialityExpanded = false;
                                  }
                                });
                              },
                              maxHeight: 200.h,
                            ),

                            SizedBox(height: 36.h),

                            // Speciality dropdown (without label as per Figma)
                            _buildDropdownWithCheckbox(
                              hint: _translations['speciality_label']!,
                              value: _selectedSpeciality,
                              options: _specialityOptions,
                              isExpanded: _isSpecialityExpanded,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSpeciality = value;
                                  _isSpecialityExpanded = false;
                                  widget.nutritionistData.specialization =
                                      value;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _isSpecialityExpanded =
                                      !_isSpecialityExpanded;
                                  if (_isSpecialityExpanded) {
                                    _isGenderExpanded = false;
                                  }
                                });
                              },
                              maxHeight: 240.h,
                            ),

                            SizedBox(height: 150.h),

                            // Suivant button
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 32.h, top: 32.h),
                              child: ElevatedButton(
                                onPressed: _continueToNextScreen,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightTeal,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                child: Text(
                                  _translations['next']!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  // Build a dropdown with checkbox list tiles
  Widget _buildDropdownWithCheckbox({
    required String hint,
    String? value,
    required List<String> options,
    required bool isExpanded,
    required Function(String) onChanged,
    required VoidCallback onTap,
    double? maxHeight, // Added parameter for flexible max height
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown button
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            height: 55.h,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF9E8),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),

        // Expanded dropdown with checkboxes
        if (isExpanded)
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? 240.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.r),
                bottomRight: Radius.circular(15.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  return CheckboxListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    value: option == value,
                    activeColor: AppColors.lightTeal,
                    onChanged: (_) {
                      onChanged(option);
                    },
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}