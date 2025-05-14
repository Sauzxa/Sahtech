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

    // Handle different field naming conventions from backend
    // Debug the barcode field
    final barcodeValue =
        map['barcode'] ?? map['codeBarre'] ?? map['code_barre'] ?? '';
    print(
        'Raw barcode value: $barcodeValue (type: ${barcodeValue.runtimeType})');
    final barcodeString = barcodeValue.toString();
    print('Converted barcode: $barcodeString');

    // Nutrition facts can be nested or directly in the map
    Map<String, dynamic> nutritionFacts = {};
    if (map['nutritionFacts'] is Map) {
      nutritionFacts = Map<String, dynamic>.from(map['nutritionFacts']);
    } else if (map['nutrition_facts'] is Map) {
      nutritionFacts = Map<String, dynamic>.from(map['nutrition_facts']);
    } else if (map['valeurNutrimentielle'] is Map) {
      nutritionFacts = Map<String, dynamic>.from(map['valeurNutrimentielle']);
    }

    // Handle ingredients as string or list
    List<String> ingredientsList = [];
    if (map['ingredients'] is List) {
      ingredientsList = List<String>.from(map['ingredients']);
    } else if (map['nomingredients'] is List) {
      ingredientsList = List<String>.from(map['nomingredients']);
    } else if (map['ingredients'] is String) {
      ingredientsList = [map['ingredients']];
    } else if (map['nomingredients'] is String) {
      ingredientsList = [map['nomingredients']];
    }

    // Handle allergens in different formats
    List<String> allergensList = [];
    if (map['allergens'] is List) {
      allergensList = List<String>.from(map['allergens']);
    } else if (map['allergenes'] is List) {
      allergensList = List<String>.from(map['allergenes']);
    }

    // Health score can be named differently
    final healthScoreRaw = map['healthScore'] ??
        map['valeurNutriScore'] ??
        map['health_score'] ??
        map['nutriScore'] ??
        0.0;

    double healthScore = 0.0;
    if (healthScoreRaw is num) {
      healthScore = healthScoreRaw.toDouble();
    } else if (healthScoreRaw is String) {
      healthScore = double.tryParse(healthScoreRaw) ?? 0.0;
    }

    // Extract ID with fallbacks
    final id = map['_id']?.toString() ??
        map['id']?.toString() ??
        map['productId']?.toString() ??
        barcodeString;

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
          ? DateTime.parse(map['scanDate'])
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
