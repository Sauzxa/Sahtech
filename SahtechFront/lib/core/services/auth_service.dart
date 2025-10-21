import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/storage_service.dart';

class AuthService {
  // Spring Boot API endpoint
  static const String apiBaseUrl =
      // final String _baseUrl = 'http://192.168.144.26:8080/API/Sahtech'; hada li yatbadal
      // final String _baseUrl = 'http://192.168.144.26:8080/API/Sahtech'; hada li yatbadal
      // Use the Android emulator host mapping (no spaces): 10.0.2.2:8080
      // For Genymotion use 10.0.3.2, for a physical device use the host machine IP address.
      // NOTE: avoid accidental spaces like "10.0.2.2 :8080" which produce invalid URLs.
      'http://10.0.2.2:8080';
  final StorageService _storageService = StorageService();

  // Registration method
  Future<Map<String, dynamic>> registerUser(UserModel user) async {
    try {
      // Prepare the user data for registration
      final Map<String, dynamic> userData = user.toAuthMap();

      // Enhanced DEBUG logging - Show complete user data details
      print('--- REGISTRATION DATA DETAILS ---');
      print('Name: ${user.name}');
      print('Email: ${user.email}');
      print('User Type: ${user.userType}');
      print('Has Chronic Disease: ${user.hasChronicDisease}');
      print('Chronic Conditions: ${user.chronicConditions}');
      print('Has Allergies: ${user.hasAllergies}');
      print('Allergies: ${user.allergies}');
      print('Does Exercise: ${user.doesExercise}');
      print('Health Goals: ${user.healthGoals}');
      print('Height: ${user.height}, Weight: ${user.weight}');
      print('Date of Birth: ${user.dateOfBirth}');
      print('PhotoUrl: ${user.photoUrl}');
      print('--- END REGISTRATION DATA DETAILS ---');

      // Check explicitly if photoUrl is in the userData map
      print('Is photoUrl in userData map? ${userData.containsKey("photoUrl")}');
      print('photoUrl value in userData: ${userData["photoUrl"]}');

      // Force add photoUrl directly to ensure it's in the request
      userData['photoUrl'] = user.photoUrl ?? "";
      print(
          'After force adding - Is photoUrl in userData map? ${userData.containsKey('photoUrl')}');
      print('photoUrl value: "${userData['photoUrl']}"');

      // DEBUG: Print request payload as JSON
      print('Sending registration data: ${json.encode(userData)}');

      // Extra debug: Print request keys in sorted order
      List<String> keys = userData.keys.toList();
      keys.sort();
      print('Registration data keys (sorted): $keys');

      // Try to get any existing token (if user is already logged in)
      final String? existingToken = await _storageService.getToken();

      // Create request headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Add authorization header if token exists
      if (existingToken != null && existingToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $existingToken';
      }

      // Log the full URL for debugging
      final registerUrl = '$apiBaseUrl/API/Sahtech/auth/register';
      print('Sending registration request to: $registerUrl');
      print('With headers: $headers');

      // Make API call to Spring Boot backend
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: headers,
        body: json.encode(userData),
      );

      // DEBUG: Print response
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      // Enhanced error logging
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Registration failed with status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        try {
          final errorData = json.decode(response.body);
          print('Decoded error response: $errorData');
        } catch (e) {
          print('Could not decode error response: ${response.body}');
        }
      }

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
  Future<Map<String, dynamic>> loginUser(String email, String password,
      {String userType = 'USER'}) async {
    try {
      // Prepare login data
      final Map<String, dynamic> loginData = {
        'email': email,
        'password': password,
        'userType': userType,
      };

      // DEBUG: Print login data
      print('Sending login data: ${json.encode(loginData)}');

      // Make API call to Spring Boot backend
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/API/Sahtech/auth/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(loginData),
          )
          .timeout(const Duration(seconds: 15)); // Add timeout

      // DEBUG: Print response
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      // Check response
      if (response.statusCode == 200) {
        // Successfully logged in
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract values with fallbacks
        final token = responseData['token'];
        final userId = responseData['userId'] ?? responseData['id'] ?? '';
        final responseUserType =
            responseData['userType'] ?? responseData['role'] ?? userType;

        // Validate required data
        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'message': 'Login failed: Invalid or missing token in response',
            'error': 'Missing token'
          };
        }

        if (userId.isEmpty) {
          return {
            'success': false,
            'message': 'Login failed: Invalid or missing user ID in response',
            'error': 'Missing user ID'
          };
        }

        // Store JWT token and user info, including email and password for refresh
        await _storageService.saveAuthInfo(
          token: token,
          userId: userId,
          userType: responseUserType,
          email: email,
          password: password,
        );

