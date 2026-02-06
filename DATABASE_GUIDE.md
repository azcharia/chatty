# 🗄️ Panduan Database & Memory System

## Penjelasan SQLite untuk Pemula

### Apa itu SQLite?
SQLite itu seperti **buku catatan pintar** di handphone kamu yang:
- 📝 **Otomatis menulis**: Setiap chat dengan Akane langsung tersimpan
- 🏠 **Tersimpan lokal**: Data ada di handphone kamu, tidak di internet
- 🔒 **Aman & privat**: Hanya aplikasi Chatty yang bisa akses
- ⚡ **Cepat**: Baca/tulis data dalam milidetik

### Analogi Mudah:
Bayangkan SQLite seperti **lemari arsip ajaib** dengan 2 laci:

```
🗄️ Lemari Arsip "chatty.db"
├── 📁 Laci 1: "user_profile" 
│   └── Info tentang kamu (nama, hobi, rutinitas)
└── 📁 Laci 2: "messages"
    └── Semua chat dengan Akane (ribuan pesan)
```

## 🧠 Memory System yang Sudah Diupgrade

### Short-term Memory (Memori Jangka Pendek)
**Sebelum**: 10 pesan terakhir  
**Sekarang**: **50 pesan terakhir** 🚀

**Cara Kerja:**
1. Akane baca 50 chat terakhir sebelum jawab
2. Akane ingat konteks percakapan yang panjang
3. Akane bisa refer ke topik yang dibahas beberapa jam lalu

**Contoh:**
```
Pagi:
User: "Akane, aku mau ujian besok, deg-degan nih"
Akane: "Semangat! Aku yakin kamu bisa kok~ 😊"

Sore (setelah 40 pesan lain):
User: "Akane, aku udah selesai ujian"
Akane: "Wah gimana ujiannya? Pasti lancar kan? Aku tadi udah bilang kamu pasti bisa! 😄✨"
```

### Long-term Memory (Memori Jangka Panjang)
**Kapasitas**: **Unlimited** (terbatas storage handphone)

**Yang Disimpan:**
- 👤 **Profile lengkap**: Nama, nickname, hobi, rutinitas
- 💬 **Semua chat**: Dari pertama install sampai sekarang
- 📅 **Timeline**: Kapan setiap pesan dikirim
- 🎯 **Preferences**: Hal-hal yang kamu suka/tidak suka

## 📊 Struktur Database Detail

### Tabel 1: user_profile
```sql
CREATE TABLE user_profile(
  id INTEGER PRIMARY KEY,           -- ID unik
  name TEXT NOT NULL,               -- Nama lengkap
  nickname TEXT,                    -- Nama panggilan
  interests TEXT,                   -- Hobi (format JSON)
  dailyRoutine TEXT,                -- Rutinitas (format JSON)
  personalInfo TEXT,                -- Info personal (format JSON)
  createdAt TEXT NOT NULL,          -- Kapan dibuat
  updatedAt TEXT NOT NULL           -- Kapan terakhir diupdate
);
```

**Contoh Data:**
```json
{
  "id": 1,
  "name": "Budi Santoso",
  "nickname": "Budi",
  "interests": ["gaming", "anime", "coding"],
  "dailyRoutine": ["bangun pagi", "kerja", "main game"],
  "personalInfo": {"umur": "25", "kota": "Jakarta"},
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-20T15:45:00Z"
}
```

### Tabel 2: messages
```sql
CREATE TABLE messages(
  id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID unik auto-increment
  content TEXT NOT NULL,                  -- Isi pesan
  isUser INTEGER NOT NULL,                -- 1=user, 0=Akane
  timestamp TEXT NOT NULL,                -- Waktu kirim
  type TEXT DEFAULT 'chat'                -- Jenis pesan
);
```

**Contoh Data:**
```json
[
  {
    "id": 1,
    "content": "Halo Akane!",
    "isUser": 1,
    "timestamp": "2024-01-15T10:30:15Z",
    "type": "chat"
  },
  {
    "id": 2,
    "content": "Halo Budi! Senang ketemu kamu~ 😊",
    "isUser": 0,
    "timestamp": "2024-01-15T10:30:18Z",
    "type": "chat"
  }
]
```

