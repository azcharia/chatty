import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../services/database_helper.dart';
import '../services/llm_service.dart';
import '../config/character_config.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LLMService _llmService = LLMService();

  List<Message> _messages = [];
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isTyping = false;
  DateTime? _lastMessageTime;
  static const Duration _minMessageInterval = Duration(milliseconds: 1500);

  List<Message> get messages => _messages;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _initializeChat();
  }

  // Method untuk reload chat saat ganti character
  Future<void> switchCharacter() async {
    _messages.clear();
    _isLoading = true;
    notifyListeners();

    await _initializeChat();
  }

  Future<void> _initializeChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _dbHelper.getUserProfile();
      _messages = await _dbHelper.getMessages(
        characterId: CharacterConfig.current.id,
      );

      // Jika user baru, tampilkan pesan welcome
      if (_messages.isEmpty) {
        await _addWelcomeMessage();
      }
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _addWelcomeMessage() async {
    final character = CharacterConfig.current;

    final welcomeMessage = Message(
      content:
          _userProfile != null
              ? 'Halo ${_userProfile!.nickname ?? _userProfile!.name}! Aku kangen ngobrol sama kamu~ 😊 Ada yang mau diceritain hari ini? ✨'
              : character.greeting,
      isUser: false,
      timestamp: DateTime.now(),
      type: 'chat',
    );

    await _dbHelper.insertMessage(
      welcomeMessage,
      characterId: CharacterConfig.current.id,
    );
    _messages.add(welcomeMessage);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Rate limiting - cegah spam chat
    final now = DateTime.now();
    if (_lastMessageTime != null &&
        now.difference(_lastMessageTime!) < _minMessageInterval) {
      // Terlalu cepat, tunggu sebentar
      await Future.delayed(
        _minMessageInterval - now.difference(_lastMessageTime!),
      );
    }
    _lastMessageTime = now;

    // Cegah multiple request bersamaan
    if (_isTyping) {
      return;
    }

    // Tambah pesan user
    final userMessage = Message(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      type: 'chat',
    );

    _messages.add(userMessage);
    await _dbHelper.insertMessage(
      userMessage,
      characterId: CharacterConfig.current.id,
    );
    notifyListeners();

    // Tampilkan typing indicator
    _isTyping = true;
    notifyListeners();

    try {
      // Kirim ke LLM dan dapatkan response
      final response = await _llmService.sendMessage(
        content,
        _userProfile,
        _messages,
      );

      final aiMessage = Message(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        type: 'chat',
      );

      _messages.add(aiMessage);
      await _dbHelper.insertMessage(
        aiMessage,
        characterId: CharacterConfig.current.id,
      );

      // Cek apakah perlu update profile user
      await _checkAndUpdateProfile(content, response);
    } catch (e) {
      final errorMessage = Message(
        content:
            'Maaf, aku lagi ada masalah teknis. Tapi aku tetap di sini buat kamu!',
        isUser: false,
        timestamp: DateTime.now(),
        type: 'chat',
      );

      _messages.add(errorMessage);
      await _dbHelper.insertMessage(
        errorMessage,
        characterId: CharacterConfig.current.id,
      );
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<void> _checkAndUpdateProfile(
    String userMessage,
    String aiResponse,
  ) async {
    // Logic sederhana untuk extract info dari percakapan
    final lowerMessage = userMessage.toLowerCase();

    if (_userProfile == null &&
        (lowerMessage.contains('nama') || lowerMessage.contains('aku'))) {
      // Extract nama dari pesan pertama
      final words = userMessage.split(' ');
      String? name;

      for (int i = 0; i < words.length - 1; i++) {
        if (words[i].toLowerCase() == 'nama' &&
            words[i + 1].toLowerCase() == 'aku') {
          if (i + 2 < words.length) {
            name = words[i + 2];
            break;
          }
        } else if (words[i].toLowerCase() == 'aku') {
          name = words[i + 1];
          break;
        }
      }

      if (name != null && name.isNotEmpty) {
        _userProfile = UserProfile(
          name: name,
          nickname: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _dbHelper.saveUserProfile(_userProfile!);
        notifyListeners();
      }
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile.copyWith(updatedAt: DateTime.now());
    await _dbHelper.saveUserProfile(_userProfile!);
    notifyListeners();
  }

  Future<void> loadMessages() async {
    try {
      _messages = await _dbHelper.getMessages(
        characterId: CharacterConfig.current.id,
      );
      _userProfile = await _dbHelper.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> clearChat() async {
    // Implementasi untuk clear chat jika diperlukan
    _messages.clear();
    notifyListeners();
  }
}
