import 'package:flutter/material.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_sms_verification.dart';
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
    // Add more countries as needed
  ];

  // Translations
  Map<String, String> _translations = {
    'title': 'Ajouter votre numero de telephone',
    'subtitle': 'We have send you an One Time Password(OTP) on this mobile number.',
    'phone_label': 'Veuillez entrer votre numéro de téléphone',
    'continue': 'Continue',
  };

  @override
  void initState() {
    super.initState();
    _translationService = Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
    
    // Pre-fill if phone number already exists in model
    if (widget.nutritionistData.phoneNumber != null) {
      _phoneController.text = widget.nutritionistData.phoneNumber!;
    }

    // Add listener to controller to update button state
    _phoneController.addListener(() {
      setState(() {
        isButtonEnabled = _phoneController.text.length >= 9;
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
        final translatedStrings = await _translationService.translateMap(_translations);
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
    
    // Validation patterns for different country codes
    Map<String, String> patterns = {
      '+213': r'^(5|6|7)[0-9]{8}$', // Algeria
      '+216': r'^[2-9][0-9]{7}$', // Tunisia
      '+212': r'^[6-7][0-9]{8}$', // Morocco
      '+33': r'^[67][0-9]{8}$', // France
      '+1': r'^[2-9][0-9]{9}$', // USA
    };

    String pattern = patterns[selectedCountryCode] ?? r'^[0-9]{9,}$';
    return RegExp(pattern).hasMatch(phone);
  }

  void _handleContinue() {
    String phoneNumber = _phoneController.text.trim();
    
    // Remove leading zero if present for Algerian numbers
    if (selectedCountryCode == '+213' && phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Basic validation for Algerian numbers
    bool isValid = false;
    if (selectedCountryCode == '+213') {
      // Check if it starts with 5, 6, or 7 (after removing 0)
      // and has correct length (9 digits without the leading 0)
      isValid = phoneNumber.length == 9 && 
                RegExp(r'^[5-7][0-9]{8}$').hasMatch(phoneNumber);
    } else {
      // Other country validations...
      isValid = phoneNumber.length >= 9;
    }

    if (isValid) {
      String fullPhoneNumber = '$selectedCountryCode$phoneNumber';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionisteSmsVerification(phoneNumber: fullPhoneNumber),
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
            bottom: false, // Allow content to extend to the bottom edge
            child: Column(
              children: [
                // Logo at the top
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Image.asset(
                    'lib/assets/images/mainlogo.jpg',
                    height: 45,
                  ),
                ),
                
                // White card taking full remaining space
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Ajouter votre numero\nde telephone',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subtitle
                          Text(
                            'We have send you an One Time Password(OTP) on this mobile number.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black54,
                              height: 1.5,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Phone label
                          Text(
                            'Veuillez entrer votre numero de téléphone',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedCountryCode,
                                    underline: const SizedBox(),
                                    items: countryCodes.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country['code'],
                                        child: Text(
                                          country['code']!,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCountryCode = value!;
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
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      hintText: 'Enter phone number',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16,
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Spacer that pushes the button to the bottom
                          const Spacer(),
                          
                          // Continue button at the bottom
                          Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
                            child: CustomButton(
                              text: 'Continue',
                              onPressed: () {
                                String phoneNumber = _phoneController.text.trim();
                                String fullPhoneNumber = '$selectedCountryCode$phoneNumber';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NutritionisteSmsVerification(phoneNumber: fullPhoneNumber),
                                  ),
                                );
                              },
                              isEnabled: _phoneController.text.length >= 9,
                            ),
                          ),
                        ],
                      ),
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