import 'package:flutter/material.dart';
import '../services/akane_preferences_service.dart';
import '../services/ayasha_preferences_service.dart';
import '../models/akane_preferences.dart';
import '../config/character_config.dart';

class AkaneCustomizationScreen extends StatefulWidget {
  const AkaneCustomizationScreen({super.key});

  @override
  State<AkaneCustomizationScreen> createState() =>
      _AkaneCustomizationScreenState();
}

class _AkaneCustomizationScreenState extends State<AkaneCustomizationScreen> {
  final AkanePreferencesService _akanePrefsService = AkanePreferencesService();
  final AyashaPreferencesService _ayashaPrefsService =
      AyashaPreferencesService();
  late AkanePreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentCharacter = CharacterConfig.current;
    if (currentCharacter.name == 'Akane') {
      _preferences = _akanePrefsService.preferences;
    } else {
      _preferences = _ayashaPrefsService.preferences;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCharacter = CharacterConfig.current;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${currentCharacter.avatar} ${currentCharacter.name} Customization',
        ),
        backgroundColor:
            currentCharacter.name == 'Akane'
                ? Colors.pink.shade100
                : Colors.blue.shade100,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Character Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentCharacter.avatar,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentCharacter.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Age: ${_preferences.age} • ${_preferences.tone} tone',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Personality: ${_preferences.personalityTraits}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Languages: ${_preferences.languages.join(', ')}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Preferences Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Preferences',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Response Style',
                              _preferences.responseStyle,
                            ),
                            _buildInfoRow(
                              'Punctuation',
                              _preferences.punctuation,
                            ),
                            _buildInfoRow(
                              'Multiple Messages',
                              _preferences.allowSendingMultipleMessages
                                  ? 'Yes'
                                  : 'No',
                            ),
                            _buildInfoRow(
                              'Roleplay Actions',
                              _preferences.allowRoleplayActions ? 'Yes' : 'No',
                            ),
                            _buildInfoRow(
                              'Self Reference',
                              _preferences.allowSelfReference ? 'Yes' : 'No',
                            ),
                            _buildInfoRow(
                              'Use Pronouns',
                              _preferences.allowPronouns ? 'Yes' : 'No',
                            ),
                            _buildInfoRow(
                              'Short Term Memory',
                              '${_preferences.shortTermMemory} messages',
                            ),
                            _buildInfoRow(
                              'Long Term Memory',
                              '${_preferences.longTermMemory} messages',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Likes & Dislikes
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Likes & Dislikes',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Likes: ${_preferences.likes.join(', ')}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dislikes: ${_preferences.dislikes.join(', ')}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Character Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Preferences untuk ${currentCharacter.name} sudah dioptimalkan. '
                            'Setiap character memiliki personality dan style yang berbeda. '
                            'Chat history juga terpisah untuk setiap character.',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
