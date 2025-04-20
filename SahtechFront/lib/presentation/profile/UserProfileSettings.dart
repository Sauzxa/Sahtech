import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/presentation/home/home_screen.dart';
import 'package:sahtech/presentation/scan/camera_access_screen.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sahtech/presentation/profile/EditUserData.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/services/translation_service.dart';

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
      // Navigate to Scan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraAccessScreen(),
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);
    final isRTL = translationService.currentLanguageCode == 'ar';

    return Scaffold(
      backgroundColor:
          const Color(0xFFE5F0E2), // Light green background from the design
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 12.h), // Added vertical padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h), // Increased for better vertical centering
              // Profile Title
              Center(
                child: Text(
                  'Mon Profile',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // User Profile Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 25.r,
                      backgroundImage: widget.user.profileImageUrl != null
                          ? NetworkImage(widget.user.profileImageUrl!)
                          : null,
                      child: widget.user.profileImageUrl == null
                          ? Icon(Icons.person, size: 30.r)
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name ?? 'Arafatilla 01',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Numero de compte: ${widget.user.phoneNumber ?? '029883614373'}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.r),
                      onPressed: _navigateToEditProfile,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Other Parameters Section
              Text(
                'Autres Parametres',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 16.h),

              // Settings Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    // Display Mode
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode, color: Colors.black),
                          SizedBox(width: 16.w),
                          Text(
                            'Mode d\'affichage',
                            style: TextStyle(
                              fontSize: 14.sp,
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
                            activeColor: AppColors.lightTeal,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),

                    // Change Language
                    _buildSettingItem(
                      icon: Icons.language,
                      title: 'Changer la langue',
                      onTap: () {
                        // Show language selection dialog
                        _showLanguageSelectionDialog();
                      },
                    ),

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

              // Change Password
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: _buildSettingItem(
                  icon: Icons.lock,
                  title: 'changer mot de passe',
                  onTap: () {
                    // Navigate to change password
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Support
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: _buildSettingItem(
                  icon: Icons.build_outlined,
                  title: 'Support',
                  onTap: () {
                    _launchUrl('https://sahtech-website.vercel.app/');
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Logout
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: _buildSettingItem(
                  icon: Icons.logout,
                  title: 'Se deconnecter',
                  textColor: Colors.red,
                  onTap: () async {
                    // Show confirmation dialog
                    showLogoutConfirmationDialog();
                  },
                ),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
      // Bottom navigation bar consistent with HomeScreen
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

  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 30.sp,
                    color: AppColors.lightTeal,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Vous allez vous déconnecter ?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Vous pouvez toujours vous reconnecter à tout moment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.lightTeal),
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
                            color: AppColors.lightTeal,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // Logout button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();

                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                Center(child: CircularProgressIndicator()),
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
                              // Navigate to login screen
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              }
                            } else {
                              if (context.mounted) {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Erreur lors de la déconnexion. Veuillez réessayer.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            print('Error during logout: $e');
                            // Close loading indicator
                            if (context.mounted) {
                              Navigator.pop(context);

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Erreur lors de la déconnexion: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Deconnecter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
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

  // Build the special scan button in the middle - matching HomeScreen style
  Widget _buildNavScanItem() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor ?? Colors.black,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
