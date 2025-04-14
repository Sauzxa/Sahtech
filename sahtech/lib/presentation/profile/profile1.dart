import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/presentation/profile/profile2.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste2.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';

class Profile1 extends StatefulWidget {
  const Profile1({super.key});

  @override
  State<Profile1> createState() => _Profile1State();
}

class _Profile1State extends State<Profile1> with WidgetsBindingObserver {
  String? selectedUserType;
  late TranslationService _translationService;
  bool _isLoading = true;
  String _currentLanguage = '';

  Map<String, String> _translations = {
    'title': 'Démarrons ensemble',
    'subtitle':
        'Scannez vos aliments et recevez des conseils adaptés à votre profil pour faire les meilleurs choix nutritionnels',
    'normalUserTitle': 'Je suis un utilisateur',
    'normalUserDesc': 'Compte utilisateur pour utiliser l\'appli',
    'nutritionistTitle': 'Je suis un nutritioniste',
    'nutritionistDesc': 'Compte nutritioniste pour être consulter',
    'continue': 'suivant',
    'selectAccountType': 'Veuillez sélectionner un type de compte',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTranslations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final translationService =
        Provider.of<TranslationService>(context, listen: true);

    if (_currentLanguage != translationService.currentLanguageCode) {
      debugPrint(
          "Language changed from $_currentLanguage to ${translationService.currentLanguageCode}");
      _currentLanguage = translationService.currentLanguageCode;
      _loadTranslations();
    }
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      _translationService =
          Provider.of<TranslationService>(context, listen: false);

      if (_currentLanguage != 'fr') {
        debugPrint("Translating to $_currentLanguage");
        final translated =
            await _translationService.translateMap(_translations);

        if (mounted) {
          setState(() {
            _translations = translated;
            _isLoading = false;
          });
        }
      } else {
        _translations = {
          'title': 'Démarrons ensemble',
          'subtitle':
              'Scannez vos aliments et recevez des conseils adaptés à votre profil pour faire les meilleurs choix nutritionnels',
          'normalUserTitle': 'Je suis un utilisateur',
          'normalUserDesc': 'Compte utilisateur pour utiliser l\'appli',
          'nutritionistTitle': 'Je suis un nutritioniste',
          'nutritionistDesc': 'Compte nutritioniste pour être consulter',
          'continue': 'suivant',
          'selectAccountType': 'Veuillez sélectionner un type de compte',
        };

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
    debugPrint("Language manually changed to $languageCode");
    setState(() {
      _isLoading = true;
      _currentLanguage = languageCode;
    });

    _loadTranslations();
  }

  void navigateToNextScreen() async {
    if (selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['selectAccountType']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedUserType == 'user') {
      final userData = UserModel(
        userType: selectedUserType!,
        preferredLanguage: _translationService.currentLanguageCode,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile2(userData: userData),
        ),
      );
      return;
    }

    if (selectedUserType == 'nutritionist') {
      final nutritionistData = NutritionisteModel(
        userType: selectedUserType!,
        preferredLanguage: _translationService.currentLanguageCode,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Nutritioniste2(nutritionistData: nutritionistData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF9FE870),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Row for logo and language selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Selector Button on the left
                  LanguageSelectorButton(
                    onLanguageChanged: _handleLanguageChanged,
                  ),

                  // Logo in the center
                  Image.asset(
                    'lib/assets/images/mainlogo.jpg',
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),

                  // Empty container to balance the row
                  SizedBox(width: 40.w),
                ],
              ),

              SizedBox(height: 20.h),

              // Title
              Center(
                child: Text(
                  _translations['title']!,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Subtitle
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    _translations['subtitle']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // User Selection Card
              InkWell(
                onTap: () {
                  setState(() {
                    selectedUserType = 'user';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: selectedUserType == 'user'
                          ? const Color(0xFF9FE870)
                          : Colors.grey.shade200,
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: selectedUserType == 'user'
                            ? const Color(0xFF9FE870).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFD5FFB8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.black87,
                          size: 22.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['normalUserTitle']!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _translations['normalUserDesc']!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFD5FFB8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black87,
                          size: 12.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Nutritionist Selection Card
              InkWell(
                onTap: () {
                  setState(() {
                    selectedUserType = 'nutritionist';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: selectedUserType == 'nutritionist'
                          ? const Color(0xFF9FE870)
                          : Colors.grey.shade200,
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: selectedUserType == 'nutritionist'
                            ? const Color(0xFF9FE870).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFD5FFB8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_information_outlined,
                          color: Colors.black87,
                          size: 22.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['nutritionistTitle']!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _translations['nutritionistDesc']!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFD5FFB8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black87,
                          size: 12.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // Custom Button for navigation
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 24.h),
                child: CustomButton(
                  text: _translations['continue']!,
                  onPressed: navigateToNextScreen,
                  width: 1.sw - 48.w,
                  height: 54.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
