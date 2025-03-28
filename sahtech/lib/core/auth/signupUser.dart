import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';

class SignupUser extends StatefulWidget {
  final UserModel userData;

  const SignupUser({Key? key, required this.userData}) : super(key: key);

  @override
  State<SignupUser> createState() => _SignupUserState();
}

class _SignupUserState extends State<SignupUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  late TranslationService _translationService;

  // Translations
  Map<String, String> _translations = {
    'signup_title': 'S\'inscrire',
    'signup_subtitle': 'Veuillez vous inscrire pour utiliser notre appli',
    'nom_label': 'Nom',
    'nom_hint': 'Entrer votre nom',
    'prenom_label': 'Prenom',
    'prenom_hint': 'Entrer votre Prenom',
    'password_label': 'Password',
    'password_hint': 'Entrer votre mot de passe',
    'confirm_label': 'Confirmation',
    'confirm_hint': 'confirmer votre mot de passe',
    'signup_button': 'S\'inscrire',
    'have_account': 'Vous avez déjà un compte?',
    'login': 'Login',
  };

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

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
    if (_formKey.currentState!.validate()) {
      // Save user data
      widget.userData.name =
          "${_prenomController.text.trim()} ${_nomController.text.trim()}";

      setState(() => _isSubmitting = true);

      try {
        // Here you will implement Firebase authentication to create a new user
        // For now just show a success message
        Future.delayed(Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup successful for ${widget.userData.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );

          if (mounted) {
            setState(() => _isSubmitting = false);
          }

          // Navigate to home screen after signup
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

  void _navigateToSignin() {
    Navigator.pop(context); // Navigate back to signin screen
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
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

                        SizedBox(height: height * 0.08),

                        // Title
                        Text(
                          _translations['signup_title']!,
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        // Subtitle
                        Text(
                          _translations['signup_subtitle']!,
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // Nom field
                        Text(
                          _translations['nom_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              hintText: _translations['nom_hint'],
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
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: height * 0.015),

                        // Prenom field
                        Text(
                          _translations['prenom_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _prenomController,
                            decoration: InputDecoration(
                              hintText: _translations['prenom_hint'],
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
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: height * 0.015),

                        // Password field
                        Text(
                          _translations['password_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

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

                        SizedBox(height: height * 0.015),

                        // Confirm Password field
                        Text(
                          _translations['confirm_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: _translations['confirm_hint'],
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
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                  size: width * 0.045,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.055,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSignup,
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
                                    _translations['signup_button']!,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _translations['have_account']!,
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignin,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.only(left: 4),
                                minimumSize: Size(50, 25),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _translations['login']!,
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
