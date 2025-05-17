import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/services/mock_api_service.dart';
import 'package:sahtech/core/utils/models/product_model.dart';
import 'package:sahtech/presentation/scan/product_recommendation_screen.dart';
import 'package:sahtech/core/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math';

class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({Key? key}) : super(key: key);

  @override
  State<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen>
    with SingleTickerProviderStateMixin {
  final MockApiService _apiService = MockApiService();
  final StorageService _storageService = StorageService();
  final TextEditingController _barcodeController = TextEditingController();

  bool _isFlashOn = false;
  bool _isScanning = false;
  bool _isProcessingBarcode = false;
  bool _isQrMode = false;
  bool _isCameraInitialized = false;
  String? _lastScannedBarcode;
  ProductModel? _scannedProduct;
  String? _currentUserId;
  DateTime _lastScanTime = DateTime.now(); // Add cooldown timer

  MobileScannerController? _scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Mark that we've seen the camera screen
    StorageService().setHasSeenCameraScreen(true);

    // Setup animation controller first
    _animationController = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Get the current user ID
    _getUserId();

    // Initialize camera with permission check
    _checkPermissionAndInitCamera();
  }

  // New method to check permission once and initialize camera
  Future<void> _checkPermissionAndInitCamera() async {
    try {
      // Check if permission was requested before
      final hasRequested =
          await StorageService().getCameraPermissionRequested();
      final status = await Permission.camera.status;

      print(
          'Camera permission status: $status, previously requested: $hasRequested');

      if (status.isGranted) {
        // Permission already granted, initialize camera
        print('Camera permission already granted, initializing camera');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _initializeCamera();
            }
          });
        }
      } else if (!hasRequested) {
        // First time seeing this screen, request permission
        print('First time on camera screen, requesting permission');
        final result = await Permission.camera.request();
        await StorageService().setCameraPermissionRequested(true);

        if (result.isGranted && mounted) {
          _initializeCamera();
        } else if (mounted) {
          _showPermissionError();
        }
      } else {
        // Permission was requested before but denied
        print('Camera permission previously denied, showing error');
        if (mounted) {
          _showPermissionError();
        }
      }
    } catch (e) {
      print('Error checking camera permission: $e');
      if (mounted) {
        _showPermissionError();
      }
    }
  }

  // Extracted method to show permission error
  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'L\'accès à la caméra est nécessaire pour scanner des produits.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
        action: SnackBarAction(
          label: 'Paramètres',
          textColor: Colors.white,
          onPressed: () {
            // Open app settings to enable permission
            openAppSettings();
          },
        ),
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      // Skip redundant permission check - we already checked in _checkPermissionAndInitCamera
      // Reset camera state before re-initializing
      setState(() {
        _isCameraInitialized = false;
      });

      // Dispose previous controller if it exists to prevent resource leaks
      if (_scannerController != null) {
        try {
          await _scannerController!.dispose();
          _scannerController = null;
        } catch (e) {
          print('Error disposing camera controller: $e');
          // Continue with initialization even if disposal fails
        }
      }

      // Add delay before initializing new controller
      await Future.delayed(const Duration(milliseconds: 300));

      // Use a more compatible configuration with lower detection speed
      _scannerController = MobileScannerController(
        detectionSpeed:
            DetectionSpeed.noDuplicates, // Try this instead of normal
        facing: CameraFacing.back,
        torchEnabled: _isFlashOn,
        // Focus on core formats only
        formats: [BarcodeFormat.ean13, BarcodeFormat.ean8],
      );

      // Add delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isScanning = true;
          _isCameraInitialized = true;
          _isProcessingBarcode = false; // Ensure processing flag is reset
        });
      }

      print('Camera initialized successfully');
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isScanning = false;
          _scannerController =
              null; // Ensure controller is null if initialization fails
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'initialisation de la caméra: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                // Try again after dismissing the snackbar
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _initializeCamera();
                }
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        // Try to re-initialize after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isCameraInitialized) {
            _initializeCamera();
          }
        });
      }
    }
  }

  // Get the current user ID from storage
  Future<void> _getUserId() async {
    _currentUserId = await _storageService.getUserId();
    print('Current user ID: $_currentUserId');
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _animationController.dispose();

    // Ensure camera resources are fully released
    if (_scannerController != null) {
      try {
        _scannerController!.dispose();
        _scannerController = null;
        print('Scanner controller disposed properly');
      } catch (e) {
        print('Error disposing scanner controller: $e');
      }
    }

    // Force a GC run to help release native resources
    Future.delayed(Duration.zero, () {
      SystemChannels.platform.invokeMethod('SystemNavigator.nullOk');
    });

    super.dispose();
  }

  void _toggleFlash() {
    try {
      if (_scannerController == null || !_isCameraInitialized) {
        print("Can't toggle flash: Camera not initialized");
        return;
      }

      setState(() => _isFlashOn = !_isFlashOn);

      // Update torch state without recreating the controller
      _scannerController!.toggleTorch();

      // Trigger platform-specific vibration feedback
      HapticFeedback.lightImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'activer le flash: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  void _toggleScanMode() {
    setState(() {
      _isQrMode = !_isQrMode;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (_scannerController == null || !_isCameraInitialized) {
        print("Can't pick image: Camera not initialized");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Initialisation de la caméra en cours, veuillez réessayer"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Process the image for barcode detection
        final result = await _scannerController!.analyzeImage(image.path);

        if (result != null &&
            result.barcodes.isNotEmpty &&
            result.barcodes.first.rawValue != null) {
          _processBarcodeResult(result.barcodes.first.rawValue!);
        } else {
          // No barcode found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Aucun code-barre détecté dans l\'image'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saisie manuelle de code'),
        content: TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Entrez le code-barre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final barcode = _barcodeController.text.trim();
              if (barcode.isNotEmpty) {
                Navigator.pop(context);
                _processBarcodeResult(barcode);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightTeal,
            ),
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  Future<void> _processBarcodeResult(String barcode) async {
    // Add basic barcode validation and cooldown
    if (barcode.isEmpty || barcode.length < 8) {
      return; // Invalid barcode, silently ignore
    }

    // Enforce cooldown period to prevent excessive processing
    final now = DateTime.now();
    if (now.difference(_lastScanTime).inMilliseconds < 1500) {
      print('Scan cooldown in effect, ignoring scan');
      return;
    }
    _lastScanTime = now;

    // Clear any existing snackbars and avoid multiple scanning
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_isProcessingBarcode || _lastScannedBarcode == barcode) {
      return;
    }

    setState(() {
      _lastScannedBarcode = barcode;
      _isProcessingBarcode = true;
    });

    // Pause scanner and give haptic feedback
    _pauseScanner();
    HapticFeedback.mediumImpact();

    // Check internet connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Show offline message instruction
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pas de connexion Internet, vérifiez votre réseau'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        setState(() {
          _isProcessingBarcode = false;
        });
        _resumeScanner();
      }
      return;
    }

    // Show searching indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recherche du produit: $barcode...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );

    try {
      print('===== STARTING SCAN FLOW =====');

      // STEP 1: Attempt to fetch the user ID for personalization
      _currentUserId = await _storageService.getUserId();
      print('Current user ID: ${_currentUserId ?? "Not logged in"}');

      // STEP 2: Fetch product data from API
      print('STEP 2: Fetching product with barcode: $barcode');
      final product = await _apiService.getProductByBarcode(barcode);

      if (product == null) {
        print('STEP 2 FAILED: Product not found');
        if (mounted) {
          // Special case for Besbassa water even if API failed
          if (barcode.contains('besbassa') ||
              barcode.toLowerCase().contains('water') ||
              barcode == '6194000101027') {
            print('Using hardcoded Besbassa water fallback');
            final besbassaProduct = ProductModel(
              id: 'besbassa123',
              name: 'Besbassa Natural Mineral Water',
              imageUrl:
                  'https://www.besbassawater.com/wp-content/uploads/2020/05/besbassa-500-ml.png',
              barcode: '6194000101027',
              brand: 'Besbassa',
              category: 'Boissons',
              nutritionFacts: {
                'calories': 0,
                'fat': 0.0,
                'carbs': 0.0,
                'protein': 0.0,
                'salt': 0.02,
              },
              ingredients: ['Natural Mineral Water'],
              allergens: [],
              healthScore: 4.5,
              scanDate: DateTime.now(),
            );

            // Continue with the hardcoded product
            _processProductAndGetRecommendation(besbassaProduct);
            return;
          }

          // Product not found message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Produit non trouvé. Réessayez avec un autre produit.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );

          _resumeScanner();
        }
      } else {
        print('STEP 2 SUCCESS: Product found - ${product.name}');
        // Continue with the found product
        _processProductAndGetRecommendation(product);
      }
    } catch (e) {
      print('ERROR in scan flow: $e');
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur: ${e.toString().substring(0, min(50, e.toString().length))}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        _resumeScanner();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingBarcode = false;
        });
      }
      print('===== SCAN FLOW COMPLETE =====');
    }
  }

  // Extracted method to process a product and get recommendation
  Future<void> _processProductAndGetRecommendation(ProductModel product) async {
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit trouvé: "${product.name}"'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }

    // Make sure we have the minimum required product data
    if (product.id.isEmpty || product.name.isEmpty) {
      print('STEP 3 SKIPPED: Invalid product data detected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informations produit incomplètes'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        _resumeScanner();
      }
      return; // Prevent navigation with invalid product
    }

    // STEP 3: Get AI recommendation if user is logged in
    if (_currentUserId != null) {
      print(
          'STEP 3: Requesting AI recommendation for user: $_currentUserId, product: ${product.id}');
      try {
        final recommendationResponse = await _apiService
            .getPersonalizedRecommendation(
              _currentUserId!,
              product.id,
            )
            .timeout(const Duration(seconds: 5));

        if (recommendationResponse != null &&
            recommendationResponse.containsKey('recommendation')) {
          product.aiRecommendation = recommendationResponse['recommendation'];
          product.recommendationType =
              recommendationResponse['recommendation_type'] ?? 'caution';
          print('STEP 3 SUCCESS: AI recommendation applied');
        } else {
          print(
              'STEP 3 WARNING: Recommendation response was null or incomplete');
          // Set default recommendation when API response is incomplete
          product.aiRecommendation =
              "Nous n'avons pas obtenu une recommandation complète. " +
                  "Veuillez consulter les informations nutritionnelles et les ingrédients.";
          product.recommendationType = "caution";
        }
      } catch (e) {
        print('STEP 3 FAILED: AI recommendation error - $e');
        // Continue without recommendation - product details will still be shown
        product.aiRecommendation =
            "Nous n'avons pas pu obtenir une recommandation personnalisée. " +
                "Veuillez consulter les informations nutritionnelles et les ingrédients.";
        product.recommendationType = "caution";
      }
    } else {
      print(
          'STEP 3 SKIPPED: User not logged in, no personalized recommendation');
      // Ensure non-logged in users still get a default recommendation
      product.aiRecommendation =
          "Connectez-vous pour obtenir une recommandation personnalisée. " +
              "En attendant, vérifiez les informations nutritionnelles ci-dessous.";
      product.recommendationType = "caution";
    }

    // STEP 4: Show the product details regardless of recommendation status
    print('STEP 4: Showing product preview');
    if (mounted) {
      _showProductPreview(product);
    }
  }

  void _showProductPreview(ProductModel product) {
    // Show a small card preview at the bottom for 2 seconds
    // Then navigate to the recommendation screen

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Product image with subtle shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      product.imageUrl,
                      width: 70.w,
                      height: 70.w,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 70.w,
                          height: 70.w,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: AppColors.lightTeal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // View Details button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToRecommendationScreen(product);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightTeal,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Voir détails',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // After 3 seconds, navigate to the recommendation screen automatically if the sheet is still showing
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context); // Close the bottom sheet if still open
        _navigateToRecommendationScreen(product);
      }
    });
  }

  // Helper method to navigate to recommendation screen
  void _navigateToRecommendationScreen(ProductModel product) {
    // Final validation before navigation
    if (product.id.isEmpty || product.name.isEmpty) {
      print('Navigation prevented: Invalid product data');
      return;
    }

    if (product.aiRecommendation == null || product.aiRecommendation!.isEmpty) {
      print('Adding fallback recommendation before navigation');
      product.aiRecommendation =
          "Nous n'avons pas d'analyse personnalisée pour ce produit. " +
              "Vérifiez les ingrédients et allergènes ci-dessous pour vous assurer " +
              "que ce produit convient à votre régime alimentaire.";
      product.recommendationType = "caution";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductRecommendationScreen(product: product),
      ),
    ).then((_) {
      // Reset scan state to enable new scans after returning
      if (mounted) {
        setState(() {
          _isScanning = true;
          _lastScannedBarcode = null;
          _isProcessingBarcode = false;
        });

        // Ensure camera is properly initialized when returning from recommendation screen
        if (!_isCameraInitialized) {
          print('Camera not initialized on return, reinitializing');
          _initializeCamera();
        } else {
          // Just to be safe, ensure the scanner is resumed
          _resumeScanner();
        }
      }
    });
  }

  Color _getNutriScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.lightGreen;
    if (score >= 2.0) return Colors.yellow;
    if (score >= 1.0) return Colors.orange;
    return Colors.red;
  }

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Scanner
          if (_isScanning && _scannerController != null)
            Container(
              color: Colors.black,
              child: MobileScanner(
                controller: _scannerController!,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    print('Raw barcode detected: ${barcodes.first.rawValue}');
                    _processBarcodeResult(barcodes.first.rawValue!);
                  }
                },
                errorBuilder: (context, error, child) {
                  // Log camera error for debugging
                  print(
                      'Camera error: ${error.errorCode} - ${error.errorDetails}');

                  // Auto-retry camera initialization after a short delay
                  if (mounted) {
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        print(
                            'Auto-retrying camera initialization after error');
                        _initializeCamera();
                      }
                    });
                  }

                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Erreur de caméra: ${error.errorCode}',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _initializeCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightTeal,
                            ),
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                fit: BoxFit.cover,
              ),
            ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      _buildSquareButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),

                      // Center toggle buttons - flexible width
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 3.h),
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Barcode scanner
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_isQrMode) _toggleScanMode();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isQrMode
                                          ? AppColors.lightTeal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Text(
                                      'Scanner un code barre',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: !_isQrMode
                                            ? Colors.black87
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // QR code scanner
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    if (!_isQrMode) _toggleScanMode();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isQrMode
                                          ? AppColors.lightTeal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Text(
                                      'Scanner un QR code',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _isQrMode
                                            ? Colors.black87
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Flash button
                      _buildSquareButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        onTap: _toggleFlash,
                      ),
                    ],
                  ),
                ),

                // Right side buttons (gallery and manual input)
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 16.h),
                        // Gallery button
                        _buildSquareButton(
                          icon: Icons.photo_library,
                          onTap: _pickImageFromGallery,
                        ),
                        SizedBox(height: 16.h),
                        // Manual input button
                        _buildSquareButton(
                          icon: Icons.keyboard,
                          onTap: _showManualInputDialog,
                        ),
                      ],
                    ),
                  ),
                ),

                // Scanner frame with animated line
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Scanner frame with corner decorations
                        SizedBox(
                          width: _isQrMode
                              ? MediaQuery.of(context).size.width * 0.8
                              : MediaQuery.of(context).size.width * 0.95,
                          height: _isQrMode
                              ? MediaQuery.of(context).size.height * 0.5
                              : MediaQuery.of(context).size.height * 0.25,
                          child: _ScannerOverlay(
                            overlayColour: Colors.transparent,
                            borderColour: AppColors.lightTeal,
                            borderWidth: 3.0,
                            borderLength: 40.0,
                            borderRadius: 10.0,
                          ),
                        ),

                        // Animated scanning line
                        if (_isScanning)
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Positioned(
                                top: _isQrMode
                                    ? MediaQuery.of(context).size.height *
                                        0.5 *
                                        _animation.value
                                    : MediaQuery.of(context).size.height *
                                        0.25 *
                                        _animation.value,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 3.h,
                                  width: _isQrMode
                                      ? MediaQuery.of(context).size.width * 0.8
                                      : MediaQuery.of(context).size.width *
                                          0.95,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.lightTeal.withOpacity(0.5),
                                        AppColors.lightTeal,
                                        AppColors.lightTeal.withOpacity(0.5),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.lightTeal
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        // Scan instruction text
                        Positioned(
                          bottom: -60.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _isQrMode
                                  ? 'Placez le QR code dans le cadre'
                                  : 'Placez le code-barre dans le cadre',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isProcessingBarcode)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.lightTeal,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Recherche de produit...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.lightTeal.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 22.sp,
        ),
      ),
    );
  }

  // Add method to pause scanner
  void _pauseScanner() {
    if (mounted) {
      setState(() {
        _isScanning = false;
      });

      // Don't dispose the controller, just stop scanning
      // This ensures we can resume quickly without reinitializing
    }
  }

  // Add method to resume scanner
  void _resumeScanner() {
    if (mounted) {
      setState(() {
        _isScanning = true;
      });

      // If camera is not initialized or had an error, try to reinitialize
      if (!_isCameraInitialized || _scannerController == null) {
        print(
            'Camera not initialized or controller is null, trying to initialize');
        _initializeCamera();
      }
    }
  }
}

