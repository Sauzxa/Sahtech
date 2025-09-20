import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/home/home_screen.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:path/path.dart' as path;
import 'package:sahtech/presentation/nutritionist/valide_nutritionist_card_screen.dart';

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
    'signup_with': 'S\'inscrire avec',
    'processing': 'Traitement en cours...',
  };

  @override
  void initState() {
    super.initState();

    // Debug print statements to verify nutritionist data
    print('=== NUTRITIONIST DATA DEBUG ===');
    print('User Type: ${widget.nutritionistData.userType}');
    print('Name: ${widget.nutritionistData.name}');
    print('Email: ${widget.nutritionistData.email}');
    print('Phone Number: ${widget.nutritionistData.phoneNumber}');
    print('Gender: ${widget.nutritionistData.gender}');
    print('Specialization: ${widget.nutritionistData.specialization}');
    print('Specialite: ${widget.nutritionistData.specialite}');
    print(
        'Proof Attestation Types: ${widget.nutritionistData.proveAttestationType}');
    print('Diploma Image Path: ${widget.nutritionistData.diplomaImagePath}');
    print('Cabinet Location: ${widget.nutritionistData.cabinetAddress}');
    print('Latitude: ${widget.nutritionistData.latitude}');
    print('Longitude: ${widget.nutritionistData.longitude}');
    print('Chronic Disease: ${widget.nutritionistData.hasChronicDisease}');
    print('Chronic Conditions: ${widget.nutritionistData.chronicConditions}');
    print('Activity Level: ${widget.nutritionistData.activityLevel}');
    print('Physical Activities: ${widget.nutritionistData.physicalActivities}');
    print('Health Goals: ${widget.nutritionistData.healthGoals}');
    print(
        'Weight: ${widget.nutritionistData.weight} ${widget.nutritionistData.weightUnit}');
    print(
        'Height: ${widget.nutritionistData.height} ${widget.nutritionistData.heightUnit}');
    print('Date of Birth: ${widget.nutritionistData.dateDeNaissance}');
    print('Preferred Language: ${widget.nutritionistData.preferredLanguage}');
    print('=== END NUTRITIONIST DATA DEBUG ===');

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
      // Try server connectivity first
      print('=== TESTING SERVER CONNECTIVITY ===');
      try {
        final testUrl = 'http://192.168.137.187:8080/health';
        final testResponse = await http
            .get(Uri.parse(testUrl))
            .timeout(const Duration(seconds: 5));
        print('Server connectivity test: ${testResponse.statusCode}');
        print('Server response: ${testResponse.body}');
      } catch (e) {
        print('Server connectivity test failed: $e');
        print('Continuing with registration attempt anyway...');
      }

      // Combine first and last name
      final fullName =
          "${_firstNameController.text} ${_lastNameController.text}".trim();

      // Update nutritionist model with user inputs
      final updatedNutritionistData = widget.nutritionistData;
      updatedNutritionistData.name = fullName;
      updatedNutritionistData.email = _emailController.text;

      // Fix password format - ensure it's explicitly set in the request
      updatedNutritionistData.password = _passwordController.text;

      // Fix telephone number format - ensure it's in the format the server expects
      // Remove the "+" prefix if it exists
      if (updatedNutritionistData.phoneNumber != null &&
          updatedNutritionistData.phoneNumber!.startsWith('+')) {
        updatedNutritionistData.phoneNumber =
            updatedNutritionistData.phoneNumber!.substring(1);
      }

      // Ensure gender/sexe is properly set
      if (updatedNutritionistData.gender != null) {
        updatedNutritionistData.sexe = updatedNutritionistData.gender;
      }

      // Make sure dateDeNaissance is properly formatted if it exists
      if (updatedNutritionistData.dateDeNaissance == null) {
        // Try to set a default date if needed
        try {
          updatedNutritionistData.dateDeNaissance = DateTime.now().subtract(
              const Duration(days: 365 * 30)); // Default to 30 years old
        } catch (e) {
          print('Could not set default date of birth: $e');
        }
      }

      // Ensure specialization is mapped to specialite
      if (updatedNutritionistData.specialization != null &&
          (updatedNutritionistData.specialite == null ||
              updatedNutritionistData.specialite!.isEmpty)) {
        updatedNutritionistData.specialite =
            updatedNutritionistData.specialization;
      }

      // Debug print statements to verify nutritionist data before submission
      print('=== NUTRITIONIST DATA BEFORE SUBMISSION ===');
      print('User Type: ${updatedNutritionistData.userType}');
      print('Full Name: ${updatedNutritionistData.name}');
      print('Email: ${updatedNutritionistData.email}');
      print('Phone Number: ${updatedNutritionistData.phoneNumber}');
      print('Gender: ${updatedNutritionistData.gender}');
      print('Sexe: ${updatedNutritionistData.sexe}');
      print('Specialization: ${updatedNutritionistData.specialization}');
      print('Specialite: ${updatedNutritionistData.specialite}');
      print('Cabinet Location: ${updatedNutritionistData.cabinetAddress}');
      print('Latitude: ${updatedNutritionistData.latitude}');
      print('Longitude: ${updatedNutritionistData.longitude}');
      print('Diploma Image Path: ${updatedNutritionistData.diplomaImagePath}');
      print('Diploma Types: ${updatedNutritionistData.proveAttestationType}');
      print(
          'Weight: ${updatedNutritionistData.weight} ${updatedNutritionistData.weightUnit}');
      print(
          'Height: ${updatedNutritionistData.height} ${updatedNutritionistData.heightUnit}');
      print('Date of Birth: ${updatedNutritionistData.dateDeNaissance}');
      print('=== END NUTRITIONIST DATA BEFORE SUBMISSION ===');

      // Store the diploma image path for later use
      final String? diplomaImagePath = updatedNutritionistData.diplomaImagePath;

      // Create API request for registration
      // Try different API URL formats in case the current one is incorrect
      final primaryApiUrl =
          'http://192.168.137.187:8080/API/Sahtech/auth/register';
      final fallbackApiUrl = 'http://192.168.137.187:8080/api/auth/register';

      print('=== SENDING REGISTRATION REQUEST ===');
      print('Primary API URL: $primaryApiUrl');
      print('Fallback API URL: $fallbackApiUrl');
      print('Request Headers: ${{'Content-Type': 'application/json'}}');

      // Convert to map and print for debugging
      final requestMap = updatedNutritionistData.toMap();

      // Ensure password is included in the request
      if (updatedNutritionistData.password != null) {
        requestMap['password'] = updatedNutritionistData.password;
      }

      // Ensure type field is set correctly (from Utilisateurs class)
      requestMap['type'] = 'NUTRITIONIST';
      requestMap['userType'] = 'NUTRITIONIST';

      // Ensure telephone field is correctly formatted and included
      if (updatedNutritionistData.phoneNumber != null) {
        String phoneNumber = updatedNutritionistData.phoneNumber!;
        if (phoneNumber.startsWith('+')) {
          phoneNumber = phoneNumber.substring(1);
        }
        requestMap['numTelephone'] = int.tryParse(phoneNumber);
        requestMap['telephone'] = phoneNumber;
      }

      // Add location data if available (not directly in the entity but might be processed by the backend)
      if (updatedNutritionistData.latitude != null &&
          updatedNutritionistData.longitude != null) {
        // Include these fields at the top level as they might be extracted by the backend
        requestMap['latitude'] = updatedNutritionistData.latitude;
        requestMap['longitude'] = updatedNutritionistData.longitude;
        requestMap['cabinetAddress'] = updatedNutritionistData.cabinetAddress;
      }

      // Ensure weight and height are properly set with the correct field names
      if (updatedNutritionistData.weight != null) {
        requestMap['poids'] = updatedNutritionistData.weight;
      }

      if (updatedNutritionistData.height != null) {
        requestMap['taille'] = updatedNutritionistData.height;
      }

      // Make sure chronic diseases are included with the correct field name
      if (updatedNutritionistData.chronicConditions != null &&
          updatedNutritionistData.chronicConditions!.isNotEmpty) {
        requestMap['maladies'] = updatedNutritionistData.chronicConditions;
      }

      // Make sure health goals are included with the correct field name
      if (updatedNutritionistData.healthGoals != null &&
          updatedNutritionistData.healthGoals!.isNotEmpty) {
        requestMap['objectives'] = updatedNutritionistData.healthGoals;
        requestMap['healthGoals'] = updatedNutritionistData.healthGoals;
      }

      // Set the sport field (from Utilisateurs class)
      requestMap['sport'] = updatedNutritionistData.doesExercise ?? false;

      // Set the provider field (from Utilisateurs class)
      requestMap['provider'] = 'LOCAL';

      // Print request details
      print('Request Body as Map: $requestMap');

      // Convert to JSON and print in chunks to avoid truncation
      final jsonString = jsonEncode(requestMap);
      print('Request Body as JSON (full):');

      // Print in chunks of 500 characters
      for (int i = 0; i < jsonString.length; i += 500) {
        final end = (i + 500 < jsonString.length) ? i + 500 : jsonString.length;
        print('${jsonString.substring(i, end)}');
      }

      // Try the primary URL first
      http.Response? response;
      String? errorMessage;
      bool registrationSuccessful = false;

      // Try primary URL
      try {
        response = await http
            .post(
              Uri.parse(primaryApiUrl),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestMap),
            )
            .timeout(const Duration(seconds: 15));

        print('=== PRIMARY URL RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          registrationSuccessful = true;
        } else {
          errorMessage = 'Primary URL failed: ${response.body}';
          print(errorMessage);
        }
      } catch (e) {
        errorMessage = 'Primary URL error: ${e.toString()}';
        print(errorMessage);
      }

      // If primary URL failed, try fallback URL
      if (!registrationSuccessful) {
        print('=== TRYING FALLBACK URL ===');
        try {
          response = await http
              .post(
                Uri.parse(fallbackApiUrl),
                headers: {
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(requestMap),
              )
              .timeout(const Duration(seconds: 15));

          print('=== FALLBACK URL RESPONSE ===');
          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            registrationSuccessful = true;
          } else {
            errorMessage = 'Fallback URL failed: ${response.body}';
            print(errorMessage);
          }
        } catch (e) {
          errorMessage = 'Fallback URL error: ${e.toString()}';
          print(errorMessage);
        }
      }

      // Handle registration result
      if (registrationSuccessful && response != null) {
        // Successful registration
        final responseData = jsonDecode(response.body);
        final String userId =
            responseData['id'] ?? '1'; // Use server-provided ID or fallback

        print('=== REGISTRATION SUCCESSFUL ===');
        print('User ID from response: $userId');

        // Create a base UserModel for HomeScreen
        final userData = UserModel(
          userType: 'nutritionist',
          name: updatedNutritionistData.name,
          email: updatedNutritionistData.email,
          userId: userId,
        );

        // Upload diploma image if available
        if (diplomaImagePath != null && diplomaImagePath.isNotEmpty) {
          try {
            print('=== STARTING DIPLOMA IMAGE UPLOAD ===');
            print('User ID: $userId');
            print('Diploma Image Path: $diplomaImagePath');

            await _uploadDiplomaImage(userId, diplomaImagePath);
            print('=== DIPLOMA IMAGE UPLOAD SUCCESSFUL ===');
          } catch (e) {
            print('=== DIPLOMA IMAGE UPLOAD FAILED ===');
            print('Error: ${e.toString()}');
            // Continue with navigation even if image upload fails
            // The user can upload it later from their profile
          }
        } else {
          print('=== NO DIPLOMA IMAGE TO UPLOAD ===');
        }

        // Debug print statements for final data before navigation
        print('=== NUTRITIONIST SIGNUP SUCCESSFUL ===');
        print('Created User ID: ${userData.userId}');
        print('Final User Type: ${userData.userType}');
        print('Final Name: ${userData.name}');
        print('Final Email: ${userData.email}');
        print('Final Preferred Language: ${userData.preferredLanguage}');
        print('=== END NUTRITIONIST SIGNUP DATA ===');

        // Clear sensitive data
        updatedNutritionistData.password = null;

        if (mounted) {
          // Navigate to ValidateNutritionistCardScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ValidateNutritionistCardScreen(
                nutritionistData: updatedNutritionistData,
              ),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        // Registration failed with both URLs
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

  // Helper method to upload the diploma image
  Future<void> _uploadDiplomaImage(String userId, String imagePath) async {
    try {
      print('=== DIPLOMA UPLOAD DETAILS ===');
      print('User ID: $userId');
      print('Image Path: $imagePath');
      print('Diploma Types: ${widget.nutritionistData.proveAttestationType}');

      // Create multipart request
      final file = File(imagePath);
      if (!file.existsSync()) {
        print('ERROR: File does not exist at path: $imagePath');
        throw Exception('Le fichier image n\'existe pas');
      }

      print('File exists: ${file.existsSync()}');
      print('File size: ${await file.length()} bytes');

      // Try different API URL formats
      final primaryApiUrl =
          'http://192.168.137.187:8080/API/Sahtech/Nutrisionistes/$userId/uploadPhotoDiplome';
      final fallbackApiUrl =
          'http://192.168.137.187:8080/api/nutritionist/$userId/uploadDiploma';
      final fallbackApiUrl2 =
          'http://192.168.137.187:8080/api/nutritionists/$userId/upload-diploma';

      print('Primary Upload API URL: $primaryApiUrl');
      print('Fallback Upload API URL 1: $fallbackApiUrl');
      print('Fallback Upload API URL 2: $fallbackApiUrl2');

      // Prepare the file data
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final mimeType = _getImageMimeType(file.path);
      print('File MIME type: image/$mimeType');
      final filename = path.basename(file.path);

      // Try each URL in sequence
      final urls = [primaryApiUrl, fallbackApiUrl, fallbackApiUrl2];
      http.Response? successResponse;
      String? errorMessage;

      for (int i = 0; i < urls.length; i++) {
        final currentUrl = urls[i];
        print('Trying URL ${i + 1}/${urls.length}: $currentUrl');

        try {
          // Create a multipart request
          final request = http.MultipartRequest('POST', Uri.parse(currentUrl));

          // Add file to the request
          final multipartFile = http.MultipartFile(
            'file', // This should match the parameter name expected by the backend
            fileStream,
            fileLength,
            filename: filename,
            contentType: MediaType('image', mimeType),
          );

          request.files.add(multipartFile);
          print('File added to request: $filename');

          // Add diploma type information if available
          if (widget.nutritionistData.proveAttestationType.isNotEmpty) {
            request.fields['proveAttestationType'] =
                widget.nutritionistData.proveAttestationType.join(',');
            print(
                'Added diploma types: ${widget.nutritionistData.proveAttestationType.join(',')}');
          }

          // Add field name that matches the Java entity
          request.fields['photoUrlDiplome'] =
              'true'; // Indicate this is for the diploma photo

          // Send the request
          print('Sending request to $currentUrl...');
          final streamedResponse =
              await request.send().timeout(const Duration(seconds: 15));
          final response = await http.Response.fromStream(streamedResponse);

          print('Response from URL ${i + 1}: Status ${response.statusCode}');
          print('Response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            print('Upload successful with URL ${i + 1}!');
            successResponse = response;
            break;
          } else {
            errorMessage =
                'Upload failed with URL ${i + 1}: Status ${response.statusCode}, Body: ${response.body}';
            print(errorMessage);

            // If this isn't the last URL, try the next one
            if (i < urls.length - 1) {
              print('Trying next URL...');
            }
          }
        } catch (e) {
          errorMessage = 'Error with URL ${i + 1}: ${e.toString()}';
          print(errorMessage);

          // If this isn't the last URL, try the next one
          if (i < urls.length - 1) {
            print('Trying next URL due to error...');
          }
        }
      }

      if (successResponse != null) {
        print('=== DIPLOMA UPLOAD SUCCESSFUL ===');
        return;
      } else {
        print('=== ALL UPLOAD ATTEMPTS FAILED ===');
        throw Exception('Échec du téléchargement du diplôme: $errorMessage');
      }
    } catch (e) {
      print('Error in _uploadDiplomaImage: $e');
      rethrow; // Rethrow to handle in the calling method
    }
  }

  // Helper method to determine MIME type based on file extension
  String _getImageMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'jpeg';
      case '.png':
        return 'png';
      case '.gif':
        return 'gif';
      case '.webp':
        return 'webp';
      case '.heic':
        return 'heic';
      default:
        return 'jpeg'; // Default to jpeg
    }
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
                color: AppColors.lightTeal.withOpacity(0.5),
                child: Stack(
                  children: [
                    // Main content
                    SafeArea(
                      child: Column(
                        children: [
                          // Logo in green section
                          SizedBox(height: 0.05.sh),
                          Center(
                            child: Image.asset(
                              'lib/assets/images/mainlogo.jpg',
                              height: 45.h,
                              fit: BoxFit.contain,
                            ),
                          ),
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
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Form(
                                    key: _formKey,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Spacing at top of white container
                                        SizedBox(height: 24.h),

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

                                        SizedBox(height: 20.h),

                                        // Form fields - each wrapped in a smaller column
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // First Name field
                                            Text(
                                              _translations['firstname_label']!,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            _buildFormField(
                                              controller: _firstNameController,
                                              hintText: _translations[
                                                  'firstname_hint']!,
                                              errorText: _firstNameError,
                                              onChanged: (val) {
                                                if (_firstNameError != null) {
                                                  setState(() {
                                                    _firstNameError = null;
                                                  });
                                                }
                                              },
                                            ),
                                            if (_firstNameError != null)
                                              _buildErrorText(_firstNameError!),
                                          ],
                                        ),

                                        SizedBox(height: 8.h),

                                        // Last Name field
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _translations['lastname_label']!,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            _buildFormField(
                                              controller: _lastNameController,
                                              hintText: _translations[
                                                  'lastname_hint']!,
                                              errorText: _lastNameError,
                                              onChanged: (val) {
                                                if (_lastNameError != null) {
                                                  setState(() {
                                                    _lastNameError = null;
                                                  });
                                                }
                                              },
                                            ),
                                            if (_lastNameError != null)
                                              _buildErrorText(_lastNameError!),
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
                                              hintText: _translations[
                                                  'password_hint']!,
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
                                              hintText: _translations[
                                                  'confirm_hint']!,
                                              errorText: _confirmPasswordError,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              toggleVisibility:
                                                  _toggleConfirmPasswordVisibility,
                                              onChanged: (val) {
                                                if (_confirmPasswordError !=
                                                    null) {
                                                  setState(() {
                                                    _confirmPasswordError =
                                                        null;
                                                  });
                                                }
                                              },
                                            ),
                                            if (_confirmPasswordError != null)
                                              _buildErrorText(
                                                  _confirmPasswordError!),
                                          ],
                                        ),

                                        SizedBox(height: 30.h),

                                        // Sign up button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _isSubmitting
                                                ? null
                                                : _handleSignup,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                  0xFF9FE870), // Light green
                                              foregroundColor: Colors.black87,
                                              disabledForegroundColor:
                                                  Colors.grey.withOpacity(0.38),
                                              disabledBackgroundColor:
                                                  Colors.grey.withOpacity(0.12),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.r),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15.h),
                                            ),
                                            child: _isSubmitting
                                                ? SizedBox(
                                                    width: 20.w,
                                                    height: 20.h,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.w,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.black54),
                                                    ),
                                                  )
                                                : Text(
                                                    _translations[
                                                        'signup_button']!,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        SizedBox(height: 16.h),

                                        // "S'inscrire avec" text with lines
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
                                                  horizontal: 16.w),
                                              child: Text(
                                                _translations['signup_with']!,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
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

                                        SizedBox(height: 16.h),

                                        // Google signup button
                                        Container(
                                          width: double.infinity,
                                          height: 48.h,
                                          child: ElevatedButton(
                                            onPressed: _signUpWithGoogle,
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
                                                      BorderRadius.circular(
                                                          4.r),
                                                  child: Image.asset(
                                                    'lib/assets/images/google.jpg',
                                                    height: 24.h,
                                                    width: 24.h,
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                // Sign up with Google text
                                                Text(
                                                  _translations[
                                                      'google_signup']!,
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
    Widget? suffixIcon,
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
          suffixIcon: suffixIcon,
        ),
        validator: (_) => null,
        textInputAction: TextInputAction.next,
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
        textInputAction: controller == _confirmPasswordController
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: controller == _confirmPasswordController
            ? (_) => _handleSignup()
            : null,
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
