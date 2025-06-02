import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/presentation/home/home_screen.dart';

class ValidateNutritionistCardScreen extends StatefulWidget {
  final NutritionisteModel nutritionistData;

  const ValidateNutritionistCardScreen({
    super.key,
    required this.nutritionistData,
  });

  @override
  State<ValidateNutritionistCardScreen> createState() =>
      _ValidateNutritionistCardScreenState();
}

class _ValidateNutritionistCardScreenState
    extends State<ValidateNutritionistCardScreen> {
  bool _isLoading = false;

  void _handleModify() {
    // Navigate back to edit profile
    Navigator.pop(context);
  }

  void _handleValidate() {
    setState(() => _isLoading = true);

    // Simulate validation process
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);

        // Create a UserModel from the essential nutritionist data for HomeScreen
        // The UserModel is what HomeScreen expects
        final userData = UserModel(
          userType: 'nutritionist',
          name: widget.nutritionistData.name,
          email: widget.nutritionistData.email,
          userId: widget.nutritionistData.userId ?? '1',
          phoneNumber: widget.nutritionistData.phoneNumber,
          photoUrl: widget.nutritionistData.profileImageUrl,
          preferredLanguage: widget.nutritionistData.preferredLanguage,
        );

        // Navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: userData),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: 1.sw,
          height: 1.sh,
          color: AppColors.lightTeal.withOpacity(0.5),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Logo
              Center(
                child: Image.asset(
                  'lib/assets/images/mainlogo.jpg',
                  height: 45.h,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 30.h),

              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Veuillez Valider les infomrations\nde votre carte',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile image and name
                            Row(
                              children: [
                                // Profile image
                                Container(
                                  width: 60.r,
                                  height: 60.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    image: widget.nutritionistData
                                                .profileImageUrl !=
                                            null
                                        ? DecorationImage(
                                            image: NetworkImage(widget
                                                .nutritionistData
                                                .profileImageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      widget.nutritionistData.profileImageUrl ==
                                              null
                                          ? Icon(
                                              Icons.person,
                                              size: 36.r,
                                              color: Colors.grey[400],
                                            )
                                          : null,
                                ),

                                SizedBox(width: 16.w),

                                // Name and title
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dr. ${widget.nutritionistData.name ?? ""}',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Speciality
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital_outlined,
                                    size: 16.r,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Specialité:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    widget.nutritionistData.specialite ??
                                        'Nutrition générale',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Location
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 16.r,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Localisation:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    widget.nutritionistData.cabinetAddress ??
                                        'Non spécifiée',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Phone number
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.phone_outlined,
                                    size: 16.r,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Numero:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    widget.nutritionistData.phoneNumber ??
                                        'Non spécifié',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Modify button
                            SizedBox(
                              width: 120.w,
                              height: 36.h,
                              child: ElevatedButton(
                                onPressed: _handleModify,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                child: Text(
                                  'Modifier',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Validate button
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleValidate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF9FE870), // Light green
                              foregroundColor: Colors.black87,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                              disabledBackgroundColor:
                                  Colors.grey.withOpacity(0.12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black54),
                                    ),
                                  )
                                : Text(
                                    'Valider',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
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
