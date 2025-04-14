class NutritionisteModel {
  final String userType; // Will be 'nutritionist'
  String? name;
  String? email;
  String? phoneNumber;
  String? password; // Added for authentication
  String? profileImageUrl;
  String preferredLanguage;
  String? gender; // Added to store gender information
  
  // Fields for profile screens flow
  bool? hasChronicDisease;
  List<String>? chronicConditions;
  List<String>? allergies;
  String? allergyDay;
  String? allergyMonth;
  String? allergyYear;
  bool? doesExercise;
  List<String>? healthGoals;

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
  double? latitude; // Added for storing cabinet location
  double? longitude; // Added for storing cabinet location
  String? cabinetAddress; // Added for storing cabinet address

  // Social media profiles
  String? linkedInUrl;
  String? twitterUrl;
  String? instagramUrl;

  // Document verification status
  bool isVerified = false;
  String? licenseNumber;
  String? licenseImageUrl;
  String? identityDocumentUrl;
  String? diplomaImagePath; // Path to the diploma image file on the device

  NutritionisteModel({
    required this.userType,
    this.name,
    this.email,
    this.phoneNumber,
    this.password,
    this.profileImageUrl,
    required this.preferredLanguage,
    this.gender,
    this.hasChronicDisease,
    this.chronicConditions,
    this.allergies,
    this.allergyDay,
    this.allergyMonth,
    this.allergyYear,
    this.doesExercise,
    this.healthGoals,
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
    this.diplomaImagePath,
    this.latitude,
    this.longitude,
    this.cabinetAddress,
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
      password: map['password'],
      profileImageUrl: map['profileImageUrl'],
      preferredLanguage: map['preferredLanguage'] ?? 'fr',
      gender: map['gender'],
      hasChronicDisease: map['hasChronicDisease'],
      chronicConditions: map['chronicConditions'] != null
        ? List<String>.from(map['chronicConditions'])
        : null,
      allergies: map['allergies'] != null
        ? List<String>.from(map['allergies'])
        : null,
      allergyDay: map['allergyDay'],
      allergyMonth: map['allergyMonth'],
      allergyYear: map['allergyYear'],
      doesExercise: map['doesExercise'],
      healthGoals: map['healthGoals'] != null
        ? List<String>.from(map['healthGoals'])
        : null,
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
      diplomaImagePath: map['diplomaImagePath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      cabinetAddress: map['cabinetAddress'],
    );
  }

  // Convert nutritionist data to a map
  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'profileImageUrl': profileImageUrl,
      'preferredLanguage': preferredLanguage,
      'gender': gender,
      'hasChronicDisease': hasChronicDisease,
      'chronicConditions': chronicConditions,
      'allergies': allergies,
      'doesExercise': doesExercise,
      'healthGoals': healthGoals,
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
      'diplomaImagePath': diplomaImagePath,
      'latitude': latitude,
      'longitude': longitude,
      'cabinetAddress': cabinetAddress,
    };
  }

  // Create a copy of the current instance with optional field updates
  NutritionisteModel copyWith({
    String? userType,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    String? profileImageUrl,
    String? preferredLanguage,
    String? gender,
    bool? hasChronicDisease,
    List<String>? chronicConditions,
    List<String>? allergies,
    bool? doesExercise,
    List<String>? healthGoals,
    String? specialization,
    String? education,
    String? certification,
    int? yearsOfExperience,
    List<String>? expertiseAreas,
    String? about,
    String? consultationFees,
    bool? isAvailableForConsultation,
    List<String>? languagesSpoken,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? clinicName,
    String? websiteUrl,
    String? linkedInUrl,
    String? twitterUrl,
    String? instagramUrl,
    bool? isVerified,
    String? licenseNumber,
    String? licenseImageUrl,
    String? identityDocumentUrl,
    String? diplomaImagePath,
    double? latitude,
    double? longitude,
    String? cabinetAddress,
  }) {
    return NutritionisteModel(
      userType: userType ?? this.userType,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      gender: gender ?? this.gender,
      hasChronicDisease: hasChronicDisease ?? this.hasChronicDisease,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      doesExercise: doesExercise ?? this.doesExercise,
      healthGoals: healthGoals ?? this.healthGoals,
      specialization: specialization ?? this.specialization,
      education: education ?? this.education,
      certification: certification ?? this.certification,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      expertiseAreas: expertiseAreas ?? List<String>.from(this.expertiseAreas),
      about: about ?? this.about,
      consultationFees: consultationFees ?? this.consultationFees,
      isAvailableForConsultation:
          isAvailableForConsultation ?? this.isAvailableForConsultation,
      languagesSpoken:
          languagesSpoken ?? List<String>.from(this.languagesSpoken),
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      clinicName: clinicName ?? this.clinicName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      identityDocumentUrl: identityDocumentUrl ?? this.identityDocumentUrl,
      diplomaImagePath: diplomaImagePath ?? this.diplomaImagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cabinetAddress: cabinetAddress ?? this.cabinetAddress,
    );
  }
}
