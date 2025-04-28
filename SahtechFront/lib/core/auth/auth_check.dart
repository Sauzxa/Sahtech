import 'package:flutter/material.dart';
import 'package:sahtech/core/services/auth_service.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/presentation/home/home_screen.dart';
import 'package:sahtech/presentation/onboarding/loading.dart';
import 'package:sahtech/core/auth/SigninUser.dart';
import 'dart:async';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // We need to use a slight delay to allow the context to be ready for navigation
    Future.delayed(Duration.zero, () {
      _checkAuthStatusAndNavigate();
    });
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    try {
      // First check if the user is logged in
      final bool isLoggedIn = await _storageService.isLoggedIn();
      final bool hasLoggedOut = await _storageService.hasLoggedOut();

      print(
          'AUTH_CHECK: Is user logged in? $isLoggedIn, Has previously logged out? $hasLoggedOut');

      if (isLoggedIn) {
        // USER IS AUTHENTICATED - Direct to home screen
        _navigateToHomeIfAuthenticated();
      } else {
        // USER IS NOT AUTHENTICATED
        if (hasLoggedOut) {
          // This is a returning user who logged out - Go directly to login screen
          print(
              'AUTH_CHECK: User previously logged out, going directly to login screen');
          if (mounted && context.mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    SigninUser(userData: UserModel(userType: 'USER')),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else {
          // New user - Show normal onboarding flow
          print('AUTH_CHECK: New user, showing normal onboarding flow');
          if (mounted && context.mounted) {
            Navigator.pushReplacementNamed(context, '/splash');
          }
        }
      }
    } catch (e) {
      print('AUTH_CHECK: Error in authentication check: $e');

      // On error, check if user previously logged out
      try {
        final bool hasLoggedOut = await _storageService.hasLoggedOut();
        if (hasLoggedOut) {
          // If they were a returning user, go to login
          if (mounted && context.mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    SigninUser(userData: UserModel(userType: 'USER')),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else {
          // Otherwise go to splash
          if (mounted && context.mounted) {
            Navigator.pushReplacementNamed(context, '/splash');
          }
        }
      } catch (storageError) {
        print('AUTH_CHECK: Error checking storage: $storageError');
        // Default to splash screen on double error
        if (mounted && context.mounted) {
          Navigator.pushReplacementNamed(context, '/splash');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToHomeIfAuthenticated() async {
    try {
      // Get the stored authentication data
      final String? userId = await _storageService.getUserId();
      final String? userType = await _storageService.getUserType();
      final String? token = await _storageService.getToken();

      print('AUTH_CHECK: User ID: $userId, User Type: $userType');
      print('AUTH_CHECK: Token exists: ${token != null && token.isNotEmpty}');

      // Check if we have all required data for authentication
      if (userId != null &&
          userType != null &&
          token != null &&
          token.isNotEmpty) {
        // Verify if the token is valid
        bool isTokenValid = false;

        try {
          isTokenValid = await _authService.isAuthenticated();
          print('AUTH_CHECK: Token validation result: $isTokenValid');
        } catch (e) {
          print('AUTH_CHECK: Error validating token: $e');
          isTokenValid = false;
        }

        if (!isTokenValid) {
          print(
              'AUTH_CHECK: Token is invalid, logging out and redirecting to login');
          // Clear auth data and redirect to login
          await _storageService.clearAuthData();
          if (mounted && context.mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    SigninUser(userData: UserModel(userType: 'USER')),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
          return;
        }

        // Create a basic user model with the stored data
        UserModel userData = UserModel(
          userId: userId,
          userType: userType,
        );

        // Try to fetch complete user data from the server with retries
        UserModel? fetchedUser;
        const int maxRetries = 3;

        for (int i = 0; i < maxRetries; i++) {
          try {
            print(
                'AUTH_CHECK: Attempting to fetch user data (attempt ${i + 1})...');
            fetchedUser = await _authService.getUserData(userId);

            if (fetchedUser != null) {
              print('AUTH_CHECK: Successfully fetched user data');
              // If we got valid user data, use it instead of the basic one
              userData = fetchedUser;
              break; // Success, exit retry loop
            } else {
              print('AUTH_CHECK: Failed to get user data (null response)');
            }
          } catch (e) {
            print(
                'AUTH_CHECK: Error fetching user data (attempt ${i + 1}): $e');
            if (i < maxRetries - 1) {
              // Wait a bit before retrying
              await Future.delayed(Duration(seconds: 1 * (i + 1)));
            }
          }
        }

        // Navigate to home page with user data
        if (mounted && context.mounted) {
          print('AUTH_CHECK: Navigating to home with user data');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  HomeScreen(userData: userData),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        print(
            'AUTH_CHECK: Missing required auth data (userId, userType, or token)');
        // Missing required data, clear problematic state and go to login
        await _storageService.clearAuthData();
        if (mounted && context.mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SigninUser(userData: UserModel(userType: 'USER')),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      }
    } catch (e) {
      print('AUTH_CHECK: Error navigating to home: $e');
      // On error, clear auth data and redirect to login
      await _storageService.clearAuthData();
      if (mounted && context.mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                SigninUser(userData: UserModel(userType: 'USER')),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show a loading indicator while we check auth status and navigate
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/mainlogo.jpg',
              width: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Chargement...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
