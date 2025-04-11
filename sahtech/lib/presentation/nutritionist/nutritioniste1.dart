import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Nutritioniste1 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste1({
    super.key,
    required this.nutritionistData,
    this.currentStep = 1,
    this.totalSteps = 5,
  });

  @override
  State<Nutritioniste1> createState() => _Nutritioniste1State();
}

class _Nutritioniste1State extends State<Nutritioniste1> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Translations
  Map<String, String> _translations = {
    'title': 'Commençons !',
    'subtitle': 'Veuillez remplir vos informations personnelles.',
    'name_label': 'Nom complet',
    'name_hint': 'Entrez votre nom complet',
    'email_label': 'Email',
    'email_hint': 'Entrez votre email',
    'next': 'suivant',
    'name_required': 'Le nom est requis',
    'email_required': 'L\'email est requis',
    'invalid_email': 'Email invalide',
    'success_message': 'Informations enregistrées avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService = Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();

    // Initialize with existing data if available
    _nameController.text = widget.nutritionistData.name ?? '';
    _emailController.text = widget.nutritionistData.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (default language)
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
    // Update nutritionist model with the new language
    widget.nutritionistData.preferredLanguage = languageCode;

    // Reload translations with the new language
    _loadTranslations();
  }

  void _continueToNextScreen() {
    if (!_formKey.currentState!.validate()) return;

    // Save the data to the nutritionist model
    widget.nutritionistData.name = _nameController.text.trim();
    widget.nutritionistData.email = _emailController.text.trim();

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Nutritioniste2(
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
                            child: Form(
                              key: _formKey,
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

                                  SizedBox(height: 32.h),

                                  // Name field
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: _translations['name_label'],
                                      hintText: _translations['name_hint'],
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.sp,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14.sp,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(
                                          color: AppColors.lightTeal,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return _translations['name_required'];
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),

                                  SizedBox(height: 24.h),

                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: _translations['email_label'],
                                      hintText: _translations['email_hint'],
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.sp,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14.sp,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(
                                          color: AppColors.lightTeal,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return _translations['email_required'];
                                      }
                                      if (!RegExp(
                                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                          .hasMatch(value)) {
                                        return _translations['invalid_email'];
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
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
}
