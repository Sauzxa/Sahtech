import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/presentation/scan/product_scanner_screen.dart';
import 'package:sahtech/core/services/storage_service.dart';

class CameraAccessScreen extends StatelessWidget {
  const CameraAccessScreen({Key? key}) : super(key: key);

  Future<void> _requestCameraPermission(BuildContext context) async {
    final storageService = StorageService();
    final status = await Permission.camera.request();

    if (status.isGranted) {
      // Set flag that user has seen the camera screen
      await storageService.setHasSeenCameraScreen(true);

      // Navigate to scanner screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductScannerScreen(),
          ),
        );
      }
    } else if (status.isDenied) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permission refusée. Veuillez autoriser l\'accès à la caméra pour scanner des produits.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // Open app settings
      if (context.mounted) {
        openAppSettings();
      }
    }
  }

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
              const Spacer(flex: 2),

              // Scan icon in green circle
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  color: AppColors.lightTeal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 80.w,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              // Title
              Text(
                'acceder au camera',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),

              // Description
              Text(
                'Pour scanner des codes-barres en utilisant la caméra de votre téléphone, veuillez autoriser l\'accès',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),

              const Spacer(flex: 3),

              // Continue button
              CustomButton(
                onPressed: () => _requestCameraPermission(context),
                text: 'continue',
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Button Widget
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightTeal,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
