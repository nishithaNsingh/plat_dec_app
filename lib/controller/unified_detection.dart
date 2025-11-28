import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/disease_model.dart';
import '../services/api_response.dart';
import '../services/firebase_services.dart';

/// Unified Detection Controller - Handles API detection for 38 plant diseases
class UnifiedDetectionController with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService.instance;

  File? _selectedImage;
  DiseaseModel? _currentPrediction;
  String? _errorMessage;
  bool _isLoading = false;
  List<DiseaseModel> _detectionHistory = [];

  // API Configuration
  static const String _apiUrl = 'https://model-predict-r05h.onrender.com';
  static const String _predictEndpoint = '/predict';
  static const int _apiTimeout = 90;

  // Getters
  File? get selectedImage => _selectedImage;
  DiseaseModel? get currentPrediction => _currentPrediction;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasImage => _selectedImage != null;
  bool get hasPrediction => _currentPrediction != null;
  List<DiseaseModel> get detectionHistory => _detectionHistory;

  UnifiedDetectionController() {
    _loadHistory();
    _warmUpApi();
  }

  // Warm up API to prevent cold starts
  Future<void> _warmUpApi() async {
    try {
      debugPrint('🔥 Warming up API...');
      await http
          .get(Uri.parse(_apiUrl), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏱️ API warm-up timeout (this is ok)');
              throw TimeoutException('Warm-up timeout');
            },
          );
      debugPrint('✅ API server is ready');
    } catch (e) {
      debugPrint('ℹ️ API warm-up: $e');
    }
  }

  // Initialize the controller
  Future<void> initialize() async {
    await _loadHistory();
    await _warmUpApi();
  }

  // Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _currentPrediction = null;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }

  // Main prediction method
  Future<void> predictDisease() async {
    if (_selectedImage == null) {
      _errorMessage = 'Please select an image first';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Starting disease prediction...');

      // Check internet connectivity
      await _checkInternetConnection();

      // Call API
      debugPrint('📡 Calling Plant Detection API...');
      final prediction = await _predictViaApi();

      _currentPrediction = prediction;

      // Save to local history
      await _saveToHistory(_currentPrediction!);

      // Save to Firebase if authenticated
      if (_firebaseService.isAuthenticated) {
        await _firebaseService.saveDetection(_currentPrediction!);
      }

      _errorMessage = null;
      debugPrint('✅ Prediction successful');
    } on SocketException catch (e) {
      _errorMessage =
          '❌ No internet connection\n\nPlease check your network settings and try again.';
      debugPrint('❌ Network error: $e');
    } on TimeoutException catch (e) {
      _errorMessage =
          '⏱️ Server is starting up\n\n'
          'The cloud server takes 30-90 seconds to wake up on first use.\n'
          'Please wait a moment and try again.';
      debugPrint('⏱️ Timeout: $e');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Unknown error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check internet connectivity
  Future<void> _checkInternetConnection() async {
    try {
      final testConnection = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (testConnection.isEmpty) {
        throw SocketException('No internet connection');
      }
    } catch (e) {
      throw SocketException(
        'No internet connection. Please check your network.',
      );
    }
  }

  // Predict via API
  Future<DiseaseModel> _predictViaApi() async {
    try {
      final String fullUrl = '$_apiUrl$_predictEndpoint';
      debugPrint('🌐 Full URL: $fullUrl');

      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));

      var imageFile = await http.MultipartFile.fromPath(
        'file',
        _selectedImage!.path,
      );
      request.files.add(imageFile);

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      debugPrint('⏳ Sending request to API...');

      var streamedResponse = await request.send().timeout(
        Duration(seconds: _apiTimeout),
        onTimeout: () {
          throw TimeoutException(
            'Server is taking longer than expected ($_apiTimeout s timeout).\n'
            'The server may be cold starting. Please try again in 30 seconds.',
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      debugPrint('📥 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = ApiResponseHandler.handleResponse(response);

        if (responseData['success']) {
          return _parseApiResponse(responseData['data']);
        } else {
          throw Exception(responseData['error']);
        }
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found. Please check the server URL.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ API error: $e');
      rethrow;
    }
  }

  // 🔥 FIXED: Parse API response to handle new format
  DiseaseModel _parseApiResponse(Map<String, dynamic> jsonResponse) {
    debugPrint('🔍 Raw API Response: $jsonResponse');

    String plant;
    String disease;
    String fullPrediction;

    // Format 1: New API format with separate 'crop' and 'disease' fields
    if (jsonResponse.containsKey('crop') &&
        jsonResponse.containsKey('disease')) {
      plant = jsonResponse['crop'] ?? 'Unknown Plant';
      disease = jsonResponse['disease'] ?? 'Unknown';
      fullPrediction =
          jsonResponse['raw_label'] ??
          '${plant}___${disease.replaceAll(' ', '_')}';

      debugPrint('✅ Using Format 1: crop + disease');
    }
    // Format 2: Old API format with single 'disease' field (Plant___Disease)
    else if (jsonResponse.containsKey('disease')) {
      String diseaseStr = jsonResponse['disease'] ?? 'Unknown';

      // Check if disease contains plant info (Plant___Disease format)
      if (diseaseStr.contains('___')) {
        plant = _extractPlantFromDisease(diseaseStr);
        disease =
            diseaseStr.split('___').length > 1
                ? diseaseStr.split('___')[1].replaceAll('_', ' ')
                : diseaseStr;
      } else {
        plant = 'Unknown Plant';
        disease = diseaseStr;
      }

      fullPrediction = diseaseStr;
      debugPrint('✅ Using Format 2: disease only');
    }
    // Format 3: Fallback
    else {
      plant = 'Unknown Plant';
      disease = 'Unknown';
      fullPrediction = 'Unknown___Unknown';
      debugPrint('⚠️ Using Format 3: fallback');
    }

    // Handle confidence in multiple formats
    double confidence = 0.0;
    if (jsonResponse.containsKey('confidence_percent')) {
      // Already in 0-100 range
      confidence = (jsonResponse['confidence_percent'] ?? 0.0).toDouble();
      debugPrint('✅ Using confidence_percent: $confidence');
    } else if (jsonResponse.containsKey('confidence')) {
      double confidenceRaw = (jsonResponse['confidence'] ?? 0.0).toDouble();
      // Convert 0-1 range to 0-100
      confidence = confidenceRaw <= 1.0 ? confidenceRaw * 100 : confidenceRaw;
      debugPrint('✅ Using confidence (converted): $confidence');
    }

    String apiRecommendation = jsonResponse['recommendation'] ?? '';
    String recommendation =
        apiRecommendation.isNotEmpty
            ? apiRecommendation
            : AppConstants.getRecommendation(disease);

    debugPrint(
      '📊 Parsed - Plant: $plant, Disease: $disease, Confidence: ${confidence.toStringAsFixed(1)}%',
    );

    return DiseaseModel(
      plant: plant,
      disease: disease,
      confidence: confidence,
      timestamp: DateTime.now(),
      imagePath: _selectedImage?.path,
      fullPrediction: fullPrediction,
      detectionSource: 'PlantVillage API (38 classes)',
    );
  }

  // Extract plant name from disease string
  String _extractPlantFromDisease(String disease) {
    // If disease follows pattern "Plant___Disease", extract plant part
    if (disease.contains('___')) {
      final parts = disease.split('___');
      if (parts.isNotEmpty) {
        String plantName = parts[0];
        // Clean up plant name
        plantName = plantName.replaceAll('_', ' ');
        plantName = plantName.replaceAll(',', ' -');
        plantName = plantName.replaceAll('(', '').replaceAll(')', '');
        return plantName.trim();
      }
    }

    return 'Unknown Plant';
  }

  // Reset detection state
  void resetDetection() {
    _selectedImage = null;
    _currentPrediction = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Save prediction to history
  Future<void> _saveToHistory(DiseaseModel prediction) async {
    _detectionHistory.insert(0, prediction);

    if (_detectionHistory.length > 100) {
      _detectionHistory = _detectionHistory.take(100).toList();
    }

    await _persistHistory();
  }

  // Load history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('detection_history') ?? [];

      _detectionHistory =
          historyJson
              .map((json) {
                try {
                  return DiseaseModel.fromJson(jsonDecode(json));
                } catch (e) {
                  debugPrint('Error parsing history item: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<DiseaseModel>()
              .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  // Persist history to SharedPreferences
  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          _detectionHistory
              .map((detection) => jsonEncode(detection.toJson()))
              .toList();

      await prefs.setStringList('detection_history', historyJson);
    } catch (e) {
      debugPrint('Error persisting history: $e');
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    _detectionHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('detection_history');

    // Also clear Firebase history if authenticated
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.clearHistory();
    }

    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    if (_detectionHistory.isEmpty) {
      return {
        'total_detections': 0,
        'average_confidence': 0.0,
        'most_common_plant': null,
      };
    }

    final totalDetections = _detectionHistory.length;
    final averageConfidence =
        _detectionHistory.map((d) => d.confidence).reduce((a, b) => a + b) /
        totalDetections;

    final plantCounts = <String, int>{};
    for (final detection in _detectionHistory) {
      plantCounts[detection.plant] = (plantCounts[detection.plant] ?? 0) + 1;
    }

    String? mostCommonPlant;
    int maxCount = 0;
    plantCounts.forEach((plant, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonPlant = plant;
      }
    });

    return {
      'total_detections': totalDetections,
      'average_confidence': averageConfidence,
      'most_common_plant': mostCommonPlant,
    };
  }

  // Get model info
  Map<String, dynamic> getModelInfo() {
    return {
      'detection_mode': 'Cloud API',
      'model_name': 'PlantVillage',
      'supported_plants': 14,
      'supported_diseases': 38,
      'local_model_loaded': false,
      'api_available': true,
    };
  }

  // Test API connection
  Future<bool> testApiConnection() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      final isConnected =
          response.statusCode == 200 || response.statusCode == 404;
      debugPrint('API test: ${isConnected ? "✅ Connected" : "❌ Failed"}');
      return isConnected;
    } catch (e) {
      debugPrint('API test failed: $e');
      return false;
    }
  }
}
