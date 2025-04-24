class NutritionistModel {
  final String id;
  final String name;
  final String profileImageUrl;
  final String location;
  final String phoneNumber;
  final double rating;
  final int reviewCount;
  final String specialization;
  final String bio;
  final bool isAvailable;

  NutritionistModel({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.location,
    required this.phoneNumber,
    required this.rating,
    required this.reviewCount,
    required this.specialization,
    required this.bio,
    required this.isAvailable,
  });

  // Factory method to create a nutritionist from a map
  factory NutritionistModel.fromMap(Map<String, dynamic> map) {
    return NutritionistModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? 'https://picsum.photos/200',
      location: map['location'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      specialization: map['specialization'] ?? '',
      bio: map['bio'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
    );
  }

  // Convert nutritionist data to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'reviewCount': reviewCount,
      'specialization': specialization,
      'bio': bio,
      'isAvailable': isAvailable,
    };
  }
}

// Mock data for testing
List<NutritionistModel> getMockNutritionists() {
  return [
    NutritionistModel(
      id: '1',
      name: 'Dr. Hamza Tariq',
      profileImageUrl: 'https://picsum.photos/id/64/300/300',
      location: 'Cité Douzi, Ben Arous',
      phoneNumber: '+216 22 345 678',
      rating: 4.9,
      reviewCount: 124,
      specialization: 'Nutritionniste générale',
      bio: 'Spécialiste en nutrition et alimentation équilibrée',
      isAvailable: true,
    ),
    NutritionistModel(
      id: '2',
      name: 'Dr. Amira Ben Salem',
      profileImageUrl: 'https://picsum.photos/id/1027/300/300',
      location: 'La Marsa, Tunis',
      phoneNumber: '+216 55 789 012',
      rating: 4.9,
      reviewCount: 98,
      specialization: 'Nutritionniste Pédiatrique',
      bio: 'Experte en nutrition infantile et adolescente',
      isAvailable: true,
    ),
    NutritionistModel(
      id: '3',
      name: 'Dr. Ahmed Kouki',
      profileImageUrl: 'https://picsum.photos/id/1074/300/300',
      location: 'Sousse Centre',
      phoneNumber: '+216 98 567 432',
      rating: 4.9,
      reviewCount: 157,
      specialization: 'Nutritionniste Sportif',
      bio: 'Spécialiste en nutrition pour les sportifs de haut niveau',
      isAvailable: true,
    ),
  ];
}
