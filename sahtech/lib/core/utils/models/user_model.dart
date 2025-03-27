class UserModel {
  final String userType; // 'user' or 'nutritionist'
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  bool? hasChronicDisease;
  List<String> chronicConditions = [];
  String? preferredLanguage;
  bool? doesExercise; // true = Yes, false = No
  List<String> physicalActivities =
      []; // List of selected physical activities for users who exercise
  List<String> dailyActivities =
      []; // List of daily physical activities for users who don't exercise
  List<String> healthGoals = []; // User's health goals/objectives
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
    this.hasChronicDisease,
    List<String>? chronicConditions,
    this.preferredLanguage,
    this.doesExercise,
    List<String>? physicalActivities,
    List<String>? dailyActivities,
    List<String>? healthGoals,
    List<String>? allergies,
    this.allergyYear,
    this.allergyMonth,
    this.allergyDay,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
  }) {
    this.chronicConditions = chronicConditions ?? [];
    this.physicalActivities = physicalActivities ?? [];
    this.dailyActivities = dailyActivities ?? [];
    this.healthGoals = healthGoals ?? [];
    this.allergies = allergies ?? [];
  }

  // Factory method to create a user from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userType: map['userType'] ?? 'user',
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      hasChronicDisease: map['hasChronicDisease'],
      chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
      preferredLanguage: map['preferredLanguage'],
      doesExercise: map['doesExercise'],
      physicalActivities: List<String>.from(map['physicalActivities'] ?? []),
      dailyActivities: List<String>.from(map['dailyActivities'] ?? []),
      healthGoals: List<String>.from(map['healthGoals'] ?? []),
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

  // Convert user data to a map
  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'hasChronicDisease': hasChronicDisease,
      'chronicConditions': chronicConditions,
      'preferredLanguage': preferredLanguage,
      'doesExercise': doesExercise,
      'physicalActivities': physicalActivities,
      'dailyActivities': dailyActivities,
      'healthGoals': healthGoals,
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
}
