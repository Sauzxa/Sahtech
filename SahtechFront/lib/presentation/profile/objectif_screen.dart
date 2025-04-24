import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';
import 'package:sahtech/presentation/profile/birthday_screen.dart';
import 'package:sahtech/presentation/profile/weight_screen.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';

class ObjectifScreen extends StatefulWidget {
  final UserModel? userData;
  final NutritionisteModel? nutritionistData;

  const ObjectifScreen({super.key, this.userData, this.nutritionistData})
      : assert(userData != null || nutritionistData != null,
            'Either userData or nutritionistData must be provided');

  @override
  State<ObjectifScreen> createState() => _ObjectifScreenState();
}

class _ObjectifScreenState extends State<ObjectifScreen> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool _isDropdownOpen = false;
  late final String userType;
  final Map<String, bool> _objectives = {
    'Réduire le cholestérol': false,
    'Perdre du poids': false,
    'Prendre du muscle': false,
    'Améliorer la digestion': false,
    'Réduire la tension artérielle': false,
    'Adopter une alimentation saine': false,
    'Éviter les produits allergènes': false,
  };

  List<String> _selectedObjectives = [];
  Map<String, String> _translations = {
    'title': 'Choisir votre objectif dans notre appli ?',
    'subtitle':
        'Choisissez un objectif pour mieux adapter votre expérience. Cette option est optionnelle',
    'dropdown_label': 'Choisir votre objectif',
    'next': 'suivant',
    'select_condition': 'Veuillez sélectionner au moins un objectif',
    'success_message': 'Informations enregistrées avec succès!',
    'objectives_selected': 'objectifs sélectionnés',
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

        final translatedObjectives = <String, bool>{};
        for (final objective in _objectives.keys) {
          final translatedObjective =
              await _translationService.translate(objective);
          translatedObjectives[translatedObjective] = false;
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

  void _toggleObjective(String objective) {
    setState(() {
      _objectives[objective] = !_objectives[objective]!;
      _selectedObjectives =
          _objectives.entries.where((e) => e.value).map((e) => e.key).toList();
    });
  }

  String _getDropdownLabel() {
    if (_selectedObjectives.isEmpty) {
      return _translations['dropdown_label']!;
    } else {
      return "${_selectedObjectives.length} ${_translations['objectives_selected'] ?? 'objectifs sélectionnés'}";
    }
  }

  void _continueToNextScreen() async {
    // Check if any objectives are selected
    if (_selectedObjectives.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['select_condition']!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      // Don't proceed to the next screen
      return;
    }

    // Save selected objectives to the appropriate model
    if (userType == 'nutritionist') {
      // Save to nutritionist model
      final updatedModel = widget.nutritionistData!.copyWith(
        healthGoals: _selectedObjectives,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WeightScreen(nutritionistData: updatedModel),
        ),
      );
    } else {
      // Save to user model
      widget.userData!.healthGoals = _selectedObjectives;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WeightScreen(userData: widget.userData),
        ),
      );
    }
  }

  Widget _buildObjectiveOption(String objective, bool isSelected) {
    return InkWell(
      onTap: () => _toggleObjective(objective),
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
                objective,
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
                  // Progress Bar (50%)
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
                            width: 1.sw * 0.5 - 3.2.w,
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
                                          color: _selectedObjectives.isNotEmpty
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

                            // Objective options (properly scrollable dropdown)
                            if (_isDropdownOpen)
                              Container(
                                margin: EdgeInsets.only(top: 4.h),
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.4,
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
                                      children: _objectives.entries
                                          .map((entry) => _buildObjectiveOption(
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
}
