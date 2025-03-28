import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/profile/profile3.dart';
import 'package:sahtech/presentation/profile/profile4.dart';

// Note: No need to import NutritionisteModel here since this screen is only used for regular users
// The nutritionist flow is handled separately starting from profile1.dart to nutritioniste1.dart

class Profile2 extends StatefulWidget {
  final UserModel userData;

  const Profile2({super.key, required this.userData});

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  bool? _hasChronicDisease;
  late TranslationService _translationService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
  }

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Show loading indicator while translations are loading
    setState(() {
      _isLoading = true;
    });

    // Use Future.delayed to allow the UI to update before continuing with potentially heavy operations
    Future.delayed(Duration.zero, () async {
      try {
        // Update the user model with the new language
        widget.userData.preferredLanguage = languageCode;

        // Force a refresh of all text in the UI
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error handling language change: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // When navigating back to Profile1, tell it if language changed
    if (widget.userData.preferredLanguage !=
        _translationService.currentLanguageCode) {
      Navigator.pop(context, 'language_changed');
    }
    super.dispose();
  }

  void _continueToNextScreen() async {
    if (_hasChronicDisease == null) {
      // Show error if no selection made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate('Veuillez sélectionner une option')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user model with the selections
    widget.userData.hasChronicDisease = _hasChronicDisease;
    widget.userData.preferredLanguage = _translationService.currentLanguageCode;

    // If user has chronic disease, navigate to Profile3
    if (_hasChronicDisease == true) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile3(userData: widget.userData),
        ),
      );

      if (result == 'conditions_selected') {
        // User has selected their conditions, show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(await _translationService
                .translate('Informations enregistrées avec succès!')),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Navigate to next screen with complete user data
      }
    } else {
      // Otherwise, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(await _translationService
              .translate('Informations enregistrées avec succès!')),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Profile4 for users without chronic disease
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile4(userData: widget.userData),
        ),
      );
    }
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
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: width * 0.05),
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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Green progress bar exactly like in Figma
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: width *
                              0.1, // Representing 10% progress (first step)
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.04),

                            // Main question
                            FutureBuilder<String>(
                                future: _translationService.translate(
                                    'Avez vous une maladie chronique ?'),
                                builder: (context, snapshot) {
                                  final text = snapshot.data ??
                                      'Avez vous une maldie chronique ?';
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                }),

                            SizedBox(height: height * 0.02),

                            // Subtitle/explanation
                            FutureBuilder<String>(
                                future: _translationService.translate(
                                    'Pour une meilleure expérience et un scan personnalisé adapté à votre profil, nous avons besoin de connaître certaines informations sur votre état de santé'),
                                builder: (context, snapshot) {
                                  final text = snapshot.data ??
                                      'Pour une meilleure expérience et un scan personnalisé adapté à votre profil, nous avons besoin de connaître certaines informations sur votre état de santé';
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                  );
                                }),

                            SizedBox(height: height * 0.06),

                            // Yes button - match Figma styling
                            FutureBuilder<String>(
                                future: _translationService.translate('Oui'),
                                builder: (context, snapshot) {
                                  final yesText = snapshot.data ?? 'Oui';
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hasChronicDisease = true;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: height * 0.075,
                                      decoration: BoxDecoration(
                                        color: _hasChronicDisease == true
                                            ? AppColors.lightTeal
                                                .withOpacity(0.2)
                                            : const Color(0xFFEFF9E8),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: _hasChronicDisease == true
                                              ? AppColors.lightTeal
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          yesText,
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            fontWeight: FontWeight.w500,
                                            color: _hasChronicDisease == true
                                                ? AppColors.lightTeal
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                            SizedBox(height: height * 0.02),

                            // No button - match Figma styling
                            FutureBuilder<String>(
                                future: _translationService.translate('Non'),
                                builder: (context, snapshot) {
                                  final noText = snapshot.data ?? 'Non';
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hasChronicDisease = false;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: height * 0.075,
                                      decoration: BoxDecoration(
                                        color: _hasChronicDisease == false
                                            ? AppColors.lightTeal
                                                .withOpacity(0.2)
                                            : const Color(0xFFEFF9E8),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: _hasChronicDisease == false
                                              ? AppColors.lightTeal
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          noText,
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            fontWeight: FontWeight.w500,
                                            color: _hasChronicDisease == false
                                                ? AppColors.lightTeal
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Next button - match Figma styling
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06, vertical: height * 0.02),
                    child: SizedBox(
                      width: double.infinity,
                      height: height * 0.065,
                      child: FutureBuilder<String>(
                          future: _translationService.translate('suivant'),
                          builder: (context, snapshot) {
                            final nextText = snapshot.data ?? 'suivant';
                            return ElevatedButton(
                              onPressed: _continueToNextScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightTeal,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                nextText,
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
