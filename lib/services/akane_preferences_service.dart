import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/akane_preferences.dart';

class AkanePreferencesService {
  static final AkanePreferencesService _instance =
      AkanePreferencesService._internal();
  factory AkanePreferencesService() => _instance;
  AkanePreferencesService._internal();

  static const String _preferencesKey = 'akane_preferences';
  AkanePreferences? _currentPreferences;

  /// Initialize service
  Future<void> initialize() async {
    await loadPreferences();
  }

  /// Get current preferences
  AkanePreferences get preferences =>
      _currentPreferences ?? const AkanePreferences();

  /// Load preferences from storage
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_preferencesKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _currentPreferences = AkanePreferences.fromJson(json);
      } else {
        _currentPreferences = const AkanePreferences();
      }
    } catch (e) {
      developer.log(
        'Error loading Akane preferences: $e',
        name: 'AkanePreferencesService',
      );
      _currentPreferences = const AkanePreferences();
    }
  }

  /// Save preferences to storage
  Future<void> savePreferences(AkanePreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(preferences.toJson());
      await prefs.setString(_preferencesKey, jsonString);
      _currentPreferences = preferences;
    } catch (e) {
      developer.log(
        'Error saving Akane preferences: $e',
        name: 'AkanePreferencesService',
      );
      throw Exception('Failed to save preferences: $e');
    }
  }

  /// Reset to default preferences
  Future<void> resetToDefaults() async {
    const defaultPreferences = AkanePreferences();
    await savePreferences(defaultPreferences);
  }

  /// Update specific preference
  Future<void> updatePreference<T>(String key, T value) async {
    final current = preferences;
    AkanePreferences updated;

    switch (key) {
      case 'name':
        updated = current.copyWith(name: value as String);
        break;
      case 'responseStyle':
        updated = current.copyWith(responseStyle: value as String);
        break;
      case 'punctuation':
        updated = current.copyWith(punctuation: value as String);
        break;
      case 'allowSendingMultipleMessages':
        updated = current.copyWith(allowSendingMultipleMessages: value as bool);
        break;
      case 'allowRoleplayActions':
        updated = current.copyWith(allowRoleplayActions: value as bool);
        break;
      case 'allowSelfReference':
        updated = current.copyWith(allowSelfReference: value as bool);
        break;
      case 'allowPronouns':
        updated = current.copyWith(allowPronouns: value as bool);
        break;
      case 'useLocalTime':
        updated = current.copyWith(useLocalTime: value as bool);
        break;
      case 'timezone':
        updated = current.copyWith(timezone: value as String);
        break;
      case 'languages':
        updated = current.copyWith(languages: value as List<String>);
        break;
      case 'shortTermMemory':
        updated = current.copyWith(shortTermMemory: value as int);
        break;
      case 'longTermMemory':
        updated = current.copyWith(longTermMemory: value as int);
        break;
      case 'personalityTraits':
        updated = current.copyWith(personalityTraits: value as String);
        break;
      case 'tone':
        updated = current.copyWith(tone: value as String);
        break;
      case 'age':
        updated = current.copyWith(age: value as int);
        break;
      case 'birthday':
        updated = current.copyWith(birthday: value as String);
        break;
      case 'likes':
        updated = current.copyWith(likes: value as List<String>);
        break;
      case 'dislikes':
        updated = current.copyWith(dislikes: value as List<String>);
        break;
      case 'conversationalGoals':
        updated = current.copyWith(conversationalGoals: value as String);
        break;
      case 'userReferral':
        updated = current.copyWith(userReferral: value as String);
        break;
      default:
        throw ArgumentError('Unknown preference key: $key');
    }

    await savePreferences(updated);
  }

  /// Get available options for dropdowns
  static const Map<String, List<String>> availableOptions = {
    'responseStyle': ['lowercase', 'normal', 'formal'],
    'punctuation': ['none', 'minimal', 'normal', 'full'],
    'tone': ['relax', 'friendly', 'professional', 'playful', 'flirty'],
    'timezone': [
      'Asia/Jakarta',
      'Asia/Tokyo',
      'America/New_York',
      'Europe/London',
      'Australia/Sydney',
    ],
    'languages': ['indonesian', 'english', 'japanese', 'korean'],
  };

  /// Get personality trait suggestions
  static const List<String> personalityTraitSuggestions = [
    'shy',
    'confident',
    'clingy',
    'independent',
    'hot',
    'cool',
    'flirty',
    'serious',
    'playful',
    'helpful',
    'sarcastic',
    'sweet',
    'teasing',
    'caring',
    'mysterious',
    'energetic',
  ];

  /// Get likes/dislikes suggestions
  static const List<String> likesSuggestions = [
    'music',
    'movies',
    'books',
    'games',
    'sports',
    'cooking',
    'travel',
    'art',
    'technology',
    'science',
    'nature',
    'animals',
    'fashion',
    'photography',
    'dancing',
    'singing',
  ];

  static const List<String> dislikesSuggestions = [
    'lies',
    'rudeness',
    'laziness',
    'noise',
    'crowds',
    'waiting',
    'spicy food',
    'cold weather',
    'early mornings',
    'fake people',
    'drama',
    'negativity',
    'ignorance',
    'arrogance',
  ];
}
