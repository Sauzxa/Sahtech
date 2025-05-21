import 'package:flutter/material.dart';
import '../../core/CustomWidgets/productRecoCard.dart';
import '../../core/services/mock_api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/models/product_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/models/user_model.dart';
import '../../core/services/storage_service.dart';
import 'ContactNutri.dart';
import 'UserProfileSettings.dart';

class HistoriqueScannedProducts extends StatefulWidget {
  final UserModel? userData;

  const HistoriqueScannedProducts({Key? key, this.userData}) : super(key: key);

  @override
  State<HistoriqueScannedProducts> createState() =>
      _HistoriqueScannedProductsState();
}

class _HistoriqueScannedProductsState extends State<HistoriqueScannedProducts> {
  // Controller for search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Navigation index
  int _currentIndex = 1; // History tab is selected

  // Mock API service instance
  final MockApiService _apiService = MockApiService();

  // Storage service for user authentication
  final StorageService _storageService = StorageService();

  // Data for products
  List<Map<String, dynamic>> _scannedProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  // Current user data
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    // Test API connection
    _testApiConnection();

    // Load products
    _loadProducts();

    // Set current user from widget if available
    if (widget.userData != null) {
      setState(() {
        _currentUser = widget.userData;
      });
      print(
          'Using userData from widget: ID=${widget.userData!.userId}, Type=${widget.userData!.userType}');
    } else {
      // Load user data from SharedPreferences if not passed
      _loadUserData();
    }

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProducts();
    });
  }

  // Add refresh method for when user returns to this screen
  void _refreshUserData() {
    _loadUserData();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_scannedProducts);
    } else {
      _filteredProducts = _scannedProducts
          .where((product) => product["produit"]["nom"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Fetch user's scanned products from backend
  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user ID from current user if available, otherwise from SharedPreferences
      String userId = _currentUser?.userId ?? '';

      // If userId is still empty, try to get it from SharedPreferences directly
      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('user_id') ?? '';
        print("Getting userId from SharedPreferences: $userId");
      }

      // If still no userId, use a default for testing
      if (userId.isEmpty) {
        userId =
            "6823359d013a9a33dabaafe0"; // Use the userId from the sample data
        print("Using default test userId: $userId");
      }

      print("===== DEBUG: LOADING PRODUCTS FROM NEW ENDPOINT =====");
      print("Fetching scanned products for user: $userId");

      // Using the new endpoint method in mock_api_service
      final products = await _apiService.getUserScannedProducts(userId);

      print("Products received: ${products.length}");
      if (products.isEmpty) {
        print("WARNING: Received empty products list");
      } else {
        print("First product ID: ${products.first["id"] ?? 'No ID found'}");
        print("First product data structure: ${products.first.keys.toList()}");
        print("Complete first product data: ${products.first}");
      }

      if (!mounted) return;

      setState(() {
        _scannedProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });

      print('Loaded ${products.length} products for user $userId');
    } catch (e) {
      print('Error loading products: $e');
      print(e.toString());

      if (!mounted) return;

      setState(() {
        // Clear any previous data and show error state
        _scannedProducts = [];
        _filteredProducts = [];
        _isLoading = false;
      });

      // In a real app, you might show a snackbar or other error UI here
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final userId = await _storageService.getUserId();
      final userType = await _storageService.getUserType();

      if (userId != null && userType != null) {
        setState(() {
          _currentUser = UserModel(
            userId: userId,
            userType: userType,
          );
        });
        print('Loaded user data: ID=$userId, Type=$userType');
      } else {
        print('Warning: Could not load user data from storage');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Test API connection by making a simple request
  Future<void> _testApiConnection() async {
    try {
      const String baseUrl =
          'http://192.168.1.69:8080/API/Sahtech'; // Same as in MockApiService
      final url = Uri.parse('$baseUrl/ping');
      print('Testing API connection to: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 5),
          onTimeout: () => http.Response('Timeout', 408));

      print('API test response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 408) {
        print(
            'WARNING: API connection timed out - check server status and IP address');
      } else if (response.statusCode != 200) {
        print(
            'WARNING: API returned non-200 status code: ${response.statusCode}');
      } else {
        print('API connection successful');
      }
    } catch (e) {
      print('ERROR: API connection test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F4E1), // Light green background
        elevation: 0,
        title: const Text(
          'Historique de scan :',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 24.0, // Add left spacing to move title to the left
        toolbarHeight: 65.0, // Increase height to add more top spacing

        centerTitle: false,
        automaticallyImplyLeading: false, // back button
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              color: Color(0xFFE6F4E1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  hintText: 'Chercher par le nom de produit scanné',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(5.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF9FE870),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.lightTeal,
                  ))
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_outlined,
                              size: 64.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Aucun produit scanné',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Scannez des produits pour les voir apparaître ici',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final productData = product["produit"];
                          final category =
                              productData["categorie"] ?? "Non classé";
                          final name = productData["nom"] ?? "Produit sans nom";
                          final imageUrl = productData["imageUrl"] ?? "";
                          final recommendationType =
                              product["recommendationType"];

                          print(
                              'Building product card for: $name, Category: $category, Recommendation: $recommendationType');

                          return ProductRecoCard(
                            imageUrl: imageUrl,
                            productName: name,
                            productType: category,
                            recommendationType: recommendationType,
                            onViewPressed: () {
                              // Navigate to recommendation page with this product data
                              print('Viewing product details for: $name');

                              // Create a ProductModel to pass to recommendation screen
                              final Map<String, dynamic> nutritionFacts = {
                                // Include nutriscore if available
                                'valeurNutriScore':
                                    productData["valeurNutriScore"],
                                // Include additives if available
                                'nomAdditif': productData["nomAdditif"],
                              };

                              final productModel = ProductModel(
                                id: productData["id"] ?? "",
                                name: name,
                                imageUrl: imageUrl,
                                brand: productData["marque"] ?? "",
                                category: category,
                                barcode: BigInt.tryParse(
                                        productData["codeBarre"]?.toString() ??
                                            "0") ??
                                    BigInt.zero,
                                nutritionFacts: nutritionFacts,
                                ingredients: _extractIngredients(
                                    productData["ingredients"]),
                                allergens: [], // Default empty list
                                healthScore: 0.0, // Default value
                                scanDate: product["dateScan"] != null
                                    ? DateTime.parse(product["dateScan"])
                                    : DateTime.now(),
                                aiRecommendation: product["recommandationIA"],
                                recommendationType:
                                    product["recommendationType"],
                              );

                              // Pass both product and user data to maintain session
                              Navigator.of(context).pushNamed(
                                '/recommendation',
                                arguments: {
                                  'product': productModel,
                                  'userData': _currentUser,
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      // Bottom navigation bar matching home_screen.dart
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Accueil'),
                _buildNavItem(
                    1, Icons.history_outlined, Icons.history, 'Historique'),
                _buildNavScanItem(),
                _buildNavItem(
                    3, Icons.bookmark_outline, Icons.bookmark, 'Favoris'),
                _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a navigation item
  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        if (index == 0) {
          // Navigate back to home screen with user data
          if (_currentUser != null) {
            print('Navigating to home with user ID: ${_currentUser!.userId}');
            Navigator.of(context)
                .pushReplacementNamed('/home', arguments: _currentUser);
          } else {
            // Fallback - try to get user data from storage directly
            _getUserDataAndNavigateHome();
          }
        } else if (index == 3) {
          // Contacts tab - Navigate to ContactNutri
          if (_currentUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactNutri(userData: _currentUser),
              ),
            );
          } else {
            // Show error if no user data available
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Données utilisateur non disponibles'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (index == 4) {
          // Profile tab - Navigate to UserProfileSettings
          if (_currentUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileSettings(user: _currentUser!),
              ),
            );
          } else {
            // Show error if no user data available
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Données utilisateur non disponibles'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.lightTeal : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.lightTeal : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get user data from storage and navigate to home
  Future<void> _getUserDataAndNavigateHome() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userType = prefs.getString('user_type');

      if (userId != null && userType != null) {
        final user = UserModel(
          userId: userId,
          userType: userType,
        );

        print(
            'Retrieved user data from SharedPreferences: ID=$userId, Type=$userType');
        Navigator.of(context).pushReplacementNamed('/home', arguments: user);
      } else {
        print('Warning: No user data available in SharedPreferences');
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('Error getting user data: $e');
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // Build the special scan button in the middle
  Widget _buildNavScanItem() {
    return GestureDetector(
      onTap: () {
        // Navigate to scanner with user data if available
        if (_currentUser != null) {
          Navigator.pushNamed(
            context,
            '/scanner',
            arguments: _currentUser,
          );
        } else {
          Navigator.pushNamed(context, '/scanner');
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: const BoxDecoration(
            color: AppColors.lightTeal,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 26.sp,
          ),
        ),
      ),
    );
  }

  // Add helper method to extract ingredients
  List<String> _extractIngredients(List<dynamic>? ingredientsList) {
    if (ingredientsList == null) return [];

    return ingredientsList.map((ingredient) {
      if (ingredient is Map<String, dynamic>) {
        final name = ingredient["nomIngrediant"] ?? "";
        final quantity = ingredient["quantite"] ?? "";
        return "$name: $quantity";
      }
      return ingredient.toString();
    }).toList();
  }
}
