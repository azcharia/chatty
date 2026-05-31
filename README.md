# Chatty - AI Companion App 🌸

Aplikasi chat personal dengan Akane, teman virtual yang ceria dan perhatian. Powered by OpenRouter dengan model Owl Alpha untuk percakapan yang natural dan cepat.

## ✨ Fitur Utama

- 🌸 **Akane** - Teman virtual yang ceria, brief, dan natural
- ⏰ **Smart Reminders** - Akane bisa buatkan reminder otomatis
- 🧠 **Massive Memory** - 1M context window untuk percakapan panjang
- ⚡ **OpenRouter + Owl Alpha** - Ultra-fast inference dengan AI terdepan (Free)
- 👤 **User Profile** - Personalisasi pengalaman chat
- 📊 **Analytics & Stats** - Monitor aktivitas chat dan database
- 💾 **Backup & Restore** - Export/import data dengan mudah
- 🧹 **Database Management** - Tools untuk maintenance database
- ⚙️ **Settings Panel** - Kontrol penuh atas aplikasi

## 🆕 Fitur Terbaru v2.0.0

### ⚡ OpenRouter + Owl Alpha Integration (NEW!)
- **Ultra-Fast**: Response instan dengan teknologi OpenRouter routing
- **Massive Context**: 1M tokens = ~800,000 kata memory
- **Advanced AI**: Owl Alpha untuk roleplay dan conversation terbaik
- **Multilingual**: Native support Bahasa Indonesia

### 🌸 Akane Personality Enhanced
- **Brief & Natural**: Respon maksimal 3 kalimat, huruf kecil, minim tanda baca
- **Context Aware**: Manfaatkan 1M context untuk percakapan mendalam
- **Smart Reminders**: Deteksi otomatis permintaan reminder dari chat natural

### ⏰ Smart Reminder System
- **Auto Detection**: Akane otomatis deteksi saat kamu minta reminder
- **Natural Language**: "ingatkan aku meeting besok jam 2" langsung jadi reminder
- **Notification System**: Notifikasi tepat waktu dengan Flutter Local Notifications
- **Reminder Management**: Kelola semua reminder di Settings

### 🧠 Memory System Revolution
- **Massive Context**: 1M tokens untuk percakapan super panjang
- **Long-term Memory**: **Unlimited** chat history tersimpan di database
- **Context Continuity**: Akane ingat detail dari ribuan pesan sebelumnya

### 📊 Analytics & Monitoring
- **Database Stats**: Monitor ukuran database dan jumlah pesan real-time
- **Chat Analytics**: Statistik lengkap aktivitas chat (total pesan, kata, jam aktif, dll)
- **Memory Usage**: Indikator penggunaan storage dengan progress bar

### 💾 Backup & Restore System
- **Export Data**: Simpan semua chat & profile ke file JSON
- **Share Backup**: Bagikan file backup dengan mudah
- **Import Data**: Restore data dari file backup

### 🧹 Database Management
- **Clean Old Messages**: Hapus pesan lama, simpan 1000 terakhir
- **Clear All Data**: Reset aplikasi (dengan konfirmasi)
- **Database Info**: Monitor ukuran dan performa database

### ⚙️ Enhanced Settings Panel
- **API Configuration**: Setup provider dan API key
- **Offline Mode Toggle**: Switch antara online/offline
- **Real-time Stats**: Informasi database dan analytics terintegrasi
- **Easy Access**: Tombol settings di chat screen

## Setup & Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd chatty
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

```bash
flutter packages pub run build_runner build
```

### 4. Setup API (Pilih salah satu)

### Option Option A: Setup dari Aplikasi (Recommended)
1. Run aplikasi: `flutter run`
2. Buka Settings → API Configuration
3. Pilih provider dan masukkan API key
4. Test connection dan save

#### Option B: Edit File (Manual)
Edit file `lib/services/llm_service.dart` dan ganti `YOUR_OPENROUTER_API_KEY_HERE` dengan API key kamu.

