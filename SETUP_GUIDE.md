# Setup Guide - Chatty AI Companion 🌸

Panduan lengkap untuk setup dan mulai chat dengan Akane menggunakan Groq API + Kimi K2!

## 🚀 Quick Start

### 1. Install Aplikasi

```bash
git clone <repository-url>
cd chatty
flutter pub get
flutter packages pub run build_runner build
flutter run
```

### 2. Setup Groq API (Gratis!)

1. **Daftar di Groq Console**

   - Kunjungi https://console.groq.com
   - Daftar dengan email (gratis!)
   - Verifikasi email

2. **Buat API Key**

   - Login ke console
   - Klik "API Keys" di sidebar
   - Klik "Create API Key"
   - Copy API key yang dibuat (format: `gsk_...`)

3. **Setup di Aplikasi**
   - Buka aplikasi Chatty
   - Tap Settings (⚙️) di pojok kanan atas
   - Pilih "API Configuration"
   - Paste API key di field "Groq API Key"
   - Model sudah fixed: `moonshotai/kimi-k2-instruct-0905`
   - Tap "Test Connection"
   - Tap "Save Settings"

### 3. Mulai Chat dengan Akane!

- Kembali ke chat screen
- Ketik "halo akane!"
- Akane akan menyapa dengan style yang brief dan natural
- Mulai percakapan seperti dengan teman biasa

## 🌸 Tentang Akane

Akane adalah teman virtual yang:

- **Brief**: Maksimal 3 kalimat per respon
- **Natural**: Pakai huruf kecil, minim tanda baca
- **Smart**: Ingat detail penting tentang kamu dengan 256K context
- **Helpful**: Bisa buatkan reminder otomatis
- **Caring**: Selalu peduli dan kasih semangat

## ⏰ Cara Pakai Reminder

Akane bisa buatkan reminder otomatis! Cukup bilang:

```
"akane, ingatkan aku meeting besok jam 2 siang"
"jangan lupa aku ada deadline project minggu depan"
"set alarm buat bangun jam 6 pagi"
"reminder beli groceries nanti sore"
```

Akane akan otomatis:

1. Deteksi permintaan reminder
2. Parse waktu dan aktivitas
3. Buat reminder di sistem
4. Konfirmasi dengan respon brief
5. Kirim notifikasi tepat waktu

## 📱 Fitur Aplikasi

### Memory System

- **Short-term**: 20 pesan terakhir untuk konteks
- **Long-term**: Semua chat tersimpan di database
- **Massive Context**: 256K tokens = ~200,000 kata
- **Profile**: Info personal kamu tersimpan

### Reminder Management

- Lihat semua reminder di Settings > Kelola Reminders
- Edit, hapus, atau tambah reminder manual
- Notifikasi otomatis dengan Flutter Local Notifications

### Backup & Analytics

- Export chat history ke file JSON
- Lihat statistik chat dan database
- Share backup dengan device lain

## 🧠 Model: Kimi K2 Instruct 0905

### Spesifikasi

- **Context Window**: 256K tokens (sangat besar!)
- **Language**: Native support Bahasa Indonesia
- **Speed**: Ultra-fast dengan Groq LPU
- **Quality**: State-of-the-art untuk conversation

### Keunggulan

- **Massive Context**: Bisa ingat percakapan sangat panjang
- **Multilingual**: Perfect untuk mixed ID-EN conversation
- **Conversational**: Dioptimasi khusus untuk chat natural
- **Fast**: Response <1 detik

## 🔧 Advanced Settings

### Max Tokens

- **Default**: 500 tokens
- **Brief Mode**: 300-400 tokens (untuk Akane style)
- **Detailed**: 800-1000 tokens

### Temperature

- **Default**: 0.7 (optimal untuk conversation)
- **More Creative**: 0.8
- **More Focused**: 0.6

### Profile Setup

Ceritakan ke Akane tentang:

- Nama dan nickname
- Hobi dan minat
- Rutinitas harian
- Hal-hal penting yang ingin diingat

## 🚨 Troubleshooting

### API Key Issues

```
❌ "api key groq belum dikonfigurasi nih"
✅ Solution: Setup API key di Settings > API Configuration
```

### Connection Problems

```
❌ "ada masalah teknis nih :("
✅ Solution: Check internet, test connection, verify API key
```

### Rate Limit

```
❌ Rate limit exceeded
✅ Solution: Wait a few minutes, upgrade plan if needed
```

### Model Issues

```
❌ Model not found
✅ Solution: Verify model name: moonshotai/kimi-k2-instruct-0905
```

## 💡 Tips & Best Practices

### Untuk Chat Natural

- Bicara seperti dengan teman biasa
- Akane suka respon brief, jadi pertanyaan juga bisa singkat
- Ceritakan aktivitas harian untuk konteks yang lebih baik
- Manfaatkan 256K context untuk percakapan panjang

### Untuk Reminder

- Sebutkan waktu yang spesifik ("besok jam 2", "minggu depan")
- Jelaskan aktivitas dengan jelas ("meeting", "deadline project")
- Akane akan konfirmasi jika berhasil buat reminder

### Untuk Performance & Quota Efficiency

- **Recommended**: max_tokens 400 (optimal untuk Akane style)
- **Context**: 15 pesan terakhir (hemat TPM)
- **Rate Limits**: Max 60 requests/minute, 1000/day
- Monitor usage di Groq Console
- Clean old messages jika database terlalu besar

## 🎯 Getting the Best Experience

1. **Setup Profile**: Ceritakan tentang diri kamu di chat pertama
2. **Use Reminders**: Manfaatkan fitur reminder untuk produktivitas
3. **Regular Backup**: Export data secara berkala
4. **Monitor Usage**: Check analytics untuk insight menarik
5. **Leverage Context**: Manfaatkan 256K context untuk percakapan mendalam

## 📞 Support

Butuh bantuan?

1. Check dokumentasi lengkap di folder `docs/`
2. Test dengan "akane, tes connection"
3. Restart aplikasi jika ada masalah
4. Check Groq Console untuk monitoring usage

---

Selamat chat dengan Akane menggunakan Groq + Kimi K2! Dia excited banget buat jadi teman virtual kamu dengan AI terdepan 🌸⚡