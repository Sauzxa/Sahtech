import 'package:flutter/material.dart';

// A reusable card widget for displaying product recommendations
class ProductRecoCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String productType;
  final String? recommendationType;
  final Function() onViewPressed;

  const ProductRecoCard({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.productType,
    this.recommendationType,
    required this.onViewPressed,
  }) : super(key: key);

  // Helper method to get recommendation color based on type
  Color _getRecommendationColor() {
    if (recommendationType == null) return Colors.grey;

    switch (recommendationType!.toLowerCase()) {
      case 'recommend':
      case 'recommended':
        return Colors.green;
      case 'caution':
        return Colors.orange;
      case 'avoid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get recommendation icon based on type
  IconData _getRecommendationIcon() {
    if (recommendationType == null) return Icons.help_outline;

    switch (recommendationType!.toLowerCase()) {
      case 'recommend':
      case 'recommended':
        return Icons.check_circle_outline;
      case 'caution':
        return Icons.warning_amber_outlined;
      case 'avoid':
        return Icons.not_interested;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF9FE870),
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $imageUrl');
                print('Error details: $error');

                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          color: Colors.grey[500], size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Image non disponible',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12.0),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      productType.isEmpty ? 'Non classé' : productType,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.0,
                      ),
                    ),
                    if (recommendationType != null) ...[
                      const SizedBox(width: 8.0),
                      Icon(
                        _getRecommendationIcon(),
                        color: _getRecommendationColor(),
                        size: 16.0,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3.0),
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // "Voir" Button
          ElevatedButton(
            onPressed: onViewPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9FE870),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              minimumSize: const Size(60, 30),
            ),
            child: const Text(
              'Voir',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

