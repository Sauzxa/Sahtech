import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/utils/models/ad_model.dart';
import 'package:sahtech/core/services/api_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahtech/presentation/scan/camera_access_screen.dart';
import 'package:sahtech/presentation/home/UserProfileSettings.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:sahtech/core/CustomWidgets/nutritionist_card.dart';
import 'package:sahtech/presentation/home/ContactNutri.dart';
import 'package:sahtech/presentation/home/NutriDisponible.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<NutritionisteModel> _nutritionists = [];
  List<AdModel> _ads = [];
  int _scannedProductsCount = 0;
  bool _isLoading = true;

  // API service
  final ApiService _apiService = ApiService();

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
      // Load nutritionists using the MockApiService (which will try server and fall back to cache/mock)
      List<NutritionisteModel> nutritionists = [];
      try {
        nutritionists = await _apiService.getNutritionists();
      } catch (e) {
        print('Exception when fetching nutritionists via service: $e');
        nutritionists = await _apiService.getNutritionists();
      }

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

    if (status.isGranted) {
      // Permission already granted, go directly to scanner

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductScannerScreen(),
        ),
      ).then((_) {
        _loadData();
      });
    } else if (!hasRequested) {
      // First time requesting permission

      final result = await Permission.camera.request();
      await storageService.setCameraPermissionRequested(true);

      if (result.isGranted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductScannerScreen(),
          ),
        ).then((_) {
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
  void _callNutritionist(NutritionisteModel nutritionist) async {
    // Get the phone number from the nutritionist model
    String? phoneNumber;

    // Try to get phone number from different possible fields
    if (nutritionist.phoneNumber != null &&
        nutritionist.phoneNumber!.isNotEmpty) {
      phoneNumber = nutritionist.phoneNumber;
    } else if (nutritionist.numTelephone != null) {
      // Convert integer to string if needed
      phoneNumber = nutritionist.numTelephone.toString();
    }

    if (phoneNumber == null || phoneNumber.isEmpty) {
      // Show error message if no phone number is available
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Numéro de téléphone non disponible'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Format the phone number for dialing
    String formattedNumber = phoneNumber;
    if (!formattedNumber.startsWith('+')) {
      // Add country code if not present
      formattedNumber = '+213$formattedNumber';
    }

    // Create the URI for launching the phone dialer
    final Uri phoneUri = Uri(scheme: 'tel', path: formattedNumber);

    try {
      // Try to launch the phone dialer
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appel à ${nutritionist.name}'),
          backgroundColor: AppColors.lightTeal,
        ));
      } else {
        // If dialer can't be launched, show a message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Impossible d\'ouvrir l\'application téléphone'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'appel: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Navigate to nutritionist details
  void _navigateToNutritionistDetails(NutritionisteModel nutritionist) {
    // Use nutritionist.userId or nutritionist.id directly when needed
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Détails de ${nutritionist.name}'),
      backgroundColor: AppColors.lightTeal,
    ));

    // TODO: Implement navigation to nutritionist details (use nutritionist.userId ?? nutritionist.id)
  }

  // Open ad link
  void _openAdLink(AdModel ad) async {
    try {
      // Check if we have a valid link
      if (ad.link.isNotEmpty) {
        // Prepare URL - ensure it has a scheme
        String url = ad.link;
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }

        // Parse the URL
        final Uri uri = Uri.parse(url);

        // Try to launch the URL
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('Opened ad link: $url');
        } else {
          // If link can't be opened, show a message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Impossible d\'ouvrir le lien: ${ad.title}'),
            backgroundColor: Colors.red,
          ));
          print('Could not launch URL: $url');
        }
      } else {
        // If no link is available, just show the ad title
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Publicité: ${ad.title}'),
          backgroundColor: AppColors.lightTeal,
        ));
        print('No link available for ad: ${ad.title}');
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'ouverture du lien: $e'),
        backgroundColor: Colors.red,
      ));
      print('Error opening ad link: $e');
    }
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
                                      ),
                                      child: Stack(
                                        children: [
                                          // Ad image with error handling
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                            child: Image.network(
                                              ad.imageUrl,
                                              width: 280.w,
                                              height: 130.h,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'Error loading ad image: $error');
                                                return Container(
                                                  width: 280.w,
                                                  height: 130.h,
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 40.sp,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  width: 280.w,
                                                  height: 130.h,
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          AppColors.lightTeal,
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          // Title overlay at the bottom
                                          if (ad.title.isNotEmpty)
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8.h,
                                                  horizontal: 12.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(16.r),
                                                    bottomRight:
                                                        Radius.circular(16.r),
                                                  ),
                                                ),
                                                child: Text(
                                                  ad.title,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                        ],
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
      onTap: () async {
        if (index == 4) {
          // Profile tab
          // Navigate to profile settings
          await Navigator.push(
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
        } else if (index == 1) {
          // History tab - Navigate to HistoriqueScannedProducts with user data
          Navigator.pushNamed(
            context,
            '/historique',
            arguments: widget.userData,
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
