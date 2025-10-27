class NutritionisteModel {
  final String userType; // Will be 'nutritionist'
  String? name;
  String? email;
  String? phoneNumber;
  dynamic numTelephone; // Can be int or String from API
  String? password; // Added for authentication
  String? profileImageUrl;
  String? photoUrl; // Direct photoUrl from API response
  String preferredLanguage;
  String? gender; // Added to store gender information
  String? userId; // ID from the backend
  String? id; // Direct ID from API response
  String? sexe; // Gender field from backend
  String? specialite; // Specialization field from backend
  String? localisationId; // Location ID from backend
  bool? hasAllergies; // Whether user has allergies
  String? activityLevel; // User's activity level
  List<String> proveAttestationType = [];
  List<String> physicalActivities = []; // User's physical activities
  List<String> dailyActivities = []; // User's daily activities
  double? weight; // User's weight
  String? weightUnit; // Unit for weight (kg, lb)
  double? height; // User's height
  String? heightUnit; // Unit for height (cm, ft)
  DateTime? dateDeNaissance; // Date of birth

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
    List<String>? proveAttestationType,
    required this.userType,
    this.name,
    this.email,
    this.phoneNumber,
    this.numTelephone,
    this.password,
    this.profileImageUrl,
    this.photoUrl,
    required this.preferredLanguage,
    this.gender,
    this.userId,
    this.id,
    this.sexe,
    this.specialite,
    this.localisationId,
    this.hasAllergies,
    this.activityLevel,
    List<String>? physicalActivities,
    List<String>? dailyActivities,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
    this.dateDeNaissance,
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
    this.physicalActivities = physicalActivities ?? [];
    this.dailyActivities = dailyActivities ?? [];
    this.proveAttestationType = proveAttestationType ?? [];
  }

  // Factory method to create a user from a map
  factory NutritionisteModel.fromMap(Map<String, dynamic> map) {
    // Debug the incoming map
    
    
    return NutritionisteModel(
      userType: 'nutritionist',
      userId: map['id']?.toString() ?? map['_id']?.toString(),
      id: map['id']?.toString(),
      name: (map['prenom'] != null && map['nom'] != null)
          ? '${map['prenom']} ${map['nom']}'
          : map['name'],
      email: map['email'],
      numTelephone: map['numTelephone'],
      phoneNumber: map['numTelephone']?.toString() ?? map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      photoUrl: map['photoUrl'],
      sexe: map['sexe'],
      specialite: map['specialite'],
      isVerified: map['estVerifie'] ?? false,
      localisationId: map['localisationId'],
      hasChronicDisease: map['hasChronicDisease'],
      // Handle both array formats and single value format for backward compatibility
      chronicConditions: map['maladies'] != null
          ? List<String>.from(map['maladies'])
          : (map['chronicConditions'] != null
              ? List<String>.from(map['chronicConditions'])
              : []),
      preferredLanguage: map['preferredLanguage'] ?? 'en',
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
      dateDeNaissance: map['dateDeNaissance'] != null
          ? DateTime.parse(map['dateDeNaissance'])
          : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      cabinetAddress: map['cabinetAddress'],
      address: map['cabinetAddress'], // Use cabinetAddress as fallback for address
    );
  }

  // Convert data to a map for API requests
  Map<String, dynamic> toMap() {
    // Split name into first and last name for backend
    String firstName = '';
    String lastName = '';
    if (name != null && name!.isNotEmpty) {
      List<String> nameParts = name!.split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    }

    // Make sure we have a date of birth
    final dateOfBirth = dateDeNaissance ??
        DateTime.now().subtract(const Duration(days: 365 * 30));

    // Create map with exact field names matching the Java backend entity
    final Map<String, dynamic> map = {
      // Fields from Utilisateurs class
      'type':
          'NUTRITIONIST', // This is how the type is set in Nutrisioniste constructor
      'userType': 'NUTRITIONIST', // Add this field as the server expects it
      'nom': lastName,
      'prenom': firstName,
      'numTelephone': phoneNumber != null
          ? int.tryParse(phoneNumber!.replaceAll('+', ''))
          : null,
      'telephone': phoneNumber, // Add explicit telephone field for backend
      'email': email,
      'dateDeNaissance': dateOfBirth.toIso8601String(),
      'maladies': chronicConditions, // Maps to List<Maladie> in Java
      'poids': weight,
      'taille': height,
      'sport': doesExercise,
      'sexe': sexe ?? gender,
      'allergies': allergies ?? [],
      'password': password,
      // 'objectif': null, // This is a single Objectif enum in Java
      'objectives': healthGoals, // Maps to List<String> objectives in Java
      'provider': 'LOCAL',
      'hasChronicDisease': hasChronicDisease ?? false,
      'hasAllergies': hasAllergies ?? false,
      'preferredLanguage': preferredLanguage,
      'physicalActivities': physicalActivities,
      'dailyActivities': dailyActivities,
      'healthGoals': healthGoals, // Maps to List<String> healthGoals in Java
      'photoUrl': profileImageUrl, // Maps to @Field("photoUrl") in Java

      // Fields from Nutrisioniste class
      'specialite': specialite ?? specialization,
      'localisationId': localisationId,
      'estVerifie': isVerified ?? false,
      'photoUrlDiplome':
          diplomaImagePath, // Maps to photoUrlDiplome in Nutrisioniste
    };

    // Add these fields for frontend compatibility only
    map['name'] = name;
    map['phoneNumber'] = phoneNumber;
    map['gender'] = gender ?? sexe;
    map['chronicConditions'] = chronicConditions;
    map['weightUnit'] = weightUnit;
    map['heightUnit'] = heightUnit;
    map['activityLevel'] = activityLevel;
    map['allergyYear'] = allergyYear;
    map['allergyMonth'] = allergyMonth;
    map['allergyDay'] = allergyDay;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['cabinetAddress'] = cabinetAddress;
    map['proveAttestationType'] = proveAttestationType;

    return map;
  }

  // Create a copy of the current instance with optional field updates
  NutritionisteModel copyWith({
    String? userType,
    String? name,
    String? email,
    String? phoneNumber,
    dynamic numTelephone,
    String? password,
    String? profileImageUrl,
    String? photoUrl,
    String? preferredLanguage,
    String? gender,
    String? userId,
    String? sexe,
    String? specialite,
    String? localisationId,
    bool? hasAllergies,
    String? activityLevel,
    List<String>? physicalActivities,
    List<String>? dailyActivities,
    double? weight,
    String? weightUnit,
    double? height,
    String? heightUnit,
    DateTime? dateDeNaissance,
    bool? hasChronicDisease,
    List<String>? chronicConditions,
    List<String>? allergies,
    String? allergyDay,
    String? allergyMonth,
    String? allergyYear,
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
      numTelephone: numTelephone ?? this.numTelephone,
      password: password ?? this.password,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      gender: gender ?? this.gender,
      userId: userId ?? this.userId,
      sexe: sexe ?? this.sexe,
      specialite: specialite ?? this.specialite,
      localisationId: localisationId ?? this.localisationId,
      hasAllergies: hasAllergies ?? this.hasAllergies,
      activityLevel: activityLevel ?? this.activityLevel,
      physicalActivities:
          physicalActivities ?? List<String>.from(this.physicalActivities),
      dailyActivities:
          dailyActivities ?? List<String>.from(this.dailyActivities),
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      dateDeNaissance: dateDeNaissance ?? this.dateDeNaissance,
      hasChronicDisease: hasChronicDisease ?? this.hasChronicDisease,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      allergyDay: allergyDay ?? this.allergyDay,
      allergyMonth: allergyMonth ?? this.allergyMonth,
      allergyYear: allergyYear ?? this.allergyYear,
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

  // Create a JSON Map from the model
  Map<String, dynamic> toJson() {
    return {
      'userType': userType,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'numTelephone': numTelephone,
      'password': password,
      'profileImageUrl': profileImageUrl,
      'photoUrl': photoUrl,
      'preferredLanguage': preferredLanguage,
      'gender': gender,
      'userId': userId,
      'sexe': sexe,
      'specialite': specialite,
      'localisationId': localisationId,
      'hasAllergies': hasAllergies,
      'activityLevel': activityLevel,
      'physicalActivities': physicalActivities,
      'dailyActivities': dailyActivities,
      'weight': weight,
      'weightUnit': weightUnit,
      'height': height,
      'heightUnit': heightUnit,
      'dateDeNaissance': dateDeNaissance?.toIso8601String(),
      'hasChronicDisease': hasChronicDisease,
      'chronicConditions': chronicConditions,
      'allergies': allergies,
      'allergyDay': allergyDay,
      'allergyMonth': allergyMonth,
      'allergyYear': allergyYear,
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

  // Create a NutritionisteModel instance from a JSON Map
  factory NutritionisteModel.fromJson(Map<String, dynamic> json) {
    return NutritionisteModel(
      userType: json['userType'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      numTelephone: json['numTelephone'],
      password: json['password'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? '',
      gender: json['gender'] ?? '',
      userId: json['userId'] ?? '',
      sexe: json['sexe'] ?? '',
      specialite: json['specialite'] ?? '',
      localisationId: json['localisationId'] ?? 0,
      hasAllergies: json['hasAllergies'] ?? false,
      activityLevel: json['activityLevel'] ?? '',
      physicalActivities: json['physicalActivities'] != null
          ? List<String>.from(json['physicalActivities'])
          : [],
      dailyActivities: json['dailyActivities'] != null
          ? List<String>.from(json['dailyActivities'])
          : [],
      weight: json['weight'] != null ? json['weight'].toDouble() : 0.0,
      weightUnit: json['weightUnit'] ?? '',
      height: json['height'] != null ? json['height'].toDouble() : 0.0,
      heightUnit: json['heightUnit'] ?? '',
      dateDeNaissance: json['dateDeNaissance'] != null
          ? DateTime.parse(json['dateDeNaissance'])
          : null,
      hasChronicDisease: json['hasChronicDisease'] ?? false,
      chronicConditions: json['chronicConditions'] != null
          ? List<String>.from(json['chronicConditions'])
          : [],
      allergies:
          json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      allergyDay: json['allergyDay'] ?? 0,
      allergyMonth: json['allergyMonth'] ?? 0,
      allergyYear: json['allergyYear'] ?? 0,
      doesExercise: json['doesExercise'] ?? false,
      healthGoals: json['healthGoals'] != null
          ? List<String>.from(json['healthGoals'])
          : [],
      specialization: json['specialization'] ?? '',
      education: json['education'] ?? '',
      certification: json['certification'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      expertiseAreas: json['expertiseAreas'] != null
          ? List<String>.from(json['expertiseAreas'])
          : [],
      about: json['about'] ?? '',
      consultationFees: json['consultationFees'] != null
          ? json['consultationFees'].toDouble()
          : 0.0,
      isAvailableForConsultation: json['isAvailableForConsultation'] ?? false,
      languagesSpoken: json['languagesSpoken'] != null
          ? List<String>.from(json['languagesSpoken'])
          : [],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      clinicName: json['clinicName'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      linkedInUrl: json['linkedInUrl'] ?? '',
      twitterUrl: json['twitterUrl'] ?? '',
      instagramUrl: json['instagramUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
      licenseNumber: json['licenseNumber'] ?? '',
      licenseImageUrl: json['licenseImageUrl'] ?? '',
      identityDocumentUrl: json['identityDocumentUrl'] ?? '',
      diplomaImagePath: json['diplomaImagePath'] ?? '',
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : 0.0,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : 0.0,
      cabinetAddress: json['cabinetAddress'] ?? '',
    );
  }
}
