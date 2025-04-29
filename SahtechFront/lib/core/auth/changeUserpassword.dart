import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/auth/PasswordUpdated.dart';

class ChangeUserPassword extends StatefulWidget {
  final String email;

  const ChangeUserPassword({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ChangeUserPassword> createState() => _ChangeUserPasswordState();
}

class _ChangeUserPasswordState extends State<ChangeUserPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  bool _validatePasswords() {
    bool isValid = true;

    // Validate new password
    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Veuillez entrer un nouveau mot de passe';
      });
      isValid = false;
    } else if (_newPasswordController.text.length < 6) {
      setState(() {
        _passwordError = 'Le mot de passe doit contenir au moins 6 caractères';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Veuillez confirmer votre mot de passe';
      });
      isValid = false;
    } else if (_confirmPasswordController.text != _newPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
      });
      isValid = false;
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }

    return isValid;
  }

  void _updatePassword() async {
    // Clear previous errors
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate passwords
    if (!_validatePasswords()) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    // Simulate API call - will be replaced with actual API call later
    await Future.delayed(const Duration(seconds: 1));

    // Hide loading state
    setState(() {
      _isLoading = false;
    });

    // Navigate to success screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordUpdated(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lock with Password Icon
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: AppColors.lightTeal,
                          size: 40.sp,
                        ),
                        Positioned(
                          right: 10.w,
                          bottom: 10.w,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 12.r,
                            child: Icon(
                              Icons.refresh,
                              color: AppColors.lightTeal,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Center(
                child: Text(
                  'Nouveaux identifiant',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Subtitle
              Center(
                child: Text(
                  'votre nouvel identifiant a été vérifié ! changer votre mot de passe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // New Password Label
              Text(
                'nouveau mot de passe',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8.h),

              // New Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        _passwordError != null ? Colors.red : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Entrer votre nouveau mot de passe',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[400],
                        size: 20.sp,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
              ),

              // Password error message
              if (_passwordError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    _passwordError!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),

              SizedBox(height: 16.h),

              // Confirm Password Label
              Text(
                'confirmation mot de passe',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8.h),

              // Confirm Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _confirmPasswordError != null
                        ? Colors.red
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'confirmer votre mot de passe',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[400],
                        size: 20.sp,
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
              ),

              // Confirm password error message
              if (_confirmPasswordError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    _confirmPasswordError!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),

              Spacer(),

              // Confirm button
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 24.h),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    elevation: 0,
                    disabledBackgroundColor:
                        AppColors.lightTeal.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.w,
                          ),
                        )
                      : Text(
                          'Confirmer',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
