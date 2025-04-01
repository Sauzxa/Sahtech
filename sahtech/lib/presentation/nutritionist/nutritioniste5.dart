import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/camera/camera.dart';
import 'package:latlong2/latlong.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';

class NutritionisteMap extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;
  final bool locationEnabled;

  const NutritionisteMap({
    Key? key,
    required this.nutritionistData,
    this.currentStep = 4,
    this.totalSteps = 5,
    this.locationEnabled = false,
  }) : super(key: key);

  @override
  _NutritionisteMapState createState() => _NutritionisteMapState();
}

class _NutritionisteMapState extends State<NutritionisteMap> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();

  LatLng? _selectedLocation;
  LatLng _initialCenter = LatLng(36.7538, 3.0588); // Algiers default
  bool _showAddLocationDialog = false;
  bool _isLocationConfirmed = false; // Added for confirmation tracking
  String? _selectedLocationAddress;
  List<Marker> _markers = [];
  double _currentZoom =
      12.0; // Changed to zoom level 12.0 for better initial view
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();

  // Translations
  Map<String, String> _translations = {
    'title': 'Localisation du cabinet',
    'search_hint': 'Rechercher votre cabinet',
    'latitude': 'Latitude',
    'longitude': 'Longitude',
    'confirm': 'Confirmer',
    'refuse': 'Refuser',
    'add_location': 'Voulez-vous vraiment ajouter votre localisation ?',
    'continue': 'Continuer',
    'save_location': 'Enregistrer la localisation',
    'enter_coordinates': 'Entrer les coordonnées manuellement',
    'cabinet_location': 'Emplacement du cabinet',
    'set_location': 'Définir l\'emplacement',
    'location_saved': 'Localisation enregistrée avec succès',
    'location_error': 'Veuillez sélectionner une localisation valide',
    'search_error': 'Aucun résultat trouvé',
    'try_again': 'Veuillez réessayer',
    'is_this_your_cabinet': 'Est-ce votre cabinet?',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
    _initializeLocation();
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

  // Initialize location
  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      // If the user already has a saved location, use it
      if (widget.nutritionistData.latitude != null &&
          widget.nutritionistData.longitude != null) {
        _selectedLocation = LatLng(widget.nutritionistData.latitude!,
            widget.nutritionistData.longitude!);
        _initialCenter = _selectedLocation!;
        _setMarker(_selectedLocation!);
        _updateCoordinateControllers(_selectedLocation!);

        if (widget.nutritionistData.cabinetAddress != null) {
          _selectedLocationAddress = widget.nutritionistData.cabinetAddress;
        } else {
          await _getAddressFromLatLng(_selectedLocation!);
        }
      }
      // If location is enabled, try to get current location
      else if (widget.locationEnabled) {
        bool serviceEnabled;
        LocationPermission permission;

        // Check if location services are enabled
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('Location services are disabled');
          // Keep default location if services are disabled
        } else {
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            debugPrint('Location permissions are denied');
            // Keep default location if permissions are denied
          } else {
            try {
              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              _initialCenter = LatLng(position.latitude, position.longitude);
              // We don't set this as selected location yet, just center the map here
            } catch (e) {
              debugPrint('Error getting current location: $e');
              // Keep default location if there's an error
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Set marker at the selected location
  void _setMarker(LatLng position) {
    setState(() {
      _markers = [
        Marker(
          width: 40.0,
          height: 40.0,
          point: position,
          child: GestureDetector(
            onTap: _showLocationConfirmationDialog,
            child: Icon(
              Icons.location_on,
              color: AppColors.lightTeal,
              size: 40.0,
            ),
          ),
        ),
      ];
    });
  }

  // Get address from LatLng
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedLocationAddress =
              '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedLocationAddress = 'Adresse inconnue';
      });
    }
  }

  // Search for a location
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newLocation = LatLng(location.latitude, location.longitude);

        // Zoom in on search results - use a higher zoom level for search results
        _currentZoom = 16.0;

        // First move the map to center the search result
        _mapController.move(newLocation, _currentZoom);

        // Then select the location which will trigger the confirmation dialog
        _selectLocation(newLocation);
      } else {
        _showErrorMessage(
            '${_translations['search_error']} - ${_translations['try_again']}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      _showErrorMessage(
          '${_translations['search_error']} - ${_translations['try_again']}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Show error message
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Handle manual coordinate input
  void _handleCoordinateInput() {
    try {
      double latitude = double.parse(_latitudeController.text.trim());
      double longitude = double.parse(_longitudeController.text.trim());

      // Basic validation
      if (latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180) {
        LatLng newLocation = LatLng(latitude, longitude);
        _mapController.move(newLocation, _currentZoom);
        _selectLocation(newLocation);
      } else {
        _showErrorMessage(_translations['location_error']!);
      }
    } catch (e) {
      debugPrint('Coordinate input error: $e');
      _showErrorMessage(_translations['location_error']!);
    }
  }

  // Update coordinate text controllers
  void _updateCoordinateControllers(LatLng location) {
    _latitudeController.text = location.latitude.toStringAsFixed(6);
    _longitudeController.text = location.longitude.toStringAsFixed(6);
  }

  // Select a location on the map
  void _selectLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _updateCoordinateControllers(location);
      _isLocationConfirmed =
          false; // Reset confirmation when new location is selected
    });

    await _getAddressFromLatLng(location);
    _setMarker(location);

    // Show confirmation dialog
    _showLocationConfirmationDialog();
  }

  // Save selected location
  void _saveLocation() {
    if (_selectedLocation == null) {
      _showErrorMessage(_translations['location_error']!);
      return;
    }

    // Save location to nutritionist model
    widget.nutritionistData.latitude = _selectedLocation!.latitude;
    widget.nutritionistData.longitude = _selectedLocation!.longitude;
    widget.nutritionistData.cabinetAddress = _selectedLocationAddress;

    // Show success message
    _showSuccessMessage(_translations['location_saved']!);

    // Wait for snackbar to show before navigating
    Future.delayed(Duration(milliseconds: 1200), () {
      if (!mounted) return;

      // Return to previous screen with updated data
      Navigator.pop(context, widget.nutritionistData);

      // Alternatively, if there's another step, navigate to it:
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => NextScreen(
      //       nutritionistData: widget.nutritionistData,
      //     ),
      //   ),
      // );
    });
  }

  // Show success message
  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Discard selected location
  void _discardLocation() {
    setState(() {
      _selectedLocation = null;
      _selectedLocationAddress = null;
      _markers = [];
      _showAddLocationDialog = false;
      _latitudeController.clear();
      _longitudeController.clear();
    });
  }

  // Location confirmation dialog
  void _showLocationConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _translations['is_this_your_cabinet']!,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedLocationAddress != null)
              Text(
                _selectedLocationAddress!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 24),
            // Green confirm button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedLocation = _selectedLocation;
                  _showAddLocationDialog = false;
                  _isLocationConfirmed = true;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _translations['confirm']!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            // Red refuse button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedLocation = null;
                  _selectedLocationAddress = null;
                  _markers = [];
                  _showAddLocationDialog = false;
                  _isLocationConfirmed = false;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _translations['refuse']!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _searchFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_translations['title']!),
        backgroundColor: AppColors.lightTeal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : Stack(
              children: [
                // Main map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _currentZoom,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, point) => _selectLocation(point),
                    onPositionChanged: (position, hasGesture) {
                      if (position.zoom != null) {
                        _currentZoom = position.zoom!;
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sahtech',
                      maxZoom: 19,
                      minZoom: 3,
                    ),
                    // Display markers
                    MarkerLayer(markers: _markers),
                  ],
                ),

                // Search and coordinate input section at the top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: _translations['search_hint'],
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                            ),
                            onSubmitted: (value) => _searchLocation(value),
                            textInputAction: TextInputAction.search,
                          ),
                        ),

                        SizedBox(height: 10),

                        // Coordinate inputs
                        ExpansionTile(
                          title: Text(
                            _translations['enter_coordinates']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          collapsedBackgroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  // Latitude input
                                  Expanded(
                                    child: TextField(
                                      controller: _latitudeController,
                                      focusNode: _latitudeFocusNode,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: _translations['latitude'],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  // Longitude input
                                  Expanded(
                                    child: TextField(
                                      controller: _longitudeController,
                                      focusNode: _longitudeFocusNode,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: _translations['longitude'],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  // Apply coordinates button
                                  ElevatedButton(
                                    onPressed: _handleCoordinateInput,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightTeal,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Icon(Icons.check),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Discard button (visible when marker is placed)
                if (_markers.isNotEmpty)
                  Positioned(
                    left: 16,
                    bottom: height * 0.15,
                    child: FloatingActionButton(
                      onPressed: _discardLocation,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      mini: true,
                    ),
                  ),

                // Zoom controls
                Positioned(
                  right: 16,
                  bottom: height * 0.2,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _currentZoom + 1,
                          );
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          color: Colors.black87,
                        ),
                        mini: true,
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _currentZoom - 1,
                          );
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.remove,
                          color: Colors.black87,
                        ),
                        mini: true,
                      ),
                    ],
                  ),
                ),

                // Bottom Save Location button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedLocationAddress != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              _selectedLocationAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ElevatedButton(
                          onPressed:
                              _selectedLocation != null && _isLocationConfirmed
                                  ? _saveLocation
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightTeal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                          ),
                          child: Text(
                            _translations['save_location']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Location confirmation dialog
                if (_showAddLocationDialog)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAddLocationDialog = false;
                        });
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightTeal.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.map,
                                    color: AppColors.lightTeal,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _translations['add_location']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                if (_selectedLocationAddress != null)
                                  Text(
                                    _selectedLocationAddress!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _showLocationConfirmationDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lightTeal,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(_translations['continue']!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
