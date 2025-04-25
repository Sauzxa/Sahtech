import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritionist_model.dart';
import 'package:sahtech/core/CustomWidgets/nutritionist_card.dart';
import 'package:sahtech/core/services/mock_api_service.dart';
import 'package:sahtech/presentation/profile/UserProfileSettings.dart';
import 'package:sahtech/presentation/scan/camera_access_screen.dart';
import 'package:sahtech/core/utils/models/user_model.dart';

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
  List<NutritionistModel> _nutritionists = [];
  List<NutritionistModel> _filteredNutritionists = [];
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
      // For initial implementation, use mock data
      final MockApiService apiService = MockApiService();
      final nutritionists = await apiService.getNutritionists();

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
          // Fallback to mock data if API fails
          _nutritionists = getMockNutritionists();
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
        return nutritionist.name.toLowerCase().contains(lowercaseQuery) ||
            nutritionist.specialization.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  void _callNutritionist(NutritionistModel nutritionist) {
    // Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel à ${nutritionist.name}'),
        backgroundColor: AppColors.lightTeal,
      ),
    );
  }

  void _navigateToNutritionistDetails(NutritionistModel nutritionist) {
    // Implement navigation to nutritionist details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de ${nutritionist.name}'),
        backgroundColor: AppColors.lightTeal,
      ),
    );
  }

  void _navigateToScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraAccessScreen(),
      ),
    );
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
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: Column(
                          children: _filteredNutritionists.map((nutritionist) {
                            return _buildNutritionistListItem(nutritionist);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildNutritionistListItem(NutritionistModel nutritionist) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nutritionist Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              nutritionist.profileImageUrl,
              width: 60.w,
              height: 60.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60.w,
                  height: 60.h,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey.shade400,
                    size: 30.r,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),

          // Nutritionist Info and Buttons
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Nutritionist Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nutritionist.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                nutritionist.rating.toString(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Specialization
                      Text(
                        nutritionist.specialization,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red.shade400,
                            size: 12.sp,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              nutritionist.location,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
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

                // Buttons Container for right alignment
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 20.h), // Push buttons to bottom
                    Row(
                      children: [
                        // Call Button
                        Container(
                          margin: EdgeInsets.only(right: 8.w),
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Color(0xAAB3F492),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.phone,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                            onPressed: () => _callNutritionist(nutritionist),
                            padding: EdgeInsets.zero,
                          ),
                        ),

                        // Details Button - Arrow
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Color(0xAAB3F492),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                            onPressed: () =>
                                _navigateToNutritionistDetails(nutritionist),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
                  3, Icons.contacts_outlined, Icons.contacts, 'Contacts', true),
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
        if (index == 0) {
          // Navigate back to home
          Navigator.pop(context);
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
