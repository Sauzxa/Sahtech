import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/auth/SigninUser.dart';
import 'package:sahtech/core/utils/models/user_model.dart';

class PasswordUpdated extends StatelessWidget {
  const PasswordUpdated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'Mot de passe\nMis à jour',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 40.h),

              // Success Check Icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.lightTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60.sp,
                ),
              ),

              SizedBox(height: 40.h),

              // Success Message
              Text(
                'Votre mot de passe a été changé avec succès',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),

              SizedBox(height: 80.h),

              // Se Connecter Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to login screen and clear all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SigninUser(
                          userData: UserModel(userType: 'USER'),
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    elevation: 0,
                  ),
                  child: Text(
                    'se connecter',
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
