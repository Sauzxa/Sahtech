import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/utils/models/nutritionist_model.dart';
import 'package:sahtech/core/utils/models/ad_model.dart';
import 'package:sahtech/core/utils/models/product_model.dart';
import 'package:sahtech/core/services/api_error_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

      // Use the ApiErrorHandler to normalize the barcode first
      String cleanBarcode = ApiErrorHandler.normalizeBarcode(barcode);
      print('Using normalized barcode: $cleanBarcode');

      // Check internet connectivity first before making any API calls
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection available');
        return null;
      }

      // Single unified endpoint for all product requests
      final String productUrl = '$_baseUrl/scan/barcode/$cleanBarcode';
      print('Fetching product data from: $productUrl');

      try {
        // Make a single request with adequate timeout
        final response = await http.get(
          Uri.parse(productUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 6));

        print('Product API response: ${response.statusCode}');

        if (ApiErrorHandler.isValidProductResponse(response)) {
          final productData = json.decode(response.body);
          print('Product data received successfully');

          // Ensure barcode field is always set in the product data
          if (!productData.containsKey('barcode')) {
            productData['barcode'] = cleanBarcode;
          }

          return ProductModel.fromJson(productData);
        } else {
          print('Invalid product response: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching product: $e');
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
        return null; // Return null instead of fallback to ensure only real AI recommendations are used
      }
    } catch (e) {
      print('Error requesting AI recommendation: $e');
      return null; // Return null instead of fallback
    }
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
