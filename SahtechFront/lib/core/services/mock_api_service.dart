import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/utils/models/nutritionist_model.dart';
import 'package:sahtech/core/utils/models/ad_model.dart';
import 'package:sahtech/core/utils/models/product_model.dart';

/// A mock API service that simulates network behavior
/// This allows testing of loading states, error handling, and UI without real backend
class MockApiService {
  // Singleton pattern
  static final MockApiService _instance = MockApiService._internal();

  factory MockApiService() => _instance;

  MockApiService._internal();

  // Random generator for simulating network conditions
  final Random _random = Random();

  // Control parameters
  final bool _shouldSimulateErrors =
      false; // Set to true to test error handling
  final double _errorProbability = 0.1; // 10% chance of error
  final int _minDelay = 500; // Minimum delay in ms
  final int _maxDelay = 2000; // Maximum delay in ms

  // In-memory database for CRUD operations
  final List<NutritionistModel> _nutritionists = getMockNutritionists();
  final List<AdModel> _ads = _getMockAds();
  final List<ProductModel> _products = _getMockProducts();

  // Map to store user-specific products
  final Map<String, List<ProductModel>> _userProductsMap = {};

  // Helper method to simulate network delay
  Future<void> _simulateNetworkDelay() async {
    final delay = _minDelay + _random.nextInt(_maxDelay - _minDelay);
    await Future.delayed(Duration(milliseconds: delay));
  }

  // Helper method to randomly throw an error
  void _maybeThrowError() {
    if (_shouldSimulateErrors && _random.nextDouble() < _errorProbability) {
      throw Exception('Simulated API error');
    }
  }

  // NUTRITIONIST API

  /// Get all available nutritionists
  Future<List<NutritionistModel>> getNutritionists() async {
    await _simulateNetworkDelay();
    _maybeThrowError();

    // Return copy of list to prevent mutation
    return List.from(_nutritionists);
  }

  /// Get nutritionist by ID
  Future<NutritionistModel?> getNutritionistById(String id) async {
    await _simulateNetworkDelay();
    _maybeThrowError();

    return _nutritionists.firstWhere(
      (nutritionist) => nutritionist.id == id,
      orElse: () => throw Exception('Nutritionist not found'),
    );
  }

  /// Contact a nutritionist (just a simulation)
  Future<bool> contactNutritionist(String nutritionistId) async {
    await _simulateNetworkDelay();
    _maybeThrowError();

    // Simulate success (always returns true unless error is thrown)
    return true;
  }

  // AD API

  /// Get all active ads
  Future<List<AdModel>> getActiveAds() async {
    await _simulateNetworkDelay();
    _maybeThrowError();

    // Filter only active ads
    final activeAds = _ads.where((ad) => ad.isActive).toList();
    return List.from(activeAds);
  }

  /// Get ad by ID
  Future<AdModel?> getAdById(String id) async {
    await _simulateNetworkDelay();
    _maybeThrowError();

    return _ads.firstWhere(
      (ad) => ad.id == id,
      orElse: () => throw Exception('Ad not found'),
    );
  }

  // PRODUCT API

  // Spring Boot API base URL
  final String _baseUrl =
      'http://192.168.1.69:8080/API/Sahtech'; // Actual backend IP address
  // Alternative URLs for different environments:
  // final String _baseUrl = 'http://10.0.2.2:8080/API/Sahtech'; // Use 10.0.2.2 for Android emulator to connect to host machine's localhost
  // final String _baseUrl = 'http://localhost:8080/API/Sahtech'; // For web testing
  // final String _baseUrl = 'http://192.168.169.8080/API/Sahtech'; // Testing IP

  /// Get product by barcode from the Spring Boot backend
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      print('===== PRODUCT SCAN DEBUG =====');
      print('Starting product scan for barcode: $barcode');

      // Immediately clean and normalize the barcode
      String cleanBarcode = barcode.replaceAll(RegExp(r'\D'), '');
      cleanBarcode = cleanBarcode.replaceAll(RegExp(r'^0+'), '');

      // Try to parse as a number
      int? numericBarcode;
      try {
        numericBarcode = int.parse(cleanBarcode);
        cleanBarcode =
            numericBarcode.toString(); // Ensure it's properly formatted
        print('Using numeric barcode: $cleanBarcode');
      } catch (e) {
        print('Using string barcode: $cleanBarcode');
      }

      // Debugging the full URL being accessed
      final String checkUrl = '$_baseUrl/scan/check/$cleanBarcode';
      print('API URL (GET): $checkUrl');

      try {
        print('Testing connection to server...');
        final testResponse = await http.get(
          Uri.parse('$_baseUrl/health'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 2));

        print(
            'Server health check: ${testResponse.statusCode} - ${testResponse.body}');
      } catch (e) {
        print('Server health check failed: $e');
        print('Attempting to continue with product check anyway');
      }