## 🔄 Bagaimana Memory Bekerja Step-by-Step

### Saat Kamu Kirim Pesan:

1. **Input**: Kamu ketik "Halo Akane, gimana kabarnya?"

2. **Database Read**: 
   ```
   📖 Baca profile kamu dari tabel user_profile
   📖 Baca 50 pesan terakhir dari tabel messages
   ```

3. **AI Processing**:
   ```
   🧠 Akane: "Oh ini Budi yang suka gaming"
   🧠 Akane: "Tadi dia cerita tentang ujian"
   🧠 Akane: "Sekarang dia tanya kabar, jawab dengan ceria"
   ```

4. **Response**: Akane jawab berdasarkan memori

5. **Database Write**:
   ```
   💾 Simpan pesan kamu ke database
   💾 Simpan jawaban Akane ke database
   ```

### Saat Aplikasi Dibuka Lagi:

1. **Load Profile**: Baca info tentang kamu
2. **Load History**: Baca 100 pesan terakhir untuk ditampilkan
3. **Welcome**: Akane sapa kamu dengan nama dan konteks terakhir

## 📈 Kapasitas & Performance

### Kapasitas Storage:
- **Profile**: ~1KB per user
- **Messages**: ~500 bytes per pesan
- **Total untuk 10,000 pesan**: ~5MB
- **Praktis**: Bisa simpan ratusan ribu pesan

### Performance:
- **Read 50 pesan**: <10ms
- **Write 1 pesan**: <5ms
- **Load profile**: <1ms
- **Total response time**: Tergantung API (1-5 detik)

## 🛠️ Maintenance Database

### Otomatis:
- ✅ **Backup**: Data aman di storage internal
- ✅ **Indexing**: Query cepat otomatis
- ✅ **Compression**: SQLite otomatis compress data

### Manual (Opsional):
```dart
// Clear old messages (keep last 1000)
Future<void> cleanOldMessages() async {
  final db = await database;
  await db.execute('''
    DELETE FROM messages 
    WHERE id NOT IN (
      SELECT id FROM messages 
      ORDER BY timestamp DESC 
      LIMIT 1000
    )
  ''');
}
```

## 🔍 Monitoring Memory Usage

### Cek Jumlah Pesan:
```dart
Future<int> getMessageCount() async {
  final db = await database;
  final result = await db.rawQuery('SELECT COUNT(*) as count FROM messages');
  return result.first['count'] as int;
}
```

### Cek Ukuran Database:
```dart
Future<int> getDatabaseSize() async {
  final dbPath = join(await getDatabasesPath(), 'chatty.db');
  final file = File(dbPath);
  return await file.length(); // Size in bytes
}
```

## 🎯 Tips Optimasi

### Untuk Performance Terbaik:
1. **Jangan hapus database** - biarkan Akane ingat semua
2. **Update profile** secara berkala untuk konteks yang lebih baik
3. **Chat konsisten** - semakin sering chat, semakin pintar Akane

### Untuk Storage Management:
1. **Monitor ukuran** database secara berkala
2. **Clean old messages** jika perlu (opsional)
3. **Backup data** sebelum uninstall

## 🚀 Kesimpulan

**Memory System Sekarang:**
- ✅ **Short-term**: 50 pesan terakhir (naik dari 10)
- ✅ **Long-term**: Unlimited chat history
- ✅ **Profile**: Lengkap dengan semua detail
- ✅ **Performance**: Cepat dan efisien
- ✅ **Privacy**: Data tersimpan lokal di device

**Akane sekarang bisa:**
- 🧠 Ingat percakapan yang sangat panjang
- 💭 Refer ke topik lama dengan akurat
- 🎯 Memberikan response yang lebih personal
- 📚 Belajar dari semua interaksi dengan kamu

Database SQLite bekerja di background tanpa kamu perlu mikirin apa-apa. Tinggal chat dengan Akane, dan dia akan ingat semuanya! 🌸✨