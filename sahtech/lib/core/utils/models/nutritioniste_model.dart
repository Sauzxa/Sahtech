class NutritionisteModel {
  final String userType; // Will be 'nutritionist'
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  String? preferredLanguage;

  // Nutritionist-specific fields
  String? specialization; // Area of specialization
  String? education; // Educational background
  String? certification; // Professional certifications
  int? yearsOfExperience; // Years of experience
  List<String> expertiseAreas =
      []; // Areas of expertise (e.g., diabetes, weight management)
  String? about; // About the nutritionist
  String? consultationFees; // Consultation fees
  bool?
      isAvailableForConsultation; // Is the nutritionist available for consultation
  List<String> languagesSpoken = []; // Languages spoken

  // Location and practice details
  String? address;
  String? city;
  String? country;
  String? postalCode;
  String? clinicName;
  String? websiteUrl;

  // Social media profiles
  String? linkedInUrl;
  String? twitterUrl;
  String? instagramUrl;

  // Document verification status
  bool isVerified = false;
  String? licenseNumber;
  String? licenseImageUrl;
  String? identityDocumentUrl;

  NutritionisteModel({
    required this.userType,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.preferredLanguage,
    this.specialization,
    this.education,
    this.certification,
    this.yearsOfExperience,
    List<String>? expertiseAreas,
    this.about,
    this.consultationFees,
    this.isAvailableForConsultation,
    List<String>? languagesSpoken,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.clinicName,
    this.websiteUrl,
    this.linkedInUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.isVerified = false,
    this.licenseNumber,
    this.licenseImageUrl,
    this.identityDocumentUrl,
  }) {
    this.expertiseAreas = expertiseAreas ?? [];
    this.languagesSpoken = languagesSpoken ?? [];
  }

  // Factory method to create a nutritionist from a map
  factory NutritionisteModel.fromMap(Map<String, dynamic> map) {
    return NutritionisteModel(
      userType: map['userType'] ?? 'nutritionist',
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      preferredLanguage: map['preferredLanguage'],
      specialization: map['specialization'],
      education: map['education'],
      certification: map['certification'],
      yearsOfExperience: map['yearsOfExperience'],
      expertiseAreas: List<String>.from(map['expertiseAreas'] ?? []),
      about: map['about'],
      consultationFees: map['consultationFees'],
      isAvailableForConsultation: map['isAvailableForConsultation'],
      languagesSpoken: List<String>.from(map['languagesSpoken'] ?? []),
      address: map['address'],
      city: map['city'],
      country: map['country'],
      postalCode: map['postalCode'],
      clinicName: map['clinicName'],
      websiteUrl: map['websiteUrl'],
      linkedInUrl: map['linkedInUrl'],
      twitterUrl: map['twitterUrl'],
      instagramUrl: map['instagramUrl'],
      isVerified: map['isVerified'] ?? false,
      licenseNumber: map['licenseNumber'],
      licenseImageUrl: map['licenseImageUrl'],
      identityDocumentUrl: map['identityDocumentUrl'],
    );
  }

  // Convert nutritionist data to a map
  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'preferredLanguage': preferredLanguage,
      'specialization': specialization,
      'education': education,
      'certification': certification,
      'yearsOfExperience': yearsOfExperience,
      'expertiseAreas': expertiseAreas,
      'about': about,
      'consultationFees': consultationFees,
      'isAvailableForConsultation': isAvailableForConsultation,
      'languagesSpoken': languagesSpoken,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'clinicName': clinicName,
      'websiteUrl': websiteUrl,
      'linkedInUrl': linkedInUrl,
      'twitterUrl': twitterUrl,
      'instagramUrl': instagramUrl,
      'isVerified': isVerified,
      'licenseNumber': licenseNumber,
      'licenseImageUrl': licenseImageUrl,
      'identityDocumentUrl': identityDocumentUrl,
    };
  }
}
