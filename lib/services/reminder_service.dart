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

    // Simple parsing logic - bisa diperbaiki dengan NLP yang lebih advanced
    final lowerText = text.toLowerCase();

    // Extract time patterns
    DateTime? reminderTime;
    String title = '';
    String category = 'general';

    // Time patterns
    final now = DateTime.now();

    if (lowerText.contains('menit')) {
      // Extract minutes like "1 menit", "5 menit", "10 menit"
      final minuteRegex = RegExp(r'(\d+)\s*menit');
      final match = minuteRegex.firstMatch(lowerText);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        reminderTime = now.add(Duration(minutes: minutes));
        title = text.replaceAll(minuteRegex, '').trim();
        print(
          '⏰ Setting reminder for $minutes minutes from now: $reminderTime',
        );
      }
    } else if (lowerText.contains('besok')) {
      reminderTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
      title =
          text
              .replaceAll(RegExp(r'besok|tomorrow', caseSensitive: false), '')
              .trim();
    } else if (lowerText.contains('nanti sore')) {
      reminderTime = DateTime(now.year, now.month, now.day, 17, 0);
      title =
          text
              .replaceAll(RegExp(r'nanti sore', caseSensitive: false), '')
              .trim();
    } else if (lowerText.contains('nanti malam')) {
      reminderTime = DateTime(now.year, now.month, now.day, 20, 0);
      title =
          text
              .replaceAll(RegExp(r'nanti malam', caseSensitive: false), '')
              .trim();
    } else if (lowerText.contains('jam')) {
      // Extract time like "jam 14:30" or "jam 2 sore"
      final timeRegex = RegExp(r'jam (\d{1,2}):?(\d{0,2})');
      final match = timeRegex.firstMatch(lowerText);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute =
            match.group(2)?.isNotEmpty == true ? int.parse(match.group(2)!) : 0;
        reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
        title = text.replaceAll(timeRegex, '').trim();
      }
    }

    // Category detection
    if (lowerText.contains('telepon') || lowerText.contains('call')) {
      category = 'call';
    } else if (lowerText.contains('meeting') || lowerText.contains('rapat')) {
      category = 'meeting';
    } else if (lowerText.contains('belanja') || lowerText.contains('beli')) {
      category = 'shopping';
    } else if (lowerText.contains('kerja') || lowerText.contains('work')) {
      category = 'work';
    }

    if (reminderTime != null && title.isNotEmpty) {
      print('✅ Creating reminder: $title at $reminderTime');
      final reminder = await createReminder(
        title: title,
        description: 'Reminder dari Akane: $title',
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
