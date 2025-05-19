import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/auth/ChangePassword.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritionist_model.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/presentation/home/home_screen.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sahtech/presentation/profile/EditUserData.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/home/ContactNutri.dart';
import 'package:sahtech/core/auth/SigninUser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/core/services/storage_service.dart';

class UserProfileSettings extends StatefulWidget {
  final UserModel user;

  const UserProfileSettings({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  bool isDarkMode = true;
  int _currentIndex = 4; // Profile is selected by default

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData: widget.user),
        ),
      );
    } else if (index == 2) {
      // Navigate to Scan with permission checking
      _navigateToScanScreen();
    } else if (index == 3) {
      // Navigate to Contacts
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactNutri(userData: widget.user),
        ),
      );
    } else {
      // For other screens that may not be implemented yet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation to index $index not implemented yet'),
          backgroundColor: AppColors.lightTeal,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fetch latest user data from MongoDB
  Future<void> _fetchLatestUserData() async {
    try {
      final AuthService authService = AuthService();

      // Get user ID from current user data
      final String? userId = widget.user.userId;

      if (userId == null) {
        print("Cannot fetch user data: User ID is null");
        return;
      }

      print("Fetching latest user data for ID: $userId");

      // Call the getUserData method to get fresh data from MongoDB
      final UserModel? updatedUser = await authService.getUserData(userId);

      if (updatedUser != null && mounted) {
        print("Received fresh user data from server");
        print("Server returned profile image URL: ${updatedUser.photoUrl}");

        setState(() {
          // Update the local user data with the latest from the server
          widget.user.name = updatedUser.name;
          widget.user.email = updatedUser.email;
          widget.user.chronicConditions = updatedUser.chronicConditions;
          widget.user.hasChronicDisease = updatedUser.hasChronicDisease;
          widget.user.allergies = updatedUser.allergies;
          widget.user.hasAllergies = updatedUser.hasAllergies;
          widget.user.healthGoals = updatedUser.healthGoals;
          widget.user.height = updatedUser.height;
          widget.user.weight = updatedUser.weight;
          widget.user.preferredLanguage = updatedUser.preferredLanguage;

          // Explicitly update the profile image URL
          if (updatedUser.photoUrl != null) {
            widget.user.photoUrl = updatedUser.photoUrl;
            print("Updated profile image URL: ${widget.user.photoUrl}");
          }

          print("User data refreshed: ${widget.user.name}");
        });
      } else {
        print("Failed to fetch updated user data or component unmounted");
      }
    } catch (e) {
      print("Error fetching updated user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the latest user data when the screen loads
    _fetchLatestUserData();
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserData(user: widget.user),
      ),
    );

    // If returned with updated user data, refresh the UI
    if (result != null && result is UserModel) {
      setState(() {
        // Update user data with the returned model
        widget.user.name = result.name;
        widget.user.email = result.email;
        widget.user.chronicConditions = result.chronicConditions;
        widget.user.hasChronicDisease = result.hasChronicDisease;
        widget.user.allergies = result.allergies;
        widget.user.hasAllergies = result.hasAllergies;
        widget.user.healthGoals = result.healthGoals;
        widget.user.height = result.height;
        widget.user.weight = result.weight;
        widget.user.preferredLanguage = result.preferredLanguage;

        // Explicitly set the profile image URL
        if (result.photoUrl != null) {
          widget.user.photoUrl = result.photoUrl;
        }
      });

      // No need to call fetchLatestUserData since we already have updated data
    }
  }

  // New method for navigating to scan screen with permission handling
  Future<void> _navigateToScanScreen() async {
    final storageService = StorageService();
    final hasRequested = await storageService.getCameraPermissionRequested();
    final status = await Permission.camera.status;

    print(
        'UserProfile: Camera permission status: $status, previously requested: $hasRequested');

    if (status.isGranted) {
      // Permission already granted, go directly to scanner
      print(
          'UserProfile: Camera permission already granted, navigating to scanner');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductScannerScreen(),
        ),
      ).then((_) {
        // Refresh user data when returning from scan
        _fetchLatestUserData();
      });
    } else if (!hasRequested) {
      // First time requesting permission
      print('UserProfile: First time requesting camera permission');
      final result = await Permission.camera.request();
      await storageService.setCameraPermissionRequested(true);

      if (result.isGranted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductScannerScreen(),
          ),
        ).then((_) {
          // Refresh user data when returning from scan
          _fetchLatestUserData();
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
          'UserProfile: Camera permission previously denied, showing settings message');
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
    final translationService = Provider.of<TranslationService>(context);
    final isRTL = translationService.currentLanguageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top green background (1/4 of screen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Container(
              color: Color.fromARGB(255, 189, 232, 163),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add extra top padding to center content better
                    SizedBox(height: 40.h),

                    // Profile Title
                    Center(
                      child: Text(
                        'Mon Profile',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // User Profile Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Profile Image with error handling
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: widget.user.photoUrl != null &&
                                    widget.user.photoUrl!.isNotEmpty
                                ? NetworkImage(
                                    // Add a cache-busting parameter to force refresh when needed
                                    widget.user.photoUrl! +
                                        '?t=${DateTime.now().millisecondsSinceEpoch}',
                                  )
                                : null,
                            // Only provide error handler when backgroundImage is not null
                            onBackgroundImageError: widget.user.photoUrl !=
                                        null &&
                                    widget.user.photoUrl!.isNotEmpty
                                ? (exception, stackTrace) {
                                    print(
                                        'Error loading profile image: $exception');
                                    print('Image URL: ${widget.user.photoUrl}');
                                  }
                                : null,
                            child: widget.user.photoUrl == null ||
                                    widget.user.photoUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 24.r,
                                    color: Colors.grey.shade500,
                                  )
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.name ?? 'UserName',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Numero de compte: ${widget.user.userId ?? '029883614373'}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit Button - Exact match with Figma design
                          InkWell(
                            onTap: _navigateToEditProfile,
                            child: Container(
                              width: 36.r,
                              height: 36.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18.r,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Other Parameters Section
                    Text(
                      'Autres Parametres',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Settings Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Display Mode
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  height: 24.r,
                                  width: 24.r,
                                  child: Icon(Icons.dark_mode_outlined,
                                      size: 20.r, color: Colors.black87),
                                ),
                                SizedBox(width: 16.w),
                                Text(
                                  'Mode d\'affichage',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Spacer(),
                                Switch(
                                  value: isDarkMode,
                                  onChanged: (value) {
                                    setState(() {
                                      isDarkMode = value;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor: AppColors.lightTeal,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey.shade300,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade200),

                          // Change Language
                          _buildSettingItem(
                            icon: Icons.language_outlined,
                            title: 'Changer la langue',
                            onTap: () {
                              // Show language selection dialog
                              _showLanguageSelectionDialog();
                            },
                          ),
                          Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade200),

                          // About Us
                          _buildSettingItem(
                            icon: Icons.info_outline,
                            title: 'Qui somme nous',
                            onTap: () {
                              _launchUrl('https://sahtech-website.vercel.app/');
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Security section containers as shown in Figma
                    // Change Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildSettingItem(
                        icon: Icons.lock_outline,
                        title: 'changer mot de passe',
                        onTap: () {
                          // Navigate to change password
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePassword(),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Support
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildSettingItem(
                        icon: Icons.support_agent_outlined,
                        title: 'Support',
                        onTap: () {
                          _launchUrl('https://sahtech-website.vercel.app/');
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Logout - Red color text and icon as shown in Figma
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Se deconnecter',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          // Show confirmation dialog based on Figma design
                          showLogoutConfirmationDialog();
                        },
                      ),
                    ),

                    // Add some space at the bottom for better padding
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom navigation bar consistent with HomeScreen
      bottomNavigationBar: Container(
        height: 70.h,
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
            padding: EdgeInsets.symmetric(horizontal: 8.w),
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

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LanguageSelectorDialog(
          onLanguageChanged: (languageCode) {
            // Update UI after language change
            setState(() {});
          },
        );
      },
    );
  }

  // Updated logout confirmation dialog to match Figma design
  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.h),
                // Icon in exact match with Figma
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 30.r,
                    color: AppColors.lightTeal,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Vous allez vous déconnecter ?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Vous pouvez toujours vous reconnecter à tout moment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button - Styled exactly as in Figma
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Logout button - Green color as shown in Figma
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          performLogout();
                        },
                        child: Text(
                          'Deconnecter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Separated logout logic to improve code organization
  Future<void> performLogout() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: AppColors.lightTeal,
        ),
      ),
    );

    try {
      // Perform logout with timeout
      final authService = AuthService();
      bool success = false;

      // Add a timeout to the logout request
      success = await authService.logout().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Logout request timed out');
          // Still clear local data on timeout
          return true;
        },
      );

      // Close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (success) {
        // Navigate to login screen with a fade transition and remove all previous routes
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SigninUser(userData: UserModel(userType: 'USER')),
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            (route) => false, // Remove all routes from the stack
          );
        }
      } else {
        if (context.mounted) {
          // Show error message with custom style
          _showCustomSnackBar(
            'Erreur lors de la déconnexion. Veuillez réessayer.',
            isError: true,
          );
        }
      }
    } catch (e) {
      print('Error during logout: $e');
      // Close loading indicator
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message with custom style
        _showCustomSnackBar(
          'Erreur lors de la déconnexion: $e',
          isError: true,
        );
      }
    }
  }

  // Custom SnackBar that matches Figma design
  void _showCustomSnackBar(String message, {bool isError = false}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.clearSnackBars();

    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: isError ? Colors.red : AppColors.lightTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.only(
          bottom: 70.h + MediaQuery.of(context).padding.bottom,
          left: 20.w,
          right: 20.w,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Build a navigation item - matching HomeScreen style
  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.lightTeal : Colors.grey,
              size: 24.r,
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

  // Build the special scan button in the middle - matching HomeScreen style
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
            size: 26.r,
          ),
        ),
      ),
    );
  }

  // Setting item widget with improved styling to match Figma
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              height: 24.r,
              width: 24.r,
              child: Icon(icon, color: iconColor ?? Colors.black87, size: 20.r),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black87,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20.r),
          ],
        ),
      ),
    );
  }
}
