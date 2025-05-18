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

      // Use a more optimized configuration for reliable barcode detection
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: _isFlashOn,
        // Focus only on product barcode formats (EAN/UPC)
        formats: [BarcodeFormat.ean13, BarcodeFormat.ean8],
        // Increase detection confidence to avoid false positives
        detectionTimeoutMs: 1500,
        returnImage: false, // Don't return images to save memory
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
    if (barcode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code-barres invalide ou vide'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
      return; // Invalid barcode
    }

    // Validate barcode format (must be digits only for product barcodes)
    final RegExp validBarcodeRegex = RegExp(r'^[0-9]{8,14}$');
    if (!validBarcodeRegex.hasMatch(barcode)) {
      print('Invalid barcode format detected: $barcode');
      return; // Silent reject of invalid barcodes to prevent UI clutter
    }

    // Check authentication status first
    final bool isLoggedIn = await _storageService.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) {
        _pauseScanner();
        // Show dialog to prompt user to login without navigation
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Authentification requise'),
            content:
                Text('Vous devez être connecté pour scanner des produits.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resumeScanner();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Special priority handling for known problematic barcodes
    final List<String> priorityBarcodes = ['6133414007137'];
    bool isPriorityBarcode = priorityBarcodes.contains(barcode);

    // Enforce cooldown period to prevent excessive processing
    // Use a consistent cooldown for all barcodes to prevent multiple rapid scans
    final now = DateTime.now();
    final int cooldownMs =
        2500; // Consistent 2.5 second cooldown for all barcodes

    if (now.difference(_lastScanTime).inMilliseconds < cooldownMs) {
      print('Scan cooldown in effect, ignoring scan');
      return; // No exceptions to cooldown - prevents multiple processing
    }
    _lastScanTime = now;

    // Debug info for barcode detection
    print('Processing barcode: $barcode (Priority: $isPriorityBarcode)');

    // Clear any existing snackbars and avoid multiple scanning
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_isProcessingBarcode && _lastScannedBarcode == barcode) {
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

      // Check if we have a valid token before proceeding
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        // Handle missing token
        if (mounted) {
          _pauseScanner();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Votre session a expiré. Reconnectez-vous.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
        // Clear invalid auth data
        await _storageService.clearAuthData();
        return;
      }

      // STEP 2: Fetch product data from API
      print('STEP 2: Fetching product with barcode: $barcode');
      final product = await _apiService.getProductByBarcode(barcode,
          userId: _currentUserId);

      if (product == null) {
        print('STEP 2 FAILED: Product not found');
        if (mounted) {
          // Product not found message with clearer details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Produit non trouvé dans la base de données'),
                  SizedBox(height: 4),
                  Text(
                    'Code-barre: $barcode',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
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
        // Check if this is an authentication error
        if (e.toString().contains('403') ||
            e.toString().contains('Forbidden') ||
            e.toString().contains('Unauthorized') ||
            e.toString().contains('401')) {
          // Handle authentication error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session expirée, reconnexion nécessaire'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
          // Clear invalid auth data
          await _storageService.clearAuthData();
        } else {
          // Show general error message
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
        }

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
    // Helper method to set empty recommendation with appropriate UI feedback
    void setEmptyRecommendation(ProductModel product, String type) {
      if (mounted) {
        String message = 'Recommandation IA non disponible';
        Color color = Colors.orange;

        switch (type) {
          case "error":
            message = 'Erreur de connexion au service IA';
            color = Colors.red;
            break;
          case "login_required":
            message = 'Connectez-vous pour voir les recommandations IA';
            color = Colors.blue;
            break;
          case "unavailable":
          default:
            // Use default values
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }

      product.aiRecommendation = null;
      product.recommendationType = type;
    }

    // Show success message for product found
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

    print('Processing product: ${product.name} (ID: ${product.id})');

    // STEP 1: Check if user is logged in
    print('STEP 1: Checking user authentication status');
    _currentUserId = await _storageService.getUserId();
    final bool isLoggedIn =
        _currentUserId != null && _currentUserId!.isNotEmpty;

    if (!isLoggedIn) {
      print('User not logged in - no personalized recommendation available');
      setEmptyRecommendation(product, "login_required");

      // Still show product details without recommendation
      _showProductPreview(product);
      return;
    }

    print('User logged in with ID: $_currentUserId');

    // STEP 2: Request AI recommendation from server
    print('STEP 2: Requesting AI recommendation');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 10.w),
              Text('Analyse IA en cours...'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }

    try {
      final recommendationResponse =
          await _apiService.getPersonalizedRecommendation(
        _currentUserId!,
        product.id,
      );

      if (recommendationResponse != null) {
        // Check if we have a recommendation field with content
        if (recommendationResponse.containsKey('recommendation') &&
            recommendationResponse['recommendation'] != null &&
            recommendationResponse['recommendation'].toString().isNotEmpty) {
          product.aiRecommendation = recommendationResponse['recommendation'];
          product.recommendationType =
              recommendationResponse['recommendation_type'] ?? 'caution';

          print('AI recommendation applied:');
          print('- Type: ${product.recommendationType}');
          print('- Length: ${product.aiRecommendation?.length ?? 0}');

          // Show success message for AI recommendation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Analyse IA complétée'),
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
        } else {
          print('WARNING: Invalid recommendation data in response');
          setEmptyRecommendation(product, "unavailable");
        }
      } else {
        print('WARNING: No AI recommendation available');
        setEmptyRecommendation(product, "unavailable");
      }
    } catch (e) {
      print('ERROR: AI recommendation error - $e');
      setEmptyRecommendation(product, "error");
    }

    // Show the product details regardless of recommendation status
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
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading product image: $error');
                        // Show a placeholder when image fails to load
                        return Container(
                          width: 70.w,
                          height: 70.w,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.no_food,
                            color: Colors.grey[600],
                            size: 30.sp,
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
                    final String rawBarcode = barcodes.first.rawValue!;

                    // Ensure we only process valid product barcodes
                    if (barcodes.first.format == BarcodeFormat.ean13 ||
                        barcodes.first.format == BarcodeFormat.ean8) {
                      print(
                          'Valid product barcode detected: $rawBarcode (${barcodes.first.format})');
                      _processBarcodeResult(rawBarcode);
                    } else {
                      // Log but don't process non-product barcodes
                      print(
                          'Ignored non-product barcode: $rawBarcode (${barcodes.first.format})');
                    }
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
                      child: Column(
                        children: [
                          Text(
                            'Recherche de produit...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Code: $_lastScannedBarcode',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
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
