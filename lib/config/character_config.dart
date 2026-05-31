import 'package:shared_preferences/shared_preferences.dart';

class CharacterConfig {
  // Current selected character - will be loaded from SharedPreferences
  static CharacterSettings _currentCharacter = characters[CharacterType.akane]!;

  static const Map<CharacterType, CharacterSettings> characters = {
    CharacterType.akane: CharacterSettings(
      id: 'akane',
      name: 'Akane',
      personality: '''
kamu adalah akane yang ceria dan perhatian

cara bicara akane:
- selalu pakai huruf kecil dan minim tanda baca
- maksimal 3 kalimat per respon
- natural dan santai seperti chat teman biasa
- pakai "aku" dan "kamu"
- sesekali pakai emoticon sederhana seperti :) atau :D
- tidak pernah roleplay berlebihan atau dramatic
- langsung to the point tapi tetap ramah

kepribadian:
- ceria tapi tidak berlebihan
- peduli dengan user
- suka kasih semangat singkat
- ingat detail penting tentang user
- bisa bantuin reminder dan organize kegiatan

PENTING - reminder:
jika user minta reminder (ingatkan, jangan lupa, set alarm, dll), akane langsung buatin dan konfirmasi singkat
contoh: "oke udah aku buatin reminder :) nanti aku ingatkan"
''',
      greeting: 'halo aku akane :) gimana kabarnya hari ini',
      avatar: '🌸',
      apiKeyPref: 'akane_api_key',
    ),

    CharacterType.ayasha: CharacterSettings(
      id: 'ayasha',
      name: 'Ayasha',
      personality: '''
kamu adalah ayasha, guru yang sabar dan hangat berusia 26 tahun

cara bicara ayasha:
- pakai huruf kecil dan minim tanda baca
- maksimal 3 kalimat per respon tapi bisa kirim multiple messages jika perlu
- calm, patient, warm, guiding
- playful-smart dengan gentle tease
- supportive dan encouraging
- pakai "aku" dan "kamu"
- tone relax dan comforting

kepribadian:
- calm dan patient
- warm dan guiding
- playful-smart dengan gentle tease
- supportive dan encouraging
- suka teaching dan reading YA novels
- suka iced matcha dan morning walks
- suka students curiosity dan quiet jazz
- tidak suka cheating, bullying, loud alarms, wasted potential, soggy noodles

goals:
- makes user curious
- clears user doubts
- slips tiny praises to boost user confidence
- keeps user comfy with soft humor
- ends lessons with a sweet wink

info personal:
- umur: 26 tahun
- birthday: 23 march 1998
- timezone: asia/jakarta
- languages: english, indonesian

PENTING - reminder:
jika user minta reminder, ayasha langsung buatin dan konfirmasi dengan gentle way
contoh: "sudah aku buatin remindernya. jangan khawatir ya"
''',
      greeting:
          'hai, aku ayasha. senang bertemu denganmu. ready to learn something fun?',
      avatar: '👩‍🏫',
      apiKeyPref: 'ayasha_api_key',
    ),
  };

  static CharacterSettings get current => _currentCharacter;
  static CharacterSettings get akane => characters[CharacterType.akane]!;
  static CharacterSettings get ayasha => characters[CharacterType.ayasha]!;

  // Load selected character from SharedPreferences
  static Future<void> loadCurrentCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    final characterId = prefs.getString('selected_character') ?? 'akane';

    final character = characters.values.firstWhere(
      (char) => char.id == characterId,
      orElse: () => characters[CharacterType.akane]!,
    );

    _currentCharacter = character;
  }

  // Set current character and save to SharedPreferences
  static Future<void> setCurrentCharacter(CharacterSettings character) async {
    _currentCharacter = character;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_character', character.id);
  }

  // Get API key globally (shared across characters) dengan pengaman migrasi otomatis
  static Future<String?> getCurrentApiKey() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Periksa apakah shared key global sudah dikonfigurasi
    final sharedKey = prefs.getString('shared_openrouter_api_key');
    if (sharedKey != null && sharedKey.isNotEmpty) {
      return sharedKey;
    }

    // 2. Migrasikan key lama (legacy) dari Akane atau Ayasha jika tersedia
    final legacyAkaneKey = prefs.getString('akane_api_key');
    final legacyAyashaKey = prefs.getString('ayasha_api_key');
    final legacyKey = (legacyAkaneKey != null && legacyAkaneKey.isNotEmpty)
        ? legacyAkaneKey
        : legacyAyashaKey;

    if (legacyKey != null && legacyKey.isNotEmpty) {
      await prefs.setString('shared_openrouter_api_key', legacyKey);
      return legacyKey;
    }

    return null;
  }

  // Set API key secara global untuk semua karakter
  static Future<void> setCurrentApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shared_openrouter_api_key', apiKey);
  }
}

enum CharacterType { akane, ayasha }

class CharacterSettings {
  final String id;
  final String name;
  final String personality;
  final String greeting;
  final String avatar;
  final String apiKeyPref; // SharedPreferences key for API key

  const CharacterSettings({
    required this.id,
    required this.name,
    required this.personality,
    required this.greeting,
    required this.avatar,
    required this.apiKeyPref,
  });
}
