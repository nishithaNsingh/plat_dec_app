import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('es', ''),
    Locale('fr', ''),
    Locale('de', ''),
    Locale('hi', ''),
    Locale('ar', ''),
    Locale('zh', ''),
    Locale('ja', ''),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Name
      'app_name': 'Plant Disease Detector',
      'ai_powered_analysis': 'AI-Powered Plant Health Analysis',

      // Navigation
      'detect': 'Detect',
      'history': 'History',
      'settings': 'Settings',

      // Detection Screen
      'plant_disease_detector': 'Plant Disease Detector',
      'upload_plant_leaf_image': 'Upload Plant Leaf Image',
      'take_photo_description': 'Take a photo or choose from gallery to detect plant diseases',
      'select_image': 'Select Image',
      'analyzing': 'Analyzing...',
      'predict_disease': 'Predict Disease',
      'ai_model_loading': 'AI Model is loading...',
      'detection_results': 'Detection Results',
      'analyze_another_image': 'Analyze Another Image',
      'confidence': 'Confidence',
      'recommendation': 'Recommendation',
      'quick_stats': 'Quick Stats',
      'total_detections': 'Total Detections',
      'recent': 'Recent',

      // Image Picker
      'select_image_source': 'Select Image Source',
      'camera': 'Camera',
      'gallery': 'Gallery',

      // History Screen
      'detection_history': 'Detection History',
      'clear_all': 'Clear All',
      'loading_history': 'Loading history...',
      'no_detection_history': 'No Detection History',
      'history_description': 'Your plant disease detection history will appear here after you analyze some images.',
      'start_detecting': 'Start Detecting',
      'statistics': 'Statistics',
      'total': 'Total',
      'avg_confidence': 'Avg. Confidence',
      'most_common': 'Most Common',
      'clear_history': 'Clear History',
      'clear_history_confirmation': 'Are you sure you want to clear all detection history? This action cannot be undone.',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'history_cleared': 'History cleared successfully',

      // Detection Details
      'detection_details': 'Detection Details',
      'plant_type': 'Plant Type',
      'disease_detected': 'Disease Detected',
      'severity': 'Severity',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'disease_information': 'Disease Information',
      'description': 'Description',
      'treatment_recommendations': 'Treatment Recommendations',
      'detection_details_info': 'Detection Details',
      'date': 'Date',
      'time': 'Time',
      'full_classification': 'Full Classification',
      'image_not_available': 'Image not available',

      // Settings Screen
      'app_settings': 'App Settings',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'notifications_description': 'Receive detection updates',
      'save_history': 'Save History',
      'save_history_description': 'Store detection history locally',
      'language': 'Language',
      'select_language': 'Select Language',
      'data_management': 'Data Management',
      'clear_history_settings': 'Clear History',
      'clear_history_settings_description': 'Delete all detection history',
      'reset_app': 'Reset App',
      'reset_app_description': 'Reset all app settings to default',
      'model_information': 'Model Information',
      'model_loaded': 'Model Loaded',
      'model_not_loaded': 'Model Not Loaded',
      'supported_diseases': 'Supported Diseases',
      'input_size': 'Input Size',
      'model_type': 'Model Type',
      'about': 'About',
      'app_info': 'App Info',
      'app_info_description': 'Version, developer information',
      'help_support': 'Help & Support',
      'help_support_description': 'Get help using the app',
      'rate_app': 'Rate App',
      'rate_app_description': 'Rate us on the app store',

      // Theme Options
      'light': 'Light',
      'dark': 'Dark',
      'system_default': 'System Default',
      'choose_theme': 'Choose Theme',

      // Languages
      'english': 'English',
      'spanish': 'Spanish',
      'french': 'French',
      'german': 'German',
      'hindi': 'Hindi',
      'arabic': 'Arabic',
      'chinese': 'Chinese',
      'japanese': 'Japanese',

      // Onboarding
      'onboarding_title_1': 'Plant Disease Detection',
      'onboarding_desc_1': 'Use AI to identify diseases in your plants quickly and accurately with just a photo.',
      'onboarding_title_2': 'Easy to Use',
      'onboarding_desc_2': 'Simply take a photo of the affected leaf and get instant results with confidence scores.',
      'onboarding_title_3': 'Smart Analysis',
      'onboarding_desc_3': 'Get detailed information about the disease, severity, and recommended treatments.',
      'onboarding_title_4': 'Track History',
      'onboarding_desc_4': 'Keep track of all your detections and monitor your plant health over time.',
      'skip': 'Skip',
      'next': 'Next',
      'previous': 'Previous',
      'get_started': 'Get Started',

      // Errors
      'no_internet': 'No internet connection. Please check your network settings.',
      'prediction_failed': 'Prediction failed. Please try again.',
      'invalid_image': 'Invalid image format. Please select a valid image file.',
      'image_too_large': 'Image file is too large. Please select a smaller image.',
      'server_error': 'Server error occurred. Please try again later.',
      'please_select_image': 'Please select an image first',
      'failed_to_pick_image': 'Failed to pick image',

      // Dialogs
      'ok': 'OK',
      'got_it': 'Got it',
      'maybe_later': 'Maybe Later',
      'rate_now': 'Rate Now',
      'reset': 'Reset',

      // Disease recommendations
      'healthy_recommendation': 'Plant appears healthy! Continue with regular care and monitoring.',
      'bacterial_spot_recommendation': 'Apply copper-based fungicide and remove affected leaves. Ensure good air circulation.',
      'default_recommendation': 'Consult with a local agricultural extension office for specific treatment recommendations.',
    },

    'es': {
      // Spanish translations
      'app_name': 'Detector de Enfermedades de Plantas',
      'ai_powered_analysis': 'Análisis de Salud Vegetal con IA',
      'detect': 'Detectar',
      'history': 'Historial',
      'settings': 'Configuración',
      'plant_disease_detector': 'Detector de Enfermedades de Plantas',
      'upload_plant_leaf_image': 'Cargar Imagen de Hoja de Planta',
      'take_photo_description': 'Toma una foto o elige de la galería para detectar enfermedades de plantas',
      'select_image': 'Seleccionar Imagen',
      'analyzing': 'Analizando...',
      'predict_disease': 'Predecir Enfermedad',
      'ai_model_loading': 'El modelo de IA se está cargando...',
      'detection_results': 'Resultados de Detección',
      'analyze_another_image': 'Analizar Otra Imagen',
      'confidence': 'Confianza',
      'recommendation': 'Recomendación',
      'camera': 'Cámara',
      'gallery': 'Galería',
      'detection_history': 'Historial de Detección',
      'no_detection_history': 'Sin Historial de Detección',
      'start_detecting': 'Comenzar a Detectar',
      'statistics': 'Estadísticas',
      'clear_history': 'Limpiar Historial',
      'cancel': 'Cancelar',
      'clear': 'Limpiar',
      'settings': 'Configuración',
      'theme': 'Tema',
      'language': 'Idioma',
      'light': 'Claro',
      'dark': 'Oscuro',
      'system_default': 'Por Defecto del Sistema',
      'english': 'Inglés',
      'spanish': 'Español',
      'french': 'Francés',
      'german': 'Alemán',
      'hindi': 'Hindi',
      'arabic': 'Árabe',
      'chinese': 'Chino',
      'japanese': 'Japonés',
      'ok': 'OK',
      'skip': 'Saltar',
      'next': 'Siguiente',
      'get_started': 'Comenzar',
    },

    'hi': {
      // Hindi translations
      'app_name': 'पौधे की बीमारी डिटेक्टर',
      'ai_powered_analysis': 'AI-संचालित पौधे स्वास्थ्य विश्लेषण',
      'detect': 'पता लगाएं',
      'history': 'इतिहास',
      'settings': 'सेटिंग्स',
      'plant_disease_detector': 'पौधे की बीमारी डिटेक्टर',
      'upload_plant_leaf_image': 'पौधे की पत्ती की छवि अपलोड करें',
      'take_photo_description': 'पौधों की बीमारियों का पता लगाने के लिए फोटो लें या गैलरी से चुनें',
      'select_image': 'छवि चुनें',
      'analyzing': 'विश्लेषण कर रहे हैं...',
      'predict_disease': 'बीमारी की भविष्यवाणी करें',
      'ai_model_loading': 'AI मॉडल लोड हो रहा है...',
      'detection_results': 'खोज परिणाम',
      'analyze_another_image': 'दूसरी छवि का विश्लेषण करें',
      'confidence': 'विश्वास',
      'recommendation': 'सिफारिश',
      'camera': 'कैमरा',
      'gallery': 'गैलरी',
      'detection_history': 'खोज इतिहास',
      'no_detection_history': 'कोई खोज इतिहास नहीं',
      'start_detecting': 'खोजना शुरू करें',
      'statistics': 'आंकड़े',
      'clear_history': 'इतिहास साफ करें',
      'cancel': 'रद्द करें',
      'clear': 'साफ करें',
      'theme': 'थीम',
      'language': 'भाषा',
      'light': 'हल्का',
      'dark': 'गहरा',
      'system_default': 'सिस्टम डिफ़ॉल्ट',
      'english': 'अंग्रेजी',
      'spanish': 'स्पेनिश',
      'french': 'फ्रेंच',
      'german': 'जर्मन',
      'hindi': 'हिंदी',
      'arabic': 'अरबी',
      'chinese': 'चीनी',
      'japanese': 'जापानी',
      'ok': 'ठीक है',
      'skip': 'छोड़ें',
      'next': 'अगला',
      'get_started': 'शुरू करें',
    },

    // Add more languages as needed...
  };

  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get aiPoweredAnalysis => _localizedValues[locale.languageCode]!['ai_powered_analysis']!;
  String get detect => _localizedValues[locale.languageCode]!['detect']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get plantDiseaseDetector => _localizedValues[locale.languageCode]!['plant_disease_detector']!;
  String get uploadPlantLeafImage => _localizedValues[locale.languageCode]!['upload_plant_leaf_image']!;
  String get takePhotoDescription => _localizedValues[locale.languageCode]!['take_photo_description']!;
  String get selectImage => _localizedValues[locale.languageCode]!['select_image']!;
  String get analyzing => _localizedValues[locale.languageCode]!['analyzing']!;
  String get predictDisease => _localizedValues[locale.languageCode]!['predict_disease']!;
  String get aiModelLoading => _localizedValues[locale.languageCode]!['ai_model_loading']!;
  String get detectionResults => _localizedValues[locale.languageCode]!['detection_results']!;
  String get analyzeAnotherImage => _localizedValues[locale.languageCode]!['analyze_another_image']!;
  String get confidence => _localizedValues[locale.languageCode]!['confidence']!;
  String get recommendation => _localizedValues[locale.languageCode]!['recommendation']!;
  String get camera => _localizedValues[locale.languageCode]!['camera']!;
  String get gallery => _localizedValues[locale.languageCode]!['gallery']!;
  String get detectionHistory => _localizedValues[locale.languageCode]!['detection_history']!;
  String get noDetectionHistory => _localizedValues[locale.languageCode]!['no_detection_history']!;
  String get startDetecting => _localizedValues[locale.languageCode]!['start_detecting']!;
  String get statistics => _localizedValues[locale.languageCode]!['statistics']!;
  String get clearHistory => _localizedValues[locale.languageCode]!['clear_history']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get clear => _localizedValues[locale.languageCode]!['clear']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get light => _localizedValues[locale.languageCode]!['light']!;
  String get dark => _localizedValues[locale.languageCode]!['dark']!;
  String get systemDefault => _localizedValues[locale.languageCode]!['system_default']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get spanish => _localizedValues[locale.languageCode]!['spanish']!;
  String get french => _localizedValues[locale.languageCode]!['french']!;
  String get german => _localizedValues[locale.languageCode]!['german']!;
  String get hindi => _localizedValues[locale.languageCode]!['hindi']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;
  String get chinese => _localizedValues[locale.languageCode]!['chinese']!;
  String get japanese => _localizedValues[locale.languageCode]!['japanese']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get getStarted => _localizedValues[locale.languageCode]!['get_started']!;

  // Helper method to get any localized string
  String getText(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Get language name from code
  static String getLanguageName(String languageCode) {
    const languageNames = {
      'en': 'English',
      'es': 'Español',
      'hi': 'हिंदी',
      'fr': 'Français',
      'de': 'Deutsch',
      'ar': 'العربية',
      'zh': '中文',
      'ja': '日本語',
    };
    return languageNames[languageCode] ?? languageCode;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}