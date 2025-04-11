import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste5.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Nutritioniste4 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste4({
    super.key,
    required this.nutritionistData,
    this.currentStep = 4,
    this.totalSteps = 5,
  });

  @override
  State<Nutritioniste4> createState() => _Nutritioniste4State();
}

class _Nutritioniste4State extends State<Nutritioniste4> {
  late TranslationService _translationService;
  bool _isLoading = false;

  // Translations
  Map<String, String> _translations = {
    'title':
        'Autoriser Maps à accéder à la localisation précise de cet appareil ?',
    'precise': 'Précise',
    'approximate': 'Approximative',
    'only_this_time': 'Lors de l\'utilisation de l\'application',
    'allow': 'Seulement cette fois',
    'deny': 'Ne pas autoriser',
    'add_location': 'Voulez-vous vraiment ajouter votre localisation ?',
    'continue': 'Continuer',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (default language)
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Request location permission and navigate to next screen
  Future<void> _requestLocationPermission(bool preciseLocation) async {
    PermissionStatus status;

    // For both precise and approximate location, we use the same permission
    // The distinction is handled in the UI for user clarity
    status = await Permission.locationWhenInUse.request();

    _navigateToMapScreen(status == PermissionStatus.granted ||
        status == PermissionStatus.limited);
  }

  // Handle one-time permission usage
  void _onlyThisTime() {
    _navigateToMapScreen(true);
    // This is simulating one-time usage permission
    // In a real app, you would handle this differently
  }

  // Deny location permission and navigate to map without location
  void _denyLocationPermission() {
    _navigateToMapScreen(false);
  }

  // Navigate to map screen
  void _navigateToMapScreen(bool locationEnabled) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Nutritioniste5(
          nutritionistData: widget.nutritionistData,
          currentStep: widget.currentStep + 1,
          totalSteps: widget.totalSteps,
          locationEnabled: locationEnabled,
        ),
      ),
    );

    // Update nutritionist data if returned from the map screen
    if (result != null && result is NutritionisteModel) {
      // Update the local data with the returned data
      setState(() {
        widget.nutritionistData.latitude = result.latitude;
        widget.nutritionistData.longitude = result.longitude;
        widget.nutritionistData.cabinetAddress = result.cabinetAddress;
      });
    }
  }

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Update nutritionist model with the new language
    widget.nutritionistData.preferredLanguage = languageCode;

    // Reload translations with the new language
    _loadTranslations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 45.w,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTeal,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: 15.w),
        ),
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          LanguageSelectorButton(
            width: 1.sw,
            onLanguageChanged: _handleLanguageChanged,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : SafeArea(
              child: Column(
                children: [
                  // Progress bar at the top
                  Container(
                    width: double.infinity,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 1.sw * (widget.currentStep / widget.totalSteps),
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2.r),
                              bottomRight: Radius.circular(2.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        // Blurred background map
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[100],
                          child: Image.asset(
                            'lib/assets/images/map_background.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Centered scrollable content
                        Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Location permission card
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(24.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _translations['title']!,
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 32.h),

                                        // Precise location option
                                        _buildLocationOption(
                                          icon: Icons.location_on,
                                          title: _translations['precise']!,
                                          onTap: () =>
                                              _requestLocationPermission(true),
                                        ),

                                        SizedBox(height: 16.h),

                                        // Approximate location option
                                        _buildLocationOption(
                                          icon: Icons.location_searching,
                                          title: _translations['approximate']!,
                                          onTap: () =>
                                              _requestLocationPermission(false),
                                        ),

                                        SizedBox(height: 32.h),

                                        // Only this time button
                                        _buildButton(
                                          text: _translations['only_this_time']!,
                                          onPressed: _onlyThisTime,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black87,
                                          borderColor: Colors.grey[300]!,
                                        ),

                                        SizedBox(height: 12.h),

                                        // Allow button
                                        _buildButton(
                                          text: _translations['allow']!,
                                          onPressed: () =>
                                              _requestLocationPermission(true),
                                          backgroundColor: AppColors.lightTeal,
                                          textColor: Colors.black87,
                                        ),

                                        SizedBox(height: 12.h),

                                        // Deny button
                                        _buildButton(
                                          text: _translations['deny']!,
                                          onPressed: _denyLocationPermission,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.red,
                                          borderColor: Colors.red,
                                        ),
                                      ],
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
                ],
              ),
            ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.lightTeal,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
