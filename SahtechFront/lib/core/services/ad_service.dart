import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/models/ad_model.dart';

class AdService {
  // Base URL of your friend's website API
  // Replace with actual API endpoint when available
  static const String baseUrl = 'https://your-dashboard-api.com/api';

  // API key or token for authentication
  static const String apiKey = 'your_api_key_here';

  // Fetch all active ads
  static Future<List<AdModel>> getActiveAds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ads/active'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AdModel.fromMap(json)).toList();
      } else {
        // Return empty list if error
        print('Error fetching ads: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception when fetching ads: $e');
      // For development, return some mock ads
      return _getMockAds();
    }
  }

  // Mock ads for development and testing
  static List<AdModel> _getMockAds() {
    return [
      AdModel(
        id: '1',
        companyName: 'Antiflex',
        imageUrl: 'https://i.ibb.co/P1Hh2BZ/antiflex-ad.jpg',
        title: 'Soulager naturellement la douleur',
        description:
            'Un médicament naturel pour soulager les douleurs articulaires',
        link: 'https://example.com/antiflex',
        isActive: true,
        state: 'ACCEPTEE',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: '2',
        companyName: 'Bio Nutrition',
        imageUrl: 'https://i.ibb.co/WcVxzRN/nutrition-ad.jpg',
        title: 'Alimentation bio pour votre santé',
        description: 'Découvrez notre gamme de produits bio et naturels',
        link: 'https://example.com/bionutrition',
        isActive: true,
        state: 'ACCEPTEE',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }

  // This method will be used to refresh ads periodically
  static Future<List<AdModel>> refreshAds() async {
    // In production, this would fetch fresh ads from the server
    // For now, it returns the mock ads
    return _getMockAds();
  }
}
