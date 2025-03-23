class UserModel {
  final String userType; // 'user' or 'nutritionist'
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  bool? hasChronicDisease;
  List<String> chronicConditions = [];
  String? preferredLanguage;

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
  }) {
    this.chronicConditions = chronicConditions ?? [];
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
    };
  }
}
