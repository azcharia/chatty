import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/backup_service.dart';
import '../services/database_helper.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/database_stats_widget.dart';
import '../widgets/chat_analytics_widget.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/profile_picture_widget.dart';
import '../config/character_config.dart';
import 'simple_settings_screen.dart';
import 'reminders_screen.dart';
import 'akane_customization_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final filePath = await _backupService.exportData();
      _showSnackBar(
        '✅ Data berhasil di-export ke: ${filePath.split('/').last}',
      );
    } catch (e) {
      _showSnackBar('❌ Gagal export data: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareBackup() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.shareBackup();
      _showSnackBar('✅ Backup file berhasil di-share!');
    } catch (e) {
      _showSnackBar('❌ Gagal share backup: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cleanOldMessages() async {
    final confirmed = await _showConfirmDialog(
      'Bersihkan Pesan Lama',
      'Hapus pesan lama ${CharacterConfig.current.name} dan simpan hanya 1000 pesan terakhir?\n\nTindakan ini tidak bisa dibatalkan.',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _dbHelper.cleanOldMessages(
        keepLast: 1000,
        characterId: CharacterConfig.current.id,
      );
      _showSnackBar('✅ Pesan lama berhasil dibersihkan!');

      // Refresh chat provider
      if (mounted) {
        context.read<ChatProvider>().loadMessages();
      }
    } catch (e) {
      _showSnackBar('❌ Gagal membersihkan pesan: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmDialog(
      'Hapus Semua Data',
      'Hapus SEMUA chat history dan profile?\n\nTindakan ini tidak bisa dibatalkan!\n\nPastikan sudah backup data terlebih dahulu.',
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _dbHelper.clearAllData();
      _showSnackBar('✅ Semua data berhasil dihapus!');

      // Refresh chat provider
      if (mounted) {
        context.read<ChatProvider>().loadMessages();
      }
    } catch (e) {
      _showSnackBar('❌ Gagal menghapus data: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmDialog(
    String title,
    String content, {
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style:
                        isDestructive
                            ? TextButton.styleFrom(foregroundColor: Colors.red)
                            : null,
                    child: Text(isDestructive ? 'Hapus' : 'Ya'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCharacter = CharacterConfig.current;
    final bgColor =
        currentCharacter.name == 'Akane'
            ? Colors.pink.shade100
            : Colors.blue.shade100;

    return Scaffold(
      appBar: AppBar(
        title: Text('⚙️ ${currentCharacter.name} Settings'),
        backgroundColor: bgColor,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    GlassmorphismCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.pink),
                              const SizedBox(width: 8),
                              Text(
                                '👤 Profile',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const ProfilePictureWidget(
                            size: 100,
                            isEditable: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap untuk mengubah foto profil',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Theme Toggle Section
                    GlassmorphismCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.palette, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text(
                                '🎨 Appearance',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return GlassmorphismButton(
                                onPressed: () => themeProvider.toggleTheme(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(themeProvider.themeIcon),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${themeProvider.themeModeString} Mode',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Database Stats Widget (Character-specific)
                    DatabaseStatsWidget(characterId: currentCharacter.id),

                    const SizedBox(height: 16),

                    // Chat Analytics Widget (Character-specific)
                    ChatAnalyticsWidget(characterId: currentCharacter.id),

                    const SizedBox(height: 16),

                    // Character Customization Section
                    _buildSectionCard(
                      title: '🌸 Character Customization',
                      children: [
                        _buildActionTile(
                          icon: Icons.person_outline,
                          title: 'Customize ${currentCharacter.name}',
                          subtitle:
                              'Atur personality, style, dan behavior ${currentCharacter.name}',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const AkaneCustomizationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // API Settings Section
                    _buildSectionCard(
                      title: '🤖 API Settings',
                      children: [
                        _buildActionTile(
                          icon: Icons.api,
                          title: 'Groq API Configuration',
                          subtitle: 'Setup API key untuk Kimi K2 model',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const SimpleSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Reminders Section
                    _buildSectionCard(
                      title: '⏰ Reminders',
                      children: [
                        _buildActionTile(
                          icon: Icons.alarm,
                          title: 'Kelola Reminders',
                          subtitle:
                              'Lihat dan atur reminder ${currentCharacter.name}',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RemindersScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Backup & Restore Section
                    _buildSectionCard(
                      title: '💾 Backup & Restore',
                      children: [
                        _buildActionTile(
                          icon: Icons.download,
                          title: 'Export Data',
                          subtitle: 'Simpan semua chat & profile ke file',
                          onTap: _exportData,
                        ),
                        _buildActionTile(
                          icon: Icons.share,
                          title: 'Share Backup',
                          subtitle: 'Export dan bagikan file backup',
                          onTap: _shareBackup,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Maintenance Section
                    _buildSectionCard(
                      title: '🧹 Maintenance',
                      children: [
                        _buildActionTile(
                          icon: Icons.cleaning_services,
                          title: 'Bersihkan Pesan Lama',
                          subtitle: 'Hapus pesan lama, simpan 1000 terakhir',
                          onTap: _cleanOldMessages,
                        ),
                        _buildActionTile(
                          icon: Icons.delete_forever,
                          title: 'Hapus Semua Data',
                          subtitle: 'Reset aplikasi (backup dulu!)',
                          onTap: _clearAllData,
                          isDestructive: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // App Info
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '🌸 Chatty v2.0.0',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Powered by Groq + Kimi K2',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blue),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
