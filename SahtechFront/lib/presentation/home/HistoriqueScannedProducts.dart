import 'package:flutter/material.dart';
import '../../core/CustomWidgets/productRecoCard.dart';
import '../../core/services/mock_api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/models/product_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/colors.dart';

class HistoriqueScannedProducts extends StatefulWidget {
  const HistoriqueScannedProducts({Key? key}) : super(key: key);

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

  // Data for products
  List<Map<String, dynamic>> _scannedProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load products
    _loadProducts();

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

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_scannedProducts);
    } else {
      _filteredProducts = _scannedProducts
          .where((product) => product["productName"]
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
      // For testing purposes, using a hardcoded user ID
      // In a real app, this would come from authentication
      String userId = "test_user"; // Replace with actual user ID from auth

      print("===== DEBUG: LOADING PRODUCTS FROM NEW ENDPOINT =====");
      print("Fetching scanned products for user: $userId");

      // Using the new endpoint method in mock_api_service
      final products = await _apiService.getUserScannedProducts(userId);

      print("Products received: ${products.length}");
      if (products.isEmpty) {
        print("WARNING: Received empty products list");
      } else {
        print("First product: ${products.first["productName"]}");
        print("Sample product image URL: ${products.first["productImageUrl"]}");

        // Check if all required fields are present in the first product
        final firstProduct = products.first;
        final requiredFields = [
          "productId",
          "productName",
          "productImageUrl",
          "category"
        ];
        for (final field in requiredFields) {
          print("Field '$field' exists: ${firstProduct.containsKey(field)}");
          print("Field '$field' value: ${firstProduct[field]}");
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F4E1), // Light green background
        elevation: 0,
        title: Container(
          margin: EdgeInsets.only(top: 25.h),
          child: const Text(
            'Historique de scan',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true, //  back button
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              color: Color(0xFFE6F4E1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(top: 20.h),
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
                      color: AppColors.lightTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20.sp,
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
                          print(
                              'Building product card for: ${product["productName"]}');

                          return ProductRecoCard(
                            imageUrl: product["productImageUrl"],
                            productName: product["productName"],
                            productType: product["category"] ?? "Non classé",
                            onViewPressed: () {
                              // Create a simple product model to pass to recommendation screen
                              print(
                                  'Viewing product details for: ${product["productName"]}');
                              final productModel = ProductModel(
                                id: product["productId"] ?? "",
                                name: product["productName"],
                                imageUrl: product["productImageUrl"],
                                brand: product["brand"] ?? "",
                                category: product["category"] ?? "Non classé",
                                barcode: BigInt.parse("0"), // Default value
                                nutritionFacts: {}, // Empty map for required parameter
                                ingredients: [], // Empty list for required parameter
                                allergens: [], // Empty list for required parameter
                                healthScore: 0.0, // Default value
                                scanDate: product["scanDate"] != null
                                    ? DateTime.parse(product["scanDate"])
                                    : DateTime.now(),
                              );

                              Navigator.of(context).pushNamed(
                                '/recommendation',
                                arguments: productModel,
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
                    3, Icons.contacts_outlined, Icons.contacts, 'Contacts'),
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
          // Navigate back to home screen
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (index == 3) {
          // Contacts tab
          // TODO: Implement navigation to contacts
        } else if (index == 4) {
          // Profile tab
          // TODO: Implement navigation to profile
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

  // Build the special scan button in the middle
  Widget _buildNavScanItem() {
    return GestureDetector(
      onTap: () {
        // Navigate to scanner
        Navigator.pushNamed(context, '/scanner');
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
}
