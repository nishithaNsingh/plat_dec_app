import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../model/disease_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance =>
      _instance ??= FirebaseService._internal();

  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Cloudinary
  // Replace with your Cloudinary credentials
  late final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dlwwwnjno', // Get from Cloudinary dashboard
    'plant_images', // Create an unsigned upload preset
    cache: false,
  );

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Save detection to Firestore (only if authenticated)
  Future<void> saveDetection(DiseaseModel detection) async {
    try {
      if (!isAuthenticated) {
        print('⚠️ User not authenticated, skipping Firestore save');
        return;
      }

      final userId = currentUserId!;

      // Upload image to Cloudinary if exists
      String? imageUrl;
      if (detection.imagePath != null &&
          File(detection.imagePath!).existsSync()) {
        imageUrl = await _uploadImageToCloudinary(detection.imagePath!, userId);
      }

      // Create detection data
      final detectionData = {
        'plant': detection.plant,
        'disease': detection.disease,
        'confidence': detection.confidence,
        'fullPrediction': detection.fullPrediction,
        'timestamp': detection.timestamp.toIso8601String(),
        'detectionSource': detection.detectionSource,
        'imageUrl': imageUrl,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('detections')
          .add(detectionData);

      print('✅ Detection saved to Firebase with Cloudinary image');
    } catch (e) {
      print('❌ Error saving detection to Firebase: $e');
      // Don't rethrow - allow app to continue even if Firebase save fails
    }
  }

  // Upload image to Cloudinary
  Future<String> _uploadImageToCloudinary(
    String imagePath,
    String userId,
  ) async {
    try {
      final File file = File(imagePath);

      // Create a unique identifier for the image
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      print('📤 Uploading image to Cloudinary...');

      // Upload to Cloudinary
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'plant_detection', // Optional: organize in folders
          publicId: fileName, // Optional: custom filename
        ),
      );

      print('✅ Image uploaded to Cloudinary: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('❌ Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }

  // Get detection history from Firestore
  Future<List<DiseaseModel>> getDetectionHistory() async {
    try {
      if (!isAuthenticated) {
        print('⚠️ User not authenticated, returning empty history');
        return [];
      }

      final userId = currentUserId!;

      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('detections')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .get();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;

              // Handle Firestore Timestamp
              if (data['timestamp'] is Timestamp) {
                data['timestamp'] =
                    (data['timestamp'] as Timestamp).toDate().toIso8601String();
              } else if (data['createdAt'] is Timestamp) {
                data['timestamp'] =
                    (data['createdAt'] as Timestamp).toDate().toIso8601String();
              }

              // Ensure detectionSource exists
              data['detectionSource'] =
                  data['detectionSource'] ?? 'PlantVillage API';

              return DiseaseModel.fromJson(data);
            } catch (e) {
              print('❌ Error parsing detection: $e');
              return null;
            }
          })
          .where((detection) => detection != null)
          .cast<DiseaseModel>()
          .toList();
    } catch (e) {
      print('❌ Error getting detection history: $e');
      return [];
    }
  }

  // Clear detection history (also delete images from Cloudinary)
  Future<void> clearHistory() async {
    try {
      if (!isAuthenticated) {
        print('⚠️ User not authenticated, skipping Firestore clear');
        return;
      }

      final userId = currentUserId!;

      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('detections')
              .get();

      final WriteBatch batch = _firestore.batch();

      // Optionally delete images from Cloudinary
      // Note: This requires Cloudinary Admin API which needs backend
      // For now, we'll just delete Firestore records
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ History cleared from Firebase');
    } catch (e) {
      print('❌ Error clearing history: $e');
    }
  }

  // Save app settings (use SharedPreferences)
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', jsonEncode(settings));
      print('✅ Settings saved locally');
    } catch (e) {
      print('❌ Error saving settings: $e');
    }
  }

  // Get app settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString('app_settings');

      if (settingsString != null) {
        return jsonDecode(settingsString);
      }

      // Return default settings
      return {
        'first_launch': true,
        'notifications_enabled': true,
        'save_history': true,
        'theme_mode': 'system',
        'language': 'en',
      };
    } catch (e) {
      print('❌ Error getting settings: $e');
      return {
        'first_launch': true,
        'notifications_enabled': true,
        'save_history': true,
        'theme_mode': 'system',
        'language': 'en',
      };
    }
  }

  // Check if first launch
  Future<bool> isFirstLaunch() async {
    final settings = await getSettings();
    return settings['first_launch'] ?? true;
  }

  // Mark first launch complete
  Future<void> setFirstLaunchComplete() async {
    final settings = await getSettings();
    settings['first_launch'] = false;
    await saveSettings(settings);
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      if (!isAuthenticated) {
        return {
          'total_detections': 0,
          'average_confidence': 0.0,
          'most_common_plant': null,
        };
      }

      final userId = currentUserId!;

      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('detections')
              .get();

      if (snapshot.docs.isEmpty) {
        return {
          'total_detections': 0,
          'average_confidence': 0.0,
          'most_common_plant': null,
        };
      }

      final detections =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data;
          }).toList();

      final totalDetections = detections.length;
      final averageConfidence =
          detections
              .map((d) => (d['confidence'] ?? 0.0) as double)
              .reduce((a, b) => a + b) /
          totalDetections;

      // Find most common plant
      final plantCounts = <String, int>{};
      for (final detection in detections) {
        final plant = detection['plant'] as String? ?? 'Unknown';
        plantCounts[plant] = (plantCounts[plant] ?? 0) + 1;
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
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'total_detections': 0,
        'average_confidence': 0.0,
        'most_common_plant': null,
      };
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }
}
