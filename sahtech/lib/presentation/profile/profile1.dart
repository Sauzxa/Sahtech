import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/presentation/profile/profile2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Profile1 extends StatefulWidget {
  const Profile1({Key? key}) : super(key: key);

  @override
  State<Profile1> createState() => _Profile1State();
}

class _Profile1State extends State<Profile1> {
  // Initial selection (null means none selected)
  String? selectedUserType;

  // Function to navigate to the next screen with user data
  void navigateToProfile2() {
    if (selectedUserType != null) {
      final userData = UserModel(userType: selectedUserType!);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile2(userData: userData),
        ),
      );
    } else {
      // Show a snackbar if no user type is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un type de compte'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Check if a user type is selected
    final bool isUserTypeSelected = selectedUserType != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.05),

              // Logo - Using mainlogo.jpg which contains the Sahtech logo
              Image.asset(
                'lib/assets/images/mainlogo.jpg',
                width: width * 0.5,
                fit: BoxFit.contain,
              ),

              SizedBox(height: height * 0.04),

              // Main Title
              Text(
                'Démarrons ensemble',
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: height * 0.015),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Text(
                  'Scannez vos aliments et recevez des conseils adaptés à votre profil pour faire les meilleurs choix nutritionnels',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: height * 0.06),

              // User option card
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedUserType = 'user';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: selectedUserType == 'user'
                          ? AppColors.lightTeal
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // User icon - green square with person icon
                      Container(
                        padding: EdgeInsets.all(width * 0.03),
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.lightTeal,
                          size: width * 0.06,
                        ),
                      ),

                      SizedBox(width: width * 0.04),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Je suis un utilisateur',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              'Compte utilisateur pour utiliser l\'appli',
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right arrow
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: width * 0.06,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.025),

              // Nutritionist option card
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedUserType = 'nutritionist';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: selectedUserType == 'nutritionist'
                          ? AppColors.lightTeal
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Nutritionist icon - green square with stethoscope icon
                      Container(
                        padding: EdgeInsets.all(width * 0.03),
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.stethoscope,
                          color: AppColors.lightTeal,
                          size: width * 0.05,
                        ),
                      ),

                      SizedBox(width: width * 0.04),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Je suis un nutritioniste',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              'Compte nutritioniste pour être consulter',
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right arrow
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: width * 0.06,
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // Continue button (disabled until a user type is selected)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: height * 0.03),
                child: ElevatedButton(
                  onPressed: isUserTypeSelected ? navigateToProfile2 : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUserTypeSelected
                        ? AppColors.lightTeal
                        : Colors.grey[300],
                    foregroundColor:
                        isUserTypeSelected ? Colors.black87 : Colors.grey[600],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w500,
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
