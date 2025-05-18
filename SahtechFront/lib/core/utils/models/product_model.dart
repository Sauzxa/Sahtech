import 'dart:math';

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final BigInt barcode;
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
        map['barcode'] ?? map['codeBarre'] ?? map['code_barre'] ?? '0';

    // Convert to BigInt, handling different input types
    BigInt barcodeValue;
    try {
      if (rawBarcode is int) {
        barcodeValue = BigInt.from(rawBarcode);
      } else if (rawBarcode is String) {
        // Remove any non-digits
        final cleanBarcode = rawBarcode.replaceAll(RegExp(r'[^0-9]'), '');
        barcodeValue =
            cleanBarcode.isEmpty ? BigInt.zero : BigInt.parse(cleanBarcode);
      } else {
        barcodeValue = BigInt.zero;
      }
    } catch (e) {
      print('Error converting barcode to BigInt: $e');
      barcodeValue = BigInt.zero;
    }

    print('Converted barcode: $barcodeValue (from ${rawBarcode.runtimeType})');

    // Validate and extract required fields with appropriate defaults
    final String id = map['id']?.toString() ?? '';

    // Extract nutrition facts or provide empty map
    Map<String, dynamic> nutritionFacts = {};
    if (map['nutritionFacts'] is Map) {
      nutritionFacts = Map<String, dynamic>.from(map['nutritionFacts']);
    } else if (map['nutrition_facts'] is Map) {
      nutritionFacts = Map<String, dynamic>.from(map['nutrition_facts']);
    }

    // Extract ingredients list or provide empty list
    List<String> ingredientsList = [];
    if (map['ingredients'] is List) {
      ingredientsList = List<String>.from(
          (map['ingredients'] as List).map((item) => item.toString()));
    }

    // Extract allergens list or provide empty list
    List<String> allergensList = [];
    if (map['allergens'] is List) {
      allergensList = List<String>.from(
          (map['allergens'] as List).map((item) => item.toString()));
    }

    // Extract health score with fallbacks
    double healthScore = 0.0;
    if (map['healthScore'] != null) {
      healthScore = double.tryParse(map['healthScore'].toString()) ?? 0.0;
    } else if (map['health_score'] != null) {
      healthScore = double.tryParse(map['health_score'].toString()) ?? 0.0;
    }

    // Create product model with all possible field names
    return ProductModel(
      id: id,
      name: map['name']?.toString() ?? map['nom']?.toString() ?? '',
      imageUrl: _validateImageUrl(
          map['imageUrl']?.toString() ?? map['image']?.toString() ?? ''),
      barcode: barcodeValue,
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

  // Helper method to validate and provide fallback for image URLs
  static String _validateImageUrl(String url) {
    if (url.isEmpty || url.contains('...') || url.endsWith('/')) {
      // Return a default placeholder image URL when the image URL is invalid
      return 'https://via.placeholder.com/150?text=Produit';
    }
    return url;
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
      'barcode': barcode.toString(),
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
      'codeBarre': barcode.toString(),
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
      'barcode': barcode.toString(),
      'brand': brand,
      'category': category,
      'nutrition_values': nutritionFacts,
      'ingredients': ingredients,
      'additives': [],
      'nutri_score': null,
      'type': category,
      'description': '',
    };
  }
}
