import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/presentation/profile/profile2.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sahtech/core/widgets/language_selector.dart';

class Profile1 extends StatefulWidget {
  const Profile1({super.key});

  @override
  State<Profile1> createState() => _Profile1State();
}

class _Profile1State extends State<Profile1> with WidgetsBindingObserver {
  // Initial selection (null means none selected)
  String? selectedUserType;
  late TranslationService _translationService;
  bool _isLoading = true;
  String _currentLanguage = '';

  // Text strings used in this screen
  Map<String, String> _translations = {
    'title': 'Démarrons ensemble',
    'subtitle':
        'Scannez vos aliments et recevez des conseils adaptés à votre profil pour faire les meilleurs choix nutritionnels',
    'normalUserTitle': 'Je suis un utilisateur',
    'normalUserDesc': 'Compte utilisateur pour utiliser l\'appli',
    'nutritionistTitle': 'Je suis un nutritioniste',
    'nutritionistDesc': 'Compte nutritioniste pour être consulter',
    'continue': 'Continue',
    'selectAccountType': 'Veuillez sélectionner un type de compte'
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
    // Check if language has changed
    final translationService =
        Provider.of<TranslationService>(context, listen: false);
    if (_currentLanguage != '' &&
        _currentLanguage != translationService.currentLanguageCode) {
      _loadTranslations();
    }
  }

  // Load translations when the screen initializes
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      _translationService =
          Provider.of<TranslationService>(context, listen: false);
      final currentLanguage = _translationService.currentLanguageCode;
      _currentLanguage = currentLanguage;

      // Only translate if not French (our default language)
      if (currentLanguage != 'fr') {
        final translated =
            await _translationService.translateMap(_translations);

        setState(() {
          _translations = translated;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      setState(() => _isLoading = false);
    }
  }

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Reset loading state and reload translations
    setState(() => _isLoading = true);

    // Set currentLanguage to the new language to prevent extra reloads
    _currentLanguage = languageCode;

    // Load translations with the new language
    _loadTranslations();
  }

  // Function to navigate to the next screen with user data
  void navigateToProfile2() async {
    if (selectedUserType != null) {
      final userData = UserModel(
        userType: selectedUserType!,
        preferredLanguage: _translationService.currentLanguageCode,
      );

      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile2(userData: userData),
        ),
      );

      // If we return to this screen and the language has changed
      if (result == 'language_changed') {
        await _loadTranslations();
      }
    } else {
      // Show a snackbar if no user type is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['selectAccountType']!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get latest language from Provider
    final translationService = Provider.of<TranslationService>(context);
    if (_currentLanguage != translationService.currentLanguageCode) {
      // If there's a new language since we last loaded, reload translations
      Future.microtask(() => _loadTranslations());
    }

    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Check if a user type is selected
    final bool isUserTypeSelected = selectedUserType != null;

    // Show loading indicator while translations are being fetched
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.lightTeal,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Language selector button
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: LanguageSelectorButton(
              width: width,
              onLanguageChanged: _handleLanguageChanged,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.02),

              // Main Title
              Text(
                _translations['title']!,
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: height * 0.015),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Text(
                  _translations['subtitle']!,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: height * 0.06),

              // User option card
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedUserType = 'user';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: selectedUserType == 'user'
                          ? AppColors.lightTeal
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // User icon - green square with person icon
                      Container(
                        padding: EdgeInsets.all(width * 0.03),
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.lightTeal,
                          size: width * 0.06,
                        ),
                      ),

                      SizedBox(width: width * 0.04),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['normalUserTitle']!,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              _translations['normalUserDesc']!,
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right arrow
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: width * 0.06,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.025),

              // Nutritionist option card
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedUserType = 'nutritionist';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: selectedUserType == 'nutritionist'
                          ? AppColors.lightTeal
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Nutritionist icon - green square with stethoscope icon
                      Container(
                        padding: EdgeInsets.all(width * 0.03),
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.stethoscope,
                          color: AppColors.lightTeal,
                          size: width * 0.05,
                        ),
                      ),

                      SizedBox(width: width * 0.04),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['nutritionistTitle']!,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              _translations['nutritionistDesc']!,
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right arrow
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: width * 0.06,
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // Continue button (disabled until a user type is selected)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: height * 0.03),
                child: ElevatedButton(
                  onPressed: isUserTypeSelected ? navigateToProfile2 : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUserTypeSelected
                        ? AppColors.lightTeal
                        : Colors.grey[300],
                    foregroundColor:
                        isUserTypeSelected ? Colors.black87 : Colors.grey[600],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _translations['continue']!,
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
