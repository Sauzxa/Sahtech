import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/localization_service.dart';
import 'package:sahtech/main.dart';

class Profile2 extends StatefulWidget {
  final UserModel userData;

  const Profile2({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  bool? _hasChronicDisease;
  final LocalizationService _localizationService = LocalizationService();
  bool _isLoading = false;

  // Switch the app language and refresh UI
  Future<void> _switchLanguage(String languageCode) async {
    if (languageCode == _localizationService.currentLanguageCode) return;

    setState(() {
      _isLoading = true;
    });

    await _localizationService.changeLocale(languageCode);

    // Update the app's locale using the Main static method
    if (mounted) {
      Main.changeLocale(context, languageCode);

      // Force rebuild this page with the new locale
      setState(() {
        _isLoading = false;
      });

      // Force a rebuild by remounting this widget
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Profile2(userData: widget.userData),
          ),
        );
      }
    }
  }

  void _continueToNextScreen() {
    if (_hasChronicDisease == null) {
      // Show error if no selection made
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user model with the selections
    widget.userData.hasChronicDisease = _hasChronicDisease;
    widget.userData.preferredLanguage =
        _localizationService.currentLanguageCode;

    // Navigate to next screen or show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations enregistrées avec succès!'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Navigate to next screen
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => NextScreen(userData: widget.userData),
    //   ),
    // );
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
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Choisir une langue'),
                    children:
                        LocalizationService.supportedLocales.map((locale) {
                      final languageCode = locale.languageCode;
                      final isSelected =
                          _localizationService.currentLanguageCode ==
                              languageCode;
                      return SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context);
                          _switchLanguage(languageCode);
                        },
                        child: Row(
                          children: [
                            Text(
                                _localizationService
                                        .languageFlags[languageCode] ??
                                    '',
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(languageCode.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.lightTeal
                                      : Colors.black87,
                                )),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: width * 0.04),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    _localizationService.languageFlags[
                            _localizationService.currentLanguageCode] ??
                        '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _localizationService.currentLanguageCode.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
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
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        Container(
                          width: width *
                              0.15, // Representing progress (1 of 5 steps)
                          height: 4,
                          color: AppColors.lightTeal,
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
                            Text(
                              'Avez vous une maldie chronique ?',
                              style: TextStyle(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: height * 0.02),

                            // Subtitle/explanation
                            Text(
                              'Pour une meilleure expérience et un scan personnalisé adapté à votre profil, nous avons besoin de connaître certaines informations sur votre état de santé',
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),

                            SizedBox(height: height * 0.06),

                            // Yes button - match Figma styling
                            GestureDetector(
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
                                      ? AppColors.lightTeal.withOpacity(0.2)
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
                                    'Oui',
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
                            ),

                            SizedBox(height: height * 0.02),

                            // No button - match Figma styling
                            GestureDetector(
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
                                      ? AppColors.lightTeal.withOpacity(0.2)
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
                                    'Non',
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
                            ),
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
                      child: ElevatedButton(
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
                          'suivant',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
