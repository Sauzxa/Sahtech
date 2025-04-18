import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:sahtech/core/auth/signupUser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/widgets/custom_button.dart';

class SigninUser extends StatefulWidget {
  final UserModel userData;

  const SigninUser({super.key, required this.userData});

  @override
  State<SigninUser> createState() => _SigninUserState();
}

class _SigninUserState extends State<SigninUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  late TranslationService _translationService;

  // Add error state variables
  String? _emailError;
  String? _passwordError;

  // Translations
  Map<String, String> _translations = {
    'login_title': 'Se connecter',
    'login_subtitle': 'Veuillez vous connecter pour utiliser notre appli',
    'email_label': 'Email',
    'email_hint': 'Entrez votre adresse e-mail',
    'password_label': 'Mot de passe',
    'password_hint': 'Entrez votre mot de passe',
    'password_forgot': 'Mot de passe oublié?',
    'button_next': 'suivant',
    'signup_with': 'S\'inscrire avec',
    'no_account': 'Vous n\'avez pas un compte?',
    'signup': '',
    'google_signup': 'S\'inscrire avec google',
    'auth_error': 'Erreur d\'authentification',
    'auth_success': 'Authentification réussie',
  };

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // Pre-fill email if available in user data
    if (widget.userData.email != null && widget.userData.email!.isNotEmpty) {
      _emailController.text = widget.userData.email!;
    }

    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _handleLoginWithEmail() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate manually
    bool isValid = true;

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Veuillez entrer votre email';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Veuillez entrer un email valide';
      });
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Veuillez entrer votre mot de passe';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Le mot de passe doit contenir au moins 6 caractères';
      });
      isValid = false;
    }

    if (!isValid) return;

    // Save email to user data
    widget.userData.email = _emailController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      // Use the AuthService to log in the user with MongoDB
      final AuthService authService = AuthService();
      final loginResult = await authService.loginUser(
          _emailController.text.trim(), _passwordController.text);

      if (loginResult['success']) {
        // If login successful, fetch the complete user data
        if (loginResult['data'] != null &&
            loginResult['data']['userId'] != null) {
          final userId = loginResult['data']['userId'];
          final userData = await authService.getUserData(userId);

          if (userData != null) {
            // Update the user model with data from MongoDB
            widget.userData.name = userData.name;
            widget.userData.email = userData.email;
            widget.userData.phoneNumber = userData.phoneNumber;
            widget.userData.profileImageUrl = userData.profileImageUrl;
            widget.userData.userId = userData.userId;
            widget.userData.hasChronicDisease = userData.hasChronicDisease;
            widget.userData.chronicConditions = userData.chronicConditions;
            widget.userData.preferredLanguage = userData.preferredLanguage;
            widget.userData.doesExercise = userData.doesExercise;
            widget.userData.activityLevel = userData.activityLevel;
            widget.userData.physicalActivities = userData.physicalActivities;
            widget.userData.dailyActivities = userData.dailyActivities;
            widget.userData.healthGoals = userData.healthGoals;
            widget.userData.hasAllergies = userData.hasAllergies;
            widget.userData.allergies = userData.allergies;
            widget.userData.allergyYear = userData.allergyYear;
            widget.userData.allergyMonth = userData.allergyMonth;
            widget.userData.allergyDay = userData.allergyDay;
            widget.userData.weight = userData.weight;
            widget.userData.weightUnit = userData.weightUnit;
            widget.userData.height = userData.height;
            widget.userData.heightUnit = userData.heightUnit;
          }
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connexion réussie!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to the home screen after authentication
        // For example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${loginResult['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSubmitting = true);

    try {
      // Here you will implement Google authentication with Firebase
      // For now just simulate a delay and show success
      Future.delayed(Duration(seconds: 1), () {
        // Update user data with Google info (this will come from Firebase in the future)
        widget.userData.email = 'google.user@example.com';
        widget.userData.name = 'Google User';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In successful'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        if (mounted) {
          setState(() => _isSubmitting = false);
        }

        // Navigate to home screen after authentication
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Here you will implement password reset with Firebase
      // For now just simulate a delay and show success
      Future.delayed(Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Password reset email sent to ${_emailController.text}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupUser(userData: widget.userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Base white background layer
                Container(
                  color: Colors.white,
                ),
                // Green overlay with opacity
                Container(
                  color: AppColors.lightTeal.withOpacity(0.5),
                ),
                // Main content
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // Top green area with 20% height
                        SizedBox(height: 0.1.sh),

                        // Bottom white container with curved top (80%)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: Offset(0, -5),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 24.w,
                                  right: 24.w,
                                  top: 20.h,
                                  bottom: 30.h, // Extra padding at bottom
                                ),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode
                                      .disabled, // Disable auto validation
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Logo centered
                                      Center(
                                        child: Image.asset(
                                          'lib/assets/images/mainlogo.jpg',
                                          height: 50.h,
                                          fit: BoxFit.contain,
                                        ),
                                      ),

                                      SizedBox(height: 40.h),

                                      // Title
                                      Text(
                                        _translations['login_title']!,
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 20.h),

                                      // Subtitle
                                      Text(
                                        _translations['login_subtitle']!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),

                                      SizedBox(height: 20.h),

                                      // Email label
                                      Text(
                                        _translations['email_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

                                      // Email field
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30.r),
                                          border: Border.all(
                                            color: _emailError != null
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          onChanged: (val) {
                                            if (_emailError != null) {
                                              setState(() {
                                                _emailError = null;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                _translations['email_hint'],
                                            hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14.sp,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 20.w,
                                              vertical: 14.h,
                                            ),
                                            border: InputBorder.none,
                                            errorStyle: TextStyle(
                                                height: 0, fontSize: 0),
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                          ),
                                          validator: (_) =>
                                              null, // No validation here
                                        ),
                                      ),

                                      // Email error message
                                      if (_emailError != null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h, left: 16.w),
                                          child: Text(
                                            _emailError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),

                                      SizedBox(
                                          height:
                                              _emailError != null ? 8.h : 16.h),

                                      // Password label
                                      Text(
                                        _translations['password_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

                                      // Password field
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30.r),
                                          border: Border.all(
                                            color: _passwordError != null
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          onChanged: (val) {
                                            if (_passwordError != null) {
                                              setState(() {
                                                _passwordError = null;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                _translations['password_hint'],
                                            hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14.sp,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 20.w,
                                              vertical: 14.h,
                                            ),
                                            border: InputBorder.none,
                                            errorStyle: TextStyle(
                                                height: 0, fontSize: 0),
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[600],
                                                size: 18.w,
                                              ),
                                              onPressed:
                                                  _togglePasswordVisibility,
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          validator: (_) =>
                                              null, // No validation here
                                        ),
                                      ),

                                      // Password error message
                                      if (_passwordError != null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h, left: 16.w),
                                          child: Text(
                                            _passwordError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),

                                      // Forgot password link
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _handleForgotPassword,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(50, 20),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            _translations['password_forgot']!,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.lightTeal,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 50.h),

                                      // Custom Button for sign in
                                      CustomButton(
                                        text: _translations['button_next']!,
                                        isLoading: _isSubmitting,
                                        onPressed: () {
                                          // Dismiss keyboard first to avoid event issues
                                          FocusScope.of(context).unfocus();
                                          // Small delay to ensure keyboard is fully dismissed
                                          Future.delayed(
                                              Duration(milliseconds: 100), () {
                                            _handleLoginWithEmail();
                                          });
                                        },
                                      ),

                                      SizedBox(height: 24.h),

                                      // Divider with text
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey[300],
                                              thickness: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.w),
                                            child: Text(
                                              _translations['signup_with']!,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey[300],
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // Google sign in button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48.h,
                                        child: OutlinedButton.icon(
                                          icon: Image.asset(
                                            'lib/assets/images/google.jpg',
                                            height: 20.h,
                                          ),
                                          label: Text(
                                            _translations['google_signup'] ??
                                                'S\'inscrire avec google',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          onPressed: () {
                                            // Dismiss keyboard first
                                            FocusScope.of(context).unfocus();
                                            // Small delay to ensure keyboard is fully dismissed
                                            Future.delayed(
                                                Duration(milliseconds: 100),
                                                () {
                                              _handleGoogleSignIn();
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                                color: Colors.grey[300]!),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 16.h),
                                    ],
                                  ),
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
    );
  }
}
