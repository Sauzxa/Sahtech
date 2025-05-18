import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/product_model.dart';
import 'dart:math';

class ProductRecommendationScreen extends StatefulWidget {
  final ProductModel product;

  const ProductRecommendationScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductRecommendationScreen> createState() =>
      _ProductRecommendationScreenState();
}

class _ProductRecommendationScreenState
    extends State<ProductRecommendationScreen> {
  // For now, we'll use mock data for the recommendations and additives
  // In a real app, these would come from an API call or be part of the product model
  late String recommendation;
  late List<String> ingredients;
  late List<Map<String, String>> additives;

  @override
  void initState() {
    super.initState();

    // Enhanced logging to debug product data
    print('=== PRODUCT RECOMMENDATION SCREEN ===');
    print('Product name: ${widget.product.name}');
    print('Product ID: ${widget.product.id}');
    print('Product barcode: ${widget.product.barcode}');
    print('AI Recommendation: ${widget.product.aiRecommendation}');
    print(
        'AI Recommendation length: ${widget.product.aiRecommendation?.length ?? 0}');
    print('Recommendation Type: ${widget.product.recommendationType}');
    print('Ingredients count: ${widget.product.ingredients.length}');
    print('Allergens count: ${widget.product.allergens.length}');

    // Parse and format AI recommendation if available
    recommendation = _formatAiRecommendation(widget.product.aiRecommendation);
    print(
        'Formatted recommendation: ${recommendation.substring(0, min(50, recommendation.length))}...');

    // Use product ingredients, with a fallback if empty
    ingredients = widget.product.ingredients;
    if (ingredients.isEmpty) {
      ingredients = ['Informations sur les ingrédients non disponibles'];
    }

    // Process additives from product if available, create empty list if none
    if (widget.product.allergens.isNotEmpty) {
      // Convert allergens to additives format
      additives = widget.product.allergens
          .map((allergen) => {
                'code': 'Allergène',
                'name': allergen,
                'function': 'Substance allergène potentielle',
              })
          .toList();
    } else {
      // Empty additives list with a message if none provided
      additives = [
        {
          'code': 'Info',
          'name': 'Aucun allergène déclaré',
          'function': 'Consultez l\'emballage pour confirmation',
        }
      ];
    }

    // Display Nutri-Score details
    print('Health Score: ${widget.product.healthScore}');
    print(
        'Nutri-Score Letter: ${_getNutriScoreLetter(widget.product.healthScore)}');
  }

  // Format and structure the AI recommendation text
  String _formatAiRecommendation(String? rawRecommendation) {
    if (rawRecommendation == null || rawRecommendation.isEmpty) {
      // Log that we're using the default message
      print('No AI recommendation available - using default message');
      return "Nous n'avons pas encore d'analyse personnalisée pour ce produit. "
          "Vérifiez les ingrédients et allergènes ci-dessous pour vous assurer "
          "que ce produit convient à votre régime alimentaire.";
    }

    // Log the raw recommendation for debugging
    print('AI recommendation found: $rawRecommendation');

    // Add paragraph breaks where appropriate to improve readability
    // Look for key phrases that indicate new sections
    String formatted = rawRecommendation
        // Major section breaks
        .replaceAll(". Alternative", ".\n\nAlternatives recommandées:")
        .replaceAll("Alternatives:", "\n\nAlternatives recommandées:")
        .replaceAll(". Si vous avez", ".\n\nConseil médical: Si vous avez")
        .replaceAll("Précautions:", "\n\nPrécautions:")
        .replaceAll("À noter:", "\n\nÀ noter:")
        .replaceAll(". Pour", ".\n\nPour")
        .replaceAll(". En conclusion", ".\n\nEn conclusion")
        // Line breaks for readability
        .replaceAll(". De plus", ".\nDe plus")
        .replaceAll(". Par ailleurs", ".\nPar ailleurs")
        .replaceAll(". Cependant", ".\nCependant")
        .replaceAll(". Toutefois", ".\nToutefois")
        .replaceAll(". Nous recommandons", ".\n\nNous recommandons");

    return formatted;
  }

  // Function to get the Nutri-score color
  Color _getNutriScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.lightGreen;
    if (score >= 2.0) return Colors.yellow;
    if (score >= 1.0) return Colors.orange;
    return Colors.red;
  }

  // Function to get the Nutri-score letter
  String _getNutriScoreLetter(double score) {
    if (score >= 4.0) return 'A';
    if (score >= 3.0) return 'B';
    if (score >= 2.0) return 'C';
    if (score >= 1.0) return 'D';
    return 'E';
  }

  // Get color based on recommendation type
  Color _getRecommendationColor() {
    final type = widget.product.recommendationType?.toLowerCase() ?? 'caution';
    switch (type) {
      case 'recommended':
        return Colors.green.shade50;
      case 'avoid':
        return Colors.red.shade50;
      case 'caution':
      default:
        return Colors.amber.shade50;
    }
  }

  // Get icon based on recommendation type
  IconData _getRecommendationIcon() {
    final type = widget.product.recommendationType?.toLowerCase() ?? 'caution';
    switch (type) {
      case 'recommended':
        return Icons.check_circle;
      case 'avoid':
        return Icons.do_not_disturb;
      case 'caution':
      default:
        return Icons.warning_amber;
    }
  }

  // Get text based on recommendation type for accessibility
  String _getRecommendationTypeText() {
    final type = widget.product.recommendationType?.toLowerCase() ?? 'caution';
    switch (type) {
      case 'recommended':
        return 'Recommandé';
      case 'avoid':
        return 'À éviter';
      case 'caution':
      default:
        return 'Attention';
    }
  }

  // Get badge color based on recommendation type
  Color _getRecommendationBadgeColor() {
    final type = widget.product.recommendationType?.toLowerCase() ?? 'caution';
    switch (type) {
      case 'recommended':
        return Colors.green;
      case 'avoid':
        return Colors.red;
      case 'caution':
      default:
        return Colors.amber;
    }
  }

  // Get badge text color based on recommendation type
  Color _getRecommendationBadgeTextColor() {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resultat d\'analyse',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {
              // Share functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Partage en cours de développement')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product summary card
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      widget.product.imageUrl,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Show a placeholder when image fails to load
                        return Container(
                          width: 60.w,
                          height: 60.w,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.no_food,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Nutri-score
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      gradient: LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.lightGreen,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10.r,
                          backgroundColor:
                              _getNutriScoreColor(widget.product.healthScore),
                          child: Text(
                            _getNutriScoreLetter(widget.product.healthScore),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Recommendation section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _getRecommendationColor(),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommendation title with type
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _getRecommendationIcon(),
                              color: Colors.black87,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Recommendation IA',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getRecommendationBadgeColor(),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _getRecommendationTypeText(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _getRecommendationBadgeTextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Recommendation text with better formatting
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // Additional information button if needed
                  if (_hasAlternatives() || _hasWarnings())
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: Icon(
                              Icons.info_outline,
                              size: 18.sp,
                              color: AppColors.lightTeal,
                            ),
                            label: Text(
                              'Plus d\'informations',
                              style: TextStyle(
                                color: AppColors.lightTeal,
                                fontSize: 12.sp,
                              ),
                            ),
                            onPressed: () {
                              // Show detailed information modal
                              _showDetailedRecommendationModal();
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Ingredients section
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5CF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients title
                  Row(
                    children: [
                      Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.category_outlined,
                        color: Colors.black87,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Ingredients list
                  ...ingredients
                      .map((ingredient) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),

            // Additives section
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5CF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Additives title
                  Row(
                    children: [
                      Text(
                        'Additifs',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.science_outlined,
                        color: Colors.black87,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Additives list
                  ...additives
                      .map((additive) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${additive['code']} (${additive['name']}) : ${additive['function']}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Scanner tab
        selectedItemColor: AppColors.lightTeal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_outlined),
            label: 'Consulter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  bool _hasAlternatives() {
    // Check if the AI recommendation contains alternatives section
    if (widget.product.aiRecommendation == null) return false;

    final String aiRec = widget.product.aiRecommendation!.toLowerCase();
    return aiRec.contains('alternative') ||
        aiRec.contains('remplacer') ||
        aiRec.contains('suggestion') ||
        aiRec.contains('recommand') ||
        aiRec.contains('essayer plutôt');
  }

  bool _hasWarnings() {
    // Check if the AI recommendation contains warnings
    if (widget.product.aiRecommendation == null) return false;

    final String aiRec = widget.product.aiRecommendation!.toLowerCase();
    return aiRec.contains('éviter') ||
        aiRec.contains('attention') ||
        aiRec.contains('précaution') ||
        aiRec.contains('risque') ||
        aiRec.contains('allergen') ||
        aiRec.contains('déconseill') ||
        aiRec.contains('consulter un');
  }

  void _showDetailedRecommendationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Détails de la Recommendation',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Full recommendation text
                      Text(
                        widget.product.aiRecommendation ??
                            'Aucune recommendation disponible',
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.6,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Additional notes
                      Text(
                        'Ces recommandations sont générées par l\'IA et sont basées sur les informations disponibles sur ce produit et votre profil de santé. Consultez un professionnel de santé pour des conseils personnalisés.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