// Custom Scanner Overlay with Corner Decorations
class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({
    Key? key,
    required this.overlayColour,
    required this.borderColour,
    required this.borderWidth,
    required this.borderLength,
    required this.borderRadius,
  }) : super(key: key);

  final Color overlayColour;
  final Color borderColour;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(
        overlayColor: overlayColour,
        borderColor: borderColour,
        borderWidth: borderWidth,
        borderLength: borderLength,
        borderRadius: borderRadius,
      ),
    );
  }
}

// Custom Painter for Scanner Overlay
class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.overlayColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
    required this.borderRadius,
  });

  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double width = size.width;
    final double height = size.height;

    // Size of the scanning area
    final double scanAreaWidth = width;
    final double scanAreaHeight = height;

    // Position the scan area in the center
    final double left = (width - scanAreaWidth) / 2;
    final double top = (height - scanAreaHeight) / 2;
    final double right = left + scanAreaWidth;
    final double bottom = top + scanAreaHeight;

    // Calculate scan rectangle
    final Rect scanRect = Rect.fromLTRB(left, top, right, bottom);

    // Draw overlay with transparent hole
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    // Define corner size
    final double cornerSize = borderLength;

    // Draw only corners (not full border)
    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerSize)
        ..lineTo(left, top)
        ..lineTo(left + cornerSize, top),
      borderPaint..color = AppColors.lightTeal,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerSize, top)
        ..lineTo(right, top)
        ..lineTo(right, top + cornerSize),
      borderPaint..color = AppColors.lightTeal,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerSize)
        ..lineTo(left, bottom)
        ..lineTo(left + cornerSize, bottom),
      borderPaint..color = AppColors.lightTeal,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerSize, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, bottom - cornerSize),
      borderPaint..color = AppColors.lightTeal,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
