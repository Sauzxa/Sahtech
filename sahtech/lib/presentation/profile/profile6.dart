import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile7.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';

class Profile6 extends StatefulWidget {
  final UserModel userData;
  final int currentStep;
  final int totalSteps;

  const Profile6({
    Key? key,
    required this.userData,
    this.currentStep = 2,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<Profile6> createState() => _Profile6State();
}

class _Profile6State extends State<Profile6> {
  late TranslationService _translationService;
  bool _isLoading = false;

  // Weight related variables
  double _weight = 70.0; // Default weight in kg
  String _weightUnit = 'kg'; // Default unit

  // Min and max weight values
  final double _minWeight = 0.0;
  final double _maxWeight = 300.0;

  // Key translations
  Map<String, String> _translations = {
    'title': 'Veuillez saisir votre poids ?',
    'subtitle':
        'Pour une expérience optimale. Afin de vous offrir un service personnalisé, nous vous invitons à renseigner certaines informations, telles que votre poids',
    'kg': 'kg',
    'lb': 'lb',
    'next': 'suivant',
    'success_message': 'Informations enregistrées avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _translationService.addListener(_onLanguageChanged);
    _loadTranslations();

    // Initialize weight from user data if available
    if (widget.userData.weight != null) {
      _weight = widget.userData.weight!;
    }
    if (widget.userData.weightUnit != null) {
      _weightUnit = widget.userData.weightUnit!;
    }
  }

  @override
  void dispose() {
    _translationService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _loadTranslations();
    }
  }

  // Load all needed translations
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (our default language)
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

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

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Update user model with the new language
    widget.userData.preferredLanguage = languageCode;

    // Language change is handled by the listener (_onLanguageChanged)
  }

  // Toggle between kg and lb
  void _toggleUnit(String unit) {
    if (_weightUnit != unit) {
      setState(() {
        _weightUnit = unit;
        // No need to convert the internal value, just update the unit
      });
    }
  }

  // Convert pounds to kilograms
  double _lbToKg(double lb) {
    return lb / 2.20462;
  }

  // Convert kilograms to pounds
  double _kgToLb(double kg) {
    return kg * 2.20462;
  }

  // Format weight value for display
  String _formatWeight(double weight) {
    if (_weightUnit == 'lb') {
      return _kgToLb(weight).toInt().toString();
    }
    return weight.toInt().toString();
  }

  void _continueToNextScreen() {
    // Store weight value in user's preferred unit
    widget.userData.weight = _weight;
    widget.userData.weightUnit = _weightUnit;

    // Navigate to the height input screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile7(
          userData: widget.userData,
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.sp),
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
          // Language selector button
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
                  // Progress Bar (60%)
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
                            width: 1.sw * 0.6 - 3.2.w,
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

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 32.h),

                          // Main question
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

                          // Subtitle/explanation
                          Text(
                            _translations['subtitle']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Weight unit selector (kg/lb) - pill style toggle
                          Center(
                            child: Container(
                              width: 120.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  // lb selector
                                  GestureDetector(
                                    onTap: () => _toggleUnit('lb'),
                                    child: Container(
                                      width: 60.w,
                                      height: 36.h,
                                      decoration: BoxDecoration(
                                        color: _weightUnit == 'lb'
                                            ? Colors.white
                                            : Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        boxShadow: _weightUnit == 'lb'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 2,
                                                  spreadRadius: 0.5,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'lb',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // kg selector
                                  GestureDetector(
                                    onTap: () => _toggleUnit('kg'),
                                    child: Container(
                                      width: 60.w,
                                      height: 36.h,
                                      decoration: BoxDecoration(
                                        color: _weightUnit == 'kg'
                                            ? AppColors.lightTeal
                                            : Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'kg',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Weight display area with slider
                          Container(
                            width: double.infinity,
                            height: 0.3.sh,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF9E8),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Weight value display
                                Container(
                                  width: 0.5.sw,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _formatWeight(_weight),
                                      style: TextStyle(
                                        fontSize: 80.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                // Scale markings and slider
                                Container(
                                  width: 0.7.sw,
                                  child: Column(
                                    children: [
                                      // Scale markings
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _weightUnit == 'kg' ? '30' : '66',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            _weightUnit == 'kg' ? '70' : '154',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            _weightUnit == 'kg' ? '115' : '253',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            _weightUnit == 'kg' ? '160' : '352',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            _weightUnit == 'kg' ? '200' : '440',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Scale ticks
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          41,
                                          (index) => Container(
                                            height:
                                                index % 10 == 0 ? 12.h : 6.h,
                                            width: 1.w,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),

                                      // Slider
                                      SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.transparent,
                                          inactiveTrackColor:
                                              Colors.transparent,
                                          thumbColor: Colors.black,
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 6.r,
                                          ),
                                          overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: 12.r,
                                          ),
                                          trackHeight: 0,
                                        ),
                                        child: Slider(
                                          value: _weight.clamp(30.0, 200.0),
                                          min: 30.0,
                                          max: 200.0,
                                          onChanged: (value) {
                                            setState(() {
                                              _weight = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Weight unit
                                Text(
                                  _weightUnit,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Spacer(),

                          // Next button
                          Padding(
                            padding: EdgeInsets.only(bottom: 32.h),
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
                  ),
                ],
              ),
            ),
    );
  }
}
