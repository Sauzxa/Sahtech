import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahtech/core/services/api_service.dart';
import 'package:sahtech/core/CustomWidgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// A screen to edit user profile data
///
/// This screen was enhanced to:
/// 1. Fix UI issues with proper field labels
/// 2. Implement proper state management after updates
/// 3. Fix data persistence issues with arrays and boolean flags
/// 4. Add debugging to track request/response data flow
class EditUserData extends StatefulWidget {
  final UserModel user;

  const EditUserData({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditUserData> createState() => _EditUserDataState();
}

class _EditUserDataState extends State<EditUserData> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // State variables
  bool _isLoading = false; // Controls loading state during save operations
  bool _isLoadingUserData =
      false; // Controls loading state during initial data fetch
  bool _hasChanges = false; // Tracks if user has made any changes to the form
  late UserModel
      _userData; // Holds the current user data, updated after fetch and save
  bool _isUploadingImage = false; // Controls loading state for image upload
  File? _pendingImageFile; // Holds the pending image file for upload

  // Text controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  // Disease dropdown variables
  String? _selectedDisease; // Currently selected disease
  final List<String> _allDiseases = [
    'DIABETIQUE',
    'HYPERTENSION',
    'OBESITE',
    'ASTHME',
    'DEPRESSION',
    'ANXIETE',
    'GASTRITE',
    'CARIES_DENTAIRES',
    'CONJONCTIVITE',
    'MALADIE_COELIAQUE',
    'ARTHROSE',
    'ALLERGIE',
    'MALADIE_DE_CROHN',
    'FIBROMYALGIE',
    'HYPOTHYROIDIE',
    'HYPERTHYROIDIE',
    'LUPUS',
    'SCLEROSE_EN_PLAQUES',
    'POLYARTHRITE_RHUMATOIDE',
    'PSORIASIS',
    'ENDOMETRIOSE',
    'GLAUCOME',
  ]; // List of all possible diseases

  // Map for display names - used for UI display only
  final Map<String, String> _diseaseDisplayNames = {
    'DIABETIQUE': 'Diabète',
    'HYPERTENSION': 'Hypertension artérielle',
    'OBESITE': 'Obésité',
    'ASTHME': 'Asthme',
    'DEPRESSION': 'Dépression',
    'ANXIETE': 'Anxiété',
    'GASTRITE': 'Gastrite',
    'CARIES_DENTAIRES': 'Caries dentaires',
    'CONJONCTIVITE': 'Conjonctivite',
    'MALADIE_COELIAQUE': 'Maladie coeliaque',
    'ARTHROSE': 'Arthrose',
    'ALLERGIE': 'Allergie',
    'MALADIE_DE_CROHN': 'Maladie de Crohn',
    'FIBROMYALGIE': 'Fibromyalgie',
    'HYPOTHYROIDIE': 'Hypothyroïdie',
    'HYPERTHYROIDIE': 'Hyperthyroïdie',
    'LUPUS': 'Lupus',
    'SCLEROSE_EN_PLAQUES': 'Sclérose en plaques',
    'POLYARTHRITE_RHUMATOIDE': 'Polyarthrite rhumatoïde',
    'PSORIASIS': 'Psoriasis',
    'ENDOMETRIOSE': 'Endométriose',
    'GLAUCOME': 'Glaucome',
  };

  // Store selected diseases with a Map for O(1) lookup
  Map<String, bool> _selectedDiseases = {};

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    print('====== EDIT USER DATA INITIALIZATION PERFORMANCE ======');
    final initStartTime = DateTime.now();
    print('EditUserData initState started: $initStartTime');
    
    _userData = widget.user;

    // Initialize with user data from the API
    _fetchUserData().then((_) {
      final fetchEndTime = DateTime.now();
      final fetchDuration = fetchEndTime.difference(initStartTime);
      print('_fetchUserData completed: $fetchEndTime');
      print('_fetchUserData duration: ${fetchDuration.inMilliseconds} ms');
    });

    // Initialize controllers with initial data (will be updated after API fetch)
    _initializeControllers();
    
    final initEndTime = DateTime.now();
    final initDuration = initEndTime.difference(initStartTime);
    print('initState completed: $initEndTime');
    print('initState sync operations duration: ${initDuration.inMilliseconds} ms');
    print('====== END INITIALIZATION PERFORMANCE ======');
  }

  void _initializeControllers() {
    // Initialize controllers with data from the user model
    _firstNameController = TextEditingController(
        text: _userData.name != null && _userData.name!.contains(" ")
            ? _userData.name!.split(" ")[0]
            : _userData.name);

    _lastNameController = TextEditingController(
        text: _userData.name != null && _userData.name!.contains(" ")
            ? _userData.name!.split(" ").length > 1
                ? _userData.name!.split(" ")[1]
                : ""
            : "");

    _emailController = TextEditingController(text: _userData.email);

    _heightController = TextEditingController(
        text: _userData.height != null ? '${_userData.height}' : '');

    _weightController = TextEditingController(
        text: _userData.weight != null ? '${_userData.weight}' : '');

    // Add listeners to detect changes
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
  }

