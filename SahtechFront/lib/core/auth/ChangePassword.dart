//ChangePassword.dart is for logged-in users changing their password

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/auth/SigninUser.dart';
import 'package:sahtech/core/utils/models/user_model.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final StorageService _storageService = StorageService();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to change the user's password
  Future<void> _changePassword() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the user ID and token
      final String? userId = await _storageService.getUserId();
      String? token = await _storageService.getToken();

      // Verify token and user ID are available
      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage =
              "Informations d'authentification manquantes. Veuillez vous reconnecter.";
          _isLoading = false;
        });
        return;
      }

      // Check token expiration
      bool tokenMightBeExpired = false;
      try {
        // Simple heuristic - if last part of token is older than 12 hours, consider refreshing
        final parts = token.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decodedPayload = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> data = json.decode(decodedPayload);

          if (data.containsKey('exp')) {
            final exp = data['exp'];
            final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            final now = DateTime.now();

            if (expDate.isBefore(now)) {
              tokenMightBeExpired = true;
            } else {}
          }
        }
      } catch (e) {
        
        // On error, assume we should try to refresh
        tokenMightBeExpired = true;
      }

      // If token might be expired, try to refresh or re-login silently
      if (tokenMightBeExpired) {
        // Try to get stored credentials (you'd need to implement this)
        final String? storedEmail = await _storageService.getEmail();
        final String? storedPassword =
            await _storageService.getSecurePassword();

        if (storedEmail != null && storedPassword != null) {
          try {
            // Re-login with stored credentials
            final AuthService authService = AuthService();
            final result = await authService.loginUser(
                storedEmail, storedPassword,
                userType: await _storageService.getUserType() ?? 'USER');

            if (result['success'] == true) {
              token = await _storageService.getToken(); // Get fresh token
            }
          } catch (e) {
            // Ignore silent re-authentication errors
          }
        }
      }

      // Prepare request data
      final url =
          '${AuthService.apiBaseUrl}/API/Sahtech/Utilisateurs/$userId/changePassword';
      final body = jsonEncode({
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });

      // Create headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Send request to backend
      final response = await http
          .put(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return http.Response('{"error":"Request timed out"}', 408);
        },
      );

      // Handle response based on status code
      if (response.statusCode == 200) {
        // Password changed successfully
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mot de passe mis à jour avec succès'),
              backgroundColor: Color(0xFF9AE08F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          // Navigate back to previous screen
          Navigator.pop(context, true);
        }
      } else if (response.statusCode == 401) {
        // Current password is incorrect
        setState(() {
          _errorMessage = 'Le mot de passe actuel est incorrect';
        });
      } else if (response.statusCode == 403) {
        // Authentication/authorization issue
        setState(() {
          _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        });
        // Clear auth data - session is invalid
        await _storageService.clearAuthData();
        // Redirect to login after a delay
        if (mounted) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      SigninUser(userData: UserModel(userType: 'USER'))),
              (route) => false,
            );
          });
        }
      } else {
        // Other errors
        String errorMsg = 'Erreur lors du changement de mot de passe';

        try {
          if (response.body.isNotEmpty) {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            if (errorData.containsKey('error')) {
              errorMsg = errorData['error'];
            }
          }
        } catch (e) {
          // Ignore error parsing response
        }

        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      // Use SingleChildScrollView to handle overflow with keyboard
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Dismiss keyboard on tap outside
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Lock Icon
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
                          color: Color(0xFF9AE08F),
                          size: 80.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Title
                    Center(
                      child: Text(
                        'Nouveaux identifiant',
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
                        'entrez votre mot de passe actuel et un nouveau mot de passe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Error message if any
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.h),
                        margin: EdgeInsets.only(bottom: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),

                    // Current Password Label
                    Text(
                      'mot de passe actuel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Current Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextFormField(
                        controller: _currentPasswordController,
                        obscureText: !_isCurrentPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe actuel';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'mot de passe actuel',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCurrentPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[400],
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCurrentPasswordVisible =
                                    !_isCurrentPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // New Password Label
                    Text(
                      'Nouveau mot de passe',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // New Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nouveau mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Nouveau mot de passe',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[400],
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Confirm Password Label
                    Text(
                      'confirmer mot de passe',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Confirm Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre nouveau mot de passe';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'confirmer votre mot de passe',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[400],
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 50.h),

                    // Confirm Button
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 24.h),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9AE08F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          elevation: 0,
                          disabledBackgroundColor:
                              Color(0xFF9AE08F).withOpacity(0.6),
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
                                'Confirmer',
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
          ),
        ),
      ),
    );
  }
}
