import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';

class Profile6 extends StatefulWidget {
  final UserModel userData;

  const Profile6({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile6> createState() => _Profile6State();
}

class _Profile6State extends State<Profile6> {
  late TranslationService _translationService;
  bool _isLoading = false;

  // Key translations
  Map<String, String> _translations = {
    'title': 'Résumé du Profil',
    'subtitle': 'Voici un résumé des informations que vous avez fournies',
    'user_type': 'Type d\'utilisateur',
    'chronic_conditions': 'Conditions chroniques',
    'exercise': 'Fait de l\'exercice',
    'activities': 'Activités physiques',
    'yes': 'Oui',
    'no': 'Non',
    'finish': 'Terminer',
    'success_message': 'Profil complété avec succès!',
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

  void _finishProfile() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // For now we'll just pop back to previous screen
    // In a real app, you might navigate to the main app screen
    Navigator.of(context).pop();
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
                              0.75, // Representing progress (5 of 5 steps)
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
                          SizedBox(height: height * 0.03),

                          // Title
                          Text(
                            _translations['title']!,
                            style: TextStyle(
                              fontSize: width * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // Subtitle
                          Text(
                            _translations['subtitle']!,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),

                          SizedBox(height: height * 0.04),

                          // User info summary
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // User type
                                  _buildInfoItem(
                                    _translations['user_type']!,
                                    widget.userData.userType == 'user'
                                        ? 'Utilisateur'
                                        : 'Nutritionniste',
                                    width,
                                  ),

                                  // Chronic conditions
                                  _buildInfoItem(
                                    _translations['chronic_conditions']!,
                                    widget.userData.chronicConditions.isNotEmpty
                                        ? widget.userData.chronicConditions
                                            .join(', ')
                                        : 'N/A',
                                    width,
                                  ),

                                  // Exercise
                                  _buildInfoItem(
                                    _translations['exercise']!,
                                    widget.userData.doesExercise == true
                                        ? _translations['yes']!
                                        : _translations['no']!,
                                    width,
                                  ),

                                  // Physical activities
                                  if (widget.userData.doesExercise == true)
                                    _buildInfoItem(
                                      _translations['activities']!,
                                      widget.userData.physicalActivities
                                              .isNotEmpty
                                          ? widget.userData.physicalActivities
                                              .join(', ')
                                          : 'N/A',
                                      width,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Finish button
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.02),
                            child: SizedBox(
                              width: double.infinity,
                              height: height * 0.065,
                              child: ElevatedButton(
                                onPressed: _finishProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightTeal,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  _translations['finish']!,
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

  Widget _buildInfoItem(String label, String value, double width) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.038,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
