import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/auth/signupUser.dart';
import 'package:provider/provider.dart';

class SigninUser extends StatefulWidget {
  final UserModel userData;

  const SigninUser({Key? key, required this.userData}) : super(key: key);

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
    'signup': 'S\'authentifier',
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
    if (_formKey.currentState!.validate()) {
      // Save email to user data
      widget.userData.email = _emailController.text.trim();

      setState(() => _isSubmitting = true);

      try {
        // Here you will implement Firebase authentication
        // For now just show a success message
        Future.delayed(Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful with ${_emailController.text}'),
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Enable keyboard adjustment
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                // Add SingleChildScrollView to enable scrolling
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width * 0.06,
                    right: width * 0.06,
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // Add padding for keyboard
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.12),

                        // Logo centered
                        Center(
                          child: Image.asset(
                            'lib/assets/images/mainlogo.jpg',
                            height: height * 0.045,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: height * 0.12),

                        // Title
                        Text(
                          _translations['login_title']!,
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        // Subtitle
                        Text(
                          _translations['login_subtitle']!,
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        // Email label
                        Text(
                          _translations['email_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: _translations['email_hint'],
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: width * 0.035,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.05,
                                vertical: height * 0.018,
                              ),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Password label
                        Text(
                          _translations['password_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        // Password field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: _translations['password_hint'],
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: width * 0.035,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.05,
                                vertical: height * 0.018,
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                  size: width * 0.045,
                                ),
                                onPressed: _togglePasswordVisibility,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
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
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _translations['password_forgot']!,
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: AppColors.lightTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // Small space instead of spacer
                        SizedBox(height: height * 0.03),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.055,
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitting ? null : _handleLoginWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightTeal,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              disabledBackgroundColor:
                                  AppColors.lightTeal.withOpacity(0.6),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    height: height * 0.022,
                                    width: height * 0.022,
                                    child: CircularProgressIndicator(
                                      color: Colors.black54,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _translations['button_next']!,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: height * 0.025),

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
                                  horizontal: width * 0.03),
                              child: Text(
                                _translations['signup_with']!,
                                style: TextStyle(
                                  fontSize: width * 0.03,
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

                        SizedBox(height: height * 0.02),

                        // Google sign in button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.055,
                          child: OutlinedButton.icon(
                            icon: Image.asset(
                              'lib/assets/images/google.jpg',
                              height: height * 0.022,
                            ),
                            label: Text(
                              _translations['google_signup'] ??
                                  'S\'inscrire avec google',
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.black87,
                              ),
                            ),
                            onPressed:
                                _isSubmitting ? null : _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _translations['no_account']!,
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignup,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.only(left: 4),
                                minimumSize: Size(50, 25),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _translations['signup']!,
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  color: AppColors.lightTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