        return {
          'success': true,
          'message': 'User logged in successfully',
          'data': responseData
        };
      } else {
        // Parse error message if available
        String errorMessage = 'Login failed: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Fall back to default message if can't parse error
        }

        // Login failed
        return {
          'success': false,
          'message': errorMessage,
          'error': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }

  // Method to get complete user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      // Get the JWT token
      final String? token = await _storageService.getToken();
      final String? userType = await _storageService.getUserType();

      if (token == null) {
        print('No authentication token found');
        return null;
      }

      print(
          'Fetching user data from API: $apiBaseUrl/API/Sahtech/Utilisateurs/$userId');
      print(
          'Using token: ${token.length > 10 ? token.substring(0, 10) + '...' : token}');

      // Ensure proper formatting of the request with Bearer token
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('Request headers: $headers');

      // Add retries for network stability
      int maxRetries = 3;
      int retryCount = 0;
      http.Response? response;

      while (retryCount < maxRetries) {
        try {
          response = await http
              .get(
                Uri.parse('$apiBaseUrl/API/Sahtech/Utilisateurs/$userId'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 15));

          // Break the loop if successful
          break;
        } catch (e) {
          retryCount++;
          print('Request attempt $retryCount failed: $e');
          if (retryCount >= maxRetries) rethrow;

          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount));
        }
      }

      if (response == null) {
        throw Exception(
            'Failed to make HTTP request after $maxRetries attempts');
      }

      print('GET user data response status: ${response.statusCode}');
      print('GET user data response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> userData;
        try {
          userData = json.decode(response.body);
        } catch (e) {
          print('Error parsing user data JSON: $e');
          return null;
        }

        print('User data successfully parsed: ${userData.keys.toList()}');

        // Try to create a UserModel from the response
        try {
          final UserModel user = UserModel.fromMap(userData);

          // Ensure user ID is set correctly
          if (user.userId == null || user.userId!.isEmpty) {
            user.userId = userId;
          }

          // Ensure userType is set correctly
          if (userType != null &&
              (user.userType.isEmpty || user.userType == 'unknown')) {
            user.userType = userType;
          }

          // Debug photoUrl
          print(
              'User data contains photoUrl: ${userData.containsKey('photoUrl')}');
          if (userData.containsKey('photoUrl')) {
            print('photoUrl from API: ${userData['photoUrl']}');
            // Make sure the photoUrl is set if photoUrl is available
            if (user.photoUrl == null && userData['photoUrl'] != null) {
              user.photoUrl = userData['photoUrl'];
              print('Set photoUrl from photoUrl: ${user.photoUrl}');
            }
          }

          // Log the user data for debugging
          print(
              'User model created: ${user.name} (${user.email}), ID: ${user.userId}, Type: ${user.userType}, Profile Image: ${user.photoUrl}');

          return user;
        } catch (e) {
          print('Error creating user model from data: $e');

          // Fallback: Create a minimal user model with the basic data we have
          final fallbackUser = UserModel(
            userType: userType ?? 'USER',
            userId: userId,
            name: userData['prenom'] != null && userData['nom'] != null
                ? '${userData['prenom']} ${userData['nom']}'
                : null,
            email: userData['email'],
          );

          print('Created fallback user model: ${fallbackUser.name}');
          return fallbackUser;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error: ${response.statusCode}');
        // Token might be expired, try to clear auth data
        await _storageService.clearAuthData();
        return null;
      } else {
        print(
            'Error getting user data: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception getting user data: $e');
      return null;
    }
  }

  // Logout method
  Future<bool> logout() async {
    try {
      final String? token = await _storageService.getToken();
      final String? userId = await _storageService.getUserId();

      if (token == null) {
        print('No token to logout');
        await _storageService.clearAuthData();
        return true;
      }

      // Call server-side logout with timeout
      try {
        // Create a proper LogoutRequest body as required by the backend
        final logoutRequestBody = {'token': token, 'userId': userId};

        print('Sending logout request: ${json.encode(logoutRequestBody)}');

        final response = await http
            .post(
              Uri.parse('$apiBaseUrl/API/Sahtech/auth/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(logoutRequestBody),
            )
            .timeout(
                const Duration(seconds: 10)); // Add timeout directly to request

        // DEBUG: Print response
        print('Logout response status: ${response.statusCode}');
        print('Logout response body: ${response.body}');

        // Regardless of server response, clear local storage
        await _storageService.clearAuthData();

        // Check if server logout was successful
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return responseData['success'] ?? true;
        }
      } catch (e) {
        print('Server logout error: $e');
        // If server call fails, just proceed with local logout
      }

      // Always clear local storage
      await _storageService.clearAuthData();
      return true; // Return success since we cleared local data
    } catch (e) {
      print('Error during logout: $e');
      // Still clear local data even if something else fails
      try {
        await _storageService.clearAuthData();
      } catch (storageError) {
        print('Error clearing storage: $storageError');
      }
      return true; // Still return true as we want to navigate to login
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storageService.isLoggedIn();
  }
}
