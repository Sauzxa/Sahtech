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

  late MobileScannerController _scannerController;
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

    // Check if camera is available before initializing
    Permission.camera.status.then((status) {
      if (status.isGranted && mounted) {
        // Camera permission is already granted, initialize after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _initializeCamera();
          }
        });
      } else if (mounted) {
        // Request camera permission
        Permission.camera.request().then((result) {
          if (result.isGranted && mounted) {
            _initializeCamera();
          } else {
            // Show error message
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
              ),
            );
          }
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      // Check camera permission
      final status = await Permission.camera.status;

      if (!status.isGranted) {
        if (mounted) {
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
            ),
          );
        }
        return;
      }

      // Dispose previous controller if it exists
      if (_isCameraInitialized) {
        await _scannerController.dispose();
      }

      // Use a simpler configuration with normal detection speed
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: _isFlashOn,
        // Explicit formats help with optimization
        formats: [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.qrCode
        ],
      );

      // Add delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isScanning = true;
          _isCameraInitialized = true;
        });
      }

      print('Camera initialized successfully');
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'initialisation de la caméra: $e'),
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
  }

  // Get the current user ID from storage
  Future<void> _getUserId() async {
    _currentUserId = await _storageService.getUserId();
    print('Current user ID: $_currentUserId');
  }

  @override
  void dispose() {
    if (_isCameraInitialized) {
      _scannerController.dispose();
    }
    _barcodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    try {
      setState(() => _isFlashOn = !_isFlashOn);

      // Dispose and reinitialize the controller to ensure torch state is updated
      _scannerController.dispose();
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: _isFlashOn,
        formats: [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.qrCode
        ],
      );

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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Process the image for barcode detection
        final result = await _scannerController.analyzeImage(image.path);

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
    // Avoid processing the same barcode multiple times in rapid succession
    if (_isProcessingBarcode || _lastScannedBarcode == barcode) {
      return;
    }

    try {
      setState(() {
        _lastScannedBarcode = barcode;
        _isProcessingBarcode = true;
      });

      // Haptic feedback for successful scan
      HapticFeedback.mediumImpact();

      // Show scanning indicator
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

      // Fetch product information using the barcode from Spring Boot backend
      final product = await _apiService.getProductByBarcode(barcode);

      if (product != null) {
        if (!mounted) return;

        // Show snackbar indicating the product was found in the database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Produit "${product.name}" trouvé dans notre base de données!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        // If we have a current user ID, request a personalized recommendation
        if (_currentUserId != null) {
          try {
            // Request recommendation from Spring Boot backend which calls the AI service
            final recommendationResponse =
                await _apiService.getPersonalizedRecommendation(
              _currentUserId!,
              product.id,
            );

            // Update the product with the recommendation
            if (recommendationResponse != null &&
                recommendationResponse.containsKey('recommendation')) {
              product.aiRecommendation =
                  recommendationResponse['recommendation'];
              product.recommendationType =
                  recommendationResponse.containsKey('recommendation_type')
                      ? recommendationResponse['recommendation_type']
                      : 'caution'; // Default to caution if not provided
            }
          } catch (recommendationError) {
            print(
                'Failed to get personalized recommendation: $recommendationError');
            // Continue even if recommendation fails - we'll just show the product without a recommendation
          }
        }

        // Show the product preview dialog
        _showProductPreview(product);
      } else {
        if (!mounted) return;

        // Show error message for product not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Produit non trouvé dans notre base de données. Veuillez réessayer ou contacter votre nutritionniste.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Show error message for any other error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du traitement du code-barres: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingBarcode = false;
        });
      }
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

            // Add product button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductRecommendationScreen(product: product),
                    ),
                  ).then((_) {
                    // Reset scan state to enable new scans after returning
                    if (mounted) {
                      setState(() {
                        _isScanning = true;
                        _lastScannedBarcode = null;
                      });
                    }
                  });
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
                  'Ajouter produit',
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

    // After 5 seconds, navigate to the recommendation screen automatically if the sheet is still showing
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context); // Close the bottom sheet if still open
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
            });
          }
        });
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
          if (_isScanning)
            Container(
              color: Colors.black,
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    _processBarcodeResult(barcodes.first.rawValue!);
                  }
                },
                errorBuilder: (context, error, child) {
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

          // Camera debug tools - can be removed in production
          if (_isScanning && _isCameraInitialized)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Force camera reload
                        _initializeCamera();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightTeal,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text('Recharger caméra',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
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
