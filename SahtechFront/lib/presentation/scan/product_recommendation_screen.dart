import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/product_model.dart';

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

    // Generate mock recommendation based on the product
    recommendation =
        "Attention ! Le fromage frais de Soummam contient des ingrédients susceptibles de déclencher une réaction allergique en raison de votre sensibilité déclarée. Pour une alternative plus adaptée à votre régime, nous vous recommandons d'opter pour Soummam Tartifast, qui est exempt des allergènes concernés et plus sûr pour votre consommation.";

    // Mock ingredients list
    ingredients = [
      'Lait reconstitué écrémé',
      'Crème fraîche',
      'Ferments lactiques',
      'Présure',
    ];

    // Mock additives
    additives = [
      {
        'code': 'E330',
        'name': 'Acide citrique',
        'function': 'Régulateur d\'acidité',
      },
      {
        'code': 'E202',
        'name': 'Sorbate de potassium',
        'function': 'Conservateur',
      },
      {
        'code': 'E410',
        'name': 'Gomme de caroube',
        'function': 'Stabilisant pour la texture',
      },
    ];
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
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fromage',
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
                color: Color(0xFFE8F5CF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommendation title
                  Row(
                    children: [
                      Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.black87,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Recommendation text
                  Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.4,
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
}
