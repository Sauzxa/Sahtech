import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';
import 'package:sahtech/presentation/profile/profile4.dart';

class AllergySelection extends StatefulWidget {
  final UserModel userData;

  const AllergySelection({super.key, required this.userData});

  @override
  State<AllergySelection> createState() => _AllergySelectionState();
}

class _AllergySelectionState extends State<AllergySelection> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool _isDropdownOpen = false;
  final Map<String, bool> _allergies = {
    'Arachides': false,
    'Fruits à coque': false,
    'Lait': false,
    'Oeufs': false,
    'Poisson': false,
    'Crustacés': false,
    'Blé': false,
    'Soja': false,
    'Sésame': false,
    'Moutarde': false,
    'Sulfites': false,
    'Lupin': false,
    'Céleri': false,
    'Mollusques': false,
  };

  List<String> _selectedAllergies = [];
  Map<String, String> _translations = {
    'title': 'Choisir vos allergies',
    'subtitle':
        'Afin de vous offrir une expérience optimale et des recommandations personnalisées, veuillez choisir vos allergies',
    'dropdown_label': 'Choisir vos allergies',
    'next': 'suivant',
    'select_condition': 'Veuillez sélectionner au moins une allergie',
    'success_message': 'Informations enregistrées avec succès!',
    'allergies_selected': 'allergies sélectionnées',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

        final translatedAllergies = <String, bool>{};
        for (final allergy in _allergies.keys) {
          final translatedAllergy =
              await _translationService.translate(allergy);
          translatedAllergies[translatedAllergy] = false;
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
    widget.userData.preferredLanguage = languageCode;
    _loadTranslations();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      _allergies[allergy] = !_allergies[allergy]!;
      _selectedAllergies =
          _allergies.entries.where((e) => e.value).map((e) => e.key).toList();
    });
  }

  String _getDropdownLabel() {
    if (_selectedAllergies.isEmpty) {
      return _translations['dropdown_label']!;
    } else {
      return "${_selectedAllergies.length} ${_translations['allergies_selected'] ?? 'allergies sélectionnées'}";
    }
  }

  void _continueToNextScreen() async {
    // Save selected allergies to user model
    widget.userData.allergies = _selectedAllergies;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate to Profile4
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Profile4(userData: widget.userData),
      ),
    );
  }

  Widget _buildAllergyOption(String allergy, bool isSelected) {
    return InkWell(
      onTap: () => _toggleAllergy(allergy),
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
                allergy,
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
                  // Progress Bar (30%)
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
                            width: 1.sw * 0.3 - 3.2.w,
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
                            SizedBox(height: 40.h),
                            Text(
                              _translations['title']!,
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              _translations['subtitle']!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey[600],
                                height: 1.3,
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
                                          color: _selectedAllergies.isNotEmpty
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

                            // Allergy options (properly scrollable dropdown)
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
                                      children: _allergies.entries
                                          .map((entry) => _buildAllergyOption(
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _continueToNextScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal,
                          foregroundColor: Colors.black87,
                          elevation: 0,
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
                  ),
                ],
              ),
            ),
    );
  }
}
