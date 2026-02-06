import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/akane_preferences.dart';

class AyashaPreferencesService {
  static final AyashaPreferencesService _instance =
      AyashaPreferencesService._internal();
  factory AyashaPreferencesService() => _instance;
  AyashaPreferencesService._internal();

  static const String _prefsKey = 'ayasha_preferences';
  AkanePreferences _preferences = AkanePreferences.defaultAyasha();

  AkanePreferences get preferences => _preferences;

  Future<void> initialize() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_prefsKey);

    if (prefsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(prefsJson);
        _preferences = AkanePreferences.fromJson(json);
      } catch (e) {
        // If parsing fails, use default
        _preferences = AkanePreferences.defaultAyasha();
        await _savePreferences();
      }
    } else {
      // First time, save default preferences
      await _savePreferences();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_preferences.toJson());
    await prefs.setString(_prefsKey, jsonString);
  }

  Future<void> updatePreferences(AkanePreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();
  }

  Future<void> resetToDefault() async {
    _preferences = AkanePreferences.defaultAyasha();
    await _savePreferences();
  }
}