      // Check if the product exists with a longer timeout
      final existsResponse = await http.get(
        Uri.parse(checkUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        print('Timeout when checking product - moving to fallback');
        throw Exception('Connection timeout');
      });

      print(
          'Product check response: ${existsResponse.statusCode} - ${existsResponse.body}');

      // Try both formats: barcode and codeBarre
      final alternativeCheckUrl =
          '$_baseUrl/scan/check?codeBarre=$cleanBarcode';
      print('Trying alternative URL (GET): $alternativeCheckUrl');
      final alternativeResponse = await http.get(
        Uri.parse(alternativeCheckUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      print(
          'Alternative check response: ${alternativeResponse.statusCode} - ${alternativeResponse.body}');

      // If product exists using either approach, fetch details
      if (existsResponse.statusCode == 200 ||
          alternativeResponse.statusCode == 200) {
        Map<String, dynamic>? data;
        bool productExists = false;

        // Try to parse the response from the primary check
        if (existsResponse.statusCode == 200) {
          try {
            data = json.decode(existsResponse.body);
            productExists = data?['exists'] == true;
            print('Primary check result: productExists=$productExists');
          } catch (e) {
            print('Error parsing primary check response: $e');
          }
        }

        // If primary check failed, try the alternative
        if (!productExists && alternativeResponse.statusCode == 200) {
          try {
            data = json.decode(alternativeResponse.body);
            productExists = data?['exists'] == true;
            print('Alternative check result: productExists=$productExists');
          } catch (e) {
            print('Error parsing alternative check response: $e');
          }
        }

        if (productExists) {
          print('Product exists! Fetching details...');

          // Try both endpoints for fetching product details
          final endpoints = [
            '$_baseUrl/scan/barcode/$cleanBarcode',
            '$_baseUrl/scan/product?codeBarre=$cleanBarcode',
          ];

          for (final url in endpoints) {
            try {
              print('Trying to fetch product details from: $url');
              final response = await http.get(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
              ).timeout(const Duration(seconds: 4));

              print('Product details response: ${response.statusCode}');

              if (response.statusCode == 200) {
                final productData = json.decode(response.body);
                print(
                    'Product data received: ${productData.toString().substring(0, min(100, productData.toString().length))}...');

                // Check if we got a valid product
                if (productData is Map<String, dynamic> &&
                    (productData.containsKey('name') ||
                        productData.containsKey('nom'))) {
                  print('Valid product data received');
                  return ProductModel.fromJson(productData);
                } else {
                  print('Invalid product data structure');
                }
              }
            } catch (e) {
              print('Error fetching from $url: $e');
            }
          }

          // Fallback for besbassa special case (temporary workaround)
          if (cleanBarcode == '6194000101027' ||
              barcode.contains('besbassa') ||
              barcode.toLowerCase().contains('water')) {
            print('Special case: Using hardcoded Besbassa water product');
            return ProductModel(
              id: 'besbassa123',
              name: 'Besbassa Natural Mineral Water',
              imageUrl:
                  'https://www.besbassawater.com/wp-content/uploads/2020/05/besbassa-500-ml.png',
              barcode: '6194000101027',
              brand: 'Besbassa',
              category: 'Boissons',
              nutritionFacts: {
                'calories': 0,
                'fat': 0.0,
                'carbs': 0.0,
                'protein': 0.0,
                'salt': 0.02,
              },
              ingredients: ['Natural Mineral Water'],
              allergens: [],
              healthScore: 4.5,
              scanDate: DateTime.now(),
            );
          }

          print(
              'Product exists according to check but could not fetch details');
        } else {
          print('Product not found in database according to both checks');
        }
      } else {
        print(
            'Error checking product: Primary=${existsResponse.statusCode}, Alternative=${alternativeResponse.statusCode}');
      }

      // If we reach here, we didn't get a valid product
      return null;
    } catch (e) {
      print('Exception in getProductByBarcode: $e');
      return null;
    } finally {
      print('===== END PRODUCT SCAN DEBUG =====');
    }
  }

  // Helper method to determine if we should use mock data
  // This allows easier testing without a live backend
  bool _shouldUseMockData() {
    // Set this to false in production, true for testing
    return false; // Disabling mock data to use only real products from database
  }

