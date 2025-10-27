import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/utils/models/ad_model.dart';
import 'package:sahtech/core/utils/models/product_model.dart';
import 'package:sahtech/core/services/api_error_handler.dart';

/// API Service for making network requests and domain operations
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // API base URL
  final String _baseUrl = 'http://10.0.2.2:8080/API/Sahtech';
  String get baseUrl => _baseUrl;

  // ===== Auth and local storage helpers =====

  /// Get auth token from shared preferences (robust across possible keys)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    token ??= prefs.getString('token');
    token ??= prefs.getString('jwt_token');
    if (token != null && token.startsWith('Bearer ')) {
      token = token.substring(7);
    }
    return token;
  }

  /// Get user ID from shared preferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // ===== Generic HTTP helpers =====

  Future<dynamic> get(String endpoint) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/$endpoint'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to upload file: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  // ===== Domain-specific APIs migrated from MockApiService =====

  // Nutritionists
  List<NutritionisteModel>? _nutritionistsCache;
  DateTime? _nutritionistsCacheTime;

  Future<List<NutritionisteModel>> getNutritionists({
    Duration ttl = const Duration(minutes: 2),
  }) async {
    try {
      if (_nutritionistsCache != null && _nutritionistsCacheTime != null) {
        final age = DateTime.now().difference(_nutritionistsCacheTime!);
        if (age <= ttl) {
          return List.from(_nutritionistsCache!);
        }
      }

      final token = await _getToken();
      final String url = '$_baseUrl/Nutrisionistes/All';
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> nutritionistsJson = json.decode(response.body);
        final List<NutritionisteModel> fetched = nutritionistsJson
            .map((json) => NutritionisteModel.fromMap(json))
            .toList();
        _nutritionistsCache = List.from(fetched);
        _nutritionistsCacheTime = DateTime.now();
        return List.from(fetched);
      }
    } catch (_) {}
    return [];
  }

  // Ads
  Future<List<AdModel>> getActiveAds() async {
    try {
      final List<AdModel> serverAds = await getAdsFromServer();
      if (serverAds.isNotEmpty) return serverAds;
    } catch (_) {}
    return [];
  }

  Future<List<AdModel>> getAdsFromServer() async {
    try {
      final String adsUrl = '$_baseUrl/Publicites';
      final token = await _getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http
          .get(Uri.parse(adsUrl), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<AdModel> ads = jsonData
            .map((data) => AdModel(
                  id: data['id'] ?? '',
                  companyName:
                      data['partenaire']?['nom'] ?? data['titre'] ?? '',
                  imageUrl: data['imageUrl'] ?? '',
                  title: data['titre'] ?? '',
                  description: data['description'] ?? '',
                  link: data['lienRedirection'] ?? '',
                  isActive: data['etatPublicite'] == 'PUBLIEE',
                  state: data['statusPublicite'] ?? 'EN_ATTENTE',
                  startDate: data['dateDebut'] != null
                      ? DateTime.parse(data['dateDebut'])
                      : DateTime.now(),
                  endDate: data['dateFin'] != null
                      ? DateTime.parse(data['dateFin'])
                      : DateTime.now().add(const Duration(days: 30)),
                ))
            .where((ad) => ad.imageUrl.isNotEmpty && ad.isActive)
            .toList();
        return ads;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Products
  Future<ProductModel?> getProductByBarcode(String barcode,
      {String? userId}) async {
    try {
      String cleanBarcode = ApiErrorHandler.normalizeBarcode(barcode);
      if (cleanBarcode.isEmpty) return null;

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return null;
      }

      String productUrl = '$_baseUrl/scan/barcode/$cleanBarcode';
      if (userId != null && userId.isNotEmpty) {
        productUrl += '?userId=$userId';
      }

      final token = await _getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(Uri.parse(productUrl), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (ApiErrorHandler.isValidProductResponse(response)) {
        final productData = json.decode(response.body);
        if (!productData.containsKey('barcode')) {
          productData['barcode'] = cleanBarcode;
        }
        return ProductModel.fromJson(productData);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPersonalizedRecommendation(
    String userId,
    String productId, {
    String? flutterCallbackUrl,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      String recommendationUrl =
          '$_baseUrl/recommendation/user/$userId/data?productId=$productId';
      if (flutterCallbackUrl != null && flutterCallbackUrl.isNotEmpty) {
        final encodedCallback = Uri.encodeComponent(flutterCallbackUrl);
        recommendationUrl += '&flutterCallbackUrl=$encodedCallback';
      }

      final response = await http.get(
        Uri.parse(recommendationUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('recommendation')) {
          final recText = data['recommendation'] as String?;
          if (recText != null && recText.isNotEmpty) return data;
        }
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final nested = data['data'] as Map<String, dynamic>;
          if (nested.containsKey('recommendation')) {
            return {
              'recommendation': nested['recommendation'],
              'recommendation_type': nested['recommendation_type'] ?? 'caution',
            };
          }
        }
        return null;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<ProductModel?> scanProduct(String barcode, {String? userId}) async {
    if (userId == null || userId.isEmpty) {
      // Proceed without personalized recommendation
    }
    final apiProduct = await getProductByBarcode(barcode, userId: userId);
    if (apiProduct != null) {
      if (userId != null && userId.isNotEmpty) {
        try {
          final String callbackUrl = getDirectRecommendationCallbackUrl();
          final freshRecommendation = await getPersonalizedRecommendation(
            userId,
            apiProduct.id,
            flutterCallbackUrl: callbackUrl,
          );
          if (freshRecommendation != null) {
            final recText = freshRecommendation['recommendation'] as String?;
            final recType =
                freshRecommendation['recommendation_type'] as String?;
            if (recText != null && recText.trim().isNotEmpty) {
              apiProduct.aiRecommendation = recText;
              apiProduct.recommendationType = recType ?? 'caution';
            }
          }
        } catch (_) {}
      }
      return apiProduct;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserHealthProfile(String userId) async {
    try {
      final String userUrl = '$_baseUrl/users/$userId/health-profile';
      final response = await http.get(Uri.parse(userUrl), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserScannedProducts(
      String userId) async {
    final String url = '$_baseUrl/HistoriqueScan/utilisateur/$userId';
    try {
      final token = await _getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final productsList =
            jsonData.map((item) => item as Map<String, dynamic>).toList();
        return productsList;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Compatibility stub: list of products for a user (replace with real endpoint when available)
  Future<List<ProductModel>> getUserProducts(String userId) async {
    return [];
  }

  Future<void> debugCheckBarcode(String barcode) async {
    try {
      final String checkUrl = '$_baseUrl/scan/check/$barcode';
      await http.get(Uri.parse(checkUrl), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  // ===== Direct recommendation callback plumbing =====
  static Function(Map<String, dynamic>)? _directRecommendationCallback;

  static void registerDirectRecommendationCallback(
      Function(Map<String, dynamic>) callback) {
    _directRecommendationCallback = callback;
  }

  static void unregisterDirectRecommendationCallback() {
    _directRecommendationCallback = null;
  }

  static void handleDirectRecommendation(
      Map<String, dynamic> recommendationData) {
    if (_directRecommendationCallback != null) {
      _directRecommendationCallback!(recommendationData);
    }
  }

  String getDirectRecommendationCallbackUrl() {
    return 'https://sahtech-app.example/api/recommendations/callback';
  }
}
