import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile10.dart';

class Profile9 extends StatefulWidget {
  final UserModel userData;
  final int currentStep;
  final int totalSteps;

  const Profile9({
    Key? key,
    required this.userData,
    this.currentStep = 3,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<Profile9> createState() => _Profile9State();
}

class _Profile9State extends State<Profile9> {
  late TranslationService _translationService;
  bool _isLoading = false;

  // Height related variables
  double _height = 170.0; // Default height in cm
  String _heightUnit = 'cm'; // Default unit

  // Min and max height values
  final double _minHeight = 100.0; // Min height in cm
  final double _maxHeight = 250.0; // Max height in cm

  // Key translations
  Map<String, String> _translations = {
    'title': 'Veuillez saisir votre taille?',
    'subtitle':
        'pour une expérience optimale. Afin de vous offrir un service personnalisé, nous vous invitons à renseigner certaines informations, telles que votre poids',
    'cm': 'cm',
    'inches': 'inches',
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

    // Initialize height from user data if available
    if (widget.userData.height != null) {
      _height = widget.userData.height!;
    }
    if (widget.userData.heightUnit != null) {
      _heightUnit = widget.userData.heightUnit!;
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

  // Toggle between cm and inches
  void _toggleUnit(String unit) {
    if (_heightUnit != unit) {
      setState(() {
        if (unit == 'cm' && _heightUnit == 'inches') {
          // Convert inches to cm
          _height = _inchesToCm(_height);
        } else if (unit == 'inches' && _heightUnit == 'cm') {
          // Convert cm to inches
          _height = _cmToInches(_height);
        }
        _heightUnit = unit;
      });
    }
  }

  // Convert inches to centimeters
  double _inchesToCm(double inches) {
    return inches * 2.54;
  }

  // Convert centimeters to inches
  double _cmToInches(double cm) {
    return cm / 2.54;
  }

  // Format height value for display
  String _formatHeight(double height) {
    return height.toInt().toString();
  }

  void _continueToNextScreen() {
    // Store height value in user's preferred unit
    widget.userData.height = _height;
    widget.userData.heightUnit = _heightUnit;

    // Navigate to the allergies screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile10(
          userData: widget.userData,
          currentStep: widget.currentStep + 1,
          totalSteps: widget.totalSteps,
        ),
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
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:
                              width * 0.8, // Representing 80% progress (step 8)
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
                              fontSize: width * 0.035,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          // Height unit selector (cm/inches) - pill style toggle
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
                                  // inches selector
                                  GestureDetector(
                                    onTap: () => _toggleUnit('inches'),
                                    child: Container(
                                      width: width * 0.15,
                                      height: height * 0.045,
                                      decoration: BoxDecoration(
                                        color: _heightUnit == 'inches'
                                            ? Colors.white
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: _heightUnit == 'inches'
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
                                          'inches',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // cm selector
                                  GestureDetector(
                                    onTap: () => _toggleUnit('cm'),
                                    child: Container(
                                      width: width * 0.15,
                                      height: height * 0.045,
                                      decoration: BoxDecoration(
                                        color: _heightUnit == 'cm'
                                            ? AppColors.lightTeal
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'cm',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            fontWeight: FontWeight.w500,
                                            color: _heightUnit == 'cm'
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

                          // Height display area with slider
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
                                // Height value display
                                Text(
                                  _formatHeight(_height),
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
                                            '150',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '160',
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
                                            '180',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '190',
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
                                          value: _height.clamp(
                                              _minHeight, _maxHeight),
                                          min: _minHeight,
                                          max: _maxHeight,
                                          onChanged: (value) {
                                            setState(() {
                                              _height = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Height unit
                                Text(
                                  _heightUnit,
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
