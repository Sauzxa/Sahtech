import 'package:flutter/material.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_success.dart';
import '../widgets/custom_button.dart';

class NutritionistePassword extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const NutritionistePassword({
    super.key,
    required this.nutritionistData,
  });

  @override
  State<NutritionistePassword> createState() => _NutritionistePasswordState();
}

class _NutritionistePasswordState extends State<NutritionistePassword> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Fix the French translations and add proper English translations
  Map<String, Map<String, String>> _allTranslations = {
    'fr': {
      'title': 'Veuillez choisir un mot de passe pour votre compte',
      'subtitle': 'Assurez-vous que le mot de passe contient au moins 8 caractères, incluant des lettres majuscules et minuscules, des chiffres et des caractères spéciaux',
      'password_label': 'Mot de passe',
      'password_hint': 'Entrer votre mot de passe',
      'confirm_label': 'Confirmation',
      'confirm_hint': 'Entrer votre confirmation',
      'confirm': 'Confirmer',
      'password_requirements': 'Le mot de passe doit contenir au moins 8 caractères, incluant des lettres majuscules et minuscules, des chiffres et des caractères spéciaux',
      'password_mismatch': 'Les mots de passe ne correspondent pas',
      'success': 'Compte créé avec succès',
    },
    'en': {
      'title': 'Please choose a password for your account',
      'subtitle': 'Make sure the password contains at least 8 characters, including uppercase and lowercase letters, numbers and special characters',
      'password_label': 'Password',
      'password_hint': 'Enter your password',
      'confirm_label': 'Confirmation',
      'confirm_hint': 'Enter your confirmation',
      'confirm': 'Confirm',
      'password_requirements': 'Password must contain at least 8 characters, including uppercase and lowercase letters, numbers and special characters',
      'password_mismatch': 'Passwords do not match',
      'success': 'Account created successfully',
    },
  };

  Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    _translationService = Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      final languageCode = _translationService.currentLanguageCode;
      if (_allTranslations.containsKey(languageCode)) {
        // Use predefined translations
        if (mounted) {
          setState(() {
            _translations = _allTranslations[languageCode]!;
            _isLoading = false;
          });
        }
      } else {
        // Default to English if language not supported
        if (mounted) {
          setState(() {
            _translations = _allTranslations['en']!;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() {
          _translations = _allTranslations['en']!;
          _isLoading = false;
        });
      }
    }
  }

  // Password validation
  bool _isPasswordValid(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special character
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$'
    );
    return passwordRegExp.hasMatch(password);
  }

  // Create account with password
  void _createAccount() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    // Check if passwords match and meet requirements
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['password_mismatch']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_isPasswordValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['password_requirements']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Save password to nutritionist model
    widget.nutritionistData.password = password;
    
    // Show success and navigate to home/success screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionisteSuccess(
          nutritionistData: widget.nutritionistData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    
    // Responsive spacing values
    final verticalSpacing = screenHeight * 0.02;  // 2% of screen height
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final cardPadding = screenWidth * 0.05;       // 5% of screen width
    final iconSize = screenWidth * 0.06;          // 6% of screen width
    final titleFontSize = screenWidth * 0.05;     // 5% of screen width
    final subtitleFontSize = screenWidth * 0.035; // 3.5% of screen width
    final labelFontSize = screenWidth * 0.04;     // 4% of screen width
    final textFieldHeight = screenHeight * 0.07;  // 7% of screen height

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with logo
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: verticalSpacing * 2),
                        child: Image.asset(
                          'lib/assets/images/mainlogo.jpg',
                          height: screenHeight * 0.05,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 3),
                    
                    // Title with lock icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _translations['title']!,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(
                          Icons.lock_outline,
                          color: Colors.black87,
                          size: iconSize * 0.8,
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),
                    
                    // Subtitle
                    Text(
                      _translations['subtitle']!,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 3),
                    
                    // Password field label
                    Text(
                      _translations['password_label']!,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.5),
                    
                    // Password field - styled like nom/prenom
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: _translations['password_hint'],
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: subtitleFontSize,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.8,
                            vertical: verticalSpacing * 0.9,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: Colors.grey[600],
                              size: iconSize * 0.7,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: verticalSpacing * 2),
                    
                    // Confirm password label
                    Text(
                      _translations['confirm_label']!,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.5),
                    
                    // Confirm password field - styled like nom/prenom
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: _translations['confirm_hint'],
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: subtitleFontSize,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.8,
                            vertical: verticalSpacing * 0.9,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: Colors.grey[600],
                              size: iconSize * 0.7,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: verticalSpacing * 5),
                    
                    // Confirm button
                    Padding(
                      padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom + verticalSpacing),
                      child: CustomButton(
                        text: _translations['confirm']!,
                        onPressed: _createAccount,
                        isEnabled: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding * 0.5),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: screenWidth * 0.04,
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.lightTeal),
              ),
            ),
        ],
      ),
    );
  }
} 