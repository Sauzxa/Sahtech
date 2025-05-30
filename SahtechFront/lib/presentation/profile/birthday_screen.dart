import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sahtech/core/auth/signupNutritionist.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';
import 'package:sahtech/core/auth/signinUser.dart';
import 'package:sahtech/core/auth/signupUser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_success.dart';
import 'dart:math';

class BirthdayScreen extends StatefulWidget {
  final UserModel? userData;
  final NutritionisteModel? nutritionistData;
  final int currentStep;
  final int totalSteps;

  const BirthdayScreen({
    Key? key,
    this.userData,
    this.nutritionistData,
    this.currentStep = 4,
    this.totalSteps = 5,
  })  : assert(userData != null || nutritionistData != null,
            'Either userData or nutritionistData must be provided'),
        super(key: key);

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  late TranslationService _translationService;
  bool _isLoading = false;
  late final String userType;

  // Years, months, days for date picker
  final List<String> _years = List.generate(
      126, // 2025 - 1900 + 1 = 126 years
      (index) =>
          (2025 - index).toString()); // Start from 2025 and go back to 1900
  final List<String> _months = [
    'Jan',
    'Fev',
    'Mar',
    'Avr',
    'Mai',
    'Juin',
    'Juil',
    'Aout',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final List<String> _days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  // Date options to display (year, month, day)
  List<List<String>> _dateOptions = [
    ['2002', 'Fev', '03'],
    ['2003', 'Mar', '04'],
    ['2004', 'Avr', '05'],
    ['2005', 'Mai', '06'],
  ];

  // Current start index for date display
  int _dateDisplayStartIndex = 0;

  // Selected date
  String _selectedYear = '2022';
  String _selectedMonth = 'Avr'; // Default to April
  String _selectedDay = '22'; // Default to 22nd

  // Common food allergies
  final List<String> _commonAllergies = [
    'Lactose',
    'Gluten',
    'Fruits de mer',
    'Arachides',
    'Soja',
    'Œufs',
    'Fruits à coque',
    'Poisson',
  ];

  // Selected allergies
  final List<String> _selectedAllergies = [];

  // Key translations
  Map<String, String> _translations = {
    'title': 'Veuillez saisir votre date de naissance ?',
    'subtitle':
        'Choisissez votre date de naissance pour mieux adapter votre expérience.',
    'year': 'Year',
    'month': 'Month',
    'day': 'Day',
    'next': 'suivant',
    'success_message': 'Informations enregistrées avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _translationService.addListener(_onLanguageChanged);
    userType = widget.nutritionistData?.userType ??
        widget.userData?.userType ??
        'user';
    _loadTranslations();

    // Initialize allergies from model data if available
    if (userType == 'nutritionist') {
      if (widget.nutritionistData?.allergies != null &&
          widget.nutritionistData!.allergies!.isNotEmpty) {
        _selectedAllergies.addAll(widget.nutritionistData!.allergies!);
      }
    } else {
      if (widget.userData?.allergies.isNotEmpty ?? false) {
        _selectedAllergies.addAll(widget.userData!.allergies);
      }
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
    widget.userData!.preferredLanguage = languageCode;

    // Language change is handled by the listener (_onLanguageChanged)
  }

  // Toggle allergy selection
  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
  }

  void _continueToNextScreen() async {
    setState(() => _isLoading = true);

    try {
      // Save allergies to appropriate model
      if (userType == 'nutritionist') {
        // Always assign allergies regardless if empty
        widget.nutritionistData!.allergies = _selectedAllergies;
        // Debug log
        print("Setting allergies for nutritionist: $_selectedAllergies");

        // For nutritionist, navigate to signup screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupNutritionist(
              nutritionistData: widget.nutritionistData!,
            ),
          ),
        );
      } else {
        // Always assign allergies regardless if empty
        widget.userData!.allergies = _selectedAllergies;
        // Set hasAllergies based on selection
        widget.userData!.hasAllergies = _selectedAllergies.isNotEmpty;
        // Debug log
        print("Setting allergies for user: $_selectedAllergies");
        print(
            "User model after assignment - allergies: ${widget.userData!.allergies}");
        print(
            "User model after assignment - hasAllergies: ${widget.userData!.hasAllergies}");

        // Format date of birth in YYYY-MM-DD format
        String day = _selectedDay.padLeft(2, '0');
        String month;
        // Convert month name to number
        switch (_selectedMonth) {
          case 'Jan':
            month = '01';
            break;
          case 'Fev':
            month = '02';
            break;
          case 'Mar':
            month = '03';
            break;
          case 'Avr':
            month = '04';
            break;
          case 'Mai':
            month = '05';
            break;
          case 'Juin':
            month = '06';
            break;
          case 'Juil':
            month = '07';
            break;
          case 'Aout':
            month = '08';
            break;
          case 'Sep':
            month = '09';
            break;
          case 'Oct':
            month = '10';
            break;
          case 'Nov':
            month = '11';
            break;
          case 'Dec':
            month = '12';
            break;
          default:
            month = '01';
        }
        String year = _selectedYear;
        widget.userData!.dateOfBirth = "$year-$month-$day";
        print("Setting date of birth: ${widget.userData!.dateOfBirth}");

        // Navigate to user signup screen with all collected data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupUser(
              userData: widget.userData!,
            ),
          ),
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      // Show error message if navigation fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black45, size: 20.sp),
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
                  // Progress Bar (80%)
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
                            width: 1.sw * 0.8 - 3.2.w, // 80% progress
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                            SizedBox(height: 40.h),
                            // Date Picker Container
                            Container(
                              height: 220.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1.5.w),
                                borderRadius: BorderRadius.circular(15.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Year Picker
                                      Expanded(
                                        child: CupertinoPicker(
                                          backgroundColor: Colors.transparent,
                                          scrollController:
                                              FixedExtentScrollController(
                                                  initialItem:
                                                      _years.indexOf('2021')),
                                          itemExtent: 44.h,
                                          diameterRatio: 1.2,
                                          selectionOverlay:
                                              const CupertinoPickerDefaultSelectionOverlay(
                                            background: Colors.transparent,
                                          ),
                                          onSelectedItemChanged: (index) {
                                            setState(() {
                                              _selectedYear = _years[index];
                                            });
                                          },
                                          children: _years.map((year) {
                                            return Center(
                                              child: Text(
                                                year,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      // Month Picker
                                      Expanded(
                                        child: CupertinoPicker(
                                          backgroundColor: Colors.transparent,
                                          scrollController:
                                              FixedExtentScrollController(
                                                  initialItem:
                                                      _months.indexOf('Avr')),
                                          itemExtent: 44.h,
                                          diameterRatio: 1.2,
                                          selectionOverlay:
                                              const CupertinoPickerDefaultSelectionOverlay(
                                            background: Colors.transparent,
                                          ),
                                          onSelectedItemChanged: (index) {
                                            setState(() {
                                              _selectedMonth = _months[index];
                                            });
                                          },
                                          children: _months.map((month) {
                                            return Center(
                                              child: Text(
                                                month,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      // Day Picker
                                      Expanded(
                                        child: CupertinoPicker(
                                          backgroundColor: Colors.transparent,
                                          scrollController:
                                              FixedExtentScrollController(
                                                  initialItem:
                                                      _days.indexOf('22')),
                                          itemExtent: 44.h,
                                          diameterRatio: 1.2,
                                          selectionOverlay:
                                              const CupertinoPickerDefaultSelectionOverlay(
                                            background: Colors.transparent,
                                          ),
                                          onSelectedItemChanged: (index) {
                                            setState(() {
                                              _selectedDay = _days[index];
                                            });
                                          },
                                          children: _days.map((day) {
                                            return Center(
                                              child: Text(
                                                day,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Custom selection indicator with divider lines instead of a color overlay
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Expanded(child: SizedBox()),
                                          Container(
                                            height: 44.h,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: AppColors.lightTeal
                                                      .withOpacity(0.3),
                                                  width: 2.h,
                                                ),
                                                bottom: BorderSide(
                                                  color: AppColors.lightTeal,
                                                  width: 2.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Expanded(child: SizedBox()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 200.h),
                            // Next Button
                            Center(
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
                  ),
                ],
              ),
            ),
    );
  }
}
