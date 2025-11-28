import 'dart:io';
import 'package:flutter/material.dart';

import '../model/disease_model.dart';

class DetectionDetailScreen extends StatelessWidget {
  final DiseaseModel detection;

  const DetectionDetailScreen({
    super.key,
    required this.detection,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(detection.confidence);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              severityColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Hero App Bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: severityColor,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: severityColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Hero(
                      tag: 'detection_${detection.timestamp}',
                      child: detection.imagePath != null &&
                          File(detection.imagePath!).existsSync()
                          ? Image.file(
                        File(detection.imagePath!),
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Title Overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${detection.confidence.toStringAsFixed(1)}% Confident',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detection.plant,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Disease Card
                  _buildDiseaseCard(severityColor),
                  const SizedBox(height: 20),

                  // Statistics Row
                  _buildStatisticsRow(severityColor),
                  const SizedBox(height: 20),

                  // Description Card
                  _buildDescriptionCard(),
                  const SizedBox(height: 20),

                  // Treatment Card
                  _buildTreatmentCard(),
                  const SizedBox(height: 20),

                  // Metadata Card
                  _buildMetadataCard(),
                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(Color severityColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            severityColor.withOpacity(0.2),
            severityColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.bug_report, color: severityColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected Disease',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detection.disease.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(Color severityColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Confidence',
            '${detection.confidence.toStringAsFixed(1)}%',
            Icons.analytics,
            severityColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Accuracy',
            _getAccuracyLevel(detection.confidence),
            Icons.verified,
            severityColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Status',
            _getStatusText(detection.disease),
            Icons.info_outline,
            severityColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'About This Disease',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Text(
              _getDiseaseDescription(detection.disease),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[900],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Treatment Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              detection.recommendation,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consult a plant specialist for severe cases',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detection Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildMetadataRow(Icons.calendar_today, 'Date', _formatDateTime(detection.timestamp)),
          const SizedBox(height: 12),
          _buildMetadataRow(Icons.access_time, 'Time', _formatTime(detection.timestamp)),
          const SizedBox(height: 12),
          _buildMetadataRow(Icons.category, 'Classification', detection.fullPrediction),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Results'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              foregroundColor: const Color(0xFF2E7D32),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(double confidence) {
    if (confidence >= 90) return const Color(0xFF4CAF50);
    if (confidence >= 70) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getAccuracyLevel(double confidence) {
    if (confidence >= 90) return 'Very High';
    if (confidence >= 75) return 'High';
    if (confidence >= 60) return 'Medium';
    return 'Low';
  }

  String _getStatusText(String disease) {
    if (disease.toLowerCase().contains('healthy')) return 'Healthy';
    return 'Diseased';
  }

  String _getDiseaseDescription(String disease) {
    final lowerDisease = disease.toLowerCase();

    if (lowerDisease.contains('healthy')) {
      return 'Your plant appears to be in good health! Continue with regular care including proper watering, adequate sunlight, and periodic fertilization to maintain its health.';
    }
    if (lowerDisease.contains('bacterial_spot') || lowerDisease.contains('bacterial spot')) {
      return 'Bacterial spot is a common disease that causes dark, water-soaked spots on leaves and fruits. It spreads rapidly in warm, humid conditions and can significantly reduce plant yield if not treated promptly.';
    }
    if (lowerDisease.contains('early_blight') || lowerDisease.contains('early blight')) {
      return 'Early blight is a fungal disease characterized by dark brown spots with concentric rings on older leaves. It can cause severe defoliation and reduced yield if left untreated.';
    }
    if (lowerDisease.contains('late_blight') || lowerDisease.contains('late blight')) {
      return 'Late blight is a devastating disease caused by water mold. It appears as dark, water-soaked lesions on leaves and stems. This disease can destroy entire crops quickly in cool, wet conditions.';
    }
    if (lowerDisease.contains('leaf_curl') || lowerDisease.contains('virus')) {
      return 'Viral diseases cause leaf curling, yellowing, and stunted growth. These diseases are typically spread by insects like aphids and whiteflies. Prevention through pest control is crucial.';
    }
    if (lowerDisease.contains('powdery_mildew') || lowerDisease.contains('powdery mildew')) {
      return 'Powdery mildew appears as white, powdery spots on leaves and stems. This fungal disease thrives in warm days and cool nights with high humidity.';
    }
    if (lowerDisease.contains('rust')) {
      return 'Rust diseases cause orange, brown, or yellow pustules on leaves. These fungal infections can weaken plants and reduce photosynthesis, affecting overall plant health and yield.';
    }

    return 'This plant disease requires attention and proper treatment. Monitor your plant closely and take appropriate action to prevent spread to other plants.';
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}