### 5. Run App

```bash
flutter run
```

## Struktur Project

```
lib/
├── config/           # API & Character configuration
├── models/           # Data models
├── services/         # API & Database services
├── providers/        # State management
├── screens/          # UI screens
├── widgets/          # Reusable widgets
└── main.dart        # Entry point

docs/
├── README.md                    # Dokumentasi utama
├── SETUP_GUIDE.md              # Panduan setup API
├── DATABASE_GUIDE.md           # Penjelasan database & memory
├── AKANE_CHARACTER_GUIDE.md    # Panduan karakter Akane
├── API_PROVIDERS_GUIDE.md      # Panduan semua API providers
└── API_SETTINGS_GUIDE.md       # Panduan API settings in-app
```

## Cara Menggunakan

### 1. Setup Profile
- Buka aplikasi dan chat dengan Akane
- Ceritakan tentang diri kamu (nama, hobi, rutinitas)
- Akane akan otomatis menyimpan info tentang kamu

### 2. Chat Natural
- Chat seperti dengan teman biasa
- Akane akan ingat percakapan sebelumnya
- Gunakan konteks dari chat lama

### 3. Monitor Stats
- Buka Settings → Lihat Database Stats & Analytics
- Monitor penggunaan memory dan aktivitas chat
- Export data untuk backup

### 4. Backup Data
- Settings → Export Data untuk backup
- Share Backup untuk berbagi dengan device lain
- Import Data untuk restore backup

## Memory System

### Short-term Memory (50 pesan)
Akane membaca 50 pesan terakhir setiap kali merespons, memberikan konteks percakapan yang panjang.

### Long-term Memory (Unlimited)
Semua chat history tersimpan permanent di SQLite database lokal.

### Profile Memory
Info personal kamu (nama, hobi, rutinitas) tersimpan dan digunakan untuk personalisasi response.

## Database

Menggunakan **SQLite** untuk penyimpanan lokal:
- **Tabel messages**: Semua chat history
- **Tabel user_profile**: Info personal user
- **Kapasitas**: Praktis unlimited (terbatas storage device)
- **Performance**: <10ms untuk read/write
- **Privacy**: Data tersimpan lokal, tidak di cloud

## API Support

Powered by:
- **OpenRouter API** - Akses ke ratusan model dalam satu endpoint
- **Owl Alpha** - State-of-the-art conversational & agentic AI (Free)
- **1M Context Window** - Massive memory untuk percakapan panjang

## Tech Stack

- **Framework**: Flutter 3.29.3
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **HTTP Client**: http package
- **File Sharing**: share_plus
- **JSON Serialization**: json_annotation + build_runner

## Changelog

### v2.0.0 (Latest)
- ✅ OpenRouter API integration dengan Owl Alpha model
- ✅ 1M context window untuk massive memory
- ✅ Ultra-fast response
- ✅ Enhanced multilingual support
- ✅ Simplified API configuration
- ✅ Optimized untuk conversational AI

### v1.2.0
- ✅ Dynamic API settings in-app
- ✅ Multiple API providers support
- ✅ API key management dengan UI
- ✅ Test connection feature

### v1.1.0
- ✅ Memory system upgrade
- ✅ Database analytics & monitoring
- ✅ Backup & restore system
- ✅ Settings panel dengan real-time stats

### v1.0.0
- ✅ Basic chat functionality
- ✅ Akane character implementation
- ✅ SQLite database integration
- ✅ Profile management

## Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License - Lihat file LICENSE untuk detail.

## Support

Jika ada pertanyaan atau masalah:
1. Baca dokumentasi di folder `docs/`
2. Check existing issues
3. Create new issue dengan detail lengkap

---

**Chatty v2.0.0** - AI Companion powered by OpenRouter + Owl Alpha dengan 1M Context Window 🌸⚡