import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';

class Nutritioniste2 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste2({
    Key? key,
    required this.nutritionistData,
    this.currentStep = 2,
    this.totalSteps = 5,
  }) : super(key: key);

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

    // Navigate to the next screen (will be implemented in future)
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Nutritioniste3(
    //       nutritionistData: widget.nutritionistData,
    //       currentStep: widget.currentStep + 1,
    //       totalSteps: widget.totalSteps,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: width * 0.12,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTeal,
            size: width * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: width * 0.04),
        ),
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Language selector button
          LanguageSelectorButton(
            width: width,
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
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:
                              width * (widget.currentStep / widget.totalSteps),
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        // Scrollable content area
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.06,
                              right: width * 0.06,
                              bottom: height *
                                  0.12, // Extra padding at bottom for button
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height * 0.05),

                                // Title
                                Text(
                                  _translations['title']!,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                SizedBox(height: height * 0.01),

                                // Subtitle
                                Text(
                                  _translations['subtitle']!,
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),

                                SizedBox(height: height * 0.05),

                                // Gender dropdown with CheckboxListTile
                                _buildDropdownWithCheckbox(
                                  hint: _translations['gender_label']!,
                                  value: _selectedGender,
                                  options: _genderOptions,
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
                                  maxHeight: height *
                                      0.2, // Limited height for gender dropdown
                                ),

                                SizedBox(height: height * 0.03),

                                // Speciality dropdown with CheckboxListTile - using the same widget as gender
                                _buildDropdownWithCheckbox(
                                  hint: _translations['speciality_label']!,
                                  value: _selectedSpeciality,
                                  options: _specialityOptions,
                                  isExpanded: _isSpecialityExpanded,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSpeciality = value;
                                      _isSpecialityExpanded = false;
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
                                  maxHeight: height *
                                      0.3, // Taller max height for speciality list
                                ),

                                // Minimum space to ensure dropdowns have enough room
                                SizedBox(height: height * 0.05),
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
                              left: width * 0.06,
                              right: width * 0.06,
                              top: height * 0.02,
                              bottom: height * 0.05,
                            ),
                            child: ElevatedButton(
                              onPressed: _continueToNextScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightTeal,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.018),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                _translations['next']!,
                                style: TextStyle(
                                  fontSize: width * 0.045,
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
    double? maxHeight, // Added parameter for flexible max height
  }) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown button
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            height: height * 0.07,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.018,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF9E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: width * 0.05,
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
              maxHeight: maxHeight ??
                  height * 0.3, // Use provided maxHeight or default
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
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
                        fontSize: width * 0.04,
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
