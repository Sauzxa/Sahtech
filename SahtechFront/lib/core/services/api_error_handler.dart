import 'dart:convert';
import 'package:http/http.dart';

/// API error handler utility for processing HTTP responses and errors
class ApiErrorHandler {
  /// Check if response contains a valid product
  static bool isValidProductResponse(Response? response) {
    if (response == null) {
      return false;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    try {
      final data = json.decode(response.body);

      // Check if data has necessary fields to be considered a valid product
      if (data is Map<String, dynamic>) {
        // Check if either name or nom field is present (indicating it's a product)
        return data.containsKey('name') ||
            data.containsKey('nom') ||
            data.containsKey('id');
      }
    } catch (e) {
      print('Error parsing response: $e');
    }

    return false;
  }

  /// Safely parse JSON response and handle errors
  static Map<String, dynamic>? parseJsonResponse(Response? response) {
    if (response == null) {
      return null;
    }

    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error parsing JSON response: $e');
    }

    return null;
  }

  /// Format error message for user display
  static String formatErrorMessage(dynamic error) {
    // Handle specific error types with user-friendly messages
    if (error.toString().contains('SocketException')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'La connexion au serveur a pris trop de temps. Veuillez réessayer.';
    } else if (error.toString().contains('FormatException')) {
      return 'Erreur de format de données. Veuillez contacter le support.';
    }

    // Generic error message
    return 'Une erreur s\'est produite. Veuillez réessayer plus tard.';
  }

  /// Standardize barcode format
  static String normalizeBarcode(String barcode) {
    // Remove non-digit characters
    String normalized = barcode.replaceAll(RegExp(r'\D'), '');
    // Remove leading zeros
    return normalized.replaceAll(RegExp(r'^0+'), '');
  }
}
