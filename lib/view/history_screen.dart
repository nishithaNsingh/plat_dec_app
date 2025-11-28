import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/unified_detection.dart';
import '../services/app_loc.dart';
import '../widget/custom_button.dart';
import 'detectio_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          localizations.detectionHistory,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<UnifiedDetectionController>(
            builder: (context, controller, child) {
              if (controller.detectionHistory.isEmpty) return Container();

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearHistoryDialog(context, controller, localizations);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(localizations.clearHistory),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.white),
              );
            },
          ),
        ],
      ),
      body: Consumer<UnifiedDetectionController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return LoadingWidget(message: localizations.getText('loading_history'));
          }

          if (controller.detectionHistory.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history,
              title: localizations.noDetectionHistory,
              description: localizations.getText('history_description'),
              action: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to detection screen (first tab)
                  DefaultTabController.of(context)?.animateTo(0);
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(localizations.startDetecting),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              // Statistics Card
              Container(
                margin: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: Colors.blue[600],
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              localizations.statistics,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatisticsRow(controller, localizations),
                      ],
                    ),
                  ),
                ),
              ),

              // History List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.detectionHistory.length,
                  itemBuilder: (context, index) {
                    final detection = controller.detectionHistory[index];
                    return HistoryItemCard(
                      detection: detection,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetectionDetailScreen(
                              detection: detection,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsRow(UnifiedDetectionController controller, AppLocalizations localizations) {
    final stats = controller.getStatistics();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          localizations.getText('total'),
          '${stats['total_detections']}',
          Icons.camera_alt,
          Colors.blue,
        ),
        _buildStatItem(
          localizations.getText('avg_confidence'),
          '${stats['average_confidence'].toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.green,
        ),
        _buildStatItem(
          localizations.getText('most_common'),
          _truncateText(stats['most_common_plant'] ?? localizations.getText('none'), 8),
          Icons.eco,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void _showClearHistoryDialog(BuildContext context, UnifiedDetectionController controller, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.clearHistory),
        content: Text(localizations.getText('clear_history_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.getText('history_cleared')),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.clear),
          ),
        ],
      ),
    );
  }
}