  /// Get personalized recommendation from Spring Boot backend
  /// which calls the FastAPI service with LLama/Groq
  Future<Map<String, dynamic>?> getPersonalizedRecommendation(
    String userId,
    String productId,
  ) async {
    try {
      print('Requesting AI recommendation via Spring Boot -> LLama/Groq');

      // Build the URL for recommendation request
      final String recommendationUrl =
          '$_baseUrl/recommendation/user/$userId/data?productId=$productId';

      // Make the request with a clear timeout
      final response = await http.get(
        Uri.parse(recommendationUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('AI recommendation received successfully');

        // Save the recommendation to history in the background
        _saveRecommendationToHistory(userId, productId, data);

        return data;
      } else {
        print('Failed to get AI recommendation: HTTP ${response.statusCode}');
        return _getFallbackRecommendation();
      }
    } catch (e) {
      print('Error requesting AI recommendation: $e');
      return _getFallbackRecommendation();
    }
  }

  // Simplified fallback recommendation when AI fails
  Map<String, dynamic> _getFallbackRecommendation() {
    return {
      'recommendation':
          'Ce produit n\'a pas encore été évalué par notre IA. Veuillez consulter la liste d\'ingrédients pour vous assurer qu\'il convient à votre régime alimentaire.',
      'recommendation_type': 'caution',
      'timestamp': DateTime.now().toIso8601String(),
      'isFallback': true
    };
  }

  // Helper method to save recommendations to user history
  Future<void> _saveRecommendationToHistory(String userId, String productId,
      Map<String, dynamic> recommendationData) async {
    try {
      print(
          'Saving recommendation to history for user: $userId, product: $productId');
      final String saveUrl = '$_baseUrl/recommendation/save';

      final Map<String, dynamic> payload = {
        'userId': userId,
        'productId': productId,
        'recommendation': recommendationData['recommendation'],
        'recommendationType':
            recommendationData['recommendation_type'] ?? 'caution',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse(saveUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Recommendation saved successfully');
      } else {
        print('Failed to save recommendation: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception saving recommendation: $e');
    }
  }

  /// Get all products for a user
  Future<List<ProductModel>> getUserProducts(String userId) async {
    await _simulateNetworkDelay();
    _maybeThrowError();

    // For new users or null/empty userIds, return an empty list
    if (userId.isEmpty || userId == 'new_user') {
      return [];
    }

    // For testing purposes: if the userId contains "empty", return empty list
    if (userId.contains("empty")) {
      return [];
    }

    // Check if user has scanned products in the user-specific map
    if (_userProductsMap.containsKey(userId)) {
      print(
          'Found ${_userProductsMap[userId]!.length} products for user $userId');
      return List.from(_userProductsMap[userId]!);
    }

    // Only return mock products for testing with specific userId patterns
    // This simulates that only certain users have scanned products
    if (userId == 'test_user' ||
        userId == 'existing_user' ||
        userId.contains('test')) {
      return List.from(_getExistingUserMockProducts());
    }

    // By default, return an empty list for all other users
    // This ensures new users start with zero products
    return [];
  }

  /// Scan a product by barcode
  Future<ProductModel?> scanProduct(String barcode, {String? userId}) async {
    // If no userId is provided, we can't associate the product with a user
    if (userId == null || userId.isEmpty) {
      print(
          'Warning: Scanning product without a userId. Product count won\'t be updated.');
    }

    // Always use the real API instead of random or mock data
    final apiProduct = await getProductByBarcode(barcode);

    if (apiProduct != null) {
      // Add to global products for consistency
      _products.add(apiProduct);

      // If we have a userId, add to user-specific products
      if (userId != null && userId.isNotEmpty) {
        // Make sure the user has a products list
        _userProductsMap.putIfAbsent(userId, () => []);
        _userProductsMap[userId]!.add(apiProduct);
        print(
            'Added product from API to user $userId\'s products. New count: ${_userProductsMap[userId]!.length}');
      }

      return apiProduct;
    } else {
      // If the product is not found in the API, return null
      print('Product not found in API: $barcode');
      return null;
    }
  }

  // Helper method to generate a random product
  ProductModel _generateRandomProduct(String barcode) {
    final id = 'p${_random.nextInt(10000)}';
    final categories = [
      'Produits laitiers',
      'Boulangerie',
      'Boissons',
      'Snacks',
      'Fruits et légumes'
    ];
    final brands = [
      'Nature Bio',
      'Délices Frais',
      'Saveurs Authentiques',
      'Bon Appétit',
      'Frutti Fresh'
    ];

    return ProductModel(
      id: id,
      name: 'Produit ${_random.nextInt(100)}',
      imageUrl: 'https://picsum.photos/200?random=${_random.nextInt(100)}',
      barcode: barcode,
      brand: brands[_random.nextInt(brands.length)],
      category: categories[_random.nextInt(categories.length)],
      nutritionFacts: {
        'calories': (50 + _random.nextInt(400)).toDouble(),
        'fat': _random.nextDouble() * 20,
        'carbs': _random.nextDouble() * 50,
        'protein': _random.nextDouble() * 20,
        'salt': _random.nextDouble() * 2,
      },
      ingredients: ['Ingrédient 1', 'Ingrédient 2', 'Ingrédient 3'],
      allergens: _random.nextBool() ? ['Gluten', 'Lait'] : [],
      healthScore: 1 + _random.nextDouble() * 4,
      scanDate: DateTime.now(),
    );
  }

  // MOCK DATA

  // Mock ads for testing
  static List<AdModel> _getMockAds() {
    return [
      AdModel(
        id: '1',
        companyName: 'Antiflex',
        imageUrl: 'https://picsum.photos/id/237/800/300',
        title: 'Soulager naturellement la douleur',
        description:
            'Un médicament naturel pour soulager les douleurs articulaires',
        link: 'https://example.com/antiflex',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: '2',
        companyName: 'Bio Nutrition',
        imageUrl: 'https://picsum.photos/id/292/800/300',
        title: 'Alimentation bio pour votre santé',
        description: 'Découvrez notre gamme de produits bio et naturels',
        link: 'https://example.com/bionutrition',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: '3',
        companyName: 'VitaPlus',
        imageUrl: 'https://picsum.photos/id/96/800/300',
        title: 'Renforcez votre système immunitaire',
        description: 'Complément alimentaire à base de plantes et vitamines',
        link: 'https://example.com/vitaplus',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: '4',
        companyName: 'Sport Nutrition',
        imageUrl: 'https://picsum.photos/id/342/800/300',
        title: 'Booste ta performance',
        description: 'Protéines et compléments pour sportifs',
        link: 'https://example.com/sportnutrition',
        isActive: false, // Inactive ad for testing
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  // Modified to return an empty list for new users by default
  static List<ProductModel> _getMockProducts() {
    // Return an empty list by default
    return [];
  }

  // Product list for existing users only
  static List<ProductModel> _getExistingUserMockProducts() {
    return [
      ProductModel(
        id: '1',
        name: 'Yaourt Nature',
        imageUrl: 'https://picsum.photos/200?random=1',
        barcode: '3033490004751',
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
        barcode: '3564700011439',
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
        barcode: '3057640385575',
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

  /// Get user health profile from Spring Boot backend
  Future<Map<String, dynamic>?> getUserHealthProfile(String userId) async {
    try {
      print('===== USER HEALTH PROFILE REQUEST =====');
      print('Fetching health profile for user: $userId');

      final String userUrl = '$_baseUrl/users/$userId/health-profile';
      print('Sending request to: $userUrl');

      final response = await http.get(
        Uri.parse(userUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      print('User profile response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('User health profile received successfully');
        return data;
      } else {
        print('Failed to get user health profile: HTTP ${response.statusCode}');
        print('Response body: ${response.body}');

        // Use mock data for testing
        if (_shouldUseMockData()) {
          print('Using mock user health profile as fallback');
          return _getMockUserHealthProfile(userId);
        }
        return null;
      }
    } catch (e) {
      print('Exception in getUserHealthProfile: $e');

      // Return mock data for testing
      if (_shouldUseMockData()) {
        print('Using mock user health profile due to exception');
        return _getMockUserHealthProfile(userId);
      }
      return null;
    } finally {
      print('===== END USER HEALTH PROFILE REQUEST =====');
    }
  }

  // Helper method to generate a mock user health profile for testing
  Map<String, dynamic> _getMockUserHealthProfile(String userId) {
    return {
      'userId': userId,
      'height': 170 + _random.nextInt(30),
      'weight': 60 + _random.nextInt(40),
      'allergies': _random.nextBool() ? ['Gluten', 'Lactose'] : [],
      'conditions': _random.nextBool() ? ['Diabète', 'Hypertension'] : [],
      'dietaryPreferences': _random.nextBool() ? ['Végétarien'] : [],
      'isMockData': true
    };
  }

  // Debug method to check if a barcode exists in the database
  Future<void> debugCheckBarcode(String barcode) async {
    try {
      final String checkUrl = '$_baseUrl/scan/check/$barcode';
      print('Debug - Sending check request to: $checkUrl');

      final existsResponse = await http.get(
        Uri.parse(checkUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        print('Debug - Timeout checking barcode');
        throw Exception('Connection timeout while checking barcode');
      });

      print('Debug - Check response status code: ${existsResponse.statusCode}');
      print('Debug - Check response body: ${existsResponse.body}');

      if (existsResponse.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(existsResponse.body);
          final bool productExists = data['exists'] == true;
          print('Debug - Product exists according to API: $productExists');

          if (productExists) {
            final String productUrl = '$_baseUrl/scan/barcode/$barcode';
            print('Debug - Product exists, would fetch from: $productUrl');
          }
        } catch (e) {
          print('Debug - Error parsing check response: $e');
        }
      }
    } catch (e) {
      print('Debug - Exception checking barcode: $e');
    }
  }
}
