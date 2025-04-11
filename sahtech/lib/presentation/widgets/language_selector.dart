import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final translationService =
        Provider.of<TranslationService>(context, listen: false);
    final currentLanguage = translationService.currentLanguageCode;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        offset: Offset(-10.w, 40.h),
        elevation: 4,
        padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
        icon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translationService.supportedLanguages[currentLanguage]?['flag'] ?? '',
                style: TextStyle(fontSize: 24.sp),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.lightTeal,
                size: 20.w,
              ),
            ],
          ),
        ),
        onSelected: (languageCode) {
          if (languageCode != currentLanguage) {
            _changeLanguage(context, languageCode);
          }
        },
        itemBuilder: (context) {
          return translationService.supportedLanguages.entries.map((entry) {
            final languageCode = entry.key;
            final languageInfo = entry.value;
            final isSelected = languageCode == currentLanguage;

            return PopupMenuItem<String>(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              value: languageCode,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    languageInfo['flag'] ?? '',
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(width: 16.w),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200.w), // Limit the text width
                    child: Text(
                      languageInfo['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        overflow: TextOverflow.ellipsis, // Prevent overflow of long names
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_rounded,
                      color: AppColors.lightTeal,
                      size: 20.w,
                    ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    final translationService =
        Provider.of<TranslationService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.lightTeal),
      ),
    );

    try {
      await translationService.setLanguage(languageCode);
    } finally {
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
