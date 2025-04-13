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
    'signup_subtitle': 'Vuillez vous inscrire pour utiliser notre appli',
    'nom_label': 'Nom Utilisateur',
    'nom_hint': 'Entrer votre nom ou un pseudo nom',
    'email_label': 'Email',
    'email_hint': 'Entrer votre email',
    'prenom_label': 'Prenom',
    'prenom_hint': 'Entrer votre Prenom',
    'password_label': 'Mot de passe',
    'password_hint': 'Entrer votre mot de passe',
    'confirm_label': 'Confirmation mot de passe',
    'confirm_hint': 'confirmer votre mot de passe',
    'signup_button': 'S\'inscrire',
    'have_account': 'Vous avez déjà un compte?',
    'login': '',
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
                                  bottom: 30.h,
                                ),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
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

                                      SizedBox(height: 25.h),

                                      // Title
                                      Text(
                                        _translations['signup_title']!,
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

                                      // Subtitle
                                      Text(
                                        _translations['signup_subtitle']!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),

                                      SizedBox(height: 20.h),

                                      // Username field
                                      Text(
                                        _translations['nom_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30.r),
                                          border: Border.all(
                                            color: _nomError != null
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _nomController,
                                          onChanged: (val) {
                                            if (_nomError != null) {
                                              setState(() {
                                                _nomError = null;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: _translations['nom_hint'],
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
                                          validator: (_) => null,
                                        ),
                                      ),

                                      // Username error message
                                      if (_nomError != null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h, left: 16.w),
                                          child: Text(
                                            _nomError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),

                                      SizedBox(
                                          height:
                                              _nomError != null ? 8.h : 16.h),

                                      // Email field
                                      Text(
                                        _translations['email_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

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
                                          validator: (_) => null,
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

                                      // Password field
                                      Text(
                                        _translations['password_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

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
                                          validator: (_) => null,
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

                                      SizedBox(
                                          height: _passwordError != null
                                              ? 8.h
                                              : 16.h),

                                      // Confirm Password field
                                      Text(
                                        _translations['confirm_label']!,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      SizedBox(height: 6.h),

                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30.r),
                                          border: Border.all(
                                            color: _confirmPasswordError != null
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          onChanged: (val) {
                                            if (_confirmPasswordError != null) {
                                              setState(() {
                                                _confirmPasswordError = null;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                _translations['confirm_hint'],
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
                                                _obscureConfirmPassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[600],
                                                size: 18.w,
                                              ),
                                              onPressed:
                                                  _toggleConfirmPasswordVisibility,
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          validator: (_) => null,
                                        ),
                                      ),

                                      // Confirm Password error message
                                      if (_confirmPasswordError != null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h, left: 16.w),
                                          child: Text(
                                            _confirmPasswordError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),

                                      SizedBox(
                                          height: _confirmPasswordError != null
                                              ? 8.h
                                              : 24.h),

                                      // Sign up button using CustomButton
                                      CustomButton(
                                        text: _translations['signup_button']!,
                                        isLoading: _isSubmitting,
                                        onPressed: () {
                                          // Dismiss keyboard first to avoid event issues
                                          FocusScope.of(context).unfocus();
                                          // Small delay to ensure keyboard is fully dismissed
                                          Future.delayed(
                                              Duration(milliseconds: 100), () {
                                            _handleSignup();
                                          });
                                        },
                                      ),

                                      SizedBox(height: 20.h),

                                      // Login link
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
