import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritionist_model.dart';
import 'package:sahtech/core/utils/models/ad_model.dart';
import 'package:sahtech/core/services/mock_api_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:sahtech/presentation/scan/camera_access_screen.dart';
import 'package:sahtech/presentation/profile/UserProfileSettings.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:sahtech/core/CustomWidgets/nutritionist_card.dart';
import 'package:sahtech/presentation/home/ContactNutri.dart';
import 'package:sahtech/presentation/home/NutriDisponible.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userData;

  const HomeScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation index
  int _currentIndex = 0;

  // Data for the home screen
  List<NutritionistModel> _nutritionists = [];
  List<AdModel> _ads = [];
  int _scannedProductsCount = 0;
  bool _isLoading = true;

  // Mock API service
  final MockApiService _apiService = MockApiService();

  // Timer for periodic refresh
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Add more detailed logging for debugging
    print('HomeScreen initState - User ID: ${widget.userData.userId}');
    print('HomeScreen initState - User name: ${widget.userData.name}');

    // First fetch latest user data from the server
    _fetchLatestUserData().then((_) {
      // After user data is fetched, then load other data (products, nutritionists, etc.)
      _loadData();
    });

    // Set up periodic refresh every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _refreshAds();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Fetch the latest user data from MongoDB
  Future<void> _fetchLatestUserData() async {
    try {
      final AuthService authService = AuthService();

      // Get user ID from current user data
      final String? userId = widget.userData.userId;

      if (userId == null || userId.isEmpty) {
        print("Cannot fetch user data: User ID is null or empty");
        return;
      }

      print("HomeScreen: Fetching latest user data for ID: $userId");

      // Call the getUserData method to get fresh data from MongoDB
      final UserModel? updatedUser = await authService.getUserData(userId);

      if (updatedUser != null && mounted) {
        print("HomeScreen: Received updated user data from server");
        setState(() {
          // Update all relevant properties from the server response
          widget.userData.name = updatedUser.name;
          widget.userData.email = updatedUser.email;
          widget.userData.photoUrl = updatedUser.photoUrl;
          widget.userData.chronicConditions = updatedUser.chronicConditions;
          widget.userData.hasChronicDisease = updatedUser.hasChronicDisease;
          widget.userData.allergies = updatedUser.allergies;
          widget.userData.hasAllergies = updatedUser.hasAllergies;
          widget.userData.healthGoals = updatedUser.healthGoals;
          widget.userData.height = updatedUser.height;
          widget.userData.weight = updatedUser.weight;
          widget.userData.heightUnit = updatedUser.heightUnit;
          widget.userData.weightUnit = updatedUser.weightUnit;
          widget.userData.dateOfBirth = updatedUser.dateOfBirth;
          widget.userData.preferredLanguage = updatedUser.preferredLanguage;

          print("HomeScreen: User data refreshed: ${widget.userData.name}");
          print("HomeScreen: User email: ${widget.userData.email}");
          print(
              "HomeScreen: Chronic conditions: ${widget.userData.chronicConditions}");
        });
      } else {
        print(
            "HomeScreen: Failed to fetch updated user data or component unmounted");
      }
    } catch (e) {
      print("HomeScreen: Error fetching updated user data: $e");
    }
  }

  // Load all necessary data for the home screen
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load nutritionists from mock API
      final nutritionists = await _apiService.getNutritionists();

      // Load ads from mock API
      final ads = await _apiService.getActiveAds();

      // Get scanned products count - with enhanced error handling
      int productCount = 0;

      // Debug check for userId
      print('DEBUG: User ID for products check: ${widget.userData.userId}');

      if (widget.userData.userId != null &&
          widget.userData.userId!.isNotEmpty) {
        try {
          // Only try to get products if we have a valid userId
          final products =
              await _apiService.getUserProducts(widget.userData.userId!);
          productCount = products.length;

          // Debug print the products count
          print('DEBUG: Products loaded for user: $productCount');
        } catch (productError) {
          print('Error loading user products: $productError');
          // Continue with 0 products rather than failing the whole screen
        }
      } else {
        print('DEBUG: No userId or empty userId - no products loaded');
      }

      if (mounted) {
        setState(() {
          _nutritionists = nutritionists;
          _ads = ads;
          _scannedProductsCount = productCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading home screen data: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Refresh only ads
  Future<void> _refreshAds() async {
    try {
      final ads = await _apiService.getActiveAds();

      if (mounted) {
        setState(() {
          _ads = ads;
        });
      }

      // Show a short message that ads have been refreshed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Publicités actualisées'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.lightTeal,
          ),
        );
      }
    } catch (e) {
      print('Error refreshing ads: $e');

      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'actualisation des publicités'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to scan product screen
  Future<void> _navigateToScanScreen() async {
    final storageService = StorageService();
    final hasRequested = await storageService.getCameraPermissionRequested();
    final status = await Permission.camera.status;

    print(
        'Home: Camera permission status: $status, previously requested: $hasRequested');

    if (status.isGranted) {
      // Permission already granted, go directly to scanner
      print('Home: Camera permission already granted, navigating to scanner');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductScannerScreen(),
        ),
      ).then((_) {
        print('Returned from scan screen, refreshing data...');
        _loadData();
      });
    } else if (!hasRequested) {
      // First time requesting permission
      print('Home: First time requesting camera permission');
      final result = await Permission.camera.request();
      await storageService.setCameraPermissionRequested(true);

      if (result.isGranted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductScannerScreen(),
          ),
        ).then((_) {
          print('Returned from scan screen, refreshing data...');
          _loadData();
        });
      } else {
        // Permission denied, show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'L\'accès à la caméra est nécessaire pour scanner des produits.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Paramètres',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    } else {
      // Permission was previously denied
      print(
          'Home: Camera permission previously denied, showing settings message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Autorisation caméra requise. Ouvrez les paramètres pour l\'activer.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Paramètres',
            textColor: Colors.white,
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  // Call nutritionist
  void _callNutritionist(NutritionistModel nutritionist) {
    // Call the mock API
    _apiService.contactNutritionist(nutritionist.id).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Appel à ${nutritionist.name}'),
        backgroundColor: AppColors.lightTeal,
      ));
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'appel: $error'),
        backgroundColor: Colors.red,
      ));
    });
  }

  // Navigate to nutritionist details
  void _navigateToNutritionistDetails(NutritionistModel nutritionist) {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Détails de ${nutritionist.name}'),
      backgroundColor: AppColors.lightTeal,
    ));

    // TODO: Implement navigation to nutritionist details
  }

  // Open ad link
  void _openAdLink(AdModel ad) {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ouverture de la publicité: ${ad.title}'),
      backgroundColor: AppColors.lightTeal,
    ));

    // TODO: Implement ad link opening
  }

  // Build the app header with greeting and profile photo
  Widget _buildHeader() {
    // Format user name for greeting
    String userName = "Utilisateur";
    if (widget.userData.name != null && widget.userData.name!.isNotEmpty) {
      // Try to extract first name for greeting
      final nameParts = widget.userData.name!.split(' ');
      if (nameParts.isNotEmpty) {
        userName = nameParts.first;
      } else {
        userName = widget.userData.name!;
      }
    } else if (widget.userData.email != null &&
        widget.userData.email!.isNotEmpty) {
      // Use email as fallback
      final emailName = widget.userData.email!.split('@').first;
      userName = emailName;
    }

    // Log the user data for debugging
    print(
        'HomeScreen user data: ${widget.userData.userId}, ${widget.userData.name}, ${widget.userData.email}');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Salut $userName  ",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Comment allez-vous aujourd'hui?",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          // Profile image or placeholder
          GestureDetector(
            onTap: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileSettings(user: widget.userData),
                ),
              );

              // If returned with updated user data, refresh the UI
              if (updatedUser != null && updatedUser is UserModel) {
                setState(() {
                  // Update individual properties instead of the entire model
                  widget.userData.name = updatedUser.name;
                  widget.userData.email = updatedUser.email;
                  widget.userData.photoUrl = updatedUser.photoUrl;
                  widget.userData.chronicConditions =
                      updatedUser.chronicConditions;
                  widget.userData.hasChronicDisease =
                      updatedUser.hasChronicDisease;
                  widget.userData.allergies = updatedUser.allergies;
                  widget.userData.hasAllergies = updatedUser.hasAllergies;
                  widget.userData.healthGoals = updatedUser.healthGoals;
                  widget.userData.height = updatedUser.height;
                  widget.userData.weight = updatedUser.weight;
                });

                // Reload data to ensure everything is up to date
                _loadData();
              }
            },
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.grey[200],
              child: widget.userData.photoUrl != null &&
                      widget.userData.photoUrl!.isNotEmpty
                  ? Container(
                      width: 48.r,
                      height: 48.r,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.network(
                          widget.userData.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading profile image: $error');
                            return Icon(
                              Icons.person,
                              size: 30.r,
                              color: Colors.grey[600],
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.lightTeal,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 30.r,
                      color: Colors.grey[600],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
              },
              color: AppColors.lightTeal,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and profile section
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Sahtech Logo - centered and bigger
                            Image.asset(
                              'lib/assets/images/mainlogo.jpg',
                              height: 40.h,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),

                      // Welcome message - single profile pic with bigger text
                      _buildHeader(),
                      SizedBox(height: 28.h),

                      // Scanner card - UPDATED TO MATCH DESIGN EXACTLY
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: GestureDetector(
                          onTap: _navigateToScanScreen,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 32.w, vertical: 24.h),
                            decoration: BoxDecoration(
                              color:
                                  Color(0x4D9FE870), // 9FE870 with 30% opacity
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Scanner un produit',
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        '$_scannedProductsCount produit${_scannedProductsCount > 1 ? 's' : ''} scanné${_scannedProductsCount > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color:
                                              Color(0xFF82A6B0), // 82A6B0 color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    color: Color(
                                        0xB39FE870), // 9FE870 with 70% opacity
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.crop_free,
                                    color: Colors.black87,
                                    size: 30.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Nutritionists section
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.03),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3, // Takes 3/4 of the available space
                              child: Text(
                                'Consulter des nutritionnistes',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1, // Takes 1/4 of the available space
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NutriDisponible(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Voir tous',
                                  textAlign:
                                      TextAlign.end, // Aligns text to the right
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9FE870),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Nutritionist cards (horizontal scroll)
                      SizedBox(
                        height: 125
                            .h, // Slightly increased height to prevent overflow
                        child: _nutritionists.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucun nutritionniste disponible',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                itemCount: _nutritionists.length,
                                itemBuilder: (context, index) {
                                  final nutritionist = _nutritionists[index];
                                  return NutritionistCard(
                                    nutritionist: nutritionist,
                                    onCallTap: () =>
                                        _callNutritionist(nutritionist),
                                    onDetailsTap: () =>
                                        _navigateToNutritionistDetails(
                                            nutritionist),
                                  );
                                },
                              ),
                      ),

                      SizedBox(height: 24.h),

                      // Ads section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Publicité exclusives',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Ads (horizontal scroll)
                      SizedBox(
                        height: 130.h,
                        child: _ads.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucune publicité disponible',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                itemCount: _ads.length,
                                itemBuilder: (context, index) {
                                  final ad = _ads[index];
                                  return GestureDetector(
                                    onTap: () => _openAdLink(ad),
                                    child: Container(
                                      width: 280.w,
                                      margin: EdgeInsets.only(right: 16.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        image: DecorationImage(
                                          image: NetworkImage(ad.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      SizedBox(
                          height:
                              70.h), // Extra space for bottom navigation bar
                    ],
                  ),
                ),
              ),
            ),

      // Enhanced Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, -5),
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
      onTap: () async {
        if (index == 4) {
          // Profile tab
          // Navigate to profile settings
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileSettings(user: widget.userData),
            ),
          );

          // When returning from profile, refresh data in case it was updated
          _fetchLatestUserData();
        } else if (index == 3) {
          // Contacts tab
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactNutri(userData: widget.userData),
            ),
          );
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
      onTap: _navigateToScanScreen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
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
