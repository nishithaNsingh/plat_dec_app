// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../model/disease_model.dart';
// import '../services/ml_services.dart';
//
// enum PredictionMode { local, api, hybrid }
//
// class DetectionController with ChangeNotifier {
//   final ImagePicker _picker = ImagePicker();
//   final MLService _mlService = MLService.instance;
//
//   File? _selectedImage;
//   DiseaseModel? _currentPrediction;
//   String? _errorMessage;
//
//   bool _isLoading = false;
//   List<DiseaseModel> _detectionHistory = [];
//   PredictionMode _currentMode = PredictionMode.local; // Force local mode
//   String _detectionSource = 'Local Model';
//
//   // API Configuration - COMMENTED OUT
//   // static const String _apiBaseUrl = 'https://leaf-scan.onrender.com';
//   // static const String _predictEndpoint = '/predict';
//   // static const int _apiTimeout = 60;
//
//   // Getters
//   File? get selectedImage => _selectedImage;
//   DiseaseModel? get currentPrediction => _currentPrediction;
//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _isLoading;
//   bool get hasImage => _selectedImage != null;
//   bool get hasPrediction => _currentPrediction != null;
//   List<DiseaseModel> get detectionHistory => _detectionHistory;
//   bool get isModelLoaded => _mlService.isModelLoaded;
//   String get detectionSource => _detectionSource;
//   PredictionMode get currentMode => _currentMode;
//
//   DetectionController() {
//     _loadHistory();
//     _initializeModels();
//   }
//
//   // Initialize models - LOCAL ONLY
//   Future<void> _initializeModels() async {
//     try {
//       debugPrint('🔄 Initializing LOCAL detection model...');
//
//       // Try to load local model
//       final localLoaded = await _mlService.loadModel();
//       if (localLoaded) {
//         debugPrint('✅ Local ML model loaded successfully');
//
//         // Test the model
//         final testResult = await _mlService.testModel();
//         debugPrint('🧪 Model test result: $testResult');
//
//         // Force local mode since we have multiple plants
//         _currentMode = PredictionMode.local;
//         _detectionSource = 'Local Model';
//         debugPrint('🔧 Using Local Mode Only for multiple plant support');
//       } else {
//         debugPrint('❌ Local model failed to load');
//         _errorMessage = 'Local model failed to load. Please check if model file exists.';
//         notifyListeners();
//       }
//
//     } catch (e) {
//       debugPrint('❌ Model initialization error: $e');
//       _errorMessage = 'Model initialization failed: $e';
//       notifyListeners();
//     }
//   }
//
//   // Initialize the controller
//   Future<void> initialize() async {
//     await _loadHistory();
//     await _initializeModels();
//   }
//
//   // Warm up API - COMMENTED OUT
//   /*
//   Future<void> _warmUpApi() async {
//     try {
//       debugPrint('🔥 Warming up API...');
//       final response = await http.get(
//         Uri.parse(_apiBaseUrl),
//         headers: {'Accept': 'application/json'},
//       ).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () {
//           debugPrint('⏱️ API warm-up timeout (this is ok)');
//           throw TimeoutException('Warm-up timeout');
//         },
//       );
//
//       if (response.statusCode == 200) {
//         debugPrint('✅ API is ready');
//       }
//     } catch (e) {
//       debugPrint('ℹ️ API warm-up: $e');
//     }
//   }
//   */
//
//   // Pick image from camera or gallery
//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         _selectedImage = File(image.path);
//         _currentPrediction = null;
//         _errorMessage = null;
//         _detectionSource = 'Local Model';
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to pick image: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   // Main prediction method - LOCAL ONLY
//   Future<void> predictDisease() async {
//     if (_selectedImage == null) {
//       _errorMessage = 'Please select an image first';
//       notifyListeners();
//       return;
//     }
//
//     _isLoading = true;
//     _errorMessage = null;
//     _detectionSource = 'Local Model';
//     notifyListeners();
//
//     try {
//       debugPrint('🔍 Starting LOCAL disease prediction...');
//       debugPrint('📊 Model loaded: ${_mlService.isModelLoaded}');
//
//       // ONLY USE LOCAL MODEL
//       if (_mlService.isModelLoaded) {
//         debugPrint('📱 Using LOCAL model for prediction...');
//         _currentPrediction = await _mlService.predictDisease(_selectedImage!);
//         _detectionSource = 'Local Model';
//         debugPrint('✅ Local prediction successful: ${_currentPrediction!.plant} - ${_currentPrediction!.disease}');
//
//         await _saveToHistory(_currentPrediction!);
//         _errorMessage = null;
//       } else {
//         debugPrint('❌ No local model available');
//         throw Exception('Local model not available. Please check if model file exists.');
//       }
//
//     } catch (e) {
//       _errorMessage = e.toString().replaceAll('Exception: ', '');
//       debugPrint('❌ Prediction error: $_errorMessage');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // API prediction method - COMMENTED OUT
//   /*
//   Future<void> _predictViaApi() async {
//     try {
//       // Check internet connectivity
//       try {
//         final testConnection = await InternetAddress.lookup('google.com')
//             .timeout(const Duration(seconds: 5));
//         if (testConnection.isEmpty) {
//           throw SocketException('No internet connection');
//         }
//       } catch (e) {
//         throw SocketException('No internet connection. Please check your network.');
//       }
//
//       // Create multipart request
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_apiBaseUrl$_predictEndpoint'),
//       );
//
//       var imageFile = await http.MultipartFile.fromPath(
//         'file',
//         _selectedImage!.path,
//       );
//       request.files.add(imageFile);
//
//       request.headers.addAll({
//         'Content-Type': 'multipart/form-data',
//         'Accept': 'application/json',
//       });
//
//       debugPrint('⏳ Sending API request...');
//
//       var streamedResponse = await request.send().timeout(
//         Duration(seconds: _apiTimeout),
//         onTimeout: () {
//           throw TimeoutException(
//             'Server is taking longer than expected. Please try again.',
//           );
//         },
//       );
//
//       var response = await http.Response.fromStream(streamedResponse);
//       debugPrint('📥 API Response status: ${response.statusCode}');
//       debugPrint('📥 API Response body: ${response.body}');
//
//       final responseData = ApiResponseHandler.handleResponse(response);
//
//       if (responseData['success']) {
//         _currentPrediction = _parseApiResponse(responseData['data']);
//         _detectionSource = 'Cloud API';
//         debugPrint('✅ API prediction successful: ${_currentPrediction!.plant} - ${_currentPrediction!.disease}');
//
//         await _saveToHistory(_currentPrediction!);
//         _errorMessage = null;
//       } else {
//         throw Exception(responseData['error']);
//       }
//     } on SocketException catch (e) {
//       throw SocketException('No internet connection. Please check your network settings.');
//     } on TimeoutException catch (e) {
//       throw TimeoutException(
//           e.message ?? 'Request timed out. The server may be starting up. Please wait 30 seconds and try again.'
//       );
//     } catch (e) {
//       throw Exception('API prediction failed: ${e.toString()}');
//     }
//   }
//
//   // Parse API response - COMMENTED OUT
//   DiseaseModel _parseApiResponse(Map<String, dynamic> jsonResponse) {
//     String disease = jsonResponse['disease'] ?? 'Unknown';
//     double confidence = ((jsonResponse['confidence'] ?? 0.0) * 100).toDouble();
//     String apiRecommendation = jsonResponse['recommendation'] ?? '';
//
//     // Extract plant from disease name instead of hardcoding
//     String plant = _extractPlantFromDisease(disease);
//
//     String recommendation = apiRecommendation.isNotEmpty
//         ? apiRecommendation
//         : AppConstants.getRecommendation(disease);
//
//     return DiseaseModel(
//       plant: plant,
//       disease: disease,
//       confidence: confidence,
//       timestamp: DateTime.now(),
//       imagePath: _selectedImage?.path,
//       fullPrediction: 'API_$plant\_\_\_$disease',
//     );
//   }
//
//   // Extract plant name from disease string - COMMENTED OUT
//   String _extractPlantFromDisease(String disease) {
//     final lowerDisease = disease.toLowerCase();
//
//     if (lowerDisease.contains('apple') && !lowerDisease.contains('pineapple')) return 'Apple';
//     if (lowerDisease.contains('tomato')) return 'Tomato';
//     if (lowerDisease.contains('potato')) return 'Potato';
//     if (lowerDisease.contains('corn') || lowerDisease.contains('maize')) return 'Corn';
//     if (lowerDisease.contains('grape')) return 'Grape';
//     if (lowerDisease.contains('peach')) return 'Peach';
//     if (lowerDisease.contains('pepper') || lowerDisease.contains('bell') || lowerDisease.contains('chili') || lowerDisease.contains('chilly')) return 'Pepper';
//     if (lowerDisease.contains('cherry')) return 'Cherry';
//     if (lowerDisease.contains('strawberry')) return 'Strawberry';
//     if (lowerDisease.contains('blueberry')) return 'Blueberry';
//     if (lowerDisease.contains('raspberry')) return 'Raspberry';
//     if (lowerDisease.contains('soybean')) return 'Soybean';
//     if (lowerDisease.contains('squash')) return 'Squash';
//     if (lowerDisease.contains('orange') || lowerDisease.contains('citrus')) return 'Orange';
//
//     // Check for disease patterns that are plant-specific
//     if (lowerDisease.contains('scab')) return 'Apple'; // Apple scab is very specific
//     if (lowerDisease.contains('cedar') || lowerDisease.contains('rust')) return 'Apple'; // Cedar apple rust
//     if (lowerDisease.contains('black rot')) return 'Apple'; // Apple black rot
//     if (lowerDisease.contains('leaf curl')) return 'Pepper'; // Chili leaf curl is common
//
//     return 'Unknown Plant';
//   }
//
//   // Validate plant detection - COMMENTED OUT
//   String _validatePlantDetection(String detectedPlant, String disease, double confidence) {
//     final lowerDisease = disease.toLowerCase();
//
//     // If confidence is low, likely misclassification
//     if (confidence < 60) {
//       return 'Unknown Plant';
//     }
//
//     // If API is chili-specific but detecting other plants with high confidence,
//     // it's likely misclassifying
//     if (detectedPlant != 'Pepper' && detectedPlant != 'Unknown Plant') {
//       // Check if this might be a chili disease misclassified as another plant
//       if (lowerDisease.contains('leaf curl') ||
//           lowerDisease.contains('mosaic') ||
//           lowerDisease.contains('virus')) {
//         return 'Pepper'; // These are common in chili
//       }
//     }
//
//     return detectedPlant;
//   }
//   */
//
//   // Change prediction mode - MODIFIED FOR LOCAL ONLY
//   void setPredictionMode(PredictionMode mode) {
//     // Only allow local mode for now
//     if (mode != PredictionMode.local) {
//       debugPrint('⚠️ Only Local mode is supported currently');
//       return;
//     }
//
//     _currentMode = mode;
//     notifyListeners();
//     debugPrint('🔄 Prediction mode: Local Only');
//   }
//
//   // Reset detection state
//   void resetDetection() {
//     _selectedImage = null;
//     _currentPrediction = null;
//     _errorMessage = null;
//     _detectionSource = 'Local Model';
//     notifyListeners();
//   }
//
//   // Save prediction to history
//   Future<void> _saveToHistory(DiseaseModel prediction) async {
//     _detectionHistory.insert(0, prediction);
//
//     if (_detectionHistory.length > 100) {
//       _detectionHistory = _detectionHistory.take(100).toList();
//     }
//
//     await _persistHistory();
//   }
//
//   // Load history from SharedPreferences
//   Future<void> _loadHistory() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final historyJson = prefs.getStringList('detection_history') ?? [];
//
//       _detectionHistory = historyJson
//           .map((json) => DiseaseModel.fromJson(jsonDecode(json)))
//           .toList();
//
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading history: $e');
//     }
//   }
//
//   // Persist history to SharedPreferences
//   Future<void> _persistHistory() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final historyJson = _detectionHistory
//           .map((detection) => jsonEncode(detection.toJson()))
//           .toList();
//
//       await prefs.setStringList('detection_history', historyJson);
//     } catch (e) {
//       debugPrint('Error persisting history: $e');
//     }
//   }
//
//   // Clear history
//   Future<void> clearHistory() async {
//     _detectionHistory.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('detection_history');
//     notifyListeners();
//   }
//
//   // Get statistics
//   Map<String, dynamic> getStatistics() {
//     if (_detectionHistory.isEmpty) {
//       return {
//         'total_detections': 0,
//         'average_confidence': 0.0,
//         'most_common_plant': null,
//       };
//     }
//
//     final totalDetections = _detectionHistory.length;
//     final averageConfidence = _detectionHistory
//         .map((d) => d.confidence)
//         .reduce((a, b) => a + b) / totalDetections;
//
//     final plantCounts = <String, int>{};
//     for (final detection in _detectionHistory) {
//       plantCounts[detection.plant] = (plantCounts[detection.plant] ?? 0) + 1;
//     }
//
//     String? mostCommonPlant;
//     int maxCount = 0;
//     plantCounts.forEach((plant, count) {
//       if (count > maxCount) {
//         maxCount = count;
//         mostCommonPlant = plant;
//       }
//     });
//
//     return {
//       'total_detections': totalDetections,
//       'average_confidence': averageConfidence,
//       'most_common_plant': mostCommonPlant,
//     };
//   }
//
//   // Get model info
//   Map<String, dynamic> getModelInfo() {
//     return {
//       'local_model_loaded': _mlService.isModelLoaded,
//       'current_mode': 'Local Only',
//       'supported_diseases': AppConstants.supportedDiseases.length,
//       'last_detection_source': _detectionSource,
//     };
//   }
// }