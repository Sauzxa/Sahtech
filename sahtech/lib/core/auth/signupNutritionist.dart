import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/home/home_screen.dart';
import 'package:sahtech/core/utils/models/user_model.dart';

class SignupNutritionist extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const SignupNutritionist({super.key, required this.nutritionistData});

  @override
  State<SignupNutritionist> createState() => _SignupNutritionistState();
}

class _SignupNutritionistState extends State<SignupNutritionist> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  late TranslationService _translationService;

  // Error states
  String? _lastNameError;
  String? _firstNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Translations
  Map<String, String> _translations = {
    'signup_title': 'S\'inscrire',
    'signup_subtitle': 'Veuillez vous inscrire pour utiliser notre appli',
    'lastname_label': 'Nom',
    'lastname_hint': 'Entrer votre nom',
    'firstname_label': 'Prénom',
    'firstname_hint': 'Entrer votre prénom',
    'email_label': 'Email',
    'email_hint': 'Entrer votre email ou un pseudo nom',
    'password_label': 'Mot de passe',
    'password_hint': 'Entrer votre mot de passe',
    'confirm_label': 'Confirmation mot de passe',
    'confirm_hint': 'Confirmer votre mot de passe',
    'signup_button': 'S\'inscrire',
    'google_signup': 'S\'inscrire avec google',
    'processing': 'Traitement en cours...',
  };

  @override
  void initState() {
    super.initState();

    // Initialize with existing name data if available
    String firstName = '';
    String lastName = '';

    if (widget.nutritionistData.name != null) {
      final nameParts = widget.nutritionistData.name!.split(' ');
      if (nameParts.length > 1) {
        firstName = nameParts.first;
        lastName = nameParts.skip(1).join(' ');
      } else if (nameParts.isNotEmpty) {
        firstName = nameParts.first;
      }
    }

    _lastNameController = TextEditingController(text: lastName);
    _firstNameController = TextEditingController(text: firstName);
    _emailController =
        TextEditingController(text: widget.nutritionistData.email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
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

  void _signUpWithGoogle() {
    // Implement Google sign-up functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inscription avec Google - Fonctionnalité à venir'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _handleSignup() async {
    // Reset error states
    setState(() {
      _lastNameError = null;
      _firstNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _isSubmitting = true;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = false);
      return;
    }

    // Basic validation
    bool hasErrors = false;

    // Last Name validation
    if (_lastNameController.text.isEmpty) {
      setState(() {
        _lastNameError = 'Le nom est requis';
        hasErrors = true;
      });
    }

    // First Name validation
    if (_firstNameController.text.isEmpty) {
      setState(() {
        _firstNameError = 'Le prénom est requis';
        hasErrors = true;
      });
    }

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
      // Combine first and last name
      final fullName =
          "${_firstNameController.text} ${_lastNameController.text}".trim();

      // Update nutritionist model with user inputs
      final updatedNutritionistData = widget.nutritionistData;
      updatedNutritionistData.name = fullName;
      updatedNutritionistData.email = _emailController.text;
      updatedNutritionistData.password = _passwordController.text;

      // Create API request
      final apiUrl = 'https://api.sahtech.com/auth/nutritionist/register';
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(updatedNutritionistData.toMap()),
          )
          .timeout(const Duration(seconds: 15));

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful registration
        final responseData = jsonDecode(response.body);

        // Create a base UserModel for HomeScreen
        final userData = UserModel(
          userType: 'nutritionist',
          name: updatedNutritionistData.name,
          email: updatedNutritionistData.email,
          userId:
              responseData['id'] ?? '1', // Use server-provided ID or fallback
        );

        // Clear sensitive data
        updatedNutritionistData.password = null;

        if (mounted) {
          // Navigate to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomeScreen(userData: userData),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        // Registration failed
        final errorMessage = response.body;
        throw Exception('Échec de l\'inscription: $errorMessage');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),

                        // Logo
                        Image.asset(
                          'lib/assets/images/mainlogo.jpg',
                          height: 50.h,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: 24.h),

                        // Title
                        Text(
                          _translations['signup_title']!,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Subtitle
                        Text(
                          _translations['signup_subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // Last Name field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['lastname_label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextField(
                              controller: _lastNameController,
                              style: TextStyle(fontSize: 15.sp),
                              decoration: InputDecoration(
                                hintText: _translations['lastname_hint'],
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: _lastNameError,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // First Name field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['firstname_label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextField(
                              controller: _firstNameController,
                              style: TextStyle(fontSize: 15.sp),
                              decoration: InputDecoration(
                                hintText: _translations['firstname_hint'],
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: _firstNameError,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Email field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['email_label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: 15.sp),
                              decoration: InputDecoration(
                                hintText: _translations['email_hint'],
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: _emailError,
                                suffixIcon:
                                    Icon(Icons.email, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Password field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['password_label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: 15.sp),
                              decoration: InputDecoration(
                                hintText: _translations['password_hint'],
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: _passwordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                    size: 20.sp,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Confirm Password field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translations['confirm_label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: TextStyle(fontSize: 15.sp),
                              decoration: InputDecoration(
                                hintText: _translations['confirm_hint'],
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: _confirmPasswordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                    size: 20.sp,
                                  ),
                                  onPressed: _toggleConfirmPasswordVisibility,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32.h),

                        // Signup button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightTeal,
                              foregroundColor: Colors.black87,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                              disabledBackgroundColor:
                                  Colors.grey.withOpacity(0.12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black54),
                                    ),
                                  )
                                : Text(
                                    _translations['signup_button']!,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Google signup button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _signUpWithGoogle,
                            icon: Image.asset(
                              'lib/assets/images/google_icon.png',
                              height: 20.h,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.g_mobiledata,
                                    size: 24.sp, color: Colors.blue);
                              },
                            ),
                            label: Text(
                              _translations['google_signup']!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
