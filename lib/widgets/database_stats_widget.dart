import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../config/character_config.dart';

class DatabaseStatsWidget extends StatefulWidget {
  final String? characterId;

  const DatabaseStatsWidget({super.key, this.characterId});

  @override
  State<DatabaseStatsWidget> createState() => _DatabaseStatsWidgetState();
}

class _DatabaseStatsWidgetState extends State<DatabaseStatsWidget> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  int _messageCount = 0;
  int _databaseSize = 0;
  bool _hasProfile = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final messageCount = await _dbHelper.getMessageCount(
        characterId: widget.characterId ?? CharacterConfig.current.id,
      );
      final databaseSize = await _dbHelper.getDatabaseSize();
      final profile = await _dbHelper.getUserProfile();

      setState(() {
        _messageCount = messageCount;
        _databaseSize = databaseSize;
        _hasProfile = profile != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Database Stats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadStats,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.message,
                    label: 'Messages',
                    value: _messageCount.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.storage,
                    label: 'Size',
                    value: _formatSize(_databaseSize),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.person,
                    label: 'Profile',
                    value: _hasProfile ? 'Yes' : 'No',
                    color: _hasProfile ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Memory Usage Indicator
            _buildMemoryIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryIndicator() {
    // Estimate memory usage (rough calculation)
    final estimatedMaxSize = 50 * 1024 * 1024; // 50MB as "full"
    final percentage = (_databaseSize / estimatedMaxSize).clamp(0.0, 1.0);

    Color indicatorColor;
    String status;

    if (percentage < 0.3) {
      indicatorColor = Colors.green;
      status = 'Low';
    } else if (percentage < 0.7) {
      indicatorColor = Colors.orange;
      status = 'Medium';
    } else {
      indicatorColor = Colors.red;
      status = 'High';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Memory Usage: $status',
              style: TextStyle(
                fontSize: 12,
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: indicatorColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        ),
      ],
    );
  }
}
