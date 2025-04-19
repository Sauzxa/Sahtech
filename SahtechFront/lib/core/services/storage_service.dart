import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save authentication information
  Future<void> saveAuthInfo({
    required String token,
    required String userId,
    required String userType,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userTypeKey, userType);
    await prefs.setBool(_isLoggedInKey, true);
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

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all stored authentication data (for logout)
  Future<void> clearAuthData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTypeKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}
