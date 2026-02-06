import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../config/character_config.dart';
import '../config/api_config.dart';
import 'reminder_service.dart';
import 'akane_preferences_service.dart';
import 'ayasha_preferences_service.dart';

class LLMService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'moonshotai/kimi-k2-instruct-0905';

  String? _apiKey;
  final ReminderService _reminderService = ReminderService();
  final AkanePreferencesService _akanePreferencesService =
      AkanePreferencesService();
  final AyashaPreferencesService _ayashaPreferencesService =
      AyashaPreferencesService();

  bool get isConfigured =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _apiKey != 'YOUR_GROQ_API_KEY_HERE';

  Future<void> init() async {
    // Load API key for current character
    _apiKey =
        await CharacterConfig.getCurrentApiKey() ?? 'YOUR_GROQ_API_KEY_HERE';
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    await CharacterConfig.setCurrentApiKey(apiKey);
  }

  Future<String> sendMessage(
    String message,
    UserProfile? userProfile,
    List<Message> chatHistory,
  ) async {
    try {
      await init();
      await _reminderService.initialize();
      await _akanePreferencesService.initialize();
      await _ayashaPreferencesService.initialize();

      if (!isConfigured) {
        final character = CharacterConfig.current;
        return character.name == 'Akane'
            ? 'api key groq belum dikonfigurasi nih, coba buka settings dulu ya'
            : 'API key Groq belum dikonfigurasi. Silakan buka Settings terlebih dahulu.';
      }

      // Check if message contains reminder request
      final reminderCreated = await _tryCreateReminder(message);

      final systemPrompt = _buildSystemPrompt(userProfile);
      final history = _buildMessageHistory(chatHistory);

      // Add reminder context to system prompt if reminder was created
      String finalSystemPrompt = systemPrompt;
      if (reminderCreated != null) {
        finalSystemPrompt +=
            '\n\nINFO: User baru saja membuat reminder "${reminderCreated.title}" untuk ${reminderCreated.dateTime}. Respond singkat dan konfirmasi reminder sudah dibuat dengan style akane yang brief.';
      }

      return await _sendToGroq(message, finalSystemPrompt, history);
    } catch (e) {
      developer.log('LLM Error: $e', name: 'LLMService');
      final character = CharacterConfig.current;
      return character.name == 'Akane'
          ? 'ada masalah teknis nih :( error: ${e.toString().length > 50 ? '${e.toString().substring(0, 50)}...' : e.toString()}'
          : 'Terjadi error: ${e.toString()}';
    }
  }

  Future<String> _sendToGroq(
    String message,
    String systemPrompt,
    List<Map<String, String>> history,
  ) async {
    final url = Uri.parse('$_baseUrl/chat/completions');

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history,
      {'role': 'user', 'content': message},
    ];

    // Get max tokens from SharedPreferences (default ke recommended)
    final prefs = await SharedPreferences.getInstance();
    final maxTokens =
        prefs.getInt('max_tokens') ?? ApiConfig.recommendedMaxTokens;

    final requestBody = {
      'model': _model,
      'messages': messages,
      'max_completion_tokens':
          maxTokens, // Use max_completion_tokens instead of max_tokens
      'temperature': 0.6,
      'top_p': 1,
      'stream': false,
      'stop': null,
    };

    developer.log(
      'Groq API Request: ${json.encode(requestBody)}',
      name: 'LLMService',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    developer.log(
      'Groq API Response: ${response.statusCode} - ${response.body}',
      name: 'LLMService',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      // Log detailed error for debugging
      developer.log(
        'Groq API Error Details: ${response.statusCode} - ${response.body}',
        name: 'LLMService',
      );

      if (response.statusCode == 401) {
        throw Exception('API key tidak valid atau expired');
      } else if (response.statusCode == 400) {
        throw Exception('Request format salah');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded');
      } else {
        throw Exception('Groq API error: ${response.statusCode}');
      }
    }
  }

  String _buildSystemPrompt(UserProfile? userProfile) {
    final character = CharacterConfig.current;

    // Use character-specific preferences
    if (character.name == 'Akane') {
      final preferences = _akanePreferencesService.preferences;
      String finalSystemPrompt = preferences.buildSystemPrompt(
        userProfile?.name,
      );

      if (userProfile != null) {
        finalSystemPrompt += '''

Informasi tentang user:
- Nama: ${userProfile.name}
- Nickname: ${userProfile.nickname ?? userProfile.name}
- Minat: ${userProfile.interests.join(', ')}
- Rutinitas: ${userProfile.dailyRoutine.join(', ')}
- Info personal: ${userProfile.personalInfo.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Gunakan informasi ini untuk membuat percakapan lebih personal dan relevan dengan ${userProfile.nickname ?? userProfile.name}.
''';
      }

      return finalSystemPrompt;
    } else if (character.name == 'Ayasha') {
      final preferences = _ayashaPreferencesService.preferences;
      String finalSystemPrompt = preferences.buildSystemPrompt(
        userProfile?.name,
      );

      if (userProfile != null) {
        finalSystemPrompt += '''

Informasi tentang user:
- Nama: ${userProfile.name}
- Nickname: ${userProfile.nickname ?? userProfile.name}
- Minat: ${userProfile.interests.join(', ')}
- Rutinitas: ${userProfile.dailyRoutine.join(', ')}
- Info personal: ${userProfile.personalInfo.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Gunakan informasi ini untuk membuat percakapan lebih personal dan relevan dengan ${userProfile.nickname ?? userProfile.name}.
''';
      }

      return finalSystemPrompt;
    } else {
      // Use default character config for other characters
      String basePrompt = character.personality;

      if (userProfile != null) {
        basePrompt += '''

Informasi tentang user:
- Nama: ${userProfile.name}
- Nickname: ${userProfile.nickname ?? userProfile.name}
- Minat: ${userProfile.interests.join(', ')}
- Rutinitas: ${userProfile.dailyRoutine.join(', ')}
- Info personal: ${userProfile.personalInfo.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Gunakan informasi ini untuk membuat percakapan lebih personal dan relevan dengan ${userProfile.nickname ?? userProfile.name}.
''';
      }

      return basePrompt;
    }
  }

  List<Map<String, String>> _buildMessageHistory(List<Message> chatHistory) {
    List<Map<String, String>> history = [];

    // Ambil 15 pesan terakhir untuk konteks (hemat TPM)
    final recentHistory =
        chatHistory.length > ApiConfig.recommendedContextMessages
            ? chatHistory.sublist(
              (chatHistory.length - ApiConfig.recommendedContextMessages)
                  .toInt(),
            )
            : chatHistory;

    for (final msg in recentHistory) {
      history.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    return history;
  }

  /// Try to create reminder from user message
  Future<dynamic> _tryCreateReminder(String message) async {
    try {
      // Check if message contains reminder keywords
      final lowerMessage = message.toLowerCase();
      final reminderKeywords = [
        'ingatkan',
        'reminder',
        'jangan lupa',
        'set alarm',
        'alarm',
        'ingatin',
        'remind me',
      ];

      final hasReminderKeyword = reminderKeywords.any(
        (keyword) => lowerMessage.contains(keyword),
      );

      if (!hasReminderKeyword) return null;

      // Try to parse and create reminder
      final reminder = await _reminderService.parseReminderFromText(message);
      return reminder;
    } catch (e) {
      // If reminder creation fails, just return null
      // The chat will continue normally
      return null;
    }
  }
}
