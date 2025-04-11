import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste3.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Nutritioniste2 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste2({
    super.key,
    required this.nutritionistData,
    this.currentStep = 2,
    this.totalSteps = 5,
  });

  @override
  State<Nutritioniste2> createState() => _Nutritioniste2State();
}

class _Nutritioniste2State extends State<Nutritioniste2> {
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
    'title': 'compléter le remplissage !',
    'subtitle':
        'Veuillez compléter le processus de remplissage de vos données.',
    'gender_label': 'Choisir votre Sexe',
    'speciality_label': 'Choisir votre Specialité',
    'next': 'suivant',
    'select_option': 'Veuillez sélectionner une option',
    'success_message': 'Informations enregistrées avec succès!',
  };

  // Gender options
  final List<String> _genderOptions = ['Homme', 'Femme', 'Autre'];

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

  // Translated versions of option lists
  List<String> _translatedGenderOptions = [];
  List<String> _translatedSpecialityOptions = [];

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
        // Add a small delay to ensure the TranslationService is ready
        await Future.delayed(const Duration(milliseconds: 100));
        
        final translatedStrings =
            await _translationService.translateMap(_translations);

        // Translate gender options
        _translatedGenderOptions = [];
        for (final gender in _genderOptions) {
          _translatedGenderOptions
              .add(await _translationService.translate(gender));
        }

        // Translate speciality options
        _translatedSpecialityOptions = [];
        for (final speciality in _specialityOptions) {
          _translatedSpecialityOptions
              .add(await _translationService.translate(speciality));
        }

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            _isLoading = false;
          });
        }
      } else {
        // Use original options for French
        _translatedGenderOptions = List.from(_genderOptions);
        _translatedSpecialityOptions = List.from(_specialityOptions);
        
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
  void _handleLanguageChanged(String languageCode) async {
    // Update nutritionist model with the new language
    widget.nutritionistData.preferredLanguage = languageCode;

    // Reload translations with the new language
    await _loadTranslations();
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

    // Show success message only if this is the final step in the flow
    // This prevents duplicate messages across screens
    if (widget.currentStep >= widget.totalSteps - 1) {
      // This is the last step, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['success_message']!),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      
      // Here you would eventually save the data to Firebase
      debugPrint('Final step reached - data ready for Firebase submission');
      debugPrint('Nutritionist data: ${widget.nutritionistData.name}, '
          'Gender: ${widget.nutritionistData.gender}, '
          'Specialization: ${widget.nutritionistData.specialization}');
    }

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Nutritioniste3(
          nutritionistData: widget.nutritionistData,
          currentStep: widget.currentStep + 1,
          totalSteps: widget.totalSteps,
        ),
      ),
    );
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
                  // Progress bar at the top
                  Container(
                    width: double.infinity,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 1.sw * (widget.currentStep / widget.totalSteps),
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2.r),
                              bottomRight: Radius.circular(2.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 24.w,
                              right: 24.w,
                              bottom: 96.h, // Extra padding for button
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 40.h),

                                // Title
                                Text(
                                  _translations['title']!,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                SizedBox(height: 8.h),

                                // Subtitle
                                Text(
                                  _translations['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),

                                SizedBox(height: 40.h),

                                // Gender dropdown
                                _buildDropdownWithCheckbox(
                                  hint: _translations['gender_label']!,
                                  value: _selectedGender,
                                  options: _translationService.currentLanguageCode != 'fr' 
                                      ? _translatedGenderOptions 
                                      : _genderOptions,
                                  isExpanded: _isGenderExpanded,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                      _isGenderExpanded = false;
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
                                  maxHeight: 0.2.sh,
                                ),

                                SizedBox(height: 24.h),

                                // Speciality dropdown
                                _buildDropdownWithCheckbox(
                                  hint: _translations['speciality_label']!,
                                  value: _selectedSpeciality,
                                  options: _translationService.currentLanguageCode != 'fr' 
                                      ? _translatedSpecialityOptions 
                                      : _specialityOptions,
                                  isExpanded: _isSpecialityExpanded,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSpeciality = value;
                                      _isSpecialityExpanded = false;
                                    });
                                  },
                                  onTap: () {
                                    setState(() {
                                      _isSpecialityExpanded = !_isSpecialityExpanded;
                                      if (_isSpecialityExpanded) {
                                        _isGenderExpanded = false;
                                      }
                                    });
                                  },
                                  maxHeight: 0.3.sh,
                                ),

                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                        ),

                        // Fixed button at the bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(
                              left: 24.w,
                              right: 24.w,
                              top: 16.h,
                              bottom: 40.h,
                            ),
                            child: ElevatedButton(
                              onPressed: _continueToNextScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightTeal,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              child: Text(
                                _translations['next']!,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
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
    double? maxHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown button
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            width: double.infinity,
            height: 56.h,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 15.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF9E8),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: TextStyle(
                    fontSize: 16.sp,
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
              maxHeight: maxHeight ?? 0.3.sh,
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
                  offset: const Offset(0, 2),
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
                        fontSize: 16.sp,
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