  // Fetch user data directly from API
  Future<void> _fetchUserData() async {
    print('===== FETCH USER DATA PERFORMANCE =====');
    final fetchStart = DateTime.now();
    print('_fetchUserData started: $fetchStart');
    
    if (mounted) {
      setState(() {
        _isLoadingUserData = true;
      });
    }

    try {
      final prefsStart = DateTime.now();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String? userId = prefs.getString('user_id');
      final prefsEnd = DateTime.now();
      print('SharedPreferences access time: ${prefsEnd.difference(prefsStart).inMilliseconds} ms');

      if (token == null || userId == null) {
        throw Exception("Authentication data missing");
      }

      // Use ApiService instead of direct http calls with hardcoded URLs
      try {
        final apiCallStart = DateTime.now();
        print('API call started: $apiCallStart');
        
        // Use ApiService to get user data
        final userData = await _apiService.get('Utilisateurs/$userId');
        
        final apiCallEnd = DateTime.now();
        final apiCallDuration = apiCallEnd.difference(apiCallStart);
        print('API call completed: $apiCallEnd');
        print('API call duration: ${apiCallDuration.inMilliseconds} ms');
        
        if (userData != null) {
          final processingStart = DateTime.now();
          print('Data processing started: $processingStart');
          
          // Debug: Log the raw data we received from MongoDB
          print('----------------------------------------');
          print('RAW USER DATA FROM MONGODB:');
          print('ID: ${userData["id"] ?? userData["_id"]}');
          print('Name: ${userData["prenom"]} ${userData["nom"]}');
          print('Email: ${userData["email"]}');
          print('Has chronic disease: ${userData["hasChronicDisease"]}');

          // Check what format the maladies are in and log them
          if (userData["maladies"] != null) {
            print('----------------------------------------');
            print('DETAILED MALADIES DEBUG:');
            print('Maladies type: ${userData["maladies"].runtimeType}');
            print('Raw maladies: ${userData["maladies"]}');
            
            if (userData["maladies"] is List) {
              List maladiesList = userData["maladies"] as List;
              for (int i = 0; i < maladiesList.length; i++) {
                var item = maladiesList[i];
                print('Maladie $i: $item (${item.runtimeType})');
              }
            }
            print('----------------------------------------');
          } else {
            print('No maladies field found in data');
          }

          print('Objectives: ${userData["objectives"]}');
          print('Height: ${userData["taille"] ?? userData["height"]}');
          print('Weight: ${userData["poids"] ?? userData["weight"]}');
          print('----------------------------------------');

          _userData = UserModel.fromMap(userData);

          // Debug: Log parsed user data
          print('PARSED USER MODEL:');
          print('Name: ${_userData.name}');
          print('Email: ${_userData.email}');
          print('Chronic conditions: ${_userData.chronicConditions}');
          print('Health goals: ${_userData.healthGoals}');
          print('Has chronic disease: ${_userData.hasChronicDisease}');
          print('Height: ${_userData.height}');
          print('Weight: ${_userData.weight}');
          print('----------------------------------------');

          // Set the selected disease from the user data
          _selectedDiseases = {}; // Reset selected diseases map
          
          // Replace the API response processing code for maladies with simpler direct matching
          // Also try direct access to maladies from the raw API response
          if (userData["maladies"] != null && userData["maladies"] is List && (userData["maladies"] as List).isNotEmpty) {
            var maladiesList = userData["maladies"] as List;
            print('Processing raw maladies from API: $maladiesList');
            
            for (var item in maladiesList) {
              print('Processing raw maladie item: $item (${item.runtimeType})');
              String? diseaseName;
              
              if (item is String) {
                diseaseName = item;
                print('String maladie: $diseaseName');
              } else if (item is Map) {
                diseaseName = item["name"] ?? item["value"];
                print('Map maladie with name/value: $diseaseName');
              }
              
              if (diseaseName != null) {
                print('Trying to match disease: "$diseaseName"');
                
                // Direct matching with the _allDiseases list
                if (_allDiseases.contains(diseaseName)) {
                  _selectedDiseases[diseaseName] = true;
                  print('✅ Direct match found in _allDiseases: $diseaseName');
                } else {
                  // Try case-insensitive matching
                  String diseaseUpper = diseaseName.toUpperCase();
                  for (var disease in _allDiseases) {
                    if (disease.toUpperCase() == diseaseUpper) {
                      _selectedDiseases[disease] = true;
                      print('✅ Case-insensitive match found: $diseaseName -> $disease');
                      break;
                    }
                  }
                  
                  if (!_selectedDiseases.containsKey(diseaseName)) {
                    print('❌ Could not match disease: $diseaseName');
                  }
                }
              }
            }
          } else {
            print('No maladies list in API response or it is empty');
          }
          
          if (_selectedDiseases.isEmpty) {
            print('No diseases found in user data');
          } else {
            print('SELECTED DISEASES AFTER PROCESSING: ${_selectedDiseases.keys.toList()}');
          }
          print('----------------------------------------');

          // Process chronic conditions from the user model
          print('Processing chronic conditions from user model');
          print('User chronic conditions from model: ${_userData.chronicConditions}');
          if (_userData.chronicConditions != null && _userData.chronicConditions.isNotEmpty) {
            print('Processing chronic conditions: ${_userData.chronicConditions}');
            for (var condition in _userData.chronicConditions) {
              print('Processing condition: "$condition" (${condition.runtimeType})');
              
              // Direct match against _allDiseases which now contains backend enum values
              if (_allDiseases.contains(condition)) {
                _selectedDiseases[condition] = true;
                print('✅ Direct match found in _allDiseases: $condition');
              } else {
                // Try case-insensitive comparison as fallback
                String conditionUpper = condition.toUpperCase();
                for (var disease in _allDiseases) {
                  if (disease.toUpperCase() == conditionUpper) {
                    _selectedDiseases[disease] = true;
                    print('✅ Case-insensitive match found: $condition -> $disease');
                    break;
                  }
                }
                
                if (!_selectedDiseases.containsKey(condition)) {
                  print('❌ Could not match disease from chronicConditions: $condition');
                }
              }
            }
          }
          
          if (_selectedDiseases.isEmpty) {
            print('No diseases found in user data');
          } else {
            print('SELECTED DISEASES AFTER PROCESSING: ${_selectedDiseases.keys.toList()}');
          }
          print('----------------------------------------');

          final processingEnd = DateTime.now();
          print('Data processing completed: $processingEnd');
          print('Data processing duration: ${processingEnd.difference(processingStart).inMilliseconds} ms');

          // Update controllers with fresh data
          // Check if widget is still mounted before calling setState
          if (mounted) {
            final uiUpdateStart = DateTime.now();
            print('UI update started: $uiUpdateStart');
            
            setState(() {
              _firstNameController.text =
                  _userData.name != null && _userData.name!.contains(" ")
                      ? _userData.name!.split(" ")[0]
                      : _userData.name ?? '';

              _lastNameController.text =
                  _userData.name != null && _userData.name!.contains(" ")
                      ? _userData.name!.split(" ").length > 1
                          ? _userData.name!.split(" ")[1]
                          : ""
                      : "";

              _emailController.text = _userData.email ?? '';
              _heightController.text =
                  _userData.height != null ? '${_userData.height}' : '';
              _weightController.text =
                  _userData.weight != null ? '${_userData.weight}' : '';

              // Reset the changes flag since we just loaded fresh data
              _hasChanges = false;
              _isLoadingUserData = false;
            });
            
            final uiUpdateEnd = DateTime.now();
            print('UI update completed: $uiUpdateEnd');
            print('UI update duration: ${uiUpdateEnd.difference(uiUpdateStart).inMilliseconds} ms');
          }
        }
      } catch (apiError) {
        print('Error calling API service: $apiError');
        throw apiError;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _showCustomSnackBar('Erreur lors du chargement des données utilisateur',
          isError: true);
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } finally {
      final fetchEnd = DateTime.now();
      final totalDuration = fetchEnd.difference(fetchStart);
      print('_fetchUserData completed: $fetchEnd');
      print('Total _fetchUserData duration: ${totalDuration.inMilliseconds} ms');
      print('===== END FETCH USER DATA PERFORMANCE =====');
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Triggered when any form field value changes
  /// Used to track if the user has made any changes to enable the save button
  void _onFieldChanged() {
    // Check if any field has changed from its original value
    final bool nameChanged = _firstNameController.text !=
        (_userData.name != null && _userData.name!.contains(" ")
            ? _userData.name!.split(" ")[0]
            : _userData.name ?? '');

    final bool lastNameChanged = _lastNameController.text !=
        (_userData.name != null && _userData.name!.contains(" ")
            ? _userData.name!.split(" ").length > 1
                ? _userData.name!.split(" ")[1]
                : ""
            : "");

    final bool emailChanged = _emailController.text != (_userData.email ?? '');

    final bool heightChanged = _heightController.text !=
        (_userData.height != null ? '${_userData.height}' : '');

    final bool weightChanged = _weightController.text !=
        (_userData.weight != null ? '${_userData.weight}' : '');
        
    // Add debugging for disease change detection:
    // Check if disease selection has changed
    bool diseaseChanged = false;
    
    // Debug disease change detection
    print('------ DISEASE CHANGE DETECTION ------');
    print('Original diseases in userData: ${_userData.chronicConditions}');
    print('Current selected diseases: ${_selectedDiseases.keys.toList()}');
    
    // Convert chronicConditions list to a map for easier comparison
    Map<String, bool> originalDiseases = {};
    if (_userData.chronicConditions != null) {
      for (var disease in _userData.chronicConditions) {
        originalDiseases[disease] = true;
      }
    }
    
    // Check if the selections are different
    if (originalDiseases.length != _selectedDiseases.length) {
      diseaseChanged = true;
      print('Disease change detected: Different count - Original: ${originalDiseases.length}, New: ${_selectedDiseases.length}');
    } else {
      // Check if every disease in originalDiseases is also in _selectedDiseases
      for (var disease in originalDiseases.keys) {
        if (!_selectedDiseases.containsKey(disease)) {
          diseaseChanged = true;
          print('Disease change detected: Original has "$disease" which is missing in new selection');
          break;
        }
      }
      
      // Check if every disease in _selectedDiseases is also in originalDiseases
      for (var disease in _selectedDiseases.keys) {
        if (!originalDiseases.containsKey(disease)) {
          diseaseChanged = true;
          print('Disease change detected: New selection has "$disease" which was not in original');
          break;
        }
      }
    }
    
    if (!diseaseChanged) {
      print('No disease changes detected - selections are the same');
    }
    print('------------------------------------');

    // Update the _hasChanges flag if any field has changed or if we have a pending image
    setState(() {
      _hasChanges = nameChanged ||
          lastNameChanged ||
          emailChanged ||
          heightChanged ||
          weightChanged ||
          diseaseChanged ||
          _pendingImageFile != null;

      // Debug info
      print('Form has changes: $_hasChanges');
      if (diseaseChanged) {
        print('Disease selection changed:');
        print('Original diseases: ${originalDiseases.keys.toList()}');
        print('New diseases: ${_selectedDiseases.keys.toList()}');
      }
    });
  }

  // Function to update user data
  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if we have a pending image to upload
      File? imageFileToUpload = _pendingImageFile;
      String? profileImageUrl = _userData.photoUrl;

      // Step 1: Upload image to Cloudinary if we have a pending image
      if (imageFileToUpload != null) {
        setState(() {
          _isUploadingImage = true;
        });

        try {
          // Get user ID
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? userId = prefs.getString('user_id');

          if (userId == null) {
            throw Exception("User ID is missing");
          }

          // Use API service to upload the file
          final responseData = await _apiService.uploadFile(
            'Utilisateurs/$userId/uploadPhoto',
            imageFileToUpload.path,
          );

          print('==========================================');
          print('IMAGE UPLOAD RESPONSE DATA:');
          print('Raw response: $responseData');
          print('Response type: ${responseData.runtimeType}');
          print('Contains photoUrl: ${responseData.containsKey('photoUrl')}');
          print('==========================================');

          // Extract photo URL from response - simplified to look for just photoUrl
          if (responseData != null && responseData['photoUrl'] != null) {
            profileImageUrl = responseData['photoUrl'];
            print('Found photoUrl in response: $profileImageUrl');

            // Update the local user model immediately
            _userData.photoUrl = profileImageUrl;
            print(
                'User model updated with new photoUrl: ${_userData.photoUrl}');

            // Test setting the photoUrl directly to ensure it's saved in MongoDB
            print('Testing direct setting of photoUrl in MongoDB...');
            if (profileImageUrl != null) {
              await _testDirectPhotoUrlSetting(profileImageUrl);
            } else {
              print('Cannot set photoUrl directly: profileImageUrl is null');
            }
          } else {
            print('WARNING: No photoUrl found in response');
            print('Response keys: ${responseData?.keys.toList() ?? 'null'}');
          }

          print('Image upload process complete. Profile URL: $profileImageUrl');

          // Clear the pending image file
          _pendingImageFile = null;
        } catch (e) {
          print('ERROR uploading image: $e');
          _showCustomSnackBar('Erreur lors du téléchargement de l\'image: $e',
              isError: true);
          // Continue with the update even if image upload fails
        } finally {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }

      // Create a copy of the user model with updated data
      final updatedUser = UserModel(
        userType: _userData.userType,
        name: "${_firstNameController.text} ${_lastNameController.text}".trim(),
        email: _emailController.text,
        phoneNumber: _userData.phoneNumber,
        photoUrl: profileImageUrl, // Use the new URL if available
        userId: _userData.userId,
        tempPassword: _userData.tempPassword,
        preferredLanguage: _userData.preferredLanguage,
        doesExercise: _userData.doesExercise,
        healthGoals: _userData.healthGoals,
        hasAllergies: _userData.hasAllergies,
        allergies: _userData.allergies,
        weightUnit: _userData.weightUnit,
        heightUnit: _userData.heightUnit,
        dateOfBirth: _userData.dateOfBirth,
        hasChronicDisease: _selectedDiseases.isNotEmpty,
        chronicConditions: _selectedDiseases.keys.toList(),
      );

      // Update height and weight if provided
      if (_heightController.text.isNotEmpty) {
        updatedUser.height = double.tryParse(_heightController.text);
      }

      if (_weightController.text.isNotEmpty) {
        updatedUser.weight = double.tryParse(_weightController.text);
      }

      // Debug: Print current profile image URL before sending to API
      print('Saving user with profile image URL: ${updatedUser.photoUrl}');

      // Log the updated user data before preparing for API
      print('----------------------------------------');
      print('USER DATA TO UPDATE:');
      print('Name: ${updatedUser.name}');
      print('Email: ${updatedUser.email}');
      print('Has Chronic Disease: ${updatedUser.hasChronicDisease}');
      print('Chronic Conditions: ${updatedUser.chronicConditions}');
      print('Height: ${updatedUser.height}');
      print('Weight: ${updatedUser.weight}');
      print('Profile Image URL: ${updatedUser.photoUrl}');
      print('----------------------------------------');

      // Debug chronic conditions specifically
      print('----------------------------------------');
      print('CHRONIC CONDITIONS DEBUG:');
      print('Current selected diseases: ${_selectedDiseases.keys.toList()}');
      print('Setting updatedUser chronicConditions to: ${_selectedDiseases.keys.toList()}');
      print('----------------------------------------');

      // Create JSON data for the API request - Using our helper function
      final userData = _prepareUserDataForAPI(updatedUser);

      // Ensure the photo URL is included in the API request
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        print('Adding profile image URL to request: $profileImageUrl');
        userData['photoUrl'] = profileImageUrl;

        // Force it as a direct field too, in case the mapping isn't working correctly
        print(
            'Request body before adding profileImageUrl: ${json.encode(userData)}');
      }

      // Debug: Log the request payload to verify it's correctly formatted
      print('Update request payload: ${json.encode(userData)}');

      // Extra verification that photoUrl is in the request
      print(
          'Final request contains photoUrl: ${userData.containsKey('photoUrl')}');
      print('photoUrl value: ${userData['photoUrl']}');

      // Get user ID from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception("User ID is missing");
      }
      
      // Add extensive PUT request debugging
      print('========== PUT REQUEST DEBUG ==========');
      print('PUT endpoint: Utilisateurs/$userId');
      print('PUT request body: ${json.encode(userData)}');
      print('Checking maladies in request: ${userData.containsKey('maladies')}');
      if (userData.containsKey('maladies')) {
        print('Maladies in request: ${userData['maladies']}');
      }
      print('Checking chronicConditions in request: ${userData.containsKey('chronicConditions')}');
      if (userData.containsKey('chronicConditions')) {
        print('ChronicConditions in request: ${userData['chronicConditions']}');
      }
      print('hasChronicDisease in request: ${userData['hasChronicDisease']}');
      print('=====================================');

      // Use ApiService to update user data
      try {
        final responseData = await _apiService.put('Utilisateurs/$userId', userData);
        
        // Debug: Log the raw response data
        print('----------------------------------------');
        print('UPDATE RESPONSE DATA:');
        print('Response data type: ${responseData.runtimeType}');
        print('Response data: $responseData');
        print(
            'Response contains photoUrl: ${responseData.containsKey('photoUrl')}');

        // Check for photoUrl in the response
        if (responseData.containsKey('photoUrl')) {
          print('PhotoUrl in response: ${responseData['photoUrl']}');
        } else {
          print('WARNING: No photoUrl found in response!');
        }

        // Log the complete response data
        print('======== COMPLETE API RESPONSE ========');
        print(json.encode(responseData));
        print('====================================');
        
        // Debug the response data specifically for diseases
        print('======== DISEASE UPDATE DEBUG ========');
        print('Response contains maladies: ${responseData.containsKey('maladies')}');
        if (responseData.containsKey('maladies')) {
          print('Maladies in response: ${responseData['maladies']}');
        }
        print('Response contains chronicConditions: ${responseData.containsKey('chronicConditions')}');
        if (responseData.containsKey('chronicConditions')) {
          print('ChronicConditions in response: ${responseData['chronicConditions']}');
        }
        print('Response contains hasChronicDisease: ${responseData.containsKey('hasChronicDisease')}');
        if (responseData.containsKey('hasChronicDisease')) {
          print('HasChronicDisease in response: ${responseData['hasChronicDisease']}');
        }
        print('====================================');
        
        // PRESERVE DISEASES: If the response doesn't include diseases but we sent them,
        // manually add them to responseData before creating the UserModel
        if (!responseData.containsKey('maladies') && userData.containsKey('maladies')) {
          print('⚠️ API response missing maladies! Adding them from request data');
          responseData['maladies'] = userData['maladies'];
        }
        
        if (!responseData.containsKey('chronicConditions') && userData.containsKey('chronicConditions')) {
          print('⚠️ API response missing chronicConditions! Adding them from request data');
          responseData['chronicConditions'] = userData['chronicConditions'];
        }
        
        if (!responseData.containsKey('hasChronicDisease') && userData.containsKey('hasChronicDisease')) {
          print('⚠️ API response missing hasChronicDisease! Adding it from request data');
          responseData['hasChronicDisease'] = userData['hasChronicDisease'];
        }

        // Update the local user model with the response data
        _userData = UserModel.fromMap(responseData);

        // Log the updated user data after mapping
        print('UPDATED USER MODEL:');
        print('Name: ${_userData.name}');
        print('Email: ${_userData.email}');
        print('Profile Image URL: ${_userData.photoUrl}');

        // Double check if we need to manually set the profileImageUrl from our local variable
        if (_userData.photoUrl == null &&
            profileImageUrl != null &&
            profileImageUrl.isNotEmpty) {
          print('Setting profileImageUrl manually from the local variable');
          _userData.photoUrl = profileImageUrl;
        }
        print('Final profileImageUrl value: ${_userData.photoUrl}');
        print('----------------------------------------');

        // After the _userData gets updated from the response, add this:
        // Log how diseases were mapped into the UserModel
        print('======== USER MODEL DISEASE MAPPING ========');
        print('Updated _userData.chronicConditions: ${_userData.chronicConditions}');
        print('Updated _userData.hasChronicDisease: ${_userData.hasChronicDisease}');
        print('_selectedDiseases before reset: ${_selectedDiseases.keys.toList()}');
        
        // IMPORTANT: After the API call, update _selectedDiseases based on the updated _userData
        // This ensures the UI reflects what's actually saved in the database
        _selectedDiseases.clear(); // Reset selected diseases
        if (_userData.chronicConditions != null && _userData.chronicConditions.isNotEmpty) {
          for (var disease in _userData.chronicConditions) {
            if (_allDiseases.contains(disease)) {
              _selectedDiseases[disease] = true;
              print('Restored disease selection from response: $disease');
            }
          }
        }
        print('_selectedDiseases after reset: ${_selectedDiseases.keys.toList()}');
        print('=========================================');

        // Update UI without requiring reconnection
        setState(() {
          // Reset changes flag since we've saved successfully
          _hasChanges = false;

          // Update controllers with fresh data from response
          _firstNameController.text =
              _userData.name != null && _userData.name!.contains(" ")
                  ? _userData.name!.split(" ")[0]
                  : _userData.name ?? '';

          _lastNameController.text =
              _userData.name != null && _userData.name!.contains(" ")
                  ? _userData.name!.split(" ").length > 1
                      ? _userData.name!.split(" ")[1]
                      : ""
                  : "";

          _emailController.text = _userData.email ?? '';
          _heightController.text =
              _userData.height != null ? '${_userData.height}' : '';
          _weightController.text =
              _userData.weight != null ? '${_userData.weight}' : '';
        });

        print(
            'Profile updated successfully! Profile URL: ${_userData.photoUrl}');
        _showCustomSnackBar('Profil mis à jour avec succès');

        // Instead of immediately popping, we can give the user a moment to see their changes
        // This will help avoid the impression that nothing happened
        Future.delayed(Duration(seconds: 1), () {
          // Ensure we pass back the updated user data with the profile image URL
          Navigator.pop(context, _userData);
        });
      } catch (apiError) {
        print('Error updating user data via API: $apiError');
        throw Exception('Erreur lors de la mise à jour du profil: $apiError');
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showCustomSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Custom SnackBar that matches Figma design
  void _showCustomSnackBar(String message, {bool isError = false}) {
    // Check if the widget is still mounted before using context
    if (!mounted) {
      print('Warning: Attempted to show SnackBar but widget is unmounted');
      return;
    }

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.clearSnackBars();

    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: isError ? Colors.red : AppColors.lightTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.only(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Function to ensure proper formatting of user data before sending to API
  Map<String, dynamic> _prepareUserDataForAPI(UserModel userData) {
    print('----------------------------------------');
    print('PREPARING USER DATA FOR API - MALADIES CHECK');
    print('updatedUser.chronicConditions: ${userData.chronicConditions}');
    print('Current _selectedDiseases: ${_selectedDiseases.keys.toList()}');
    print('----------------------------------------');

    // Create a base map from the user model
    final Map<String, dynamic> formattedData = userData.toMap();

    // Add debug log for current data
    print('----------------------------------------');
    print('PREPARING USER DATA FOR API:');
    print('Name: ${userData.name}');
    print('Email: ${userData.email}');
    print('Chronic Conditions: ${userData.chronicConditions}');
    print('Has Chronic Disease: ${userData.hasChronicDisease}');
    print('Height: ${userData.height}');
    print('Weight: ${userData.weight}');
    print('Profile Image URL: ${userData.photoUrl}');
    print('----------------------------------------');

    // Since we're now using the same enum values as the backend, we can send them directly
    // No mapping needed, we already have the correct values
    List<String> serverFormattedDiseases = _selectedDiseases.keys.toList();
    
    // Log what we're sending
    print('FINAL FORMATTED DISEASES: $serverFormattedDiseases');
    
    formattedData['maladies'] = serverFormattedDiseases;

    // Make extra sure the maladies field is correctly sent in the format expected by MongoDB
    print('MALADIES being sent to API: ${formattedData['maladies']}');

    // Also add chronicConditions field for API flexibility (use same format)
    formattedData['chronicConditions'] = serverFormattedDiseases;
    
    // Make sure hasChronicDisease is explicitly set to true when there are diseases
    if (_selectedDiseases.isNotEmpty) {
      formattedData['hasChronicDisease'] = true;
      print('Explicitly setting hasChronicDisease to TRUE since there are diseases');
    } else {
      formattedData['hasChronicDisease'] = false;
      print('Explicitly setting hasChronicDisease to FALSE since there are no diseases');
      
      // Explicitly set empty arrays for maladies and chronicConditions
      // This ensures the server receives empty lists rather than null
      formattedData['maladies'] = [];
      formattedData['chronicConditions'] = [];
      print('Explicitly sending empty arrays for maladies and chronicConditions');
      print('These empty arrays should be preserved in MongoDB and not removed from the document');
    }

    formattedData['allergies'] =
        userData.allergies.isNotEmpty ? userData.allergies : [];

    formattedData['objectives'] =
        userData.healthGoals.isNotEmpty ? userData.healthGoals : [];

    // Ensure boolean flags are explicitly set
    formattedData['hasAllergies'] = userData.hasAllergies ?? false;
    formattedData['doesExercise'] = userData.doesExercise ?? false;

    // Convert height and weight to proper number format if they exist
    if (userData.height != null) {
      formattedData['height'] = userData.height;
      formattedData['taille'] = userData.height;
    }

    if (userData.weight != null) {
      formattedData['weight'] = userData.weight;
      formattedData['poids'] = userData.weight;
    }

    // Ensure profile image URL is explicitly included with both field names
    if (userData.photoUrl != null && userData.photoUrl!.isNotEmpty) {
      formattedData['photoUrl'] = userData.photoUrl;
      formattedData['profileImageUrl'] = userData.photoUrl;
      print('Including image URL in request: ${userData.photoUrl}');
    }

    // Ensure name is properly formatted for the backend
    if (userData.name != null) {
      final nameParts = userData.name!.trim().split(' ');
      formattedData['prenom'] = nameParts.isNotEmpty ? nameParts[0] : '';
      formattedData['nom'] =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

    // Convert phone number to integer if it exists
    if (userData.phoneNumber != null) {
      formattedData['numTelephone'] = int.tryParse(userData.phoneNumber!) ?? 0;
    }

    // Debug log to check what's being sent
    print('PREPARED DATA FOR API: ${json.encode(formattedData)}');

    return formattedData;
  }

  // Method to show the image source selection bottom sheet
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisir une photo de profil',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.h),
              // Information message about the upload process
              if (_pendingImageFile == null)
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Votre photo sera téléchargée lorsque vous cliquerez sur "Sauvegarder Modification"',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Message for pending image
              if (_pendingImageFile != null)
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Photo prête à être téléchargée lors de la sauvegarde',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.lightTeal,
                    size: 24.r,
                  ),
                ),
                title: Text(
                  'Prendre une photo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _requestCameraPermission();
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.lightTeal,
                    size: 24.r,
                  ),
                ),
                title: Text(
                  'Choisir depuis la galerie',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _requestGalleryPermission();
                },
              ),
              // Show reset button if there's a pending image
              if (_pendingImageFile != null)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.orange,
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'Annuler le changement de photo',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _pendingImageFile = null;
                      _onFieldChanged(); // Update form state
                    });
                    Navigator.pop(context);
                    _showCustomSnackBar('Changement de photo annulé');
                  },
                ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 24.r,
                  ),
                ),
                title: Text(
                  'Fermer',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Request camera permission
  Future<void> _requestCameraPermission() async {
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      _getImageFromCamera();
    } else if (cameraStatus.isPermanentlyDenied) {
      _showPermissionDeniedDialog('camera');
    } else {
      _showCustomSnackBar(
        'Permission de caméra refusée. Veuillez autoriser l\'accès à la caméra pour prendre une photo.',
        isError: true,
      );
    }
  }

  // Request gallery permission
  Future<void> _requestGalleryPermission() async {
    PermissionStatus photosStatus = await Permission.photos.request();

    if (photosStatus.isGranted) {
      _getImageFromGallery();
    } else if (photosStatus.isPermanentlyDenied) {
      _showPermissionDeniedDialog('gallery');
    } else {
      _showCustomSnackBar(
        'Permission de galerie refusée. Veuillez autoriser l\'accès à la galerie pour choisir une photo.',
        isError: true,
      );
    }
  }

  // Show dialog for permanently denied permissions
  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission requise'),
          content: Text(
            permissionType == 'camera'
                ? 'L\'accès à la caméra est nécessaire pour prendre une photo. Veuillez l\'activer dans les paramètres de votre appareil.'
                : 'L\'accès à la galerie est nécessaire pour choisir une photo. Veuillez l\'activer dans les paramètres de votre appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  // Get image from camera
  Future<void> _getImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (photo != null) {
        setState(() {
          _pendingImageFile = File(photo.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      _showCustomSnackBar('Erreur lors de la prise de photo.', isError: true);
    }
  }

  // Get image from gallery
  Future<void> _getImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          _pendingImageFile = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showCustomSnackBar('Erreur lors de la sélection de l\'image.',
          isError: true);
    }
  }

  // Add this method to test direct photoUrl setting
  Future<void> _testDirectPhotoUrlSetting(String photoUrl) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception("User ID is missing");
      }

      print('Testing direct photoUrl setting...');
      print('User ID: $userId');
      print('PhotoUrl to set: $photoUrl');

      // Use ApiService for the direct photoUrl setting
      try {
        final responseData = await _apiService.put(
          'Utilisateurs/$userId/setPhotoUrlDirect',
          {'photoUrl': photoUrl}
        );
        
        print('PhotoUrl set successfully: ${responseData['photoUrl']}');

        // Update local user model
        setState(() {
          _userData.photoUrl = photoUrl;
        });

        _showCustomSnackBar('PhotoUrl set successfully');
      } catch (apiError) {
        print('Error setting photoUrl via API: $apiError');
        throw Exception('Failed to set photoUrl: $apiError');
      }
    } catch (e) {
      print('Error setting photoUrl directly: $e');
      _showCustomSnackBar('Error setting photoUrl: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 184, 235, 153),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Background - Increased height to 30% of screen
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height *
                  0.3, // Increased from 0.25 to 0.3
              child: Container(
                color: const Color.fromARGB(255, 184, 235, 153),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      children: [
                        // Back button
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                              size: 20.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Title
                        Text(
                          'Modifier les Données Personale',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: _isLoadingUserData
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.lightTeal,
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 30.h),

                                      // Profile image
                                      Center(
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 80.r,
                                              width: 80.r,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                shape: BoxShape.circle,
                                                image: _pendingImageFile != null
                                                    ? DecorationImage(
                                                        image: FileImage(
                                                            _pendingImageFile!),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : _userData.photoUrl !=
                                                                null &&
                                                            _userData.photoUrl!
                                                                .isNotEmpty
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                                _userData
                                                                    .photoUrl!),
                                                            fit: BoxFit.cover,
                                                            onError: (error,
                                                                stackTrace) {
                                                              print(
                                                                  'Error loading profile image: $error');
                                                              print(
                                                                  'Image URL: ${_userData.photoUrl}');
                                                            })
                                                        : null,
                                              ),
                                              child: _isUploadingImage
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            AppColors.lightTeal,
                                                        strokeWidth: 2.w,
                                                      ),
                                                    )
                                                  : _pendingImageFile == null &&
                                                          (_userData.photoUrl ==
                                                                  null ||
                                                              _userData
                                                                  .photoUrl!
                                                                  .isEmpty)
                                                      ? Icon(
                                                          Icons.person,
                                                          size: 40.r,
                                                          color: Colors
                                                              .grey.shade400,
                                                        )
                                                      : null,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: _isUploadingImage
                                                    ? null
                                                    : _showImageSourceOptions,
                                                child: Container(
                                                  padding: EdgeInsets.all(4.r),
                                                  decoration: BoxDecoration(
                                                    color: _isUploadingImage
                                                        ? Colors.grey
                                                        : AppColors.lightTeal,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: 16.r,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 30.h),

                                      // First name label - Updated to "Prénom" instead of "Nom Utilisateur"
                                      Text(
                                        'Prénom',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // First name input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: TextFormField(
                                          controller: _firstNameController,
                                          decoration: InputDecoration(
                                            fillColor:Colors.green,
                                            hintText: 'Votre prénom',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 14.h),
                                            border: InputBorder.none,
                                            suffixIcon: Icon(
                                              Icons.person_outline,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Veuillez entrer votre prénom';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 16.h),

                                      // Last name label - Now a separate label
                                      Text(
                                        'Nom',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Last name input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: TextFormField(
                                          controller: _lastNameController,
                                          decoration: InputDecoration(
                                            hintText: 'Nom',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 14.h),
                                            border: InputBorder.none,
                                            suffixIcon: Icon(
                                              Icons.person_outline,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Veuillez entrer votre nom';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 24.h),

                                      // Email Label
                                      Text(
                                        'Adresse Email',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Email input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: TextFormField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            hintText: 'Email',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 14.h),
                                            border: InputBorder.none,
                                            suffixIcon: Icon(
                                              Icons.email_outlined,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Veuillez entrer votre email';
                                            }
                                            // Simple email validation
                                            if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Veuillez entrer un email valide';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 24.h),

                                      // Maladie Label
                                      Text(
                                        'Maladie',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Maladie dropdown
                                      Container(
                                        decoration: BoxDecoration(
                                          color:Colors.grey.shade50, // Light green background
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: ExpansionTile(
                                          title: Text(
                                            'Maladies',
                                            style: TextStyle(
                                                 fontSize: 16.sp,
                                            color: Colors.black87,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey.shade700,
                                          ),
                                          children: [
                                            Container(
                                              color: Colors.white,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: _allDiseases.length,
                                                itemBuilder: (context, index) {
                                                  final disease = _allDiseases[index];
                                                  final isSelected = _selectedDiseases[disease] ?? false;
                                                  
                                                  return CheckboxListTile(
                                                    title: Text(
                                                      _diseaseDisplayNames[disease] ?? disease, // Use display name if available, otherwise the enum value
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    value: isSelected,
                                                    activeColor: Color(0xFF9FE870), // Green checkbox when selected
                                                    checkColor: Colors.white,
                                                    controlAffinity: ListTileControlAffinity.leading,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        print('Disease checkbox changed: $disease (${_diseaseDisplayNames[disease]}) -> $value');
                                                        if (value == true) {
                                                          _selectedDiseases[disease] = true;
                                                          print('Added disease: $disease, _selectedDiseases: ${_selectedDiseases.keys.toList()}');
                                                        } else {
                                                          _selectedDiseases.remove(disease);
                                                          print('Removed disease: $disease, _selectedDiseases: ${_selectedDiseases.keys.toList()}');
                                                          
                                                          // Check if all diseases were unchecked
                                                          if (_selectedDiseases.isEmpty) {
                                                            print('⚠️ ALL DISEASES UNCHECKED - This should result in empty arrays sent to server');
                                                          }
                                                        }
                                                        _onFieldChanged(); // Track changes
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 24.h),

                                      // Hauteur Label
                                      Text(
                                        'Hauteur',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Hauteur input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: TextFormField(
                                          controller: _heightController,
                                          decoration: InputDecoration(
                                            hintText: '175cm',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 14.h),
                                            border: InputBorder.none,
                                            suffixIcon: Icon(
                                              Icons.height,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      SizedBox(height: 24.h),

                                      // Poids Label
                                      Text(
                                        'Poids',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Poids input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: TextFormField(
                                          controller: _weightController,
                                          decoration: InputDecoration(
                                            hintText: '80kg',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 14.h),
                                            border: InputBorder.none,
                                            suffixIcon: Icon(
                                              Icons.monitor_weight_outlined,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      SizedBox(height: 40.h),

                                      // Save button
                                      SizedBox(
                                        width: double.infinity,
                                        child: CustomButton(
                                          text: 'Sauvegarder Modification',
                                          isLoading: _isLoading,
                                          onPressed: _hasChanges
                                              ? _updateUserData
                                              : null,
                                          backgroundColor: _hasChanges
                                              ? AppColors.lightTeal
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      SizedBox(height: 30.h),
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
    );
  }
}
