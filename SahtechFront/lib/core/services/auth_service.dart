import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/storage_service.dart';

class AuthService {
  // Spring Boot API endpoint
  static const String apiBaseUrl = 'http://localhost:8080';

  final StorageService _storageService = StorageService();

  // Registration method
  Future<Map<String, dynamic>> registerUser(UserModel user) async {
    try {
      // Prepare the user data for registration
      final Map<String, dynamic> userData = user.toAuthMap();

      // DEBUG: Print request payload
      print('Sending registration data: ${json.encode(userData)}');

      // Make API call to Spring Boot backend
      final response = await http.post(
        Uri.parse('$apiBaseUrl/API/Sahtech/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      // DEBUG: Print response
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      // Check response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully registered
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Store JWT token and user info
        if (responseData['token'] != null) {
          await _storageService.saveAuthInfo(
            token: responseData['token'],
            userId: responseData['userId'] ?? '',
            userType: user.userType,
          );
        }

        // Update user with the ID from MongoDB
        if (responseData['userId'] != null) {
          user.userId = responseData['userId'];
        }

        // Clear the password for security
        user.clearPassword();

        return {
          'success': true,
          'message': 'User registered successfully',
          'data': responseData
        };
      } else {
        // Registration failed
        return {
          'success': false,
          'message': 'Registration failed: ${response.statusCode}',
          'error': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration error',
        'error': e.toString()
      };
    }
  }

  // Login method
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Prepare login data
      final Map<String, dynamic> loginData = {
        'email': email,
        'password': password,
      };

      // DEBUG: Print login data
      print('Sending login data: ${json.encode(loginData)}');

      // Make API call to Spring Boot backend
      final response = await http.post(
        Uri.parse('$apiBaseUrl/API/Sahtech/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );

      // DEBUG: Print response
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      // Check response
      if (response.statusCode == 200) {
        // Successfully logged in
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Store JWT token and user info
        if (responseData['token'] != null) {
          await _storageService.saveAuthInfo(
            token: responseData['token'],
            userId: responseData['userId'] ?? responseData['id'] ?? '',
            userType:
                responseData['userType'] ?? responseData['role'] ?? 'USER',
          );
        }

        return {
          'success': true,
          'message': 'User logged in successfully',
          'data': responseData
        };
      } else {
        // Login failed
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
          'error': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error',
        'error': e.toString()
      };
    }
  }

  // Method to get complete user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      // Get the JWT token
      final String? token = await _storageService.getToken();

      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/API/Sahtech/Utilisateurs/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return UserModel.fromMap(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _storageService.clearAuthData();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storageService.isLoggedIn();
  }
}
