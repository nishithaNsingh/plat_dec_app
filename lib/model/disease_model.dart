class DiseaseModel {
  final String plant;
  final String disease;
  final double confidence;
  final String fullPrediction;
  final DateTime timestamp;
  final String? imagePath;
  final String detectionSource;

  DiseaseModel({
    required this.plant,
    required this.disease,
    required this.confidence,
    required this.fullPrediction,
    required this.timestamp,
    this.imagePath,
    required this.detectionSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'plant': plant,
      'disease': disease,
      'confidence': confidence,
      'fullPrediction': fullPrediction,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'detectionSource': detectionSource,
    };
  }

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      plant: json['plant'] ?? '',
      disease: json['disease'] ?? '',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      fullPrediction: json['fullPrediction'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
      detectionSource: json['detectionSource'] ?? 'Unknown',
    );
  }

  DiseaseSeverity get severity {
    if (confidence >= 90) return DiseaseSeverity.high;
    if (confidence >= 70) return DiseaseSeverity.medium;
    return DiseaseSeverity.low;
  }

  String get recommendation {
    return AppConstants.getRecommendation(disease);
  }
}

enum DiseaseSeverity { low, medium, high }

class AppConstants {
  // 38 classes from PlantVillage dataset
  static const List<String> supportedDiseases = [
    'Apple___Apple_scab',
    'Apple___Black_rot',
    'Apple___Cedar_apple_rust',
    'Apple___healthy',
    'Blueberry___healthy',
    'Cherry_(including_sour)___Powdery_mildew',
    'Cherry_(including_sour)___healthy',
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
    'Corn_(maize)___Common_rust_',
    'Corn_(maize)___Northern_Leaf_Blight',
    'Corn_(maize)___healthy',
    'Grape___Black_rot',
    'Grape___Esca_(Black_Measles)',
    'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    'Grape___healthy',
    'Orange___Haunglongbing_(Citrus_greening)',
    'Peach___Bacterial_spot',
    'Peach___healthy',
    'Pepper,_bell___Bacterial_spot',
    'Pepper,_bell___healthy',
    'Potato___Early_blight',
    'Potato___Late_blight',
    'Potato___healthy',
    'Raspberry___healthy',
    'Soybean___healthy',
    'Squash___Powdery_mildew',
    'Strawberry___Leaf_scorch',
    'Strawberry___healthy',
    'Tomato___Bacterial_spot',
    'Tomato___Early_blight',
    'Tomato___Late_blight',
    'Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Target_Spot',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy'
  ];

  static const int modelInputSize = 224;
  static const int maxHistoryItems = 100;

  static String getRecommendation(String disease) {
    final lowerDisease = disease.toLowerCase();

    if (lowerDisease.contains('healthy')) {
      return 'Plant appears healthy! Continue with regular care and monitoring.';
    }
    if (lowerDisease.contains('bacterial_spot') || lowerDisease.contains('bacterial spot')) {
      return 'Apply copper-based fungicide. Remove affected leaves and ensure good air circulation. Avoid overhead watering.';
    }
    if (lowerDisease.contains('early_blight') || lowerDisease.contains('early blight')) {
      return 'Remove infected leaves, apply fungicide, practice crop rotation, and mulch around plants to prevent splash.';
    }
    if (lowerDisease.contains('late_blight') || lowerDisease.contains('late blight')) {
      return 'Remove and destroy infected plants immediately. Apply copper fungicide preventively in wet weather.';
    }
    if (lowerDisease.contains('rust')) {
      return 'Apply sulfur or neem-based fungicide. Improve air circulation and remove infected leaves.';
    }
    if (lowerDisease.contains('powdery_mildew') || lowerDisease.contains('powdery mildew')) {
      return 'Apply sulfur or potassium bicarbonate spray. Ensure adequate spacing and air circulation.';
    }
    if (lowerDisease.contains('leaf_curl') || lowerDisease.contains('virus') || lowerDisease.contains('mosaic')) {
      return 'Remove infected plants. Control aphids and whiteflies. Use virus-free seeds or transplants.';
    }
    if (lowerDisease.contains('black_rot') || lowerDisease.contains('black rot')) {
      return 'Prune and destroy infected parts. Apply appropriate fungicide and practice good sanitation.';
    }
    if (lowerDisease.contains('leaf_spot') || lowerDisease.contains('cercospora') || lowerDisease.contains('septoria')) {
      return 'Remove infected leaves, apply fungicide, and ensure proper plant spacing for air circulation.';
    }
    if (lowerDisease.contains('scab')) {
      return 'Apply fungicide during wet periods. Rake and destroy fallen leaves. Prune for better air circulation.';
    }
    if (lowerDisease.contains('leaf_mold') || lowerDisease.contains('mold')) {
      return 'Improve ventilation, reduce humidity, remove affected leaves, and apply appropriate fungicide.';
    }
    if (lowerDisease.contains('target_spot') || lowerDisease.contains('target spot')) {
      return 'Remove infected plant parts, apply fungicide, avoid overhead watering, and practice crop rotation.';
    }
    if (lowerDisease.contains('spider_mite') || lowerDisease.contains('spider mite')) {
      return 'Spray with water to dislodge mites. Use insecticidal soap or neem oil. Maintain proper humidity.';
    }
    if (lowerDisease.contains('leaf_scorch') || lowerDisease.contains('leaf scorch')) {
      return 'Ensure adequate watering, mulch around plants, and remove severely affected leaves.';
    }
    if (lowerDisease.contains('northern_leaf_blight') || lowerDisease.contains('northern leaf blight')) {
      return 'Plant resistant varieties, practice crop rotation, and apply fungicide if severe.';
    }
    if (lowerDisease.contains('esca') || lowerDisease.contains('measles')) {
      return 'Prune infected areas, protect pruning wounds, and maintain plant vigor through proper care.';
    }
    if (lowerDisease.contains('haunglongbing') || lowerDisease.contains('citrus greening')) {
      return 'Remove infected trees immediately. Control insect vectors. Use certified disease-free plants.';
    }

    return 'Consult with a local agricultural extension office for specific treatment. Remove affected plant parts and improve growing conditions.';
  }

  static String extractPlant(String fullPrediction) {
    if (fullPrediction.contains('___')) {
      return fullPrediction.split('___')[0]
          .replaceAll('_', ' ')
          .replaceAll(',', ' -')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();
    }
    return 'Unknown';
  }

  static String extractDisease(String fullPrediction) {
    final parts = fullPrediction.split('___');
    return parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Unknown';
  }
}