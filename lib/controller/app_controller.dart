import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class AppController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  // State variables
  bool _isInitialized = false;
  bool _isFirstLaunch = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _saveHistory = true;
  String _languageCode = 'en';
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isFirstLaunch => _isFirstLaunch;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get saveHistory => _saveHistory;
  String get languageCode => _languageCode;
  Locale get currentLocale => Locale(_languageCode);
  String? get errorMessage => _errorMessage;

  // Initialize app
  Future<void> initializeApp() async {
    try {
      // Load settings from Firebase
      final settings = await _firebaseService.getSettings();

      _isFirstLaunch = settings['first_launch'] ?? true;
      _notificationsEnabled = settings['notifications_enabled'] ?? true;
      _saveHistory = settings['save_history'] ?? true;
      _languageCode = settings['language'] ?? 'en';

      // Parse theme mode
      String themeModeString = settings['theme_mode'] ?? 'system';
      _themeMode = _parseThemeMode(themeModeString);

      _isInitialized = true;
      _clearError();

      print('✅ App initialized successfully');
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize app: $e');
      print('❌ App initialization failed: $e');
    }
  }

  // Complete first launch
  Future<void> completeFirstLaunch() async {
    try {
      await _firebaseService.setFirstLaunchComplete();
      _isFirstLaunch = false;
      await _saveCurrentSettings();
      notifyListeners();
    } catch (e) {
      _setError('Error completing first launch: $e');
    }
  }

  // Update theme mode
  Future<void> updateThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      await _saveCurrentSettings();
      notifyListeners();
    } catch (e) {
      _setError('Error updating theme: $e');
    }
  }

  // Update language
  Future<void> updateLanguage(String languageCode) async {
    try {
      _languageCode = languageCode;
      await _saveCurrentSettings();
      notifyListeners();
    } catch (e) {
      _setError('Error updating language: $e');
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      await _saveCurrentSettings();
      notifyListeners();
    } catch (e) {
      _setError('Error updating notifications setting: $e');
    }
  }

  // Toggle save history
  Future<void> toggleSaveHistory(bool enabled) async {
    try {
      _saveHistory = enabled;
      await _saveCurrentSettings();
      notifyListeners();
    } catch (e) {
      _setError('Error updating save history setting: $e');
    }
  }

  // Get app info
  Map<String, String> getAppInfo() {
    return {
      'version': '1.0.0',
      'build': '1',
      'developer': 'Plant Disease Detection Team',
      'email': 'support@plantdisease.com',
      'website': 'https://plantdisease.com',
    };
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> _saveCurrentSettings() async {
    final settings = {
      'first_launch': _isFirstLaunch,
      'notifications_enabled': _notificationsEnabled,
      'save_history': _saveHistory,
      'theme_mode': _themeModeToString(_themeMode),
      'language': _languageCode,
    };

    await _firebaseService.saveSettings(settings);
  }
}