import 'package:flutter/material.dart';
import '../utils/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/models/user_model.dart';
import '../services/storage_service.dart';

class HistoRecommandationPage extends StatelessWidget {
  final ProductModel product;
  final StorageService _storageService = StorageService();

  HistoRecommandationPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Resultat d\'analyse',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
              onPressed: () {
                _getUserDataAndNavigateToScanner(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Information Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.image, color: Colors.grey),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nutri-Score if available
                  if (product.healthScore > 0 || _getNutriScore() != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getNutriScoreColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getNutriScore() ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommendation Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getRecommendationColor(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getRecommendationIcon(),
                        color: _getRecommendationIconColor(),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.aiRecommendation ??
                        "Aucune recommandation disponible pour ce produit.",
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingredients Section
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (product.ingredients.isEmpty)
                    const Text(
                      "Pas d'ingrédients disponibles",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...product.ingredients
                        .map((ingredient) => _buildIngredientItem(ingredient)),

                  const SizedBox(height: 24),

                  // Additives Section
                  const Text(
                    'Additifs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_getAdditives().isEmpty)
                    const Text(
                      "Pas d'additifs disponibles",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ..._getAdditives().map((additive) {
                      // Split code and description if available
                      final parts = additive.split(':');
                      final code = parts[0].trim();
                      final description =
                          parts.length > 1 ? parts[1].trim() : '';

                      return _buildAdditiveItem(
                          code,
                          description.isNotEmpty
                              ? description
                              : 'Additif alimentaire',
                          '');
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Center item selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            _getUserDataAndNavigateHome(context);
          } else if (index == 1) {
            _getUserDataAndNavigateToHistory(context);
          } else if (index == 2) {
            _getUserDataAndNavigateToScanner(context);
          }
          // TODO: Handle other navigation
        },
      ),
    );
  }

  // Get nutriScore from product data
  String? _getNutriScore() {
    // Use the valeurNutriScore field from the API if available
    if (product.nutritionFacts.containsKey('valeurNutriScore')) {
      return product.nutritionFacts['valeurNutriScore'];
    }
    return null;
  }

  // Get color based on nutriScore or recommendation type
  Color _getNutriScoreColor() {
    final score = _getNutriScore();
    if (score == null) {
      return Colors.grey;
    }

    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF6BB324); // Green
      case 'B':
        return const Color(0xFF99C140); // Light green
      case 'C':
        return const Color(0xFFFFC234); // Yellow
      case 'D':
        return const Color(0xFFFF9800); // Orange
      case 'E':
        return const Color(0xFFE63946); // Red
      default:
        return Colors.grey;
    }
  }

  // Get color based on recommendation type
  Color _getRecommendationColor() {
    final type = product.recommendationType?.toLowerCase() ?? '';

    if (type.contains('avoid') || type == 'avoid') {
      return const Color(0xFFFADEDF); // Light red
    } else if (type.contains('caution') || type == 'caution') {
      return const Color(0xFFFFF3CD); // Light yellow
    } else if (type.contains('recommended') || type == 'recommended') {
      return const Color(0xFFE6F4E1); // Light green
    } else {
      return const Color(0xFFE6F4E1); // Default light green
    }
  }

  // Get icon based on recommendation type
  IconData _getRecommendationIcon() {
    final type = product.recommendationType?.toLowerCase() ?? '';

    if (type.contains('avoid') || type == 'avoid') {
      return Icons.cancel;
    } else if (type.contains('caution') || type == 'caution') {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  // Get icon color based on recommendation type
  Color _getRecommendationIconColor() {
    final type = product.recommendationType?.toLowerCase() ?? '';

    if (type.contains('avoid') || type == 'avoid') {
      return Colors.red[700]!;
    } else if (type.contains('caution') || type == 'caution') {
      return Colors.orange[700]!;
    } else {
      return Colors.green[700]!;
    }
  }

  // Get additives from product data
  List<String> _getAdditives() {
    if (product.nutritionFacts.containsKey('nomAdditif') &&
        product.nutritionFacts['nomAdditif'] is List) {
      return List<String>.from(product.nutritionFacts['nomAdditif']);
    }
    return [];
  }

  Widget _buildIngredientItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        name,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildAdditiveItem(String code, String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $code ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              description.isEmpty ? name : '($name): $description',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Get user data and navigate to home
  Future<void> _getUserDataAndNavigateHome(BuildContext context) async {
    try {
      final userId = await _storageService.getUserId();
      final userType = await _storageService.getUserType();

      if (userId != null && userType != null) {
        final user = UserModel(
          userId: userId,
          userType: userType,
        );

        Navigator.of(context).pushReplacementNamed('/home', arguments: user);
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('Error getting user data: $e');
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // Get user data and navigate to scanner
  Future<void> _getUserDataAndNavigateToScanner(BuildContext context) async {
    try {
      final userId = await _storageService.getUserId();
      final userType = await _storageService.getUserType();

      if (userId != null && userType != null) {
        final user = UserModel(
          userId: userId,
          userType: userType,
        );

        Navigator.pushNamed(context, '/scanner', arguments: user);
      } else {
        Navigator.pushNamed(context, '/scanner');
      }
    } catch (e) {
      print('Error getting user data: $e');
      Navigator.pushNamed(context, '/scanner');
    }
  }

  // Get user data and navigate to history
  Future<void> _getUserDataAndNavigateToHistory(BuildContext context) async {
    try {
      final userId = await _storageService.getUserId();
      final userType = await _storageService.getUserType();

      if (userId != null && userType != null) {
        final user = UserModel(
          userId: userId,
          userType: userType,
        );

        Navigator.of(context).pushReplacementNamed('/history', arguments: user);
      } else {
        Navigator.of(context).pushReplacementNamed('/history');
      }
    } catch (e) {
      print('Error getting user data: $e');
      Navigator.of(context).pushReplacementNamed('/history');
    }
  }
}
