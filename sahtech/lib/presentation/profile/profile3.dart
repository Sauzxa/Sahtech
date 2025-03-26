import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile4.dart';

class Profile3 extends StatefulWidget {
  final UserModel userData;

  const Profile3({super.key, required this.userData});

  @override
  State<Profile3> createState() => _Profile3State();
}

class _Profile3State extends State<Profile3> {
  late TranslationService _translationService;
  bool _isLoading = false;
  bool _isDropdownOpen = false;
  String? _selectedDisease;

  // Available chronic conditions with selection state
  final Map<String, bool> _diseases = {
    'Diabète': false,
    'Hypertension artérielle': false,
    'Obésité': false,
    'Asthme': false,
    'Dépression': false,
    'Anxiété': false,
    'Gastrite': false,
    'Caries dentaires': false,
    'Conjonctivite': false,
    'Maladie coeliaque': false,
    'Arthrose': false,
  };

  // Key translations
  Map<String, String> _translations = {
    'title': 'Choisir votre maladies ?',
    'subtitle':
        'Afin de vous offrir une expérience optimale et des recommandations personnalisées, veuillez choisir votre maladie',
    'dropdown_label': 'Choisir ton maladie',
    'next': 'suivant',
    'select_condition': 'Veuillez sélectionner votre condition',
    'success_message': 'Informations enregistrées avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
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

        // Translate disease names
        final translatedDiseases = <String, bool>{};
        for (final disease in _diseases.keys) {
          final translatedDisease =
              await _translationService.translate(disease);
          translatedDiseases[translatedDisease] = false;
        }

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            // Uncomment to enable disease translation
            // _diseases.clear();
            // _diseases.addAll(translatedDiseases);
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
    // Reset loading state and reload translations
    setState(() => _isLoading = true);

    // Update user model with the new language
    widget.userData.preferredLanguage = languageCode;

    // Load translations with the new language
    _loadTranslations();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _selectDisease(String disease) {
    setState(() {
      if (_diseases[disease] == true) {
        _diseases[disease] = false;
      } else {
        _diseases[disease] = true;
      }

      // Update selected disease for dropdown display
      final selectedDiseases =
          _diseases.entries.where((e) => e.value).map((e) => e.key).toList();
      if (selectedDiseases.isNotEmpty) {
        _selectedDisease = selectedDiseases.first;
      }
    });
  }

  void _continueToNextScreen() async {
    final selectedDiseases =
        _diseases.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedDiseases.isEmpty) {
      // Show error if no selection made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate(_translations['select_condition']!)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user model with the selected chronic conditions
    widget.userData.chronicConditions = selectedDiseases;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to Profile4 with the updated user data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Profile4(userData: widget.userData),
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
              color: Colors.black87, size: width * 0.05),
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
              child: Stack(
                children: [
                  Column(
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
                                  0.30, // Representing progress (2 of 5 steps)
                              height: 4,
                              color: AppColors.lightTeal,
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.06),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height * 0.04),

                                // Main question
                                Text(
                                  _translations['title']!,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                SizedBox(height: height * 0.02),

                                // Subtitle/explanation
                                Text(
                                  _translations['subtitle']!,
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),

                                SizedBox(height: height * 0.03),

                                // Dropdown
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
                                          _selectedDisease ??
                                              _translations['dropdown_label']!,
                                          style: TextStyle(
                                            fontSize: width * 0.04,
                                            color: _selectedDisease != null
                                                ? Colors.black87
                                                : Colors.black54,
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

                                // Disease options (only shown when dropdown is open)
                                if (_isDropdownOpen)
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: _diseases.entries
                                          .map((entry) => _buildDiseaseOption(
                                              entry.key,
                                              entry.value,
                                              width,
                                              height))
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Next button
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06, vertical: height * 0.02),
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
                ],
              ),
            ),
    );
  }

  Widget _buildDiseaseOption(
      String disease, bool isSelected, double width, double height) {
    return InkWell(
      onTap: () => _selectDisease(disease),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: height * 0.012),
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

            // Disease name
            Text(
              disease,
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
