import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for making network requests
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  // API base URL
  // this is the main endpoint url its should be var depends on the ip
  //var = 192.168.85.26 exmple hada
  // final String _baseUrl = 'http://192.168.144.26:8080/API/Sahtech';
  final String _baseUrl =
      'http://192.168.137.15:8080/API/Sahtech'; // hada li yatbadal

  /// Get auth token from shared preferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get user ID from shared preferences
  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// GET request
  Future<dynamic> get(String endpoint) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return true;
    } else {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }

  /// Upload file using multipart request
  Future<dynamic> uploadFile(String endpoint, String filePath,
      {String fileField = 'file'}) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    print('------- UPLOADING FILE -------');
    print('Endpoint: $_baseUrl/$endpoint');
    print('File path: $filePath');
    print('File exists: ${await File(filePath).exists()}');
    print('File size: ${await File(filePath).length()} bytes');

    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/$endpoint'),
    );

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';
    print('Authorization header added');

    // Add file to request
    request.files.add(
      await http.MultipartFile.fromPath(
        fileField,
        filePath,
      ),
    );
    print('File added to request');

    try {
      // Send request
      print('Sending request...');
      final streamedResponse = await request.send();
      print('Response status code: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);
      print('Response body: ${response.body}');

      // Check response
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('Decoded response: $decodedResponse');
        return decodedResponse;
      } else {
        print('ERROR: Upload failed with status ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception(
            'Failed to upload file: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION during upload: $e');
      throw Exception('Error uploading file: $e');
    }
  }
}
