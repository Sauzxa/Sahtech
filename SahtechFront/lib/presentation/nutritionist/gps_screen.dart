import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/core/config/maps_config.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:sahtech/presentation/nutritionist/nutritioniste_phone.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class NutritionisteMap extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;
  final bool locationEnabled;

  const NutritionisteMap({
    super.key,
    required this.nutritionistData,
    this.currentStep = 4,
    this.totalSteps = 5,
    this.locationEnabled = false,
  });

  @override
  _NutritionisteMapState createState() => _NutritionisteMapState();
}

class _NutritionisteMapState extends State<NutritionisteMap> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();

  LatLng? _selectedLocation;
  static const CameraPosition _initialCenter = CameraPosition(
    target: LatLng(36.7538, 3.0588), // Algiers default
    zoom: 12.0,
  );
  bool _showAddLocationDialog = false;
  bool _isLocationConfirmed = false;
  String? _selectedLocationAddress;
  Set<Marker> _markers = {};
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();

  // Add new variables for location preview
  String? _locationPreviewUrl;
  bool _isPreviewVisible = false;
  bool _isLoadingPreview = false;
  static const double _previewHeight = 180.0;
  String? _placeId;
  String? _previewType; // 'place', 'streetview', or 'map'

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
    'view_street_view': 'View Street View',
    'no_preview': 'No preview available',
  };

  WebViewController? _webViewController;
  bool _isWebViewVisible = false;

  // Use headers from MapsConfig

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
    _initializeLocation();
    _requestPermissions();
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
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

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      if (widget.nutritionistData.latitude != null &&
          widget.nutritionistData.longitude != null) {
        _selectedLocation = LatLng(
          widget.nutritionistData.latitude!,
          widget.nutritionistData.longitude!,
        );
        _setMarker(_selectedLocation!);
        _updateCoordinateControllers(_selectedLocation!);

        if (widget.nutritionistData.cabinetAddress != null) {
          _selectedLocationAddress = widget.nutritionistData.cabinetAddress;
        } else {
          await _getAddressFromLatLng(_selectedLocation!);
        }

        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 15.0,
          ),
        ));
      } else if (widget.locationEnabled) {
        bool serviceEnabled;
        LocationPermission permission;

        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('Location services are disabled');
        } else {
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            debugPrint('Location permissions are denied');
          } else {
            try {
              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              final currentLocation =
                  LatLng(position.latitude, position.longitude);
              final GoogleMapController controller = await _controller.future;
              await controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: currentLocation,
                  zoom: 15.0,
                ),
              ));
            } catch (e) {
              debugPrint('Error getting current location: $e');
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

  Future<void> _requestPermissions() async {
    try {
      // Request location permission
      LocationPermission locationPermission =
          await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
      }

      // Request camera permission if needed
      if (await Permission.camera.status.isDenied) {
        await Permission.camera.request();
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  void _setMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(
            title: _translations['cabinet_location'],
            snippet: _selectedLocationAddress ?? '',
          ),
          onTap: _showLocationConfirmationDialog,
        ),
      };
    });
    _updateLocationPreview(position);
  }

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

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newLocation = LatLng(location.latitude, location.longitude);

        setState(() {
          _markers.clear();
        });

        _selectedLocation = newLocation;
        _setMarker(newLocation);
        await _getAddressFromLatLng(newLocation);

        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newLocation,
            zoom: 15.0,
          ),
        ));

        _updateCoordinateControllers(newLocation);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_translations['search_error']!)),
          );
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_translations['try_again']!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateCoordinateControllers(LatLng location) {
    _latitudeController.text = location.latitude.toStringAsFixed(6);
    _longitudeController.text = location.longitude.toStringAsFixed(6);
  }

  void _showLocationConfirmationDialog() {
    if (_selectedLocation != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_translations['is_this_your_cabinet']!),
          content: Text(_selectedLocationAddress ?? ''),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isLocationConfirmed = false);
              },
              child: Text(_translations['refuse']!),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isLocationConfirmed = true);
              },
              child: Text(_translations['confirm']!),
            ),
          ],
        ),
      );
    }
  }

  void _useStaticMapFallback(LatLng position) {
    // Use Google Maps Static API with minimal parameters
    final String markers =
        "markers=color:red%7C${position.latitude},${position.longitude}";
    _locationPreviewUrl = "https://maps.googleapis.com/maps/api/staticmap"
        "?center=${position.latitude},${position.longitude}"
        "&zoom=17"
        "&size=800x400"
        "&scale=2"
        "&$markers"
        "&key=${MapsConfig.apiKey}";
    _previewType = 'map';
  }

  Future<void> _updateLocationPreview(LatLng position) async {
    setState(() {
      _isLoadingPreview = true;
      _isPreviewVisible = true;
    });

    try {
      // Try to get nearby place photos first
      final placesUrl = Uri.parse(
              'https://maps.googleapis.com/maps/api/place/nearbysearch/json')
          .replace(queryParameters: {
        'location': '${position.latitude},${position.longitude}',
        'radius': '100',
        'key': MapsConfig.apiKey,
      });

      final placesResponse =
          await http.get(placesUrl, headers: MapsConfig.apiHeaders);
      debugPrint('Places API response: ${placesResponse.body}');

      if (placesResponse.statusCode == 200) {
        final placesData = json.decode(placesResponse.body);

        if (placesData['status'] == 'OK' &&
            placesData['results'] != null &&
            placesData['results'].isNotEmpty) {
          // Get the first place that has photos
          for (var place in placesData['results']) {
            if (place['photos'] != null && place['photos'].isNotEmpty) {
              final photoReference = place['photos'][0]['photo_reference'];
              final photoUrl =
                  Uri.parse('https://maps.googleapis.com/maps/api/place/photo')
                      .replace(queryParameters: {
                'maxwidth': '800',
                'maxheight': '400',
                'photo_reference': photoReference,
                'key': MapsConfig.apiKey,
              });

              final photoResponse =
                  await http.get(photoUrl, headers: MapsConfig.apiHeaders);

              if (photoResponse.statusCode == 200) {
                _locationPreviewUrl = photoUrl.toString();
                _previewType = 'place';
                setState(() {});
                return;
              }
            }
          }
        }
      }

      // If no place photos found, try Street View
      final streetViewUrl =
          Uri.parse('https://maps.googleapis.com/maps/api/streetview')
              .replace(queryParameters: {
        'location': '${position.latitude},${position.longitude}',
        'fov': '90',
        'heading': '0',
        'pitch': '0',
        'key': MapsConfig.apiKey,
      });

      final streetViewResponse =
          await http.get(streetViewUrl, headers: MapsConfig.apiHeaders);
      debugPrint('Street View status: ${streetViewResponse.statusCode}');

      if (streetViewResponse.statusCode == 200 &&
          streetViewResponse.bodyBytes.length > 0) {
        _locationPreviewUrl = streetViewUrl.toString();
        _previewType = 'streetview';
        setState(() {});
      } else {
        debugPrint('Street View error: ${streetViewResponse.statusCode}');

        // Use static map as final fallback
        final staticMapUrl =
            Uri.parse('https://maps.googleapis.com/maps/api/staticmap')
                .replace(queryParameters: {
          'center': '${position.latitude},${position.longitude}',
          'zoom': '17',
          'size': '800x400',
          'scale': '2',
          'markers': 'color:red|${position.latitude},${position.longitude}',
          'key': MapsConfig.apiKey,
        });

        final staticMapResponse =
            await http.get(staticMapUrl, headers: MapsConfig.apiHeaders);
        debugPrint('Static Map status: ${staticMapResponse.statusCode}');

        if (staticMapResponse.statusCode == 200) {
          _locationPreviewUrl = staticMapUrl.toString();
          _previewType = 'map';
          setState(() {});
        } else {
          debugPrint('Static Map error: ${staticMapResponse.statusCode}');
          throw Exception('Failed to load any preview image');
        }
      }
    } catch (e) {
      debugPrint('Error getting location preview: $e');
      setState(() {
        _locationPreviewUrl = null;
        _previewType = null;
        _isLoadingPreview = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPreview = false;
        });
      }
    }
  }

  Widget _buildMapPreview() {
    return SizedBox(
      height: _previewHeight,
      width: double.infinity,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation!,
          zoom: 17,
        ),
        markers: _markers,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
    );
  }

  void _saveLocationAndNavigate() {
    if (_selectedLocation != null) {
      // Update the nutritionist model with location data
      widget.nutritionistData.latitude = _selectedLocation!.latitude;
      widget.nutritionistData.longitude = _selectedLocation!.longitude;
      widget.nutritionistData.cabinetAddress = _selectedLocationAddress;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['location_saved']!),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate to phone screen after a brief delay
      Future.delayed(const Duration(milliseconds: 1200), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionistePhone(
              nutritionistData: widget.nutritionistData,
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations['location_error']!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStreetView(LatLng location) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setBackgroundColor(const Color(0x00000000))
                  ..loadRequest(
                    Uri.parse(
                        'https://www.google.com/maps/@${location.latitude},${location.longitude},14z/data=!3m1!1e3!4m2!3m1!1e1'),
                  ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translations['title']!),
        backgroundColor: AppColors.lightTeal,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCenter,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (LatLng position) {
              setState(() {
                _selectedLocation = position;
                _setMarker(position);
                _updateCoordinateControllers(position);
                _getAddressFromLatLng(position);
                _updateLocationPreview(position);
              });
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: _translations['search_hint'],
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () =>
                              _searchLocation(_searchController.text),
                        ),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latitudeController,
                            focusNode: _latitudeFocusNode,
                            decoration: InputDecoration(
                              labelText: _translations['latitude'],
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _longitudeController,
                            focusNode: _longitudeFocusNode,
                            decoration: InputDecoration(
                              labelText: _translations['longitude'],
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildPreviewCard(),
        ],
      ),
      floatingActionButton: _selectedLocation != null
          ? FloatingActionButton.extended(
              onPressed: _saveLocationAndNavigate,
              label: Text(_translations['save_location']!),
              icon: const Icon(Icons.save),
              backgroundColor: AppColors.lightTeal,
            )
          : null,
    );
  }

  Widget _buildPreviewCard() {
    if (!_isPreviewVisible) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 80,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: _isLoadingPreview
                      ? Container(
                          height: _previewHeight,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _locationPreviewUrl != null
                          ? Stack(
                              children: [
                                Image.network(
                                  _locationPreviewUrl!,
                                  height: _previewHeight,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  headers: MapsConfig.apiHeaders,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                        'Error loading preview image: $error');
                                    return Container(
                                      height: _previewHeight,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey[400],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _translations['no_preview'] ??
                                                  'No preview available',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_previewType == 'streetview')
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _selectedLocation != null
                                          ? _showStreetView(_selectedLocation!)
                                          : null,
                                      icon: const Icon(Icons.streetview,
                                          size: 16),
                                      label: Text(
                                        _translations['view_street_view'] ??
                                            'View Street View',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              height: _previewHeight,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  _translations['no_preview'] ??
                                      'No preview available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                ),
                if (_selectedLocationAddress != null && !_isLoadingPreview)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocationAddress!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _searchFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    // WebViewController doesn't need to be disposed in newer versions
    super.dispose();
  }
}
