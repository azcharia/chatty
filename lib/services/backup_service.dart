import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Export semua data ke file JSON
  Future<String> exportData() async {
    try {
      // Ambil semua data
      final profile = await _dbHelper.getUserProfile();

      // Export messages untuk kedua karakter secara terpisah
      final akaneMessages = await _dbHelper.getMessages(limit: -1, characterId: 'akane');
      final ayashaMessages = await _dbHelper.getMessages(limit: -1, characterId: 'ayasha');

      // Buat struktur data export v2.0
      final exportData = {
        'version': '2.0',
        'exportDate': DateTime.now().toIso8601String(),
        'profile': profile?.toJson(),
        'messages': {
          'akane': akaneMessages.map((m) => m.toJson()).toList(),
          'ayasha': ayashaMessages.map((m) => m.toJson()).toList(),
        },
        'messageCount': akaneMessages.length + ayashaMessages.length,
      };

      // Convert ke JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Simpan ke file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'chatty_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Gagal export data: $e');
    }
  }

  /// Import data dari file JSON dengan backward-compatibility v1.0
  Future<bool> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan');
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validasi format
      if (data['version'] == null) {
        throw Exception('Format file tidak valid');
      }

      // Clear existing data sebelum mengimpor data baru
      await _dbHelper.clearAllData();

      // Import profile
      if (data['profile'] != null) {
        final profile = UserProfile.fromJson(data['profile']);
        await _dbHelper.saveUserProfile(profile);
      }

      // Periksa versi format backup
      final version = data['version'] ?? '1.0';
      if (version == '1.0') {
        // Legacy backup format: messages berbentuk List tunggal
        if (data['messages'] != null && data['messages'] is List) {
          final messagesList = data['messages'] as List;
          for (final messageData in messagesList) {
            final message = Message.fromJson(messageData);
            // Pada v1.0, semua pesan ditujukan untuk karakter Akane
            await _dbHelper.insertMessage(message, characterId: 'akane');
          }
        }
      } else {
        // v2.0 backup format: messages berbentuk Map of characterId -> messages list
        if (data['messages'] != null && data['messages'] is Map) {
          final messagesMap = data['messages'] as Map<String, dynamic>;
          for (final characterId in messagesMap.keys) {
            final messagesList = messagesMap[characterId] as List;
            for (final messageData in messagesList) {
              final message = Message.fromJson(messageData);
              await _dbHelper.insertMessage(message, characterId: characterId);
            }
          }
        }
      }

      return true;
    } catch (e) {
      throw Exception('Gagal import data: $e');
    }
  }

  /// Share backup file
  Future<void> shareBackup() async {
    try {
      final filePath = await exportData();
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Backup data Chatty - ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      throw Exception('Gagal share backup: $e');
    }
  }

  /// Get backup info
  Future<Map<String, dynamic>> getBackupInfo() async {
    try {
      final profile = await _dbHelper.getUserProfile();
      final akaneCount = await _dbHelper.getMessageCount(characterId: 'akane');
      final ayashaCount = await _dbHelper.getMessageCount(characterId: 'ayasha');

      return {
        'hasProfile': profile != null,
        'profileName': profile?.name ?? 'Tidak ada',
        'messageCount': akaneCount + ayashaCount,
        'lastBackup': null,
      };
    } catch (e) {
      return {
        'hasProfile': false,
        'profileName': 'Error',
        'messageCount': 0,
        'lastBackup': null,
      };
    }
  }
}
