import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:sahtech/presentation/home/ContactNutri.dart';
import 'package:sahtech/presentation/home/UserProfileSettings.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sahtech/presentation/home/HistoriqueScannedProducts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NutriDisponible extends StatefulWidget {
  const NutriDisponible({Key? key}) : super(key: key);

  @override
  State<NutriDisponible> createState() => _NutriDisponibleState();
}

class _NutriDisponibleState extends State<NutriDisponible> {
  List<NutritionisteModel> _nutritionists = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNutritionists();
  }

  // Load nutritionists from API
  Future<void> _loadNutritionists() async {
    setState(() => _isLoading = true);

    try {
      // Get the authentication token
      final StorageService storageService = StorageService();
      final String? token = await storageService.getToken();

      print(
          'Fetching nutritionists with auth token: ${token != null ? 'Yes (length: ${token.length})' : 'No token available'}');

      final response = await http.get(
        Uri.parse('http://192.168.137.187:8080/API/Sahtech/Nutrisionistes/All'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Nutritionists API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> nutritionistsJson = json.decode(response.body);
        final nutritionists = nutritionistsJson
            .map((json) => NutritionisteModel.fromMap(json))
            .toList();

        if (mounted) {
          setState(() {
            _nutritionists = nutritionists;
            _isLoading = false;
          });
        }
      } else {
        print('Error fetching nutritionists: ${response.statusCode}');
        print('Error response body: ${response.body}');

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement des nutritionnistes'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Exception when fetching nutritionists: $e');

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des nutritionnistes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        print('Launched phone dialer with number: $formattedNumber');

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
        print('Could not launch phone dialer: $phoneUri');
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'appel: $e'),
        backgroundColor: Colors.red,
      ));
      print('Error launching phone dialer: $e');
    }
  }

  // Navigate to nutritionist details
  void _navigateToNutritionistDetails(NutritionisteModel nutritionist) {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Détails de ${nutritionist.name}'),
      backgroundColor: AppColors.lightTeal,
    ));
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
      );
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
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFE4), // Light green background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'nutritionnistes disponible :',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Green header section (already part of the app bar background)
          SizedBox(height: 30.h),

          // Main content with nutritionist cards
          Expanded(
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: AppColors.lightTeal))
                : RefreshIndicator(
                    onRefresh: _loadNutritionists,
                    color: AppColors.lightTeal,
                    child: _nutritionists.isEmpty
                        ? Center(
                            child: Text(
                              'Aucun nutritionniste disponible',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w,
                                80.h), // Added extra bottom padding
                            itemCount: _nutritionists.length,
                            itemBuilder: (context, index) {
                              final nutritionist = _nutritionists[index];
                              return _buildNutritionistCard(nutritionist);
                            },
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build a vertical nutritionist card
  Widget _buildNutritionistCard(NutritionisteModel nutritionist) {
    // Generate a random rating between 4.5 and 5.0
    final rating = (45 + (nutritionist.id.hashCode % 5)) / 10;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r), // Increased border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                nutritionist.photoUrl ??
                    nutritionist.profileImageUrl ??
                    'https://picsum.photos/200',
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading nutritionist image: $error');
                  return Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 30.r,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),

            // Nutritionist info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name with rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          nutritionist.name ?? 'Nutritionniste',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '$rating',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Specialization
                  Text(
                    nutritionist.specialite ?? 'Nutritionniste',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red[400],
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          nutritionist.cabinetAddress ??
                              nutritionist.address ??
                              'Location',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Action buttons - side by side
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Call button
                InkWell(
                  onTap: () => _callNutritionist(nutritionist),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFF9FE870),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Bookmark button
                InkWell(
                  onTap: () => _navigateToNutritionistDetails(nutritionist),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF9FE870),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.bookmark_outline,
                      color: Color(0xFF9FE870),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
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
                  3, Icons.bookmark_outline, Icons.bookmark, 'Favoris',
                  isActive: true),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  // Build a navigation item
  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label,
      {bool isActive = false}) {
    return InkWell(
      onTap: () {
        if (index == 0) {
          // Home tab - Navigate back to home
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 1) {
          // History tab - Navigate to HistoriqueScannedProducts
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HistoriqueScannedProducts(),
            ),
          );
        } else if (index == 3) {
          // Favorites tab - Already on this screen
          // Do nothing as we're already here
        } else if (index == 4) {
          // Profile tab - Navigate to UserProfileSettings
          // Since we don't have userData here, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Profil utilisateur - Besoin de données utilisateur'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Color(0xFF9FE870) : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Color(0xFF9FE870) : Colors.grey,
            ),
          ),
        ],
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
            color: Color(0xFF9FE870), // Use the same green color
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
