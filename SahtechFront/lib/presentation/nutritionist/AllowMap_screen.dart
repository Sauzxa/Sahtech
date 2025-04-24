import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahtech/presentation/nutritionist/gps_screen.dart';

class Nutritioniste4 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste4({
    Key? key,
    required this.nutritionistData,
    this.currentStep = 3,
    this.totalSteps = 5,
  }) : super(key: key);

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
        builder: (context) => NutritionisteMap(
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
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: width * 0.12,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTeal,
            size: width * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: width * 0.04),
        ),
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Language selector button
          LanguageSelectorButton(
            width: width,
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
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:
                              width * (widget.currentStep / widget.totalSteps),
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        // Background map (blurred/dimmed)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              'lib/assets/images/map_background.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Main content - Location permission dialog
                        Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.06),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Location permission card
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(width * 0.04),
                                      child: Column(
                                        children: [
                                          // Location pin icon
                                          Container(
                                            width: width * 0.15,
                                            height: width * 0.15,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.map,
                                              color: AppColors.lightTeal,
                                              size: width * 0.08,
                                            ),
                                          ),

                                          SizedBox(height: height * 0.02),

                                          // Title
                                          Text(
                                            _translations['title']!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: width * 0.045,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),

                                          SizedBox(height: height * 0.03),

                                          // Location options
                                          Row(
                                            children: [
                                              // Precise location option
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _requestLocationPermission(
                                                          true),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.blue,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: height * 0.02,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: width * 0.12,
                                                          height: width * 0.12,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.1),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .location_searching,
                                                            color: Colors.blue,
                                                            size: width * 0.06,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.01),
                                                        Text(
                                                          _translations[
                                                              'precise']!,
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: width * 0.04),

                                              // Approximate location option
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _requestLocationPermission(
                                                          false),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: height * 0.02,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: width * 0.12,
                                                          height: width * 0.12,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.1),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons.map,
                                                            color: Colors.grey,
                                                            size: width * 0.06,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.01),
                                                        Text(
                                                          _translations[
                                                              'approximate']!,
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: height * 0.03),

                                          // Only this time button
                                          TextButton(
                                            onPressed: _onlyThisTime,
                                            style: TextButton.styleFrom(
                                              backgroundColor: AppColors
                                                  .lightTeal
                                                  .withOpacity(0.1),
                                              padding: EdgeInsets.symmetric(
                                                vertical: height * 0.015,
                                                horizontal: width * 0.04,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: Text(
                                              _translations['only_this_time']!,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.lightTeal,
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: height * 0.015),

                                          // Allow button
                                          TextButton(
                                            onPressed: _onlyThisTime,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                vertical: height * 0.015,
                                                horizontal: width * 0.04,
                                              ),
                                            ),
                                            child: Text(
                                              _translations['allow']!,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),

                                          // Deny button
                                          TextButton(
                                            onPressed: _denyLocationPermission,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                vertical: height * 0.015,
                                                horizontal: width * 0.04,
                                              ),
                                            ),
                                            child: Text(
                                              _translations['deny']!,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red.shade400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // "Do you want to add your location?" dialog can appear here
                                  // This is shown in the third image
                                  // But we'll handle this in the map screen when the user clicks on the map
                                ],
                              ),
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
}
