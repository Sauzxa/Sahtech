import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';

class Profile8 extends StatefulWidget {
  final UserModel userData;

  const Profile8({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile8> createState() => _Profile8State();
}

class _Profile8State extends State<Profile8> {
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
        if (unit == 'kg' && _weightUnit == 'lb') {
          // Convert lb to kg
          _weight = _lbToKg(_weight);
        } else if (unit == 'lb' && _weightUnit == 'kg') {
          // Convert kg to lb
          _weight = _kgToLb(_weight);
        }
        _weightUnit = unit;
      });
    }
  }

  // Convert pounds to kilograms
  double _lbToKg(double lb) {
    return lb * 0.453592;
  }

  // Convert kilograms to pounds
  double _kgToLb(double kg) {
    return kg * 2.20462;
  }

  // Format weight value for display
  String _formatWeight(double weight) {
    return weight.toInt().toString();
  }

  void _continueToNextScreen() {
    // Store weight value in user's preferred unit
    widget.userData.weight = _weight;
    widget.userData.weightUnit = _weightUnit;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to home or to the main screen
    Navigator.popUntil(context, (route) => route.isFirst);
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
              color: Colors.green, size: width * 0.05),
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
                  // Green progress bar/line at the top
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppColors.lightTeal,
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
                              fontSize: width * 0.035,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          // Weight unit selector (kg/lb) - pill style toggle
                          Center(
                            child: Container(
                              width: width * 0.3,
                              height: height * 0.045,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  // lb selector
                                  GestureDetector(
                                    onTap: () => _toggleUnit('lb'),
                                    child: Container(
                                      width: width * 0.15,
                                      height: height * 0.045,
                                      decoration: BoxDecoration(
                                        color: _weightUnit == 'lb'
                                            ? Colors.white
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(25),
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
                                            fontSize: width * 0.035,
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
                                      width: width * 0.15,
                                      height: height * 0.045,
                                      decoration: BoxDecoration(
                                        color: _weightUnit == 'kg'
                                            ? AppColors.lightTeal
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'kg',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            fontWeight: FontWeight.w500,
                                            color: _weightUnit == 'kg'
                                                ? Colors.black87
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          // Weight display area with slider
                          Container(
                            width: double.infinity,
                            height: height * 0.3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF9E8),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Weight value display
                                Text(
                                  _formatWeight(_weight),
                                  style: TextStyle(
                                    fontSize: width * 0.2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                SizedBox(height: height * 0.03),

                                // Scale markings and slider
                                Container(
                                  width: width * 0.7,
                                  child: Column(
                                    children: [
                                      // Scale markings
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '50',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '60',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Container(
                                            height: height * 0.04,
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            '80',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '90',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
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
                                          21,
                                          (index) => Container(
                                            height: index % 5 == 0 ? 12 : 6,
                                            width: 1,
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
                                            enabledThumbRadius: width * 0.015,
                                          ),
                                          overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: width * 0.025,
                                          ),
                                          trackHeight: 0,
                                        ),
                                        child: Slider(
                                          value: _weight.clamp(
                                              _minWeight, _maxWeight),
                                          min: _minWeight,
                                          max: _maxWeight,
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
                                    fontSize: width * 0.04,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Spacer(),

                          // Next button
                          Padding(
                            padding: EdgeInsets.only(bottom: height * 0.02),
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
}
