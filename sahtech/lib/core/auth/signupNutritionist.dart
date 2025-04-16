import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste_success.dart';

class SignupNutritionist extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const SignupNutritionist({super.key, required this.nutritionistData});

  @override
  State<SignupNutritionist> createState() => _SignupNutritionistState();
}

class _SignupNutritionistState extends State<SignupNutritionist> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  late TranslationService _translationService;

  // Add error state variables
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Translations
  Map<String, String> _translations = {
    'signup_title': 'Créer un compte nutritionniste',
    'signup_subtitle': 'Veuillez remplir les informations manquantes pour compléter votre profil',
    'email_label': 'Email',
    'email_hint': 'Entrer votre email professionnel',
    'password_label': 'Mot de passe',
    'password_hint': 'Créer un mot de passe sécurisé',
    'confirm_label': 'Confirmation mot de passe',
    'confirm_hint': 'Confirmer votre mot de passe',
    'signup_button': 'Créer mon compte',
    'processing': 'Traitement en cours...',
  };

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Pre-fill email if available in nutritionist data
    if (widget.nutritionistData.email != null && widget.nutritionistData.email!.isNotEmpty) {
      _emailController.text = widget.nutritionistData.email!;
    }

    _translationService = Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (default language)
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleSignup() async {
    // Reset error states
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _isSubmitting = true;
    });

    // Basic validation
    bool hasErrors = false;

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'L\'email est requis';
        hasErrors = true;
      });
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Veuillez saisir un email valide';
        hasErrors = true;
      });
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Le mot de passe est requis';
        hasErrors = true;
      });
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Le mot de passe doit contenir au moins 6 caractères';
        hasErrors = true;
      });
    }

    // Confirm password validation
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Veuillez confirmer votre mot de passe';
        hasErrors = true;
      });
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
        hasErrors = true;
      });
    }

    // If there are errors, stop the submission process
    if (hasErrors) {
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      // Update nutritionist model with email and password
      final updatedNutritionistData = widget.nutritionistData.copyWith(
        email: _emailController.text,
        password: _passwordController.text, // This is stored temporarily for registration
      );

      // Simulate API call with delay (for development purposes)
      // This will be replaced with actual API call in production
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: API Integration
      // When the Spring Boot backend is ready, implement the API call here
      // Example:
      /*
      final response = await http.post(
        Uri.parse('https://api.sahtech.com/auth/register/nutritionist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedNutritionistData.toMap()),
      );
      
      if (response.statusCode == 200) {
        // Handle successful registration
        final responseData = jsonDecode(response.body);
        // Update nutritionist data with any additional info from server
      } else {
        // Handle error
        throw Exception('Failed to register nutritionist: ${response.body}');
      }
      */

      // For now, simulate successful registration
      // Clear password from memory after registration (security practice)
      updatedNutritionistData.password = null;

      if (mounted) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionisteSuccess(
              nutritionistData: updatedNutritionistData,
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _translations['signup_title']!,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Subtitle
                        Text(
                          _translations['signup_subtitle']!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: _translations['email_label'],
                            hintText: _translations['email_hint'],
                            errorText: _emailError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          validator: (val) => null, // Handled manually
                        ),
                        SizedBox(height: 16.h),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: _translations['password_label'],
                            hintText: _translations['password_hint'],
                            errorText: _passwordError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (val) => null, // Handled manually
                        ),
                        SizedBox(height: 16.h),

                        // Confirm Password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: _translations['confirm_label'],
                            hintText: _translations['confirm_hint'],
                            errorText: _confirmPasswordError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
                            ),
                          ),
                          validator: (val) => null, // Handled manually
                        ),
                        SizedBox(height: 32.h),

                        // Signup button
                        CustomButton(
                          text: _isSubmitting ? _translations['processing']! : _translations['signup_button']!,
                          onPressed: _isSubmitting ? null : _handleSignup,
                          isEnabled: !_isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
