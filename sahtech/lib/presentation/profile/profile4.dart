import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile5.dart';

class Profile4 extends StatefulWidget {
  final UserModel userData;

  const Profile4({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile4> createState() => _Profile4State();
}

class _Profile4State extends State<Profile4> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool? _doesExercise; // true = Yes, false = No, null = Not selected yet

  // Key translations
  Map<String, String> _translations = {
    'title': 'Pratiquez-vous une activité physique ?',
    'subtitle':
        'Pour un suivi plus précis, veuillez spécifier si vous faites de l\'activité physique',
    'yes': 'Oui',
    'no': 'Non',
    'next': 'suivant',
    'select_option': 'Veuillez sélectionner une option',
    'success_message': 'Informations enregistrées avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _translationService.addListener(_onLanguageChanged);
    _loadTranslations();
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

  void _continueToNextScreen() async {
    if (_doesExercise == null) {
      // Show error if no selection made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['select_option']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user model with the exercise selection
    widget.userData.doesExercise = _doesExercise;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // If user does exercise, navigate to Profile5 for activity selection
    // If not, we don't navigate anywhere (as per updated requirements)
    if (_doesExercise == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile5(userData: widget.userData),
        ),
      );
    }
    // No else block needed - if user selects "No", we stay on this screen
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Calculate safe padding
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Use safe area values for better positioning on notched devices
    final double safeAreaVerticalPadding = topPadding + bottomPadding;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: width * 0.12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTeal, size: width * 0.05),
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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Green progress bar
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        Container(
                          width: width *
                              0.45, // Representing progress (3 of 5 steps)
                          height: 4,
                          color: AppColors.lightTeal,
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.04),

                          // Main question
                          Text(
                            _translations['title']!,
                            style: TextStyle(
                              fontSize: width * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // Subtitle/explanation
                          Text(
                            _translations['subtitle']!,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),

                          SizedBox(height: height * 0.06),

                          // Yes button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _doesExercise = true;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: height * 0.07,
                              decoration: BoxDecoration(
                                color: _doesExercise == true
                                    ? AppColors.lightTeal.withOpacity(0.3)
                                    : AppColors.lightTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _doesExercise == true
                                      ? AppColors.lightTeal
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _translations['yes']!,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // No button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _doesExercise = false;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: height * 0.07,
                              decoration: BoxDecoration(
                                color: _doesExercise == false
                                    ? AppColors.lightTeal.withOpacity(0.3)
                                    : AppColors.lightTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _doesExercise == false
                                      ? AppColors.lightTeal
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _translations['no']!,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Next button
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: height * 0.03,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: height * 0.06,
                              child: ElevatedButton(
                                onPressed: _continueToNextScreen,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightTeal,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
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
                  ),
                ],
              ),
            ),
    );
  }
}
