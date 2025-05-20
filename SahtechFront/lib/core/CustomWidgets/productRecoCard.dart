import 'package:flutter/material.dart';

// A reusable card widget for displaying product recommendations
class ProductRecoCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String productType;
  final Function() onViewPressed;

  const ProductRecoCard({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.productType,
    required this.onViewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            spreadRadius: 1.0,
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
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFFDCF1D4),
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $imageUrl');
                print('Error details: $error');

                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.grey[500]),
                      const SizedBox(height: 4),
                      Text(
                        'Image non disponible',
                        style: TextStyle(
                          fontSize: 10,
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

          const SizedBox(width: 16.0),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productType,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
          ),

          // "Voir" Button
          ElevatedButton(
            onPressed: onViewPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCF1D4),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            ),
            child: const Text(
              'Voir',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
Example usage in a ListView:

ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return ProductRecoCard(
      imageUrl: product.imageUrl,
      productName: product.name,
      productType: product.type,
      onViewPressed: () {
        // TODO: Navigate to Recommendation page with ScanResult data
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => RecommendationScreen(scanResult: product.scanResult),
        //   ),
        // );
      },
    );
  },
)
*/
