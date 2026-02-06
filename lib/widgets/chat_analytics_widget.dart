import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/message.dart';
import '../config/character_config.dart';

class ChatAnalyticsWidget extends StatefulWidget {
  final String? characterId;

  const ChatAnalyticsWidget({super.key, this.characterId});

  @override
  State<ChatAnalyticsWidget> createState() => _ChatAnalyticsWidgetState();
}

class _ChatAnalyticsWidgetState extends State<ChatAnalyticsWidget> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final messages = await _dbHelper.getMessages(
        limit: -1,
        characterId: widget.characterId ?? CharacterConfig.current.id,
      );
      final analytics = _calculateAnalytics(messages);

      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _calculateAnalytics(List<Message> messages) {
    if (messages.isEmpty) {
      return {
        'totalMessages': 0,
        'userMessages': 0,
        'aiMessages': 0,
        'averageWordsPerMessage': 0.0,
        'longestMessage': 0,
        'firstMessageDate': null,
        'lastMessageDate': null,
        'messagesPerDay': 0.0,
        'mostActiveHour': 0,
        'totalWords': 0,
      };
    }

    final userMessages = messages.where((m) => m.isUser).toList();
    final aiMessages = messages.where((m) => !m.isUser).toList();

    // Calculate word counts
    int totalWords = 0;
    int longestMessage = 0;
    final hourCounts = List.filled(24, 0);

    for (final message in messages) {
      final words = message.content.split(' ').length;
      totalWords += words;
      if (words > longestMessage) longestMessage = words;

      // Count messages per hour
      hourCounts[message.timestamp.hour]++;
    }

    // Find most active hour
    int mostActiveHour = 0;
    int maxCount = hourCounts[0];
    for (int i = 1; i < 24; i++) {
      if (hourCounts[i] > maxCount) {
        maxCount = hourCounts[i];
        mostActiveHour = i;
      }
    }

    // Calculate messages per day
    final firstMessage = messages.first.timestamp;
    final lastMessage = messages.last.timestamp;
    final daysDiff = lastMessage.difference(firstMessage).inDays + 1;
    final messagesPerDay = messages.length / daysDiff;

    return {
      'totalMessages': messages.length,
      'userMessages': userMessages.length,
      'aiMessages': aiMessages.length,
      'averageWordsPerMessage': totalWords / messages.length,
      'longestMessage': longestMessage,
      'firstMessageDate': firstMessage,
      'lastMessageDate': lastMessage,
      'messagesPerDay': messagesPerDay,
      'mostActiveHour': mostActiveHour,
      'totalWords': totalWords,
      'daysDiff': daysDiff,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
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

    if (_analytics == null || _analytics!['totalMessages'] == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada data chat',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const Text(
                'Mulai chat untuk melihat analytics!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
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
                const Icon(Icons.analytics, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Chat Analytics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadAnalytics,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Chat',
                    '${_analytics!['totalMessages']}',
                    Icons.chat,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Hari Aktif',
                    '${_analytics!['daysDiff']}',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Per Hari',
                    '${_analytics!['messagesPerDay'].toStringAsFixed(1)}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Detailed Stats
            _buildDetailRow('💬 Pesan Kamu', '${_analytics!['userMessages']}'),
            _buildDetailRow('🤖 Pesan AI', '${_analytics!['aiMessages']}'),
            _buildDetailRow('📝 Total Kata', '${_analytics!['totalWords']}'),
            _buildDetailRow(
              '📊 Rata-rata Kata/Pesan',
              '${_analytics!['averageWordsPerMessage'].toStringAsFixed(1)}',
            ),
            _buildDetailRow(
              '📏 Pesan Terpanjang',
              '${_analytics!['longestMessage']} kata',
            ),
            _buildDetailRow(
              '🕐 Jam Paling Aktif',
              _formatHour(_analytics!['mostActiveHour']),
            ),

            const SizedBox(height: 12),

            // Timeline
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📅 Timeline',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Mulai: '),
                      Text(
                        _formatDate(_analytics!['firstMessageDate']),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Terakhir: '),
                      Text(
                        _formatDate(_analytics!['lastMessageDate']),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
