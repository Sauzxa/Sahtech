import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/models/product_model.dart';

class ProductService {
  // Base URL of your API
  static const String baseUrl = 'https://your-api.com/api';

  // API key or token for authentication
  static const String apiKey = 'your_api_key_here';

  // Get all scanned products for a user
  static Future<List<ProductModel>> getUserProducts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromMap(json)).toList();
      } else {
        print('Error fetching products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception when fetching products: $e');
      // For development, return some mock products
      return _getMockProducts();
    }
  }

  // Scan a product by barcode
  static Future<ProductModel?> scanProduct(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/barcode/$barcode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromMap(data);
      } else {
        print('Error scanning product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception when scanning product: $e');
      // For development, return a mock product
      return _getMockProducts().first;
    }
  }

  // Mock products for development and testing
  static List<ProductModel> _getMockProducts() {
    return [
      ProductModel(
        id: '1',
        name: 'Yaourt Nature',
        imageUrl: 'https://picsum.photos/200?random=1',
        barcode: BigInt.parse('3033490004751'),
        brand: 'Nature Bio',
        category: 'Produits laitiers',
        nutritionFacts: {
          'calories': 120,
          'fat': 4.5,
          'carbs': 12.0,
          'protein': 8.0,
          'salt': 0.2,
        },
        ingredients: ['Lait entier', 'Ferments lactiques'],
        allergens: ['Lait'],
        healthScore: 4.2,
        scanDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: '2',
        name: 'Pain Complet',
        imageUrl: 'https://picsum.photos/200?random=2',
        barcode: BigInt.parse('3564700011439'),
        brand: 'Boulangerie Artisanale',
        category: 'Boulangerie',
        nutritionFacts: {
          'calories': 240,
          'fat': 1.2,
          'carbs': 45.0,
          'protein': 9.0,
          'salt': 1.1,
        },
        ingredients: ['Farine complète', 'Eau', 'Levure', 'Sel'],
        allergens: ['Gluten'],
        healthScore: 3.8,
        scanDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProductModel(
        id: '3',
        name: 'Jus d\'Orange',
        imageUrl: 'https://picsum.photos/200?random=3',
        barcode: BigInt.parse('3057640385575'),
        brand: 'Fruits Bio',
        category: 'Boissons',
        nutritionFacts: {
          'calories': 45,
          'fat': 0.0,
          'carbs': 10.5,
          'protein': 0.5,
          'salt': 0.0,
        },
        ingredients: ['Jus d\'orange', 'Pulpe d\'orange'],
        allergens: [],
        healthScore: 4.0,
        scanDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
