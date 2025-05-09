import 'dart:async';
import 'dart:math';
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
    await _simulateNetworkDelay();
    _maybeThrowError();

    // If no userId is provided, we can't associate the product with a user
    if (userId == null || userId.isEmpty) {
      print(
          'Warning: Scanning product without a userId. Product count won\'t be updated.');
    }

    // Check if the product already exists
    ProductModel? existingProduct;
    try {
      // First check global products
      existingProduct = _products.firstWhere(
        (product) => product.barcode == barcode,
      );
    } catch (e) {
      // Product not found in global products
      existingProduct = null;
    }

    // If we have a userId, check user-specific products
    if (userId != null && userId.isNotEmpty) {
      // Make sure the user has a products list
      _userProductsMap.putIfAbsent(userId, () => []);

      // Check if the user already has this product
      try {
        existingProduct = _userProductsMap[userId]!.firstWhere(
          (product) => product.barcode == barcode,
        );
      } catch (e) {
        // User doesn't have this product yet
      }
    }

    // If the product doesn't exist anywhere, create a new one
    if (existingProduct == null) {
      final newProduct = _generateRandomProduct(barcode);

      // Add to global products for consistency
      _products.add(newProduct);

      // If we have a userId, add to user-specific products
      if (userId != null && userId.isNotEmpty) {
        _userProductsMap[userId]!.add(newProduct);
        print(
            'Added new product to user $userId\'s products. New count: ${_userProductsMap[userId]!.length}');
      }

      return newProduct;
    }

    return existingProduct;
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
}
