// Test file to verify API response format handling
// Save as: test/api_format_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API Response Format Tests', () {

    test('Should handle Chili API format (predicted_class)', () {
      // Chili API Response: http://172.17.39.93:5000/predict
      final chiliResponse = {
        "confidence": 100.0,
        "predicted_class": "Apple___Black_rot"
      };

      final normalized = _normalizeApiResponse(chiliResponse);

      expect(normalized['disease'], 'Apple___Black_rot');
      expect(normalized['confidence'], 1.0); // Converted from 100.0 to 0-1 range
      expect(normalized.containsKey('recommendation'), true);
    });

    test('Should handle Plant API format (disease)', () {
      // Plant API Response (38 classes)
      final plantResponse = {
        "disease": "Tomato___Late_blight",
        "confidence": 0.95,
        "recommendation": "Apply fungicide immediately"
      };

      final normalized = _normalizeApiResponse(plantResponse);

      expect(normalized['disease'], 'Tomato___Late_blight');
      expect(normalized['confidence'], 0.95);
      expect(normalized['recommendation'], 'Apply fungicide immediately');
    });

    test('Should convert confidence from 0-100 to 0-1 range', () {
      final response = {
        "predicted_class": "Pepper___Bacterial_spot",
        "confidence": 85.5
      };

      final normalized = _normalizeApiResponse(response);

      expect(normalized['confidence'], 0.855);
    });

    test('Should keep confidence in 0-1 range unchanged', () {
      final response = {
        "disease": "Pepper___Bacterial_spot",
        "confidence": 0.855
      };

      final normalized = _normalizeApiResponse(response);

      expect(normalized['confidence'], 0.855);
    });

    test('Should extract plant name from disease', () {
      expect(_extractPlant('Apple___Black_rot'), 'Apple');
      expect(_extractPlant('Tomato___Late_blight'), 'Tomato');
      expect(_extractPlant('Pepper,_bell___Bacterial_spot'), 'Pepper');
      expect(_extractPlant('Corn_(maize)___Common_rust_'), 'Corn');
    });
  });
}

// Helper functions (copy from your actual code)
Map<String, dynamic> _normalizeApiResponse(Map<String, dynamic> response) {
  if (response.containsKey('predicted_class')) {
    return {
      'disease': response['predicted_class'],
      'confidence': (response['confidence'] ?? 0.0) / 100.0,
      'recommendation': '',
    };
  }

  if (response.containsKey('disease')) {
    return {
      'disease': response['disease'],
      'confidence': response['confidence'] ?? 0.0,
      'recommendation': response['recommendation'] ?? '',
    };
  }

  return response;
}

String _extractPlant(String disease) {
  if (disease.contains('___')) {
    return disease.split('___')[0]
        .replaceAll('_', ' ')
        .replaceAll(',', ' -')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();
  }
  return 'Unknown';
}