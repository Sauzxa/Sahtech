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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
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
