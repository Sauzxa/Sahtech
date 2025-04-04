import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service to manage nutritionist data persistence, registration, and loading
class NutritionistService extends ChangeNotifier {
  static final NutritionistService _instance = NutritionistService._internal();
  factory NutritionistService() => _instance;
  NutritionistService._internal();

  static const String _dataKey = 'nutritionist_data';
  static const String _registrationInProgressKey = 'nutritionist_reg_in_progress';
  static const String _registrationStepKey = 'nutritionist_reg_step';
  
  bool _isLoading = false;
  NutritionisteModel? _currentNutritionist;
  
  bool get isLoading => _isLoading;
  NutritionisteModel? get currentNutritionist => _currentNutritionist;
  
  // Check if registration is in progress
  Future<bool> isRegistrationInProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_registrationInProgressKey) ?? false;
    } catch (e) {
      debugPrint('Error checking registration status: $e');
      return false;
    }
  }
  
  // Get current registration step
  Future<int> getCurrentRegistrationStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_registrationStepKey) ?? 1;
    } catch (e) {
      debugPrint('Error getting registration step: $e');
      return 1;
    }
  }
  
  // Save current registration step
  Future<void> saveRegistrationStep(int step) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_registrationStepKey, step);
    } catch (e) {
      debugPrint('Error saving registration step: $e');
    }
  }
  
  // Start or continue nutritionist registration
  Future<NutritionisteModel> startRegistration() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Try to load existing data first
      await loadNutritionistData();
      
      // If no data exists, create a new model
      if (_currentNutritionist == null) {
        _currentNutritionist = NutritionisteModel(userType: 'nutritionist');
      }
      
      // Mark registration as in progress
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_registrationInProgressKey, true);
      
      return _currentNutritionist!;
    } catch (e) {
      debugPrint('Error starting registration: $e');
      // Create a default model if loading fails
      return NutritionisteModel(userType: 'nutritionist');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Save nutritionist data during registration steps
  Future<void> saveRegistrationData(NutritionisteModel data, int currentStep) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentNutritionist = data;
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(data.toMap());
      await prefs.setString(_dataKey, jsonData);
      
      // Update current step
      await prefs.setInt(_registrationStepKey, currentStep);
      
      debugPrint('Saved nutritionist data for step $currentStep');
    } catch (e) {
      debugPrint('Error saving nutritionist data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Complete registration and mark as finished
  Future<void> completeRegistration(NutritionisteModel data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentNutritionist = data;
      
      // Save the final data
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(data.toMap());
      await prefs.setString(_dataKey, jsonData);
      
      // Mark registration as complete
      await prefs.setBool(_registrationInProgressKey, false);
      
      // Reset step counter
      await prefs.remove(_registrationStepKey);
      
      debugPrint('Nutritionist registration completed successfully');
      
      // Here you would typically also:
      // 1. Upload data to a backend server
      // 2. Create the user account if needed
      // 3. Set up the nutritionist profile online
    } catch (e) {
      debugPrint('Error completing registration: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load saved nutritionist data
  Future<NutritionisteModel?> loadNutritionistData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_dataKey);
      
      if (jsonData != null && jsonData.isNotEmpty) {
        final map = jsonDecode(jsonData) as Map<String, dynamic>;
        _currentNutritionist = NutritionisteModel.fromMap(map);
        debugPrint('Loaded nutritionist data successfully');
        return _currentNutritionist;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading nutritionist data: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear all saved nutritionist data
  Future<void> clearNutritionistData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dataKey);
      await prefs.remove(_registrationInProgressKey);
      await prefs.remove(_registrationStepKey);
      
      _currentNutritionist = null;
      debugPrint('Cleared all nutritionist data');
    } catch (e) {
      debugPrint('Error clearing nutritionist data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 