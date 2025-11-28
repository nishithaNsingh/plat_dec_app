import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponseHandler {
  // Handle API response and return parsed data or error
  static Map<String, dynamic> handleResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if response contains error field
        if (jsonData.containsKey('error')) {
          return {
            'success': false,
            'error': jsonData['error'],
          };
        }

        // 🔥 FIXED: Don't normalize - pass raw response to controller
        // The controller will handle different formats

        // Validate that we have at least some data
        if (!_validateApiResponse(jsonData)) {
          return {
            'success': false,
            'error': 'Invalid response format from server',
          };
        }

        return {
          'success': true,
          'data': jsonData, // 🔥 Pass raw response without normalization
        };
      } else {
        return {
          'success': false,
          'error': _getErrorMessageForStatusCode(response.statusCode),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to parse server response: ${e.toString()}',
      };
    }
  }

  // Validate that the API response has at least one expected field
  static bool _validateApiResponse(Map<String, dynamic> response) {
    // Check if response has at least one of these fields
    return response.containsKey('disease') ||
        response.containsKey('crop') ||
        response.containsKey('predicted_class') ||
        response.containsKey('class') ||
        response.containsKey('prediction');
  }

  // Get user-friendly error messages for different HTTP status codes
  static String _getErrorMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid image format. Please select a valid image file.';
      case 404:
        return 'Server endpoint not found. Please try again later.';
      case 413:
        return 'Image file is too large. Please select a smaller image.';
      case 422:
        return 'Image processing failed. Please try with a different image.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 502:
        return 'Server is temporarily unavailable (Bad Gateway). The server may be restarting.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      case 504:
        return 'Request timed out. Please check your connection and try again.';
      default:
        return 'Network error (${statusCode}). Please try again.';
    }
  }

  // Format confidence percentage for display
  static String formatConfidence(double confidence) {
    return '${confidence.toStringAsFixed(1)}%';
  }

  // Get confidence color based on value
  static String getConfidenceLevel(double confidence) {
    if (confidence >= 90) {
      return 'Very High';
    } else if (confidence >= 75) {
      return 'High';
    } else if (confidence >= 60) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }
}