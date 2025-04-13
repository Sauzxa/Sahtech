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
  });

  // Factory method to create a product from a map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      barcode: map['barcode'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      nutritionFacts: Map<String, dynamic>.from(map['nutritionFacts'] ?? {}),
      ingredients: List<String>.from(map['ingredients'] ?? []),
      allergens: List<String>.from(map['allergens'] ?? []),
      healthScore: (map['healthScore'] ?? 0.0).toDouble(),
      scanDate: map['scanDate'] != null
          ? DateTime.parse(map['scanDate'])
          : DateTime.now(),
    );
  }

  // Convert product data to a map
  Map<String, dynamic> toMap() {
    return {
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
    };
  }
}
