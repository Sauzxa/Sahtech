import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/auth/changeUserpassword.dart';
import 'package:sahtech/core/theme/colors.dart';

class CheckEmail extends StatefulWidget {
  const CheckEmail({super.key});

  @override
  State<CheckEmail> createState() => _CheckEmailState();
}

class _CheckEmailState extends State<CheckEmail> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateAndContinue() async {
    // Clear any previous errors
    setState(() {
      _emailError = null;
    });

    // Validate email format
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Veuillez entrer votre adresse e-mail';
      });
      return;
    }

    // Simple email validation using regex
    final bool emailValid =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!emailValid) {
      setState(() {
        _emailError = 'Veuillez entrer une adresse e-mail valide';
      });
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    // Simulate API call - will be replaced with actual API call later
    await Future.delayed(const Duration(seconds: 1));

    // Hide loading state
    setState(() {
      _isLoading = false;
    });

    // Navigate to password change screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeUserPassword(email: email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lock Image from assets
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.green,
                    size: 80.sp,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Center(
                child: Text(
                  'Nouveau Mot de passe',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Subtitle
              Center(
                child: Text(
                  'Veuillez fournir l\'adresse e-mail de votre compte pour lequel vous souhaitez réinitialiser le mot de passe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Email Label
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8.h),

              // Email Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        _emailError != null ? Colors.red : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter votre nom ou un pseudo nom',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[400],
                      size: 20.sp,
                    ),
                  ),
                ),
              ),

              // Error message if email is invalid
              if (_emailError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    _emailError!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),

              Spacer(),

              // Suivant button
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 24.h),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9AE08F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    elevation: 0,
                    disabledBackgroundColor: Color(0xFF9AE08F).withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.w,
                          ),
                        )
                      : Text(
                          'suivant',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
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
