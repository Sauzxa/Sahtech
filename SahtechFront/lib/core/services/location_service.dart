import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/widgets.dart';

class LocationService with WidgetsBindingObserver {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  
  LocationService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool _isInitialized = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Check location permission
      final permission = await _checkPermission();
      if (!permission) return false;

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request to enable location service
        await Geolocator.openLocationSettings();
        return false;
      }

      // Start listening to position updates
      await _startLocationUpdates();

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  Future<void> _startLocationUpdates() async {
    await _stopLocationUpdates();  // Stop any existing subscription
    
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,  // Update every 10 meters
      ),
    ).listen(
      (Position position) {
        // Handle position update
        print('Position update: ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        print('Error getting location updates: $error');
        _restartLocationService();
      },
    );
  }

  Future<void> _stopLocationUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> _restartLocationService() async {
    await _stopLocationUpdates();
    await initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        _startLocationUpdates();
        break;
      case AppLifecycleState.paused:
        // App is in the background
        _stopLocationUpdates();
        break;
      default:
        break;
    }
  }

  void disposeLocationService() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates();
  }

  Future<bool> _checkPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Handle permanently denied permission
        await openAppSettings();
        return false;
      }

      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  void dispose() {
    _isInitialized = false;
  }
}