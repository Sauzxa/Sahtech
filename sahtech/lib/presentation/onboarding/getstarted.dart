import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/base/base_screen.dart';
import 'package:sahtech/presentation/widgets/custom_button.dart';
import 'package:sahtech/presentation/profile/profile1.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  Map<String, String> translations = {
    'get_started': 'Get Started',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            width: 1.sw,
            height: 1.sh,
          ),
          // Content overlay
          Container(
            color: Colors.black.withOpacity(0.5),
            width: 1.sw,
            height: 1.sh,
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 150.w,
                  height: 150.h,
                ),
                // Get Started button
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: CustomButton(
                    text: translations['get_started']!,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Profile1(),
                        ),
                      );
                    },
                    width: 1.sw,
                    height: 56.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 