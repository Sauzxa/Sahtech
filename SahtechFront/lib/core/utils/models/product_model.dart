import 'dart:math';

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
    // Debug the raw data
    print(
        'Creating ProductModel from data: ${map.toString().substring(0, min(100, map.toString().length))}...');

    // Handle different field naming conventions from backend and validate data
    // Standardized field mapping - prioritize 'barcode' first, then fallback to others
    final rawBarcode =
        map['barcode'] ?? map['codeBarre'] ?? map['code_barre'] ?? '';
    final String barcodeString;

    // Ensure barcode is always a string
    if (rawBarcode is int || rawBarcode is double) {
      barcodeString = rawBarcode.toString();
    } else {
      barcodeString = rawBarcode.toString();
    }

    print('Converted barcode: $barcodeString (from ${rawBarcode.runtimeType})');

    // Validate and extract required fields with appropriate defaults
    final String id = map['id']?.toString() ?? '';

    // Extract nutrition facts with validation
    final Map<String, dynamic> nutritionFacts = (map['nutritionFacts'] is Map)
        ? Map<String, dynamic>.from(map['nutritionFacts'])
        : (map['nutrition_values'] is Map)
            ? Map<String, dynamic>.from(map['nutrition_values'])
            : {};

    // Extract ingredients with validation
    List<String> ingredientsList = [];
    if (map['ingredients'] is List) {
      ingredientsList = List<String>.from(
          (map['ingredients'] as List).map((i) => i.toString()));
    }

    // Extract allergens with validation
    List<String> allergensList = [];
    if (map['allergens'] is List) {
      allergensList = List<String>.from(
          (map['allergens'] as List).map((i) => i.toString()));
    }

    // Health score validation (defaults to 2.5 as middle value if missing)
    double healthScore = 2.5;
    final rawScore =
        map['healthScore'] ?? map['health_score'] ?? map['score'] ?? 2.5;
    if (rawScore is num) {
      healthScore = rawScore.toDouble();
    } else if (rawScore is String) {
      healthScore = double.tryParse(rawScore) ?? 2.5;
    }

    // Create product model with all possible field names
    return ProductModel(
      id: id,
      name: map['name']?.toString() ?? map['nom']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? map['image']?.toString() ?? '',
      barcode: barcodeString,
      brand: map['brand']?.toString() ?? map['marque']?.toString() ?? '',
      category:
          map['category']?.toString() ?? map['categorie']?.toString() ?? '',
      nutritionFacts: nutritionFacts,
      ingredients: ingredientsList,
      allergens: allergensList,
      healthScore: healthScore,
      scanDate: map['scanDate'] != null
          ? DateTime.parse(map['scanDate'].toString())
          : DateTime.now(),
      aiRecommendation: map['aiRecommendation'] ?? map['recommendation'],
      recommendationType:
          map['recommendationType'] ?? map['recommendation_type'],
    );
  }

  // Factory method to create a product from JSON string
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel.fromMap(json);
  }

  // Convert product data to a map - use standardized field names for API communication
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'barcode': barcode, // Use standardized field name
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

  // Convert to Spring Boot compatible format
  Map<String, dynamic> toSpringFormat() {
    return {
      'id': id,
      'nom': name,
      'imageUrl': imageUrl,
      'codeBarre': barcode, // Convert to Spring Boot expected field name
      'marque': brand,
      'categorie': category,
      'nutritionFacts': nutritionFacts,
      'ingredients': ingredients,
      'allergens': allergens,
      'healthScore': healthScore,
      'scanDate': scanDate.toIso8601String(),
      'aiRecommendation': aiRecommendation,
      'recommendationType': recommendationType,
    };
  }

  // Convert to FastAPI compatible format
  Map<String, dynamic> toFastAPIFormat() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'barcode': barcode, // FastAPI uses 'barcode'
      'brand': brand,
      'category': category,
      'nutrition_values': nutritionFacts, // FastAPI uses 'nutrition_values'
      'ingredients': ingredients,
      'additives': [], // Add empty additives field for FastAPI
      'nutri_score': null,
      'type': category,
      'description': '',
    };
  }
}
