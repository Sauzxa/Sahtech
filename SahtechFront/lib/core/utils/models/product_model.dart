class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final String barcode;
  final String brand;
  final String category;
  final Map<String, dynamic> nutritionFacts;
  final List<String> ingredients;
  final List<String> allergens;
  final double healthScore;
  final DateTime scanDate;
  
  // AI-generated personalized recommendation for this product
  String? aiRecommendation;
  
  // Type of recommendation: 'recommended', 'caution', or 'avoid'
  String? recommendationType;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.barcode,
    required this.brand,
    required this.category,
    required this.nutritionFacts,
    required this.ingredients,
    required this.allergens,
    required this.healthScore,
    required this.scanDate,
    this.aiRecommendation,
    this.recommendationType,
  });

  // Factory method to create a product from a map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? map['nom'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      barcode: map['barcode'] ?? map['codeBarre']?.toString() ?? '',
      brand: map['brand'] ?? map['marque'] ?? '',
      category: map['category'] ?? map['categorie'] ?? '',
      nutritionFacts: Map<String, dynamic>.from(map['nutritionFacts'] ?? {}),
      ingredients: List<String>.from(map['ingredients'] ?? map['nomingredients'] ?? []),
      allergens: List<String>.from(map['allergens'] ?? []),
      healthScore: (map['healthScore'] ?? map['valeurNutriScore'] ?? 0.0).toDouble(),
      scanDate: map['scanDate'] != null
          ? DateTime.parse(map['scanDate'])
          : DateTime.now(),
      aiRecommendation: map['aiRecommendation'] ?? map['recommendation'],
      recommendationType: map['recommendationType'] ?? map['recommendation_type'],
    );
  }
  
  // Factory method to create a product from JSON string
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel.fromMap(json);
  }

  // Convert product data to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'brand': brand,
      'category': category,
      'nutritionFacts': nutritionFacts,
      'ingredients': ingredients,
      'allergens': allergens,
      'healthScore': healthScore,
      'scanDate': scanDate.toIso8601String(),
      'aiRecommendation': aiRecommendation,
      'recommendationType': recommendationType,
    };
  }
}
