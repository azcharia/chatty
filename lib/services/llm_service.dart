import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
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
  static const String _baseUrl = ApiConfig.baseUrl;
  static const String _model = ApiConfig.model;

  String? _apiKey;
  final ReminderService _reminderService = ReminderService();
  final AkanePreferencesService _akanePreferencesService =
      AkanePreferencesService();
  final AyashaPreferencesService _ayashaPreferencesService =
      AyashaPreferencesService();

  bool get isConfigured =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _apiKey != 'YOUR_OPENROUTER_API_KEY_HERE';

  Future<void> init() async {
    // Load API key for current character
    _apiKey =
        await CharacterConfig.getCurrentApiKey() ?? 'YOUR_OPENROUTER_API_KEY_HERE';
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
            ? 'api key openrouter belum dikonfigurasi nih, coba buka settings dulu ya'
            : 'API key OpenRouter belum dikonfigurasi. Silakan buka Settings terlebih dahulu.';
      }

      // Check if message contains reminder request
      final reminderCreated = await _tryCreateReminder(message);

      // Load custom character soul if configured in assets
      String customSoul = '';
      try {
        customSoul = await rootBundle.loadString('assets/soul.md');
      } catch (e) {
        developer.log('Custom soul.md asset not found or failed to load: $e', name: 'LLMService');
      }

      String systemPrompt = _buildSystemPrompt(userProfile);
      if (customSoul.isNotEmpty) {
        systemPrompt += '\n\nCUSTOM SOUL/CHARACTER SYSTEM RULES:\n$customSoul';
      }
      
      final history = _buildMessageHistory(chatHistory);

      // Add Tavily Web Search context if configured and needed (Modular RAG Level 3)
      final prefs = await SharedPreferences.getInstance();
      final tavilyApiKey = prefs.getString('tavily_api_key') ?? '';
      
      String finalSystemPrompt = systemPrompt;
      if (tavilyApiKey.isNotEmpty) {
        final needsSearch = await _checkIfNeedsWebSearch(message);
        if (needsSearch) {
          final searchContext = await _performTavilySearch(message, tavilyApiKey);
          if (searchContext.isNotEmpty) {
            finalSystemPrompt += '\n\nREAL-TIME WEB SEARCH CONTEXT:\n$searchContext\n\nUse the above web search results to answer the user\'s question accurately. Keep your response in character (${CharacterConfig.current.name}).';
          }
        }
      }

      // Add reminder context to system prompt if reminder was created
      if (reminderCreated != null) {
        final character = CharacterConfig.current;
        finalSystemPrompt +=
            '\n\nINFO: User baru saja membuat reminder "${reminderCreated.title}" untuk ${reminderCreated.dateTime}. Respond singkat dan konfirmasi reminder sudah dibuat dengan style kepribadian ${character.name}.';
      }

      return await _sendToOpenRouter(message, finalSystemPrompt, history);
    } catch (e) {
      developer.log('LLM Error: $e', name: 'LLMService');
      final character = CharacterConfig.current;
      return character.name == 'Akane'
          ? 'ada masalah teknis nih :( error: ${e.toString().length > 50 ? '${e.toString().substring(0, 50)}...' : e.toString()}'
          : 'Terjadi error: ${e.toString()}';
    }
  }

  Future<String> _sendToOpenRouter(
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
      'OpenRouter API Request: ${json.encode(requestBody)}',
      name: 'LLMService',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://github.com/user/chatty',
        'X-OpenRouter-Title': 'Chatty - AI Companion',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    developer.log(
      'OpenRouter API Response: ${response.statusCode} - ${response.body}',
      name: 'LLMService',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rawContent = data['choices'][0]['message']['content'].toString().trim();
      return _cleanAIResponse(rawContent);
    } else {
      // Log detailed error for debugging
      developer.log(
        'OpenRouter API Error Details: ${response.statusCode} - ${response.body}',
        name: 'LLMService',
      );

      if (response.statusCode == 401) {
        throw Exception('API key tidak valid atau expired');
      } else if (response.statusCode == 400) {
        throw Exception('Request format salah');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded');
      } else {
        throw Exception('OpenRouter API error: ${response.statusCode}');
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

  /// Check if user message requires real-time web search
  Future<bool> _checkIfNeedsWebSearch(String message) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/completions');
      final systemPrompt = '''
Analyze the following user message. Respond with ONLY 'YES' if it requires looking up real-time/current/web information or factual updates (such as current events, weather, scores, releases, recent facts). Respond with ONLY 'NO' if it is a general chat, greeting, personal question, or reminder request.
Do not explain, just return YES or NO.
''';
      final requestBody = {
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message},
        ],
        'max_completion_tokens': 3,
        'temperature': 0.0,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://github.com/user/chatty',
          'X-OpenRouter-Title': 'Chatty - AI Companion',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['choices'][0]['message']['content'].toString().trim().toUpperCase();
        developer.log('Router LLM Decision: $answer', name: 'LLMService');
        return answer.contains('YES');
      }
    } catch (e) {
      developer.log('Router LLM error: $e', name: 'LLMService');
    }
    return false;
  }

  /// Perform search on Tavily API
  Future<String> _performTavilySearch(String query, String apiKey) async {
    try {
      final url = Uri.parse('https://api.tavily.com/search');
      final requestBody = {
        'api_key': apiKey,
        'query': query,
        'search_depth': 'basic',
        'max_results': 3,
      };

      developer.log('Tavily API Request for query: $query', name: 'LLMService');
      
      final response = await http.post(
         url,
         headers: {'Content-Type': 'application/json'},
         body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        
        if (results.isEmpty) {
          return 'No search results found.';
        }

        final contextBuffer = StringBuffer();
        for (var i = 0; i < results.length; i++) {
          final r = results[i];
          contextBuffer.writeln('Source [${i+1}]: ${r['title']} (${r['url']})');
          contextBuffer.writeln('Content: ${r['content']}');
          contextBuffer.writeln('');
        }
        
        final searchContext = contextBuffer.toString();
        developer.log('Tavily Search Context fetched (${searchContext.length} chars)', name: 'LLMService');
        return searchContext;
      } else {
        developer.log('Tavily error: ${response.statusCode} - ${response.body}', name: 'LLMService');
      }
    } catch (e) {
      developer.log('Tavily API Call failed: $e', name: 'LLMService');
    }
    return '';
  }

  /// Clean raw LLM response (humanizer filter)
  String _cleanAIResponse(String text) {
    // Remove markdown bold tags (**)
    String cleaned = text.replaceAll('**', '');
    
    // Normalize space and newlines
    return cleaned.trim();
  }
}
