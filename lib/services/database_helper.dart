import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../config/character_config.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static MockDatabase? _mockDatabase;

  Future<Database> get database async {
    if (kIsWeb) {
      _mockDatabase ??= MockDatabase();
      return _mockDatabase!;
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chatty.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create character-specific message tables
    await db.execute('''
      CREATE TABLE messages_akane(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        isUser INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT DEFAULT 'chat'
      )
    ''');

    await db.execute('''
      CREATE TABLE messages_ayasha(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        isUser INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT DEFAULT 'chat'
      )
    ''');

    // Keep single user profile table (shared across characters)
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        nickname TEXT,
        interests TEXT,
        dailyRoutine TEXT,
        personalInfo TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create character-specific message tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages_akane(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          isUser INTEGER NOT NULL,
          timestamp TEXT NOT NULL,
          type TEXT DEFAULT 'chat'
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages_ayasha(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          isUser INTEGER NOT NULL,
          timestamp TEXT NOT NULL,
          type TEXT DEFAULT 'chat'
        )
      ''');

      // Migrate existing messages to Akane table
      try {
        await db.execute('''
          INSERT INTO messages_akane (content, isUser, timestamp, type)
          SELECT content, isUser, timestamp, type FROM messages
        ''');

        // Drop old messages table
        await db.execute('DROP TABLE IF EXISTS messages');
      } catch (e) {
        // If migration fails, just continue
        print('Migration warning: $e');
      }
    }
  }

  Future<int> insertMessage(Message message, {String? characterId}) async {
    final db = await database;
    final tableName = 'messages_${characterId ?? CharacterConfig.current.id}';
    return await db.insert(tableName, {
      'content': message.content,
      'isUser': message.isUser ? 1 : 0,
      'timestamp': message.timestamp.toIso8601String(),
      'type': message.type,
    });
  }

  Future<List<Message>> getMessages({
    int limit = 50,
    String? characterId,
  }) async {
    final db = await database;
    final tableName = 'messages_${characterId ?? CharacterConfig.current.id}';

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return maps
          .map(
            (map) => Message(
              id: map['id'],
              content: map['content'],
              isUser: map['isUser'] == 1,
              timestamp: DateTime.parse(map['timestamp']),
              type: map['type'],
            ),
          )
          .toList()
          .reversed
          .toList();
    } catch (e) {
      // If table doesn't exist, return empty list
      return [];
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert('user_profile', {
      'id': 1,
      'name': profile.name,
      'nickname': profile.nickname,
      'interests': jsonEncode(profile.interests),
      'dailyRoutine': jsonEncode(profile.dailyRoutine),
      'personalInfo': jsonEncode(profile.personalInfo),
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return UserProfile(
      name: map['name'],
      nickname: map['nickname'],
      interests: List<String>.from(jsonDecode(map['interests'] ?? '[]')),
      dailyRoutine: List<String>.from(jsonDecode(map['dailyRoutine'] ?? '[]')),
      personalInfo: Map<String, String>.from(
        jsonDecode(map['personalInfo'] ?? '{}'),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Get total message count for specific character
  Future<int> getMessageCount({String? characterId}) async {
    final db = await database;
    final tableName = 'messages_${characterId ?? CharacterConfig.current.id}';
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all data (for import/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('messages_akane');
    await db.delete('messages_ayasha');
    await db.delete('user_profile');
  }

  /// Delete old messages (keep last N messages) for specific character
  Future<void> cleanOldMessages({
    int keepLast = 1000,
    String? characterId,
  }) async {
    final db = await database;
    final tableName = 'messages_${characterId ?? CharacterConfig.current.id}';
    try {
      await db.execute(
        '''
        DELETE FROM $tableName 
        WHERE id NOT IN (
          SELECT id FROM $tableName 
          ORDER BY timestamp DESC 
          LIMIT ?
        )
      ''',
        [keepLast],
      );
    } catch (e) {
      print('Clean old messages error: $e');
    }
  }

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    if (kIsWeb) return 0;
    final dbPath = join(await getDatabasesPath(), 'chatty.db');
    final file = File(dbPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}

class MockDatabase implements Database {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  int _lastId = 0;

  @override
  String get path => 'in_memory_chatty.db';

  @override
  bool get isOpen => true;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '');
    
    if (memberName == 'execute') {
      return Future<void>.value();
    }
    
    if (memberName == 'insert') {
      final table = invocation.positionalArguments[0] as String;
      final values = invocation.positionalArguments[1] as Map<String, dynamic>;
      _tables.putIfAbsent(table, () => []);
      
      _lastId++;
      final row = Map<String, dynamic>.from(values);
      row['id'] = _lastId;
      _tables[table]!.add(row);
      return Future<int>.value(_lastId);
    }

    if (memberName == 'query') {
      final table = invocation.positionalArguments[0] as String;
      final rows = _tables[table] ?? [];
      
      var result = rows.map((r) => Map<String, dynamic>.from(r)).toList();
      
      final orderBy = invocation.namedArguments[#orderBy] as String?;
      if (orderBy != null) {
        if (orderBy.contains('timestamp DESC')) {
          result.sort((a, b) {
            final ta = a['timestamp'] as String? ?? '';
            final tb = b['timestamp'] as String? ?? '';
            return tb.compareTo(ta);
          });
        } else if (orderBy.contains('dateTime ASC')) {
          result.sort((a, b) {
            final da = a['dateTime'] as String? ?? '';
            final db = b['dateTime'] as String? ?? '';
            return da.compareTo(db);
          });
        }
      }
      
      final limit = invocation.namedArguments[#limit] as int?;
      if (limit != null && result.length > limit) {
        result = result.sublist(0, limit);
      }
      
      return Future<List<Map<String, dynamic>>>.value(result);
    }
    
    if (memberName == 'update') {
      final table = invocation.positionalArguments[0] as String;
      final values = invocation.positionalArguments[1] as Map<String, dynamic>;
      final whereArgs = invocation.namedArguments[#whereArgs] as List<dynamic>?;
      
      final rows = _tables[table] ?? [];
      if (whereArgs != null && whereArgs.isNotEmpty) {
        final id = whereArgs[0];
        for (var i = 0; i < rows.length; i++) {
          if (rows[i]['id'] == id) {
            final updatedRow = Map<String, dynamic>.from(rows[i]);
            values.forEach((k, v) => updatedRow[k] = v);
            rows[i] = updatedRow;
          }
        }
      }
      return Future<int>.value(1);
    }

    if (memberName == 'delete') {
      final table = invocation.positionalArguments[0] as String;
      final whereArgs = invocation.namedArguments[#whereArgs] as List<dynamic>?;
      
      if (whereArgs != null && whereArgs.isNotEmpty) {
        final id = whereArgs[0];
        _tables[table]?.removeWhere((r) => r['id'] == id);
      } else {
        _tables[table]?.clear();
      }
      return Future<int>.value(1);
    }
    
    if (memberName == 'rawQuery') {
      final sql = invocation.positionalArguments[0] as String;
      if (sql.toLowerCase().contains('select count(*)')) {
        final match = RegExp(r'from\s+(\w+)', caseSensitive: false).firstMatch(sql);
        if (match != null) {
          final tableName = match.group(1)!;
          final count = _tables[tableName]?.length ?? 0;
          return Future<List<Map<String, dynamic>>>.value([
            {'count': count}
          ]);
        }
      }
      return Future<List<Map<String, dynamic>>>.value([]);
    }

    if (memberName == 'close') {
      return Future<void>.value();
    }
    
    return super.noSuchMethod(invocation);
  }
}
