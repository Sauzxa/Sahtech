import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/utils/models/user_model.dart';

class AuthService {
  // Replace with your MongoDB API endpoint
  static const String apiBaseUrl = 'YOUR_MONGODB_API_URL';

  // Registration method
  Future<Map<String, dynamic>> registerUser(UserModel user) async {
    try {
      // Prepare the user data for registration
      final Map<String, dynamic> userData = user.toAuthMap();

      // Make API call to your MongoDB backend
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      // Check response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully registered
        final Map<String, dynamic> responseData = json.decode(response.body);

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

      // Make API call to your MongoDB backend
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );

      // Check response
      if (response.statusCode == 200) {
        // Successfully logged in
        final Map<String, dynamic> responseData = json.decode(response.body);
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
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
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
}
