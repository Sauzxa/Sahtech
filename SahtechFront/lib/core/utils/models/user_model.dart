import 'dart:convert';

class UserModel {
  String userType; // 'user' or 'nutritionist' - removed final
  String? name;
  String? email;
  String? phoneNumber;
  String? photoUrl;
  String? userId; // MongoDB document ID

  // We don't store the actual password in the model for security reasons
  // Only for temporary use during registration/login process
  String? _tempPassword;

  bool? hasChronicDisease;
  List<String> chronicConditions = [];
  String? preferredLanguage; // Language preference for the user
  bool? doesExercise; // true = Yes, false = No
  List<String> healthGoals = []; // User's health goals/objectives
  bool? hasAllergies; // Whether the user has any allergies
  List<String> allergies = []; // List of user's allergies
  double? weight; // User's weight in kg
  String? weightUnit; // 'kg' or 'lb'
  double? height; // User's height in cm
  String? heightUnit; // 'cm' or 'inches'
  String? dateOfBirth; // User's date of birth

  // Add more fields as needed for your application

  UserModel({
    required this.userType,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.userId,
    String? tempPassword,
    this.hasChronicDisease,
    List<String>? chronicConditions,
    this.preferredLanguage,
    this.doesExercise,
    List<String>? healthGoals,
    this.hasAllergies,
    List<String>? allergies,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
    this.dateOfBirth,
  }) {
    this._tempPassword = tempPassword;
    this.chronicConditions = chronicConditions ?? [];
    this.healthGoals = healthGoals ?? [];
    this.allergies = allergies ?? [];
  }

  // Get temporary password (only used during auth process)
  String? get tempPassword => _tempPassword;

  // Set temporary password
  set tempPassword(String? value) {
    _tempPassword = value;
  }

  // Clear temporary password after authentication
  void clearPassword() {
    _tempPassword = null;
  }

  // Factory method to create a user from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Extract profile image URL with debugging
    String? photoUrl;
    if (map['photoUrl'] != null) {
      photoUrl = map['photoUrl'];
      print('Found photoUrl in map: $photoUrl');
    } else if (map['photoUrl'] != null) {
      photoUrl = map['photoUrl'];
      print('Found photoUrl in map: $photoUrl');
    } else {
      print('No profile image URL found in data from server');
    }

    return UserModel(
      userType: map['userType'] ?? 'user',
      name: (map['prenom'] != null && map['nom'] != null)
          ? '${map['prenom']} ${map['nom']}'
          : map['name'],
      email: map['email'],
      phoneNumber: map['numTelephone']?.toString() ?? map['phoneNumber'],
      photoUrl: photoUrl,
      userId: map['id']?.toString() ??
          map['_id']?.toString(), // Support both MongoDB ID formats
      hasChronicDisease: map['hasChronicDisease'],
      // Handle both array formats and single value format for backward compatibility
      chronicConditions: map['maladies'] != null
          ? List<String>.from(map['maladies'])
          : (map['chronicConditions'] != null
              ? List<String>.from(map['chronicConditions'])
              : []),
      preferredLanguage: map['preferredLanguage'],
      doesExercise: map['doesExercise'],
      healthGoals: map['objectives'] != null
          ? List<String>.from(map['objectives'])
          : (map['healthGoals'] != null
              ? List<String>.from(map['healthGoals'])
              : []),
      hasAllergies: map['hasAllergies'],
      allergies:
          map['allergies'] != null ? List<String>.from(map['allergies']) : [],
      weight: map['poids']?.toDouble() ?? map['weight']?.toDouble(),
      weightUnit: map['weightUnit'],
      height: map['taille']?.toDouble() ?? map['height']?.toDouble(),
      heightUnit: map['heightUnit'],
      dateOfBirth: map['dateDeNaissance'],
    );
  }

  // Convert user data to a map - NEVER include password in this map
  Map<String, dynamic> toMap() {
    // Split name into first and last name for backend
    String firstName = '';
    String lastName = '';
    if (name != null && name!.isNotEmpty) {
      List<String> nameParts = name!.split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.last : '';
    }

    // Create a map with all data correctly mapped to backend field names
    final Map<String, dynamic> userData = {
      // Required user identity fields
      'userType': userType,
      'name': name, // Keep for frontend compatibility
      'prenom': firstName, // Backend field
      'nom': lastName, // Backend field
      'email': email,
      'phoneNumber': phoneNumber, // Keep for frontend compatibility
      'numTelephone': phoneNumber != null
          ? int.tryParse(phoneNumber!) ?? 0
          : 0, // Backend field (as integer)

      // IMPORTANT: Map profileImageUrl to photoUrl for MongoDB
      'photoUrl': photoUrl, // This is the key field for MongoDB

      // Health condition fields
      'hasChronicDisease': hasChronicDisease ?? false, // Ensure not null
      'chronicConditions': chronicConditions, // Frontend field
      'maladies': chronicConditions, // Backend field

      // Allergy fields
      'hasAllergies': hasAllergies ?? false, // Ensure not null
      'allergies': allergies,

      // Language and activity fields
      'preferredLanguage': preferredLanguage,
      'doesExercise': doesExercise ?? false, // Ensure not null

      // Goals
      'healthGoals': healthGoals, // Frontend field
      'objectives': healthGoals, // Backend field

      // Physical measurements
      'weight': weight, // Frontend field
      'poids': weight, // Backend field
      'weightUnit': weightUnit,
      'height': height, // Frontend field
      'taille': height, // Backend field
      'heightUnit': heightUnit,

      // Handle birthday - convert to appropriate format if needed
      'dateDeNaissance': dateOfBirth,
    };

    // Remove any null values to avoid validation errors on the backend
    userData.removeWhere((key, value) => value == null);

    return userData;
  }

  // For authentication only - used when registering a user
  // This map includes the password but shouldn't be used for general data operations
  Map<String, dynamic> toAuthMap() {
    // Create a comprehensive map with all user data for registration
    final Map<String, dynamic> authData = {
      // Basic authentication fields
      'nom': name?.split(' ').last ?? '',
      'prenom': name?.split(' ').first ?? '',
      'email': email,
      'password': _tempPassword,
      'telephone': phoneNumber != null ? int.tryParse(phoneNumber!) ?? 0 : 0,
      'numTelephone': phoneNumber != null ? int.tryParse(phoneNumber!) ?? 0 : 0,
      'userType':
          userType.toUpperCase() == 'NUTRITIONIST' ? 'NUTRITIONIST' : 'USER',

      // Include photoUrl with empty string as default to ensure it's included in the request
      'photoUrl': photoUrl ?? "",

      // Include date of birth if available
      'dateDeNaissance': dateOfBirth,

      // Health-related data
      'hasChronicDisease': hasChronicDisease ?? false,
      'maladies': chronicConditions,
      'hasAllergies': hasAllergies ?? false,
      'allergies': allergies,

      // Language preference
      'preferredLanguage': preferredLanguage,

      // Physical attributes
      'taille': height,
      'poids': weight,

      // Activity information
      'doesExercise': doesExercise ?? false,

      // Goals and objectives
      'objectives': healthGoals,
    };

    // Remove any null values that might cause validation issues on the backend
    authData.removeWhere((key, value) => value == null);

    print('Prepared registration data: ${json.encode(authData)}');

    return authData;
  }
}
