class UserModel {
  final String userType; // 'user' or 'nutritionist'
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;

  // Add more fields as needed for your application

  UserModel({
    required this.userType,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
  });

  // Factory method to create a user from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userType: map['userType'] ?? 'user',
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
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
    };
  }
}
