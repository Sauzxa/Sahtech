class UserModel {
  String userType; // 'user' or 'nutritionist' - removed final
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  String? userId; // MongoDB document ID

  // We don't store the actual password in the model for security reasons
  // Only for temporary use during registration/login process
  String? _tempPassword;

  bool? hasChronicDisease;
  List<String> chronicConditions = [];
  String? preferredLanguage;
  bool? doesExercise; // true = Yes, false = No
  String? activityLevel; // sedentary, light, moderate, or active
  List<String> physicalActivities =
      []; // List of selected physical activities for users who exercise
  List<String> dailyActivities =
      []; // List of daily physical activities for users who don't exercise
  List<String> healthGoals = []; // User's health goals/objectives
  bool? hasAllergies; // Whether the user has any allergies
  List<String> allergies = []; // List of user's allergies
  String? allergyYear; // Year when allergies were first noticed
  String? allergyMonth; // Month when allergies were first noticed
  String? allergyDay; // Day when allergies were first noticed
  double? weight; // User's weight in kg
  String? weightUnit; // 'kg' or 'lb'
  double? height; // User's height in cm
  String? heightUnit; // 'cm' or 'inches'

  // Add more fields as needed for your application

  UserModel({
    required this.userType,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.userId,
    String? tempPassword,
    this.hasChronicDisease,
    List<String>? chronicConditions,
    this.preferredLanguage,
    this.doesExercise,
    this.activityLevel,
    List<String>? physicalActivities,
    List<String>? dailyActivities,
    List<String>? healthGoals,
    this.hasAllergies,
    List<String>? allergies,
    this.allergyYear,
    this.allergyMonth,
    this.allergyDay,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
  }) {
    this._tempPassword = tempPassword;
    this.chronicConditions = chronicConditions ?? [];
    this.physicalActivities = physicalActivities ?? [];
    this.dailyActivities = dailyActivities ?? [];
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
    return UserModel(
      userType: map['userType'] ?? 'user',
      name: (map['prenom'] != null && map['nom'] != null)
          ? '${map['prenom']} ${map['nom']}'
          : map['name'],
      email: map['email'],
      phoneNumber: map['numTelephone']?.toString() ?? map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
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
      activityLevel: map['activityLevel'],
      physicalActivities: map['physicalActivities'] != null
          ? List<String>.from(map['physicalActivities'])
          : [],
      dailyActivities: map['dailyActivities'] != null
          ? List<String>.from(map['dailyActivities'])
          : [],
      healthGoals: map['objectives'] != null
          ? List<String>.from(map['objectives'])
          : (map['healthGoals'] != null
              ? List<String>.from(map['healthGoals'])
              : []),
      hasAllergies: map['hasAllergies'],
      allergies:
          map['allergies'] != null ? List<String>.from(map['allergies']) : [],
      allergyYear: map['allergyYear'],
      allergyMonth: map['allergyMonth'],
      allergyDay: map['allergyDay'],
      weight: map['poids']?.toDouble() ?? map['weight']?.toDouble(),
      weightUnit: map['weightUnit'],
      height: map['taille']?.toDouble() ?? map['height']?.toDouble(),
      heightUnit: map['heightUnit'],
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

    return {
      'userType': userType,
      'name': name, // Keep for frontend compatibility
      'prenom': firstName, // Add for backend compatibility
      'nom': lastName, // Add for backend compatibility
      'email': email,
      'phoneNumber': phoneNumber, // Keep for frontend compatibility
      'numTelephone': phoneNumber != null
          ? int.tryParse(phoneNumber!)
          : null, // Add for backend
      'profileImageUrl': profileImageUrl,
      // We don't include the userId here as MongoDB will manage that
      'hasChronicDisease': hasChronicDisease,
      'chronicConditions': chronicConditions, // Keep for frontend compatibility
      'maladies': chronicConditions, // Add for backend compatibility
      'preferredLanguage': preferredLanguage,
      'doesExercise': doesExercise,
      'activityLevel': activityLevel,
      'physicalActivities': physicalActivities,
      'dailyActivities': dailyActivities,
      'healthGoals': healthGoals, // Keep for frontend compatibility
      'objectives': healthGoals, // Add for backend compatibility
      'hasAllergies': hasAllergies,
      'allergies': allergies,
      'allergyYear': allergyYear,
      'allergyMonth': allergyMonth,
      'allergyDay': allergyDay,
      'weight': weight, // Keep for frontend compatibility
      'poids': weight, // Add for backend compatibility
      'weightUnit': weightUnit,
      'height': height, // Keep for frontend compatibility
      'taille': height, // Add for backend compatibility
      'heightUnit': heightUnit,
    };
  }

  // For authentication only - used when registering a user
  // This map includes the password but shouldn't be used for general data operations
  Map<String, dynamic> toAuthMap() {
    return {
      'nom': name?.split(' ').last ?? '',
      'prenom': name?.split(' ').first ?? '',
      'email': email,
      'password': _tempPassword,
      'telephone': phoneNumber != null ? int.tryParse(phoneNumber!) ?? 0 : 0,
      'userType':
          userType.toUpperCase() == 'NUTRITIONIST' ? 'NUTRITIONIST' : 'USER'
    };
  }
}
