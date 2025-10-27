import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/CustomWidgets/nutritionist_card.dart';
import 'package:sahtech/core/services/api_service.dart';
import 'package:sahtech/presentation/home/UserProfileSettings.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';

// Widget for displaying nutritionist cards in a vertical list
class VerticalNutritionistCard extends StatelessWidget {
  final NutritionisteModel nutritionist;
  final VoidCallback onCallTap;
  final VoidCallback onDetailsTap;

  const VerticalNutritionistCard({
    Key? key,
    required this.nutritionist,
    required this.onCallTap,
    required this.onDetailsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor image with margins
          Padding(
            padding: EdgeInsets.all(6.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                nutritionist.profileImageUrl ?? 'https://picsum.photos/200',
                width: 80.w,
                height: 98.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80.w,
                    height: 98.h,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 40.r,
                    ),
                  );
                },
              ),
            ),
          ),

          // Doctor info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '4.9',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),

                  // Name
                  Text(
                    nutritionist.name ?? 'Nutritionist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Specialization
                  Text(
                    nutritionist.specialite ?? 'Nutritionist',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Location with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red[400],
                        size: 12.sp,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          nutritionist.address ?? 'Location',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Buttons moved to the right side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Call button
                      InkWell(
                        onTap: onCallTap,
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Color(0x7D9FE870),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.phone,
                            color: Colors.black,
                            size: 14.sp,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Arrow button
                      InkWell(
                        onTap: onDetailsTap,
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Color(0x7D9FE870),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactNutri extends StatefulWidget {
  final UserModel? userData;

  const ContactNutri({Key? key, this.userData}) : super(key: key);

  @override
  State<ContactNutri> createState() => _ContactNutriState();
}

class _ContactNutriState extends State<ContactNutri> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<NutritionisteModel> _nutritionists = [];
  List<NutritionisteModel> _filteredNutritionists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNutritionists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNutritionists() async {
    setState(() => _isLoading = true);
    try {
      // Create empty list for now since we've removed the mock data
      final List<NutritionisteModel> nutritionists = [];

      if (mounted) {
        setState(() {
          _nutritionists = nutritionists;
          _filteredNutritionists = nutritionists;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading nutritionists: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Create empty list since we've removed the mock data
          _nutritionists = [];
          _filteredNutritionists = _nutritionists;
        });
      }
    }
  }

  void _filterNutritionists(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNutritionists = _nutritionists;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredNutritionists = _nutritionists.where((nutritionist) {
        return (nutritionist.name?.toLowerCase()?.contains(lowercaseQuery) ??
                false) ||
            (nutritionist.specialite?.toLowerCase()?.contains(lowercaseQuery) ??
                false);
      }).toList();
    });
  }

  void _callNutritionist(NutritionisteModel nutritionist) {
    // Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel à ${nutritionist.name}'),
        backgroundColor: AppColors.lightTeal,
      ),
    );
  }

  void _navigateToNutritionistDetails(NutritionisteModel nutritionist) {
    // Implement navigation to nutritionist details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de ${nutritionist.name}'),
        backgroundColor: AppColors.lightTeal,
      ),
    );
  }

  void _navigateToScanScreen() async {
    final storageService = StorageService();
    final hasRequested = await storageService.getCameraPermissionRequested();
    final status = await Permission.camera.status;

    print(
        'ContactNutri: Camera permission status: $status, previously requested: $hasRequested');

    if (status.isGranted) {
      // Permission already granted, go directly to scanner
      print(
          'ContactNutri: Camera permission already granted, navigating to scanner');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductScannerScreen(),
        ),
      );
    } else if (!hasRequested) {
      // First time requesting permission
      print('ContactNutri: First time requesting camera permission');
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
      print(
          'ContactNutri: Camera permission previously denied, showing settings message');
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

  void _navigateToProfile() {
    if (widget.userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileSettings(user: widget.userData!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Données utilisateur non disponibles'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Color(0x4D9FE870),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Historique des nutrsioniste contacté',
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
          // Light green top background
          Container(
            width: double.infinity,
            height: 20.h,
            color: Color(0x4D9FE870),
          ),

          // Search Box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _filterNutritionists,
                decoration: InputDecoration(
                  hintText: 'Chercher par le nom',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterNutritionists('');
                            setState(() {
                              _isSearching = false;
                            });
                            _searchFocusNode.unfocus();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
            ),
          ),

          // Nutritionist List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightTeal,
                    ),
                  )
                : _filteredNutritionists.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun nutritionniste trouvé',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: _filteredNutritionists.length,
                        itemBuilder: (context, index) {
                          final nutritionist = _filteredNutritionists[index];
                          return VerticalNutritionistCard(
                            nutritionist: nutritionist,
                            onCallTap: () => _callNutritionist(nutritionist),
                            onDetailsTap: () =>
                                _navigateToNutritionistDetails(nutritionist),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

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
              _buildNavItem(
                  0, Icons.home_outlined, Icons.home, 'Accueil', false),
              _buildNavItem(1, Icons.history_outlined, Icons.history,
                  'Historique', false),
              _buildScanButton(),
              _buildNavItem(
                  3, Icons.bookmark_outline, Icons.bookmark, 'Favoris', true),
              _buildNavItem(
                  4, Icons.person_outline, Icons.person, 'Profil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon,
      String label, bool isSelected) {
    return InkWell(
      onTap: () {
        // Don't do anything if the tab is already selected
        if (isSelected) return;

        if (index == 0) {
          // Navigate back to home - use popUntil to avoid stacking
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 1) {
          // Navigate to History
          Navigator.pushNamed(
            context,
            '/historique',
            arguments: widget.userData,
          );
        } else if (index == 4) {
          // Navigate to profile
          _navigateToProfile();
        } else if (index == 2) {
          // Navigate to scan screen
          _navigateToScanScreen();
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

  Widget _buildScanButton() {
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
