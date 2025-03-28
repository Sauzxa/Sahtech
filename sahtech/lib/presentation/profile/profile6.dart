import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile7.dart';

class Profile6 extends StatefulWidget {
  final UserModel userData;

  const Profile6({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile6> createState() => _Profile6State();
}

class _Profile6State extends State<Profile6> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool _isDropdownOpen = false;

  // Available goals with selection state
  final Map<String, bool> _goals = {
    'Contrôle du diabète': false,
    'Perte de poid': false,
    'Réduction du cholestérol': false,
  };

  // Key translations
  Map<String, String> _translations = {
    'title': 'choisir votre objectif dans notre application ?',
    'subtitle':
        'Choisissez un objectif pour mieux adapter votre expérience. Cette option est optionnelle!',
    'dropdown_label': 'Choisir ton objectif',
    'next': 'suivant',
    'success_message': 'Objectifs enregistrés avec succès!',
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

        // Translate goal names
        final translatedGoals = <String, bool>{};
        for (final goal in _goals.keys) {
          final translatedGoal = await _translationService.translate(goal);
          translatedGoals[translatedGoal] = false;
        }

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            // Uncomment to enable goal translation
            // _goals.clear();
            // _goals.addAll(translatedGoals);
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

  void _toggleGoal(String goal) {
    setState(() {
      _goals[goal] = !_goals[goal]!;
    });
  }

  void _continueToNextScreen() {
    // Get selected goals
    final selectedGoals =
        _goals.entries.where((e) => e.value).map((e) => e.key).toList();

    // Update user model with selected goals (can be empty since goals are optional)
    widget.userData.healthGoals = selectedGoals;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate to Profile7
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile7(userData: widget.userData),
      ),
    );
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
                  // Green divider line
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppColors.lightTeal,
                  ),

                  // Green progress bar
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:
                              width * 0.5, // Representing 50% progress (step 5)
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
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

                          // Goal options list - only shown when dropdown is open
                          if (_isDropdownOpen)
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Column(
                                    children: _goals.entries.map((entry) {
                                      return _buildGoalOption(
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

                          if (!_isDropdownOpen) Expanded(child: SizedBox()),

                          // Next button
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.05),
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

  // Updated goal option widget to better match the design
  Widget _buildGoalOption(
      String goal, bool isSelected, double width, double height) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleGoal(goal),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.022,
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: width * 0.06,
                  height: width * 0.06,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.lightTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.lightTeal : Colors.grey[400]!,
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

                // Goal name
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
