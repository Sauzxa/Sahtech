import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritionist_model.dart';

class NutritionistCard extends StatelessWidget {
  final NutritionistModel nutritionist;
  final VoidCallback onCallTap;
  final VoidCallback onDetailsTap;

  const NutritionistCard({
    Key? key,
    required this.nutritionist,
    required this.onCallTap,
    required this.onDetailsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.only(
          bottom: 11), // Added 11px padding at the bottom to prevent overflow
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
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top to prevent stretching
        children: [
          // Doctor image with margins
          Padding(
            padding: EdgeInsets.all(6.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                nutritionist.profileImageUrl,
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
              padding: EdgeInsets.only(
                left: 8.w,
                right: 8.w,
                top: 8.h,
                bottom:
                    0, // Removed additional bottom padding since we're using fixed padding on container
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use minimum size needed
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
                        nutritionist.rating.toString(),
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
                    nutritionist.name,
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
                    nutritionist.specialization,
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
                          nutritionist.location,
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

                  SizedBox(height: 8.h), // Fixed spacing instead of Spacer

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
