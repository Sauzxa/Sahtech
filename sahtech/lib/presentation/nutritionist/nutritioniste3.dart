import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class Nutritioniste3 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste3({
    Key? key,
    required this.nutritionistData,
    this.currentStep = 3,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<Nutritioniste3> createState() => _Nutritioniste3State();
}

class _Nutritioniste3State extends State<Nutritioniste3> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _selectedImageName;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  // Translations
  Map<String, String> _translations = {
    'title': 'Sélection de l\'image de d\'attestaion de fonction !',
    'subtitle':
        'Veuillez sélectionner une image contenant votre diplôme. Cette étape est obligatoire',
    'select_image': 'Selectionner un image',
    'take_photo': 'Ouvrir la camera et prendre une photo',
    'next': 'suivant',
    'gallery_permission_error': 'Veuillez autoriser l\'accès à la galerie',
    'camera_permission_error': 'Veuillez autoriser l\'accès à la caméra',
    'image_required': 'Une image de diplôme est requise pour continuer',
    'image_removed': 'Image supprimée',
    'upload_in_progress': 'Veuillez attendre la fin du téléchargement',
    'image_saved': 'Image de diplôme enregistrée avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();

    // Initialize with existing data if available
    if (widget.nutritionistData.diplomaImagePath != null &&
        widget.nutritionistData.diplomaImagePath!.isNotEmpty) {
      final imagePath = widget.nutritionistData.diplomaImagePath!;
      final file = File(imagePath);

      // Only set the file if it exists
      if (file.existsSync()) {
        _selectedImage = file;
        _selectedImageName = path.basename(imagePath);
        _uploadProgress =
            1.0; // If image already exists, show as fully uploaded
      } else {
        // Clear the path if the file doesn't exist
        widget.nutritionistData.diplomaImagePath = null;
      }
    }
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (default language)
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Update nutritionist model with the new language
    widget.nutritionistData.preferredLanguage = languageCode;

    // Reload translations with the new language
    _loadTranslations();
  }

  // Simulate a file upload process
  Future<void> _simulateUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _uploadProgress = i / 10;
      });
    }

    setState(() {
      _isUploading = false;
    });
  }

  // Select image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _selectedImageName = path.basename(image.path);
        });

        await _simulateUpload();

        // The path will be saved to the model only when the user presses the Continue button
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Show gallery permission error
      _showErrorSnackbar(_translations['gallery_permission_error']!);
    }
  }

  // Take a photo with the camera
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _selectedImageName = path.basename(image.path);
        });

        await _simulateUpload();

        // The path will be saved to the model only when the user presses the Continue button
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      // Show camera permission error
      _showErrorSnackbar(_translations['camera_permission_error']!);
    }
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Remove the selected image
  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageName = null;
      _uploadProgress = 0.0;
    });

    // Clear the path in the nutritionist model
    widget.nutritionistData.diplomaImagePath = null;

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['image_removed']!),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _continueToNextScreen() {
    if (_selectedImage == null) {
      _showErrorSnackbar(_translations['image_required']!);
      return;
    }

    // Check if upload is in progress
    if (_isUploading || _uploadProgress < 1.0) {
      _showErrorSnackbar(_translations['upload_in_progress']!);
      return;
    }

    // Save the data to the nutritionist model
    widget.nutritionistData.diplomaImagePath = _selectedImage!.path;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['image_saved']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigation to the next screen will be implemented in the future
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Nutritioniste4(
    //       nutritionistData: widget.nutritionistData,
    //       currentStep: widget.currentStep + 1,
    //       totalSteps: widget.totalSteps,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: width * 0.12,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTeal,
            size: width * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: width * 0.04),
        ),
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Language selector button
          LanguageSelectorButton(
            width: width,
            onLanguageChanged: _handleLanguageChanged,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : SafeArea(
              child: Column(
                children: [
                  // Progress bar at the top
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:
                              width * (widget.currentStep / widget.totalSteps),
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        // Scrollable content area
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.06,
                              right: width * 0.06,
                              bottom: height *
                                  0.12, // Extra padding at bottom for button
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height * 0.05),

                                // Title
                                Text(
                                  _translations['title']!,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                SizedBox(height: height * 0.01),

                                // Subtitle
                                Text(
                                  _translations['subtitle']!,
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),

                                SizedBox(height: height * 0.04),

                                // Image selection area
                                GestureDetector(
                                  onTap: _pickImageFromGallery,
                                  child: Container(
                                    width: double.infinity,
                                    height: height * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.lightTeal
                                            .withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _selectedImage != null
                                        ? Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Image.file(
                                                  _selectedImage!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                              // Only show the remove button after upload is complete
                                              if (_uploadProgress >= 1.0)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: GestureDetector(
                                                    onTap: _removeSelectedImage,
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: width * 0.05,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_outlined,
                                                color: Colors.grey[400],
                                                size: width * 0.12,
                                              ),
                                              SizedBox(height: height * 0.01),
                                              Text(
                                                _translations['select_image']!,
                                                style: TextStyle(
                                                  fontSize: width * 0.035,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                SizedBox(height: height * 0.03),

                                // Camera option
                                GestureDetector(
                                  onTap: _takePhoto,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04,
                                      vertical: height * 0.02,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.grey[600],
                                          size: width * 0.05,
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Text(
                                          _translations['take_photo']!,
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Show upload progress and file info if there's a selected image
                                if (_selectedImage != null) ...[
                                  SizedBox(height: height * 0.03),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04,
                                      vertical: height * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.description,
                                              color: Colors.grey[600],
                                              size: width * 0.05,
                                            ),
                                            SizedBox(width: width * 0.02),
                                            Expanded(
                                              child: Text(
                                                _selectedImageName ?? 'Image',
                                                style: TextStyle(
                                                  fontSize: width * 0.035,
                                                  color: Colors.grey[800],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (_uploadProgress >= 1.0) ...[
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: width * 0.05,
                                              ),
                                              SizedBox(width: width * 0.02),
                                              GestureDetector(
                                                onTap: _removeSelectedImage,
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: width * 0.05,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Row(
                                          children: [
                                            Text(
                                              '${(_selectedImage!.lengthSync() / 1024).toStringAsFixed(0)} KB',
                                              style: TextStyle(
                                                fontSize: width * 0.03,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${(_uploadProgress * 100).toInt()}%',
                                              style: TextStyle(
                                                fontSize: width * 0.03,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: height * 0.005),
                                        // Progress bar
                                        Container(
                                          width: double.infinity,
                                          height: height * 0.005,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FractionallySizedBox(
                                            widthFactor: _uploadProgress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.lightTeal,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Fixed button at the bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(
                              left: width * 0.06,
                              right: width * 0.06,
                              top: height * 0.02,
                              bottom: height * 0.05,
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  _isUploading ? null : _continueToNextScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightTeal,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.018),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                disabledBackgroundColor:
                                    AppColors.lightTeal.withOpacity(0.5),
                              ),
                              child: Text(
                                _translations['next']!,
                                style: TextStyle(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
