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
import 'package:sahtech/presentation/home/home_screen.dart'; // Import HomeScreen directly

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
  String? _generalError;

  // Translations
  Map<String, String> _translations = {
    'login_title': 'Se connecter',
    'login_subtitle': 'Veuillez vous connecter pour utiliser notre app',
    'email_label': 'Email',
    'email_hint': 'Entrez votre adresse e-mail',
    'password_label': 'Mot de passe',
    'password_hint': 'Entrez votre mot de passe',
    'password_forgot': 'Mot de passe oublié?',
    'button_next': 'se connecter',
    'signup_with': 'Se connecter avec',
    'no_account': 'Vous n\'avez pas un compte?',
    'signup': 'S\'authentifier',
    'google_signup': 'Se connecter avec google',
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
    // Reset all errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
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
    widget.userData.tempPassword =
        _passwordController.text; // Save for login process only

    setState(() => _isSubmitting = true);

    try {
      // Use the AuthService to log in the user
      final AuthService authService = AuthService();

      // Show logging for debugging
      print('Attempting login with email: ${_emailController.text}');
      print('User type: ${widget.userData.userType}');

      final loginResult = await authService.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
        userType: widget.userData.userType.toUpperCase(),
      );

      // Clear the password for security
      widget.userData.clearPassword();

      if (loginResult['success']) {
        print('Login successful');

        // If login successful, fetch the complete user data
        String? userId = null;
        if (loginResult['data'] != null) {
          userId = loginResult['data']['userId'] ?? loginResult['data']['id'];
        }

        if (userId != null) {
          print('User ID from login response: $userId');
          widget.userData.userId = userId;

          print('Fetching complete user data...');
          int maxRetries = 3;
          UserModel? userData;

          // Try multiple times to fetch user data with exponential backoff
          for (int i = 0; i < maxRetries; i++) {
            try {
              userData = await authService.getUserData(userId);
              if (userData != null) {
                break; // Success, exit the retry loop
              } else {
                print(
                    'Attempt ${i + 1}: Failed to get user data (null response)');
              }
            } catch (e) {
              print('Attempt ${i + 1}: Error fetching user data: $e');
            }

            // Wait before retrying, with increasing delay (exponential backoff)
            if (i < maxRetries - 1) {
              await Future.delayed(Duration(seconds: (i + 1) * 2));
            }
          }

          if (userData != null) {
            print('Retrieved user data successfully.');
            // Update the user model with all data from MongoDB
            widget.userData.name = userData.name ?? widget.userData.name;
            widget.userData.email = userData.email ?? widget.userData.email;
            widget.userData.phoneNumber =
                userData.phoneNumber ?? widget.userData.phoneNumber;
            widget.userData.photoUrl =
                userData.photoUrl ?? widget.userData.photoUrl;
            widget.userData.hasChronicDisease =
                userData.hasChronicDisease ?? widget.userData.hasChronicDisease;
            widget.userData.chronicConditions =
                userData.chronicConditions.isNotEmpty
                    ? userData.chronicConditions
                    : widget.userData.chronicConditions;
            widget.userData.preferredLanguage =
                userData.preferredLanguage ?? widget.userData.preferredLanguage;
            widget.userData.doesExercise =
                userData.doesExercise ?? widget.userData.doesExercise;
            widget.userData.healthGoals = userData.healthGoals.isNotEmpty
                ? userData.healthGoals
                : widget.userData.healthGoals;
            widget.userData.hasAllergies =
                userData.hasAllergies ?? widget.userData.hasAllergies;
            widget.userData.allergies = userData.allergies.isNotEmpty
                ? userData.allergies
                : widget.userData.allergies;
            widget.userData.weight = userData.weight ?? widget.userData.weight;
            widget.userData.weightUnit =
                userData.weightUnit ?? widget.userData.weightUnit;
            widget.userData.height = userData.height ?? widget.userData.height;
            widget.userData.heightUnit =
                userData.heightUnit ?? widget.userData.heightUnit;
          } else {
            print('Failed to retrieve user data after multiple attempts');
            // Continue with just the basic user data we have
          }
        }

        // Navigate to home screen with user data, even if we couldn't fetch complete profile
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userData: widget.userData),
            ),
          );
        }
      } else {
        // Login failed
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _generalError = loginResult['message'] ?? 'Login failed';
          });

          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_generalError ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Exception during login: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _generalError = 'An error occurred: $e';
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            backgroundColor: Color(0xFF9FE870),
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
            backgroundColor: Color(0xFF9FE870),
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
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9FE870)))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                width: 1.sw,
                height: 1.sh,
                color: Colors.white,
                child: Stack(
                  children: [
                    // Green overlay at the top area with opacity
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 0.30.sh,
                      child: Container(
                        color: AppColors.lightTeal.withOpacity(0.5),
                      ),
                    ),

                    // Main content
                    SafeArea(
                      child: Column(
                        children: [
                          // Top spacer and logo in green area
                          SizedBox(height: 0.05.sh),

                          // Logo in green area
                          Center(
                            child: Image.asset(
                              'lib/assets/images/mainlogo.jpg',
                              height: 50.h,
                              fit: BoxFit.contain,
                            ),
                          ),

                          // Spacer between logo and container
                          SizedBox(height: 0.07.sh),

                          // Main white container with form content
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.r),
                                  topRight: Radius.circular(40.r),
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.w, vertical: 25.h),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title & Subtitle
                                      Text(
                                        _translations['login_title']!,
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        _translations['login_subtitle']!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      SizedBox(height: 30.h),

                                      // Email label
                                      Text(
                                        _translations['email_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 8.h),

                                      // Email field
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(30.r),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
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
                                              color: Colors.grey.shade400,
                                              fontSize: 14.sp,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              borderSide: BorderSide(
                                                  color: AppColors.lightTeal
                                                      .withOpacity(0.5),
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (_emailError != null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h, left: 8.w),
                                          child: Text(
                                            _emailError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),

                                      SizedBox(height: 20.h),

                                      // Password Label
                                      Text(
                                        _translations['password_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 8.h),

                                      // Password field
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(30.r),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
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
                                              color: Colors.grey.shade400,
                                              fontSize: 14.sp,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              borderSide: BorderSide(
                                                  color: AppColors.lightTeal
                                                      .withOpacity(0.5),
                                                  width: 1.5),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey.shade500,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  _togglePasswordVisibility,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Forgot password link (right-aligned)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: _handleForgotPassword,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 8.h, right: 8.w),
                                            child: Text(
                                              _translations['password_forgot']!,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Color(0xFF9FE870),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (_passwordError != null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h, left: 8.w),
                                          child: Text(
                                            _passwordError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),

                                      SizedBox(height: 30.h),

                                      // Button - Light green pill button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48.h,
                                        child: ElevatedButton(
                                          onPressed: _isSubmitting
                                              ? null
                                              : () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 100),
                                                      () {
                                                    _handleLoginWithEmail();
                                                  });
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF9FE870),
                                            foregroundColor: Colors.black,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isSubmitting
                                              ? SizedBox(
                                                  height: 20.h,
                                                  width: 20.h,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.black54,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  _translations['button_next']!,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      SizedBox(height: 20.h),

                                      // Divider with text
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w),
                                            child: Text(
                                              _translations['signup_with']!,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // Google button
                                      InkWell(
                                        onTap: _handleGoogleSignIn,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(30.r),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'lib/assets/images/google.jpg',
                                                height: 24.h,
                                                width: 24.h,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                _translations['google_signup']!,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      Spacer(),

                                      // Register link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _translations['no_account']!,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _navigateToSignup,
                                            style: TextButton.styleFrom(
                                              minimumSize: Size(10, 10),
                                              padding:
                                                  EdgeInsets.only(left: 4.w),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              _translations['signup']!,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Color(0xFF9FE870),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
