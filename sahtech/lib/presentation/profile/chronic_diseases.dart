import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/physical_activity_question_screen.dart';
import 'package:sahtech/presentation/profile/allergy_selection.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';

class ChronicDiseases extends StatefulWidget {
  final UserModel? userData;
  final NutritionisteModel? nutritionistData;

  const ChronicDiseases({super.key, this.userData, this.nutritionistData})
      : assert(userData != null || nutritionistData != null,
            'Either userData or nutritionistData must be provided');

  @override
  State<ChronicDiseases> createState() => _ChronicDiseasesState();
}

class _ChronicDiseasesState extends State<ChronicDiseases> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool _isDropdownOpen = false;
  List<String> _selectedDiseases = [];
  late final String userType;

  final Map<String, bool> _diseases = {
    'Diabète': false,
    'Hypertension artérielle': false,
    'Obésité': false,
    'Asthme': false,
    'Dépression': false,
    'Anxiété': false,
    'Gastrite': false,
    'Caries dentaires': false,
    'Conjonctivite': false,
    'Maladie coeliaque': false,
    'Arthrose': false,
    'Allergie': false,
    'Maladie de Crohn': false,
    'Fibromyalgie': false,
    'Hypothyroïdie': false,
    'Hyperthyroïdie': false,
    'Lupus': false,
    'Sclérose en plaques': false,
    'Polyarthrite rhumatoïde': false,
    'Psoriasis': false,
    'Endométriose': false,
    'Glaucome': false,
  };

  Map<String, String> _translations = {
    'title': 'Choisir votre maladies ?',
    'subtitle':
        'Afin de vous offrir une expérience optimale et des recommandations personnalisées, veuillez choisir votre maladie',
    'dropdown_label': 'Choisir ton maladie',
    'next': 'suivant',
    'select_condition': 'Veuillez sélectionner votre condition',
    'success_message': 'Informations enregistrées avec succès!',
    'conditions_selected': 'conditions sélectionnées',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    userType = widget.nutritionistData?.userType ??
        widget.userData?.userType ??
        'user';
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

        final translatedDiseases = <String, bool>{};
        for (final disease in _diseases.keys) {
          final translatedDisease =
              await _translationService.translate(disease);
          translatedDiseases[translatedDisease] = false;
        }

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

  void _handleLanguageChanged(String languageCode) {
    setState(() => _isLoading = true);
    if (userType == 'nutritionist') {
      widget.nutritionistData!.preferredLanguage = languageCode;
    } else {
      widget.userData!.preferredLanguage = languageCode;
    }
    _loadTranslations();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _selectDisease(String disease) {
    setState(() {
      _diseases[disease] = !_diseases[disease]!;
      _selectedDiseases =
          _diseases.entries.where((e) => e.value).map((e) => e.key).toList();
    });
  }

  String _getDropdownLabel() {
    if (_selectedDiseases.isEmpty) {
      return _translations['dropdown_label']!;
    } else {
      return "${_selectedDiseases.length} ${_translations['conditions_selected'] ?? 'conditions sélectionnées'}";
    }
  }

  void _continueToNextScreen() async {
    if (_selectedDiseases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate('Veuillez sélectionner votre condition')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update the appropriate model based on user type
    if (userType == 'nutritionist') {
      widget.nutritionistData!.chronicConditions = _selectedDiseases;

      // Check if nutritionist has selected 'Allergie'
      if (_diseases['Allergie'] == true) {
        // Navigate to allergy selection screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                AllergySelection(nutritionistData: widget.nutritionistData),
          ),
        );
      } else {
        // Navigate directly to Profile4
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhysicalActivityQuestionScreen(
                nutritionistData: widget.nutritionistData),
          ),
        );
      }
    } else {
      // Handle regular user flow
      widget.userData!.chronicConditions = _selectedDiseases;

      // Check if user has selected 'Allergie'
      if (_diseases['Allergie'] == true) {
        // Navigate to allergy selection screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AllergySelection(userData: widget.userData),
          ),
        );
      } else {
        // Navigate directly to Profile4
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PhysicalActivityQuestionScreen(userData: widget.userData),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage (20%) - second screen in the flow
    final progressPercentage = 0.2;

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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Fixed Progress Bar with correct styling
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width:
                                    constraints.maxWidth * progressPercentage,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: AppColors.lightTeal,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                            Text(
                              _translations['title']!,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              _translations['subtitle']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // Dropdown (Fixed Text)
                            GestureDetector(
                              onTap: _toggleDropdown,
                              child: Container(
                                width: double.infinity,
                                height: 65.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF9E8),
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 1.w,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getDropdownLabel(),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: _selectedDiseases.isNotEmpty
                                              ? Colors.black87
                                              : Colors.black54,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    Icon(
                                      _isDropdownOpen
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black54,
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Disease options (properly scrollable dropdown)
                            if (_isDropdownOpen)
                              Container(
                                margin: EdgeInsets.only(top: 4.h),
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height *
                                          0.4, // 40% of screen height
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 3.h),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: _diseases.entries
                                          .map((entry) => _buildDiseaseOption(
                                              entry.key, entry.value))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
                    child: CustomButton(
                      text: _translations['next']!,
                      onPressed: _continueToNextScreen,
                      width: 1.sw - 32.w,
                      height: 50.h,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDiseaseOption(String disease, bool isSelected) {
    return InkWell(
      onTap: () => _selectDisease(disease),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected ? AppColors.lightTeal : Colors.grey,
                  width: 1.5.w,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.sp,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                disease,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
