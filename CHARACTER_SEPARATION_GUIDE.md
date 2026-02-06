# Character Separation Guide - Akane & Ayasha

## Overview
Aplikasi Chatty sekarang memisahkan data, analytics, dan settings antara Akane dan Ayasha. Setiap character memiliki:
- Database chat history terpisah
- Analytics data terpisah
- Settings dan preferences terpisah

## Database Structure

### Character-Specific Message Tables
```
messages_akane    - Menyimpan semua chat dengan Akane
messages_ayasha   - Menyimpan semua chat dengan Ayasha
user_profile      - Shared profile (sama untuk semua character)
```

### Migration
Jika Anda upgrade dari versi lama, sistem akan otomatis:
1. Membuat tabel `messages_akane` dan `messages_ayasha`
2. Migrasi pesan lama ke tabel `messages_akane`
3. Menghapus tabel `messages` lama

## API Changes

### DatabaseHelper Methods

#### getMessages()
```dart
// Get messages untuk character saat ini
final messages = await _dbHelper.getMessages();

// Get messages untuk character spesifik
final messages = await _dbHelper.getMessages(
  characterId: 'akane',
  limit: 50,
);
```

#### getMessageCount()
```dart
// Count messages untuk character saat ini
final count = await _dbHelper.getMessageCount();

// Count messages untuk character spesifik
final count = await _dbHelper.getMessageCount(
  characterId: 'ayasha',
);
```

#### cleanOldMessages()
```dart
// Clean old messages untuk character saat ini
await _dbHelper.cleanOldMessages(keepLast: 1000);

// Clean old messages untuk character spesifik
await _dbHelper.cleanOldMessages(
  keepLast: 1000,
  characterId: 'akane',
);
```

## Widget Updates

### ChatAnalyticsWidget
Sekarang menerima parameter `characterId` opsional:

```dart
// Analytics untuk character saat ini
ChatAnalyticsWidget()

// Analytics untuk character spesifik
ChatAnalyticsWidget(characterId: 'ayasha')
```

### DatabaseStatsWidget
Sekarang menerima parameter `characterId` opsional:

```dart
// Stats untuk character saat ini
DatabaseStatsWidget()

// Stats untuk character spesifik
DatabaseStatsWidget(characterId: 'akane')
```

## Settings Screen

Settings screen sekarang:
- Menampilkan nama character di AppBar
- Menampilkan analytics spesifik untuk character yang aktif
- Menampilkan database stats spesifik untuk character yang aktif
- Operasi maintenance (clean, delete) hanya mempengaruhi character yang aktif

### Contoh:
```dart
// Ketika user membuka Settings dengan Akane aktif:
- AppBar: "⚙️ Akane Settings"
- Analytics: Hanya data Akane
- Database Stats: Hanya data Akane
- Clean Old Messages: Hanya pesan Akane

// Ketika user membuka Settings dengan Ayasha aktif:
- AppBar: "⚙️ Ayasha Settings"
- Analytics: Hanya data Ayasha
- Database Stats: Hanya data Ayasha
- Clean Old Messages: Hanya pesan Ayasha
```

## Character Config

Pastikan `character_config.dart` memiliki `id` untuk setiap character:

```dart
class Character {
  final String id;        // 'akane' atau 'ayasha'
  final String name;      // 'Akane' atau 'Ayasha'
  final String avatar;    // '🌸' atau '❄️'
  // ... properties lainnya
}
```

## Usage Examples

### Mendapatkan Analytics untuk Character Spesifik
```dart
// Di dalam build method
ChatAnalyticsWidget(
  characterId: CharacterConfig.current.id,
)
```

### Membersihkan Pesan Lama untuk Character Aktif
```dart
await _dbHelper.cleanOldMessages(
  keepLast: 1000,
  characterId: CharacterConfig.current.id,
);
```

### Menampilkan Stats Database
```dart
DatabaseStatsWidget(
  characterId: CharacterConfig.current.id,
)
```

## Benefits

✅ **Isolated Data**: Setiap character memiliki chat history terpisah
✅ **Independent Analytics**: Analytics tidak tercampur antar character
✅ **Separate Settings**: Preferences bisa berbeda per character
✅ **Cleaner UI**: Settings screen menampilkan data yang relevan
✅ **Better Performance**: Query lebih cepat karena data lebih terorganisir

## Migration Checklist

- [x] Database schema updated
- [x] DatabaseHelper methods updated
- [x] ChatAnalyticsWidget updated
- [x] DatabaseStatsWidget updated
- [x] SettingsScreen updated
- [x] Character-specific table queries implemented
- [x] Backward compatibility maintained

## Notes

- User profile tetap shared (satu profile untuk semua character)
- Backup/restore masih mencakup semua data
- Setiap character memiliki message count terpisah
- Analytics dihitung per character
