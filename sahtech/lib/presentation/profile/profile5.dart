import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile6.dart';

class Profile5 extends StatefulWidget {
  final UserModel userData;

  const Profile5({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile5> createState() => _Profile5State();
}

class _Profile5State extends State<Profile5> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool _isDropdownOpen = false;

  // Available physical activities with selection state
  final Map<String, bool> _activities = {
    'Musculation': false,
    'Football': false,
    'Boxe': false,
    'Vélo': false,
    'Natation': false,
    'Saut à la corde': false,
    'Handball': false,
    'Tennis': false,
    'Kung-fu': false,
    'Lutte': false,
  };

  // Key translations
  Map<String, String> _translations = {
    'title': 'Choisir votre activités physiques ?',
    'subtitle':
        'Pour des recommandations adaptées, veuillez nous informer sur votre fréquence d\'activité physique',
    'dropdown_label': 'Choisir ton Activité',
    'next': 'suivant',
    'select_activity': 'Veuillez sélectionner au moins une activité',
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
        // Translate the UI strings
        final translatedStrings =
            await _translationService.translateMap(_translations);

        // Translate activity names
        final translatedActivities = <String, bool>{};
        for (final activity in _activities.keys) {
          final translatedActivity =
              await _translationService.translate(activity);
          translatedActivities[translatedActivity] = false;
        }

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            // Uncomment to enable activity translation
            // _activities.clear();
            // _activities.addAll(translatedActivities);
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

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _toggleActivity(String activity) {
    setState(() {
      _activities[activity] = !_activities[activity]!;
    });
  }

  void _continueToNextScreen() async {
    final selectedActivities =
        _activities.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedActivities.isEmpty) {
      // Show error if no selection made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['select_activity']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user model with the selected activities
    widget.userData.physicalActivities = selectedActivities;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // As per updated requirements, we don't navigate to Profile6 yet
    // Navigation to the next screen will be implemented later
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
                              0.60, // Representing progress (4 of 5 steps)
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

                          SizedBox(height: height * 0.03),

                          // Dropdown button
                          GestureDetector(
                            onTap: _toggleDropdown,
                            child: Container(
                              width: double.infinity,
                              height: height * 0.07,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF9E8),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.04),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _translations['dropdown_label']!,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    _isDropdownOpen
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Activity options list (always visible, no need for dropdown)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: _activities.entries.map((entry) {
                                      return _buildActivityOption(
                                        entry.key,
                                        entry.value,
                                        width,
                                        height,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Next button
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.02),
                            child: SizedBox(
                              width: double.infinity,
                              height: height * 0.065,
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
                                    fontSize: width * 0.04,
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

  Widget _buildActivityOption(
      String activity, bool isSelected, double width, double height) {
    return InkWell(
      onTap: () => _toggleActivity(activity),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: height * 0.015),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: width * 0.06,
              height: width * 0.06,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.lightTeal : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: width * 0.04,
                    )
                  : null,
            ),
            SizedBox(width: width * 0.03),

            // Activity name
            Text(
              activity,
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
