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
      final messages = await _dbHelper.getMessages(limit: -1); // Ambil semua

      // Buat struktur data export
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'profile': profile?.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'messageCount': messages.length,
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

  /// Import data dari file JSON
  Future<bool> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan');
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validasi format
      if (data['version'] == null || data['messages'] == null) {
        throw Exception('Format file tidak valid');
      }

      // Clear existing data (optional - bisa ditambah konfirmasi)
      await _dbHelper.clearAllData();

      // Import profile
      if (data['profile'] != null) {
        final profile = UserProfile.fromJson(data['profile']);
        await _dbHelper.saveUserProfile(profile);
      }

      // Import messages
      final messagesList = data['messages'] as List;
      for (final messageData in messagesList) {
        final message = Message.fromJson(messageData);
        await _dbHelper.insertMessage(message);
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
      final messageCount = await _dbHelper.getMessageCount();

      return {
        'hasProfile': profile != null,
        'profileName': profile?.name ?? 'Tidak ada',
        'messageCount': messageCount,
        'lastBackup': null, // Bisa ditambah tracking
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
