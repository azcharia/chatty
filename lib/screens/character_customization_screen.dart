import 'package:flutter/material.dart';
import '../config/character_config.dart';

class CharacterCustomizationScreen extends StatelessWidget {
  const CharacterCustomizationScreen({super.key});

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
      body: SingleChildScrollView(
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
                    Text(
                      '${currentCharacter.avatar} ${currentCharacter.name}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Character Customization Screen',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
}
