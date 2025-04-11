import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Responsive width
      height: height, // Responsive height
      decoration: BoxDecoration(
        color: const Color(0xFF9FE870), // Button color (green)
        borderRadius: BorderRadius.circular(30.r), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp, // Updated to consistent size
            fontWeight: FontWeight.w500, // Medium font weight for consistency
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
