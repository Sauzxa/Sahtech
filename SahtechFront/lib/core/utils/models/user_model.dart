class UserModel {
  final String userType; // 'user' or 'nutritionist'
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
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      userId: map['_id']?.toString(), // MongoDB document ID
      hasChronicDisease: map['hasChronicDisease'],
      chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
      preferredLanguage: map['preferredLanguage'],
      doesExercise: map['doesExercise'],
      activityLevel: map['activityLevel'],
      physicalActivities: List<String>.from(map['physicalActivities'] ?? []),
      dailyActivities: List<String>.from(map['dailyActivities'] ?? []),
      healthGoals: List<String>.from(map['healthGoals'] ?? []),
      hasAllergies: map['hasAllergies'],
      allergies: List<String>.from(map['allergies'] ?? []),
      allergyYear: map['allergyYear'],
      allergyMonth: map['allergyMonth'],
      allergyDay: map['allergyDay'],
      weight: map['weight']?.toDouble(),
      weightUnit: map['weightUnit'],
      height: map['height']?.toDouble(),
      heightUnit: map['heightUnit'],
    );
  }

  // Convert user data to a map - NEVER include password in this map
  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      // We don't include the userId here as MongoDB will manage that
      'hasChronicDisease': hasChronicDisease,
      'chronicConditions': chronicConditions,
      'preferredLanguage': preferredLanguage,
      'doesExercise': doesExercise,
      'activityLevel': activityLevel,
      'physicalActivities': physicalActivities,
      'dailyActivities': dailyActivities,
      'healthGoals': healthGoals,
      'hasAllergies': hasAllergies,
      'allergies': allergies,
      'allergyYear': allergyYear,
      'allergyMonth': allergyMonth,
      'allergyDay': allergyDay,
      'weight': weight,
      'weightUnit': weightUnit,
      'height': height,
      'heightUnit': heightUnit,
    };
  }

  // For authentication only - used when registering a user
  // This map includes the password but shouldn't be used for general data operations
  Map<String, dynamic> toAuthMap() {
    final Map<String, dynamic> authMap = toMap();
    if (_tempPassword != null) {
      authMap['password'] = _tempPassword;
    }
    return authMap;
  }
}
