import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTestUtility {
  static const String apiBaseUrl = 'http://172.17.39.93:5000/predict';

  // Test if API is reachable
  static Future<Map<String, dynamic>> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse(apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return {
        'success': true,
        'message': 'API is reachable',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Test prediction endpoint with a sample image
  static Future<Map<String, dynamic>> testPredictionEndpoint(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/predict'),
      );

      var imageFile = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(imageFile);

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return {
          'success': true,
          'data': jsonData,
          'message': 'Prediction successful',
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Validate expected response structure
  static bool validateResponseStructure(Map<String, dynamic> response) {
    final requiredFields = ['disease', 'confidence', 'recommendation'];

    for (String field in requiredFields) {
      if (!response.containsKey(field)) {
        return false;
      }
    }

    // Additional validation
    if (response['confidence'] is! num) return false;
    if (response['disease'] is! String) return false;
    if (response['recommendation'] is! String) return false;

    return true;
  }

  // Print response analysis
  static void analyzeResponse(Map<String, dynamic> response) {
    print('=== API Response Analysis ===');
    print('Disease: ${response['disease']}');
    print('Confidence: ${response['confidence']}');
    print('Has GradCAM: ${response.containsKey('gradcam')}');
    print('Recommendation: ${response['recommendation']}');
    print('Response Structure Valid: ${validateResponseStructure(response)}');
  }
}