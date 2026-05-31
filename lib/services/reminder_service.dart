import 'dart:developer' as developer;
import '../models/reminder.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  /// Initialize reminder service
  Future<void> initialize() async {
    await _notificationService.initialize();
    await _createReminderTable();
  }

  /// Create reminder table
  Future<void> _createReminderTable() async {
    final db = await _dbHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL DEFAULT 'general',
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');
  }

  /// Create a new reminder
  Future<Reminder> createReminder({
    required String title,
    required String description,
    required DateTime dateTime,
    String category = 'general',
  }) async {
    final db = await _dbHelper.database;

    final reminder = Reminder(
      title: title,
      description: description,
      dateTime: dateTime,
      category: category,
      createdAt: DateTime.now(),
    );

    final id = await db.insert('reminders', {
      'title': reminder.title,
      'description': reminder.description,
      'dateTime': reminder.dateTime.toIso8601String(),
      'isCompleted': reminder.isCompleted ? 1 : 0,
      'category': reminder.category,
      'createdAt': reminder.createdAt.toIso8601String(),
    });

    final createdReminder = reminder.copyWith(id: id);

    // Schedule notification
    await _scheduleNotification(createdReminder);

    return createdReminder;
  }

  /// Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      orderBy: 'dateTime ASC',
    );

    return List.generate(maps.length, (i) {
      return Reminder(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        isCompleted: maps[i]['isCompleted'] == 1,
        category: maps[i]['category'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        completedAt:
            maps[i]['completedAt'] != null
                ? DateTime.parse(maps[i]['completedAt'])
                : null,
      );
    });
  }

  /// Get upcoming reminders (next 7 days)
  Future<List<Reminder>> getUpcomingReminders() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'dateTime >= ? AND dateTime <= ? AND isCompleted = 0',
      whereArgs: [now.toIso8601String(), nextWeek.toIso8601String()],
      orderBy: 'dateTime ASC',
    );

    return List.generate(maps.length, (i) {
      return Reminder(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        isCompleted: maps[i]['isCompleted'] == 1,
        category: maps[i]['category'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        completedAt:
            maps[i]['completedAt'] != null
                ? DateTime.parse(maps[i]['completedAt'])
                : null,
      );
    });
  }

  /// Mark reminder as completed
  Future<void> completeReminder(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'reminders',
      {'isCompleted': 1, 'completedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Cancel notification
    await _notificationService.cancelNotification(id);
  }

  /// Delete reminder
  Future<void> deleteReminder(int id) async {
    final db = await _dbHelper.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);

    // Cancel notification
    await _notificationService.cancelNotification(id);
  }

  /// Update reminder
  Future<void> updateReminder(Reminder reminder) async {
    final db = await _dbHelper.database;
    await db.update(
      'reminders',
      {
        'title': reminder.title,
        'description': reminder.description,
        'dateTime': reminder.dateTime.toIso8601String(),
        'category': reminder.category,
      },
      where: 'id = ?',
      whereArgs: [reminder.id],
    );

    // Reschedule notification
    await _scheduleNotification(reminder);
  }

  /// Schedule notification for reminder
  Future<void> _scheduleNotification(Reminder reminder) async {
    if (reminder.id == null) return;

    print(
      '🔔 Scheduling notification for: ${reminder.title} at ${reminder.dateTime}',
    );

    try {
      await _notificationService.scheduleNotification(
        id: reminder.id!,
        title: '🔔 ${reminder.title}',
        body: reminder.description,
        scheduledDate: reminder.dateTime,
        payload: 'reminder_${reminder.id}',
      );
      print('✅ Notification scheduled successfully');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
    }
  }

  /// Parse reminder from natural language (for Akane integration)
  Future<Reminder?> parseReminderFromText(String text) async {
    print('🤖 Parsing reminder from text: $text');

    final lowerText = text.toLowerCase();
    DateTime? reminderTime;
    String cleanTitle = '';
    String category = 'general';
    final now = DateTime.now();

    // 1. Detect relative time patterns: "menit"
    if (lowerText.contains('menit')) {
      final minuteRegex = RegExp(r'(\d+)\s*menit');
      final match = minuteRegex.firstMatch(lowerText);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        reminderTime = now.add(Duration(minutes: minutes));
      }
    }
    // "setengah jam" -> 30 minutes
    else if (lowerText.contains('setengah jam')) {
      reminderTime = now.add(const Duration(minutes: 30));
    }
    // "jam lagi" / "jam dari sekarang" -> relative hours
    else if (RegExp(r'(\d+)\s*jam lagi').hasMatch(lowerText)) {
      final hourRegex = RegExp(r'(\d+)\s*jam lagi');
      final match = hourRegex.firstMatch(lowerText);
      if (match != null) {
        final hours = int.parse(match.group(1)!);
        reminderTime = now.add(Duration(hours: hours));
      }
    }
    // "hari lagi" -> relative days
    else if (RegExp(r'(\d+)\s*hari lagi').hasMatch(lowerText)) {
      final dayRegex = RegExp(r'(\d+)\s*hari lagi');
      final match = dayRegex.firstMatch(lowerText);
      if (match != null) {
        final days = int.parse(match.group(1)!);
        reminderTime = DateTime(now.year, now.month, now.day + days, 9, 0); // Default to 9 AM
      }
    }
    // "besok" -> tomorrow
    else if (lowerText.contains('besok')) {
      int hour = 9; // Default 9 AM
      int minute = 0;

      if (lowerText.contains('pagi')) {
        hour = 8;
      } else if (lowerText.contains('siang')) {
        hour = 12;
      } else if (lowerText.contains('sore')) {
        hour = 16;
      } else if (lowerText.contains('malam')) {
        hour = 19;
      }

      // Check if user specifies an exact time like "besok jam 14:00" or "besok jam 2 sore"
      final jamMatch = RegExp(r'jam\s*(\d{1,2})[:.]?(\d{0,2})').firstMatch(lowerText);
      if (jamMatch != null) {
        hour = int.parse(jamMatch.group(1)!);
        minute = jamMatch.group(2)?.isNotEmpty == true ? int.parse(jamMatch.group(2)!) : 0;

        // Convert to 24h format based on sore/malam/siang context
        if (hour < 12) {
          if (lowerText.contains('siang') && hour <= 4) {
            hour += 12;
          } else if (lowerText.contains('sore') && hour <= 6) {
            hour += 12;
          } else if (lowerText.contains('malam') && hour <= 11) {
            hour += 12;
          }
        }
      }

      reminderTime = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    // "lusa" -> day after tomorrow
    else if (lowerText.contains('lusa')) {
      reminderTime = DateTime(now.year, now.month, now.day + 2, 9, 0);
    }
    // "nanti sore"
    else if (lowerText.contains('nanti sore')) {
      reminderTime = DateTime(now.year, now.month, now.day, 17, 0);
    }
    // "nanti malam"
    else if (lowerText.contains('nanti malam')) {
      reminderTime = DateTime(now.year, now.month, now.day, 20, 0);
    }
    // "nanti siang"
    else if (lowerText.contains('nanti siang')) {
      reminderTime = DateTime(now.year, now.month, now.day, 13, 0);
    }
    // Absolute time matching "jam 15:30" or "jam 2 sore"
    else if (lowerText.contains('jam')) {
      final timeRegex = RegExp(r'jam\s*(\d{1,2})[:.]?(\d{0,2})');
      final match = timeRegex.firstMatch(lowerText);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final minute = match.group(2)?.isNotEmpty == true ? int.parse(match.group(2)!) : 0;

        // Adjust for afternoon/evening
        if (hour < 12) {
          if (lowerText.contains('siang') && hour <= 4) {
            hour += 12;
          } else if (lowerText.contains('sore') && hour <= 6) {
            hour += 12;
          } else if (lowerText.contains('malam') && hour <= 11) {
            hour += 12;
          }
        }

        reminderTime = DateTime(now.year, now.month, now.day, hour, minute);

        // If the parsed time has already passed today, assume it's for tomorrow
        if (reminderTime.isBefore(now)) {
          reminderTime = reminderTime.add(const Duration(days: 1));
        }
      }
    }

    // 2. Extract a clean, meaningful title
    // Strip out prompt helper phrases and time triggers
    cleanTitle = text;

    // Commands to remove
    final removePatterns = [
      RegExp(r'ingatkan\s+aku\s+untuk\s+', caseSensitive: false),
      RegExp(r'ingatkan\s+aku\s+buat\s+', caseSensitive: false),
      RegExp(r'ingatkan\s+aku\s+', caseSensitive: false),
      RegExp(r'tolong\s+ingatkan\s+', caseSensitive: false),
      RegExp(r'tolong\s+ingatin\s+', caseSensitive: false),
      RegExp(r'ingatin\s+aku\s+', caseSensitive: false),
      RegExp(r'ingatin\s+', caseSensitive: false),
      RegExp(r'jangan\s+lupa\s+untuk\s+', caseSensitive: false),
      RegExp(r'jangan\s+lupa\s+', caseSensitive: false),
      RegExp(r'set\s+alarm\s+untuk\s+', caseSensitive: false),
      RegExp(r'set\s+alarm\s+', caseSensitive: false),
      RegExp(r'remind\s+me\s+to\s+', caseSensitive: false),
      RegExp(r'remind\s+me\s+', caseSensitive: false),
    ];

    for (final pattern in removePatterns) {
      cleanTitle = cleanTitle.replaceFirst(pattern, '');
    }

    // Time descriptions to remove from title
    final timePatterns = [
      RegExp(r'\b\d+\s*menit\s*(lagi)?\b', caseSensitive: false),
      RegExp(r'\b\d+\s*jam\s*lagi\b', caseSensitive: false),
      RegExp(r'\b\d+\s*hari\s*lagi\b', caseSensitive: false),
      RegExp(r'\bsetengah\s*jam\s*(lagi)?\b', caseSensitive: false),
      RegExp(r'\bbesok\s*(pagi|siang|sore|malam)?\b', caseSensitive: false),
      RegExp(r'\blusa\s*(pagi|siang|sore|malam)?\b', caseSensitive: false),
      RegExp(r'\bnanti\s*(siang|sore|malam)\b', caseSensitive: false),
      RegExp(r'\bjam\s*\d{1,2}([:.]\d{2})?\s*(pagi|siang|sore|malam)?\b', caseSensitive: false),
      RegExp(r'\b(pagi|siang|sore|malam)\b', caseSensitive: false),
    ];

    for (final pattern in timePatterns) {
      cleanTitle = cleanTitle.replaceAll(pattern, '');
    }

    // Clean up trailing/leading whitespace and punctuation
    cleanTitle = cleanTitle.replaceAll(RegExp(r'^[,\s\-]+|[,\s\-]+$'), '').trim();

    // Capitalize first letter
    if (cleanTitle.isNotEmpty) {
      cleanTitle = cleanTitle[0].toUpperCase() + cleanTitle.substring(1);
    } else {
      cleanTitle = 'Reminder'; // Fallback
    }

    // 3. Category detection
    if (lowerText.contains('telepon') || lowerText.contains('call') || lowerText.contains('hubungi')) {
      category = 'call';
    } else if (lowerText.contains('meeting') || lowerText.contains('rapat') || lowerText.contains('kelas') || lowerText.contains('kuliah')) {
      category = 'meeting';
    } else if (lowerText.contains('belanja') || lowerText.contains('beli') || lowerText.contains('shopping')) {
      category = 'shopping';
    } else if (lowerText.contains('kerja') || lowerText.contains('work') || lowerText.contains('tugas') || lowerText.contains('belajar')) {
      category = 'work';
    } else if (lowerText.contains('minum') || lowerText.contains('obat') || lowerText.contains('makan')) {
      category = 'health';
    }

    if (reminderTime != null) {
      print('✅ Creating reminder: $cleanTitle at $reminderTime (Category: $category)');
      final reminder = await createReminder(
        title: cleanTitle,
        description: 'Reminder: $cleanTitle',
        dateTime: reminderTime,
        category: category,
      );
      print('🎯 Reminder created with ID: ${reminder.id}');
      return reminder;
    }

    print('❌ Could not parse reminder from text');
    return null;
  }

  /// Get reminder statistics
  Future<Map<String, int>> getReminderStats() async {
    final db = await _dbHelper.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reminders',
    );
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reminders WHERE isCompleted = 1',
    );
    final upcomingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reminders WHERE dateTime > ? AND isCompleted = 0',
      [DateTime.now().toIso8601String()],
    );

    return {
      'total': totalResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'upcoming': upcomingResult.first['count'] as int,
    };
  }
}
