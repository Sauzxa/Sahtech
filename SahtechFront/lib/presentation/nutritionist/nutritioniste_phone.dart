import 'package:flutter/material.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/profile/chronic_disease_screen.dart';
import '../widgets/custom_button.dart';

class NutritionistePhone extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const NutritionistePhone({
    super.key,
    required this.nutritionistData,
  });

  @override
  State<NutritionistePhone> createState() => _NutritionistePhoneState();
}

class _NutritionistePhoneState extends State<NutritionistePhone> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  String selectedCountryCode = '+213';
  bool isButtonEnabled = false;

  // List of country codes
  final List<Map<String, String>> countryCodes = [
    {'code': '+213', 'country': 'Algeria'},
    {'code': '+216', 'country': 'Tunisia'},
    {'code': '+212', 'country': 'Morocco'},
    {'code': '+33', 'country': 'France'},
    {'code': '+1', 'country': 'USA'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+49', 'country': 'Germany'},
    {'code': '+34', 'country': 'Spain'},
    {'code': '+39', 'country': 'Italy'},
    {'code': '+32', 'country': 'Belgium'},
    {'code': '+41', 'country': 'Switzerland'},
    {'code': '+31', 'country': 'Netherlands'},
    {'code': '+351', 'country': 'Portugal'},
    {'code': '+971', 'country': 'UAE'},
    {'code': '+966', 'country': 'Saudi Arabia'},
  ];

  // Max length for phone numbers by country code
  final Map<String, int> phoneMaxLength = {
    '+213': 9, // Algeria: 9 digits (excluding leading 0)
    '+216': 8, // Tunisia: 8 digits
    '+212': 9, // Morocco: 9 digits
    '+33': 9, // France: 9 digits (excluding leading 0)
    '+1': 10, // USA/Canada: 10 digits
    '+44': 10, // UK: 10 digits (excluding leading 0)
    '+49': 11, // Germany: 10-11 digits
    '+34': 9, // Spain: 9 digits
    '+39': 10, // Italy: 10 digits
    '+32': 9, // Belgium: 9 digits
    '+41': 9, // Switzerland: 9 digits
    '+31': 9, // Netherlands: 9 digits
    '+351': 9, // Portugal: 9 digits
    '+971': 9, // UAE: 9 digits
    '+966': 9, // Saudi Arabia: 9 digits
  };

  // Validation patterns for phone numbers by country code
  final Map<String, String> phonePatterns = {
    '+213':
        r'^(5|6|7)[0-9]{8}$', // Algeria: starts with 5, 6, or 7 followed by 8 digits
    '+216': r'^[2-9][0-9]{7}$', // Tunisia: starts with 2-9 followed by 7 digits
    '+212': r'^[6-7][0-9]{8}$', // Morocco: starts with 6-7 followed by 8 digits
    '+33': r'^[67][0-9]{8}$', // France: starts with 6-7 followed by 8 digits
    '+1':
        r'^[2-9][0-9]{9}$', // USA/Canada: starts with 2-9 followed by 9 digits
    '+44': r'^[7][0-9]{9}$', // UK: starts with 7 followed by 9 digits
    '+49':
        r'^[1-9][0-9]{9,10}$', // Germany: starts with 1-9 followed by 9-10 digits
    '+34': r'^[6-9][0-9]{8}$', // Spain: starts with 6-9 followed by 8 digits
    '+39': r'^[3][0-9]{9}$', // Italy: starts with 3 followed by 9 digits
    '+32': r'^[4][0-9]{8}$', // Belgium: starts with 4 followed by 8 digits
    '+41': r'^[7][0-9]{8}$', // Switzerland: starts with 7 followed by 8 digits
    '+31': r'^[6][0-9]{8}$', // Netherlands: starts with 6 followed by 8 digits
    '+351': r'^[9][0-9]{8}$', // Portugal: starts with 9 followed by 8 digits
    '+971': r'^[5][0-9]{8}$', // UAE: starts with 5 followed by 8 digits
    '+966':
        r'^[5][0-9]{8}$', // Saudi Arabia: starts with 5 followed by 8 digits
  };

  // Translations
  Map<String, String> _translations = {
    'title': 'Ajouter votre numero de telephone',
    'subtitle':
        'Pour vous rendre joignable par les utilisateurs, veuillez saisir votre numéro de téléphone afin  qu \'ils puissent vous contacter ou se connecter directement avec vous',
    'phone_label': 'Veuillez entrer votre numero de téléphone',
    'continue': 'Continue',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();

    // Pre-fill if phone number already exists in model
    if (widget.nutritionistData.phoneNumber != null) {
      _phoneController.text = widget.nutritionistData.phoneNumber!;
    }

    // Add listener to controller to update button state
    _phoneController.addListener(() {
      setState(() {
        isButtonEnabled = _phoneController.text.length >= 3 &&
            isValidPhoneNumber(_phoneController.text);
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
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

  bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;

    // Get the pattern for the selected country code or use a default pattern
    String pattern = phonePatterns[selectedCountryCode] ?? r'^[0-9]{9,}$';

    return RegExp(pattern).hasMatch(phone);
  }

  int getMaxLengthForSelectedCountry() {
    return phoneMaxLength[selectedCountryCode] ??
        10; // Default to 10 if not specified
  }

  void _handleContinue() {
    String phoneNumber = _phoneController.text.trim();

    // Remove leading zero if present for country codes that don't use it
    if ((selectedCountryCode == '+213' ||
            selectedCountryCode == '+33' ||
            selectedCountryCode == '+44') &&
        phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Validate using the isValidPhoneNumber method
    bool isValid = isValidPhoneNumber(phoneNumber);

    if (isValid) {
      String fullPhoneNumber = '$selectedCountryCode$phoneNumber';

      // Update the phone number in the nutritionist data model
      widget.nutritionistData.phoneNumber = fullPhoneNumber;

      // Navigate directly to ChronicDiseaseScreen instead of SMS verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChronicDiseaseScreen(
            nutritionistData: widget.nutritionistData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background with opacity
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF9FE870).withOpacity(0.4),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top section with logo and progress bar
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 02, 24, 20),
                  child: Column(
                    children: [
                      // Back button
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      // Logo
                      Image.asset(
                        'lib/assets/images/mainlogo.jpg',
                        height: 45,
                      ),

                      const SizedBox(height: 24),

                      // Progress bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 33,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9FE870),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 67,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // White card content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, -3),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  'Ajouter votre numero\nde telephone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                // Subtitle
                                Text(
                                  'Pour vous rendre joignable par les utilisateurs, veuillez saisir votre numéro de téléphone afin  qu \'ils puissent vous contacter ou se connecter directement avec vous',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.black54,
                                        height: 1.5,
                                        fontSize: 15,
                                      ),
                                ),
                                const SizedBox(height: 40),
                                // Phone label
                                Text(
                                  'Veuillez entrer votre numero de téléphone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                // Phone number input field
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.5),
                                          ),
                                        ),
                                        child: DropdownButton<String>(
                                          value: selectedCountryCode,
                                          underline: const SizedBox(),
                                          items: countryCodes.map((country) {
                                            return DropdownMenuItem<String>(
                                              value: country['code'],
                                              child: Row(
                                                children: [
                                                  Text(
                                                    country['code']!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black87,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '(${country['country']})',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: 10,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCountryCode = value!;
                                              if (_phoneController.text.length >
                                                  getMaxLengthForSelectedCountry()) {
                                                _phoneController.text =
                                                    _phoneController.text.substring(
                                                        0,
                                                        getMaxLengthForSelectedCountry());
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                            hintText: 'Enter phone number',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 16,
                                            ),
                                            counterText: '',
                                          ),
                                          keyboardType: TextInputType.phone,
                                          maxLength:
                                              getMaxLengthForSelectedCountry(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Continue button at the bottom
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: CustomButton(
                            text: 'Continue',
                            onPressed: _handleContinue,
                            isEnabled: isButtonEnabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
