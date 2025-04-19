import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/widgets/custom_button.dart';
import 'package:sahtech/core/auth/user_success.dart';

class SignupUser extends StatefulWidget {
  final UserModel userData;

  const SignupUser({super.key, required this.userData});

  @override
  State<SignupUser> createState() => _SignupUserState();
}

class _SignupUserState extends State<SignupUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  late TranslationService _translationService;

  // Add error state variables
  String? _nomError;
  String? _prenomError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Translations
  Map<String, String> _translations = {
    'signup_title': 'S\'inscrire',
    'signup_subtitle': 'Veuillez vous inscrire pour utiliser notre appli',
    'nom_label': 'Nom',
    'nom_hint': 'Entrer votre nom',
    'prenom_label': 'Prenom',
    'prenom_hint': 'Entrer votre Prenom',
    'email_label': 'Email',
    'email_hint': 'Entrer votre email',
    'password_label': 'Mot de passe',
    'password_hint': 'Entrer votre mot de passe',
    'confirm_label': 'Confirmation mot de passe',
    'confirm_hint': 'confirmer votre mot de passe',
    'signup_button': 'S\'inscrire',
    'have_account': 'Vous avez déjà un compte?',
    'login': '',
    'google_signup': 'S\'inscrire avec Google',
  };

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Pre-fill email if available in user data
    if (widget.userData.email != null && widget.userData.email!.isNotEmpty) {
      _emailController.text = widget.userData.email!;
    }

    // Pre-fill name if available in user data
    if (widget.userData.name != null && widget.userData.name!.isNotEmpty) {
      final nameParts = widget.userData.name!.split(' ');
      if (nameParts.length > 1) {
        _prenomController.text = nameParts[0];
        _nomController.text = nameParts.sublist(1).join(' ');
      } else {
        _prenomController.text = widget.userData.name!;
      }
    }

    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
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

  Future<void> _handleSignup() async {
    // Clear previous errors
    setState(() {
      _nomError = null;
      _prenomError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate manually
    bool isValid = true;

    if (_nomController.text.isEmpty) {
      setState(() {
        _nomError = 'Veuillez entrer votre nom';
      });
      isValid = false;
    }

    if (_prenomController.text.isEmpty) {
      setState(() {
        _prenomError = 'Veuillez entrer votre prénom';
      });
      isValid = false;
    }

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

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Veuillez confirmer votre mot de passe';
      });
      isValid = false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
      });
      isValid = false;
    }

    if (!isValid) return;

    // Set name and email in the user model
    widget.userData.name =
        "${_prenomController.text.trim()} ${_nomController.text.trim()}";
    widget.userData.email = _emailController.text.trim();

    // Set password temporarily for registration
    widget.userData.tempPassword = _passwordController.text;

    setState(() => _isSubmitting = true);

    try {
      // Use the AuthService to register the user with MongoDB
      final AuthService authService = AuthService();
      final registrationResult =
          await authService.registerUser(widget.userData);

      if (registrationResult['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inscription réussie!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        // Navigate to the success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserSuccess(userData: widget.userData),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${registrationResult['message']}'),
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
      // Always clear the password after authentication attempt for security
      widget.userData.clearPassword();
    }
  }

  void _navigateToSignin() {
    Navigator.pop(context); // Navigate back to signin screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      height: 0.25.sh,
                      child: Container(
                        color: AppColors.lightTeal.withOpacity(0.5),
                      ),
                    ),

                    // Main content
                    SafeArea(
                      child: Column(
                        children: [
                          // Top spacer to push the white container down
                          SizedBox(height: 0.05.sh),

                          // White container with curved top (main content)
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Logo centered
                                      SizedBox(height: 20.h),
                                      Center(
                                        child: Image.asset(
                                          'lib/assets/images/mainlogo.jpg',
                                          height: 40.h,
                                          fit: BoxFit.contain,
                                        ),
                                      ),

                                      SizedBox(height: 12.h),

                                      // Title & Subtitle
                                      Text(
                                        _translations['signup_title']!,
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        _translations['signup_subtitle']!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),

                                      // Spacer for dynamic spacing
                                      Spacer(flex: 1),

                                      // Form fields - each wrapped in a smaller column
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Prenom field (First name)
                                          Text(
                                            _translations['prenom_label']!,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          _buildFormField(
                                            controller: _prenomController,
                                            hintText:
                                                _translations['prenom_hint']!,
                                            errorText: _prenomError,
                                            onChanged: (val) {
                                              if (_prenomError != null) {
                                                setState(() {
                                                  _prenomError = null;
                                                });
                                              }
                                            },
                                          ),
                                          if (_prenomError != null)
                                            _buildErrorText(_prenomError!),
                                        ],
                                      ),

                                      SizedBox(height: 8.h),

                                      // Nom field (Last name)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _translations['nom_label']!,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          _buildFormField(
                                            controller: _nomController,
                                            hintText:
                                                _translations['nom_hint']!,
                                            errorText: _nomError,
                                            onChanged: (val) {
                                              if (_nomError != null) {
                                                setState(() {
                                                  _nomError = null;
                                                });
                                              }
                                            },
                                          ),
                                          if (_nomError != null)
                                            _buildErrorText(_nomError!),
                                        ],
                                      ),

                                      SizedBox(height: 8.h),

                                      // Email field
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _translations['email_label']!,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          _buildFormField(
                                            controller: _emailController,
                                            hintText:
                                                _translations['email_hint']!,
                                            errorText: _emailError,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            onChanged: (val) {
                                              if (_emailError != null) {
                                                setState(() {
                                                  _emailError = null;
                                                });
                                              }
                                            },
                                          ),
                                          if (_emailError != null)
                                            _buildErrorText(_emailError!),
                                        ],
                                      ),

                                      SizedBox(height: 8.h),

                                      // Password field
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _translations['password_label']!,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          _buildPasswordField(
                                            controller: _passwordController,
                                            hintText:
                                                _translations['password_hint']!,
                                            errorText: _passwordError,
                                            obscureText: _obscurePassword,
                                            toggleVisibility:
                                                _togglePasswordVisibility,
                                            onChanged: (val) {
                                              if (_passwordError != null) {
                                                setState(() {
                                                  _passwordError = null;
                                                });
                                              }
                                            },
                                          ),
                                          if (_passwordError != null)
                                            _buildErrorText(_passwordError!),
                                        ],
                                      ),

                                      SizedBox(height: 8.h),

                                      // Confirm Password field
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _translations['confirm_label']!,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          _buildPasswordField(
                                            controller:
                                                _confirmPasswordController,
                                            hintText:
                                                _translations['confirm_hint']!,
                                            errorText: _confirmPasswordError,
                                            obscureText:
                                                _obscureConfirmPassword,
                                            toggleVisibility:
                                                _toggleConfirmPasswordVisibility,
                                            onChanged: (val) {
                                              if (_confirmPasswordError !=
                                                  null) {
                                                setState(() {
                                                  _confirmPasswordError = null;
                                                });
                                              }
                                            },
                                          ),
                                          if (_confirmPasswordError != null)
                                            _buildErrorText(
                                                _confirmPasswordError!),
                                        ],
                                      ),

                                      // Spacer to push buttons to bottom
                                      Spacer(flex: 1),

                                      // Sign up button
                                      CustomButton(
                                        text: _translations['signup_button']!,
                                        isLoading: _isSubmitting,
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          Future.delayed(
                                              Duration(milliseconds: 100), () {
                                            _handleSignup();
                                          });
                                        },
                                      ),

                                      SizedBox(height: 16.h),

                                      // Sign up with Google button
                                      Container(
                                        width: double.infinity,
                                        height: 48.h,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Google sign-up logic will be implemented here
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Google sign-up will be implemented'),
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black87,
                                            elevation: 1,
                                            shadowColor: Colors.black38,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              side: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Google logo
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                child: Image.asset(
                                                  'lib/assets/images/google.jpg',
                                                  height: 24.h,
                                                  width: 24.h,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              // Sign up with Google text
                                              Text(
                                                _translations['google_signup']!,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Bottom padding
                                      SizedBox(height: 24.h),
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

  // Reusable widget for form fields
  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required String? errorText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: errorText != null ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 10.h,
          ),
          border: InputBorder.none,
          errorStyle: TextStyle(height: 0, fontSize: 0),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        validator: (_) => null,
      ),
    );
  }

  // Reusable widget for password fields
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String? errorText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: errorText != null ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 10.h,
          ),
          border: InputBorder.none,
          errorStyle: TextStyle(height: 0, fontSize: 0),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
              size: 18.w,
            ),
            onPressed: toggleVisibility,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
        validator: (_) => null,
      ),
    );
  }

  // Reusable widget for error messages
  Widget _buildErrorText(String errorText) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, left: 16.w),
      child: Text(
        errorText,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
