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
    _isTyping = false; // Pengaman: Reset status mengetik dari karakter sebelumnya
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

    // Ambil ID karakter pengirim secara lokal di awal untuk pengaman asinkron (race conditions)
    final String sendingCharacterId = CharacterConfig.current.id;

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
      characterId: sendingCharacterId,
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

      final parts = _splitAIResponse(response);
      _isTyping = false; // Turn off initial typing indicator

      for (var i = 0; i < parts.length; i++) {
        final partContent = parts[i];

        final aiMessage = Message(
          content: partContent,
          isUser: false,
          timestamp: DateTime.now(),
          type: 'chat',
        );

        // Simpan ke database lokal pengirim terlebih dahulu (selalu aman)
        await _dbHelper.insertMessage(
          aiMessage,
          characterId: sendingCharacterId,
        );

        // Hanya perbarui UI dan daftar memori chat jika user BELUM beralih karakter ke karakter lain
        if (CharacterConfig.current.id == sendingCharacterId) {
          _messages.add(aiMessage);
          notifyListeners();
        }

        // Tampilkan typing indicator kembali jika masih ada bubble berikutnya
        if (i < parts.length - 1) {
          if (CharacterConfig.current.id == sendingCharacterId) {
            _isTyping = true;
            notifyListeners();
          }

          // Delay pengetikan dinamis (12ms per karakter, batas antara 800ms s.d. 1800ms)
          final delayMs = (parts[i + 1].length * 12).clamp(800, 1800);
          await Future.delayed(Duration(milliseconds: delayMs));

          if (CharacterConfig.current.id == sendingCharacterId) {
            _isTyping = false;
          }
        }
      }

      // Cek apakah perlu update profile user (menggunakan response penuh)
      if (CharacterConfig.current.id == sendingCharacterId) {
        await _checkAndUpdateProfile(content, response);
        _isTyping = false;
        notifyListeners();
      }
    } catch (e) {
      final errorMessage = Message(
        content:
            'Maaf, aku lagi ada masalah teknis. Tapi aku tetap di sini buat kamu!',
        isUser: false,
        timestamp: DateTime.now(),
        type: 'chat',
      );

      await _dbHelper.insertMessage(
        errorMessage,
        characterId: sendingCharacterId,
      );

      if (CharacterConfig.current.id == sendingCharacterId) {
        _messages.add(errorMessage);
        _isTyping = false;
        notifyListeners();
      }
    }
  }

  Future<void> _checkAndUpdateProfile(
    String userMessage,
    String aiResponse,
  ) async {
    final lowerMessage = userMessage.toLowerCase().trim();
    bool updated = false;

    // Load or initialize user profile
    UserProfile currentProfile = _userProfile ?? UserProfile(
      name: 'User',
      nickname: 'User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    List<String> newInterests = List.from(currentProfile.interests);
    List<String> newRoutines = List.from(currentProfile.dailyRoutine);
    Map<String, String> newPersonalInfo = Map.from(currentProfile.personalInfo);
    String? newName = currentProfile.name == 'User' ? null : currentProfile.name;
    String? newNickname = currentProfile.nickname == 'User' ? null : currentProfile.nickname;

    // Helper functions to clean punctuation
    String cleanValue(String val) {
      return val.replaceAll(RegExp(r'[.!?~😊✨]+$'), '').trim();
    }

    // 1. EXTRACT NAME / NICKNAME
    final nameRegexes = [
      RegExp(r'\bnama\s+aku\s+([a-zA-Z\s]{2,15})\b'),
      RegExp(r'\bnamaku\s+([a-zA-Z\s]{2,15})\b'),
      RegExp(r'\bpanggil\s+aku\s+([a-zA-Z\s]{2,15})\b'),
      RegExp(r'\bpanggil\s+aja\s+([a-zA-Z\s]{2,15})\b'),
      RegExp(r'\bnama\s+gw\s+([a-zA-Z\s]{2,15})\b'),
    ];

    for (final regex in nameRegexes) {
      final match = regex.firstMatch(lowerMessage);
      if (match != null) {
        final startIdx = match.start + match.group(0)!.indexOf(match.group(1)!);
        final extractedName = cleanValue(userMessage.substring(startIdx, startIdx + match.group(1)!.length));
        if (extractedName.isNotEmpty) {
          newName = extractedName;
          newNickname = extractedName;
          updated = true;
          break;
        }
      }
    }

    // 2. EXTRACT HOBBIES / INTERESTS
    final interestRegexes = [
      RegExp(r'\bhobi\s+aku\s+(?:adalah\s+)?([^,.]+)\b'),
      RegExp(r'\bhobiku\s+(?:adalah\s+)?([^,.]+)\b'),
      RegExp(r'\baku\s+suka\s+bermain\s+([^,.]+)\b'),
      RegExp(r'\baku\s+suka\s+main\s+([^,.]+)\b'),
      RegExp(r'\bsuka\s+nonton\s+([^,.]+)\b'),
      RegExp(r'\blagi\s+tertarik\s+belajar\s+([^,.]+)\b'),
    ];

    for (final regex in interestRegexes) {
      final match = regex.firstMatch(lowerMessage);
      if (match != null) {
        final startIdx = match.start + match.group(0)!.indexOf(match.group(1)!);
        final interest = cleanValue(userMessage.substring(startIdx, startIdx + match.group(1)!.length));
        if (interest.isNotEmpty && !newInterests.any((item) => item.toLowerCase() == interest.toLowerCase())) {
          newInterests.add(interest);
          updated = true;
        }
      }
    }

    // 3. EXTRACT ROUTINE
    final routineRegexes = [
      RegExp(r'\bsetiap\s+pagi\s+aku\s+([^,.]+)\b'),
      RegExp(r'\bsetiap\s+hari\s+aku\s+([^,.]+)\b'),
      RegExp(r'\bbiasanya\s+tiap\s+malam\s+aku\s+([^,.]+)\b'),
      RegExp(r'\bsetiap\s+weekend\s+aku\s+([^,.]+)\b'),
    ];

    for (final regex in routineRegexes) {
      final match = regex.firstMatch(lowerMessage);
      if (match != null) {
        final startIdx = match.start + match.group(0)!.indexOf(match.group(1)!);
        final routine = cleanValue(userMessage.substring(startIdx, startIdx + match.group(1)!.length));
        if (routine.isNotEmpty && !newRoutines.any((item) => item.toLowerCase() == routine.toLowerCase())) {
          newRoutines.add(routine);
          updated = true;
        }
      }
    }

    // 4. EXTRACT PERSONAL INFO (Age, Location, Favorite Food, etc.)
    // Age
    final ageRegex = RegExp(r'\bumur\s+aku\s+(\d+\s*(?:tahun)?)\b');
    final ageMatch = ageRegex.firstMatch(lowerMessage);
    if (ageMatch != null) {
      final age = cleanValue(ageMatch.group(1)!);
      newPersonalInfo['Umur'] = age;
      updated = true;
    }

    // Location/City
    final locationRegex = RegExp(r'\btinggal\s+di\s+([a-zA-Z\s]{3,15})\b');
    final locationMatch = locationRegex.firstMatch(lowerMessage);
    if (locationMatch != null) {
      final startIdx = locationMatch.start + locationMatch.group(0)!.indexOf(locationMatch.group(1)!);
      final city = cleanValue(userMessage.substring(startIdx, startIdx + locationMatch.group(1)!.length));
      newPersonalInfo['Kota asal'] = city;
      updated = true;
    }

    // Favorite Food
    final foodRegex = RegExp(r'\bmakanan\s+favoritku\s+(?:adalah\s+)?([^,.]+)\b');
    final foodMatch = foodRegex.firstMatch(lowerMessage);
    if (foodMatch != null) {
      final startIdx = foodMatch.start + foodMatch.group(0)!.indexOf(foodMatch.group(1)!);
      final food = cleanValue(userMessage.substring(startIdx, startIdx + foodMatch.group(1)!.length));
      newPersonalInfo['Makanan Favorit'] = food;
      updated = true;
    }

    if (updated) {
      _userProfile = currentProfile.copyWith(
        name: newName ?? currentProfile.name,
        nickname: newNickname ?? currentProfile.nickname,
        interests: newInterests,
        dailyRoutine: newRoutines,
        personalInfo: newPersonalInfo,
        updatedAt: DateTime.now(),
      );

      await _dbHelper.saveUserProfile(_userProfile!);
      notifyListeners();
      print('👤 Dynamic User Profile Updated: ${_userProfile!.toJson()}');
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

  /// Helper to split AI response into multiple logical bubbles (intro vs content)
  List<String> _splitAIResponse(String text) {
    final paragraphs = text.split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.length <= 1) return [text];

    List<String> result = [];

    // Jika bagian pertama pendek (misal intro/salam), jadikan bubble pembuka tersendiri
    if (paragraphs[0].length < 130) {
      result.add(paragraphs[0]);
      if (paragraphs.length > 2) {
        result.add(paragraphs.sublist(1).join('\n\n'));
      } else {
        result.add(paragraphs[1]);
      }
    } else {
      // Jika bagian pertama panjang, batasi menjadi maksimal 2 bubble agar tidak spam
      result.add(paragraphs[0]);
      result.add(paragraphs.sublist(1).join('\n\n'));
    }

    return result;
  }
}
