import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _hasLoggedOutKey = 'has_logged_out';
  static const String _emailKey = 'user_email';

  // For secure storage
  final _secureStorage = const FlutterSecureStorage();
  static const String _passwordKey = 'user_password';

  // Save authentication information
  Future<void> saveAuthInfo({
    required String token,
    required String userId,
    required String userType,
    String? email,
    String? password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userTypeKey, userType);
    await prefs.setBool(_isLoggedInKey, true);

    // Store email if provided
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_emailKey, email);
    }

    // Store password securely if provided
    if (password != null && password.isNotEmpty) {
      await _secureStorage.write(key: _passwordKey, value: password);
    }
  }

  // Get the stored JWT token
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get the stored user ID
  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get the stored user type
  Future<String?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Get the stored email
  Future<String?> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Get the securely stored password
  Future<String?> getSecurePassword() async {
    return await _secureStorage.read(key: _passwordKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Check if user has previously logged out
  Future<bool> hasLoggedOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasLoggedOutKey) ?? false;
  }

  // Clear all stored authentication data (for logout)
  Future<void> clearAuthData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_emailKey);
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_hasLoggedOutKey, true);

    // Clear secure storage
    await _secureStorage.delete(key: _passwordKey);
  }

  // Reset app state completely (for debugging or app reset)
  Future<void> resetAppState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }
}
