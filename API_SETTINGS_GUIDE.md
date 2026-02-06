# 🤖 Panduan API Settings - Chatty

## Overview

Fitur API Settings memungkinkan kamu untuk:
- **Pilih API Provider** (OpenAI, Gemini, Claude, dll)
- **Set API Key** langsung dari aplikasi
- **Offline Mode** untuk LLM lokal
- **Custom Configuration** untuk server lokal
- **Test Connection** sebelum chat

## Cara Mengakses API Settings

1. **Buka aplikasi Chatty**
2. **Tap icon Settings** (⚙️) di chat screen
3. **Pilih "API Configuration"** di bagian API Settings
4. **Configure sesuai kebutuhan**

## 🌐 Online Mode (Cloud API)

### Supported Providers:

#### 1. **🤖 OpenAI GPT**
- **Model**: GPT-3.5-turbo, GPT-4
- **API Key**: Dari OpenAI Platform
- **URL**: https://platform.openai.com/api-keys

#### 2. **💎 Google Gemini**
- **Model**: Gemini-1.5-flash-latest
- **API Key**: Dari Google AI Studio
- **URL**: https://aistudio.google.com/app/apikey

#### 3. **🧠 Anthropic Claude**
- **Model**: Claude-3-haiku
- **API Key**: Dari Anthropic Console
- **URL**: https://console.anthropic.com/

#### 4. **⚡ Groq**
- **Model**: Llama3-8b-8192
- **API Key**: Dari Groq Console
- **URL**: https://console.groq.com/keys

#### 5. **🚀 Novita AI**
- **Model**: Meta-Llama/llama-3.1-8b-instruct
- **API Key**: Dari Novita Dashboard
- **URL**: https://novita.ai/

#### 6. **🌐 OpenRouter**
- **Model**: Meta-Llama/llama-3.1-8b-instruct:free
- **API Key**: Dari OpenRouter
- **URL**: https://openrouter.ai/keys

#### 7. **🔥 Cerebras**
- **Model**: llama3.1-8b
- **API Key**: Dari Cerebras
- **URL**: https://cloud.cerebras.ai/

### Setup Online Mode:

1. **Pilih Provider** dari grid yang tersedia
2. **Masukkan API Key** yang valid
3. **Tap "Test Connection"** untuk validasi
4. **Save Settings** jika test berhasil

## 🏠 Offline Mode (Local LLM)

### Supported Local Servers:

#### 1. **LM Studio**
- Download: https://lmstudio.ai/
- Default URL: `http://localhost:1234/v1/chat/completions`
- Compatible dengan OpenAI API format

#### 2. **Ollama**
- Download: https://ollama.ai/
- Perlu OpenAI-compatible server (ollama-openai-compat)
- Default URL: `http://localhost:11434/v1/chat/completions`

#### 3. **Text Generation WebUI**
- GitHub: https://github.com/oobabooga/text-generation-webui
- Enable OpenAI extension
- Default URL: `http://localhost:5000/v1/chat/completions`

#### 4. **LocalAI**
- GitHub: https://github.com/go-skynet/LocalAI
- OpenAI-compatible API
- Default URL: `http://localhost:8080/v1/chat/completions`

### Setup Offline Mode:

1. **Toggle "Offline Mode"** ON
2. **Masukkan Server URL** (contoh: `http://localhost:1234/v1/chat/completions`)
3. **Set Model Name** (sesuai model yang di-load di server)
4. **Test Connection** untuk memastikan server berjalan
5. **Save Settings**

## 📋 Step-by-Step Setup

### Untuk Pemula (Recommended: Google Gemini)

1. **Buka https://aistudio.google.com/app/apikey**
2. **Login dengan Google account**
3. **Create API Key** (gratis)
4. **Copy API Key**
5. **Buka Chatty → Settings → API Configuration**
6. **Pilih "Google Gemini"**
7. **Paste API Key**
8. **Test Connection**
9. **Save Settings**
10. **Mulai chat dengan Akane!**

### Untuk Advanced User (Local LLM)

1. **Download LM Studio** dari https://lmstudio.ai/
2. **Install dan buka LM Studio**
3. **Download model** (contoh: Llama-3.1-8B-Instruct)
4. **Start Local Server** di LM Studio
5. **Buka Chatty → Settings → API Configuration**
6. **Toggle "Offline Mode" ON**
7. **Set Server URL**: `http://localhost:1234/v1/chat/completions`
8. **Set Model Name**: sesuai model yang di-load
9. **Test Connection**
10. **Save Settings**
11. **Chat offline dengan Akane!**

## ⚙️ Advanced Settings

### Max Tokens
- **Default**: 500 tokens
- **Range**: 100-2000 tokens
- **Fungsi**: Mengatur panjang maksimum response AI
- **Tips**: 500-1000 untuk chat normal, 1000+ untuk response panjang

### Custom URL & Model
- **Fungsi**: Override default settings untuk provider
- **Use Case**: Custom endpoints, self-hosted APIs
- **Format**: Harus OpenAI-compatible

## 🔧 Troubleshooting

### Error: "API Key diperlukan"
- **Solusi**: Masukkan API key yang valid untuk provider yang dipilih
- **Cek**: API key tidak expired dan memiliki quota

### Error: "Test gagal"
- **Solusi**: 
  - Cek koneksi internet (online mode)
  - Cek server lokal berjalan (offline mode)
  - Validasi URL dan API key

### Error: "Local LLM Error"
- **Solusi**:
  - Pastikan server LLM lokal berjalan
  - Cek URL server benar
  - Pastikan model sudah di-load di server

### Response lambat atau timeout
- **Solusi**:
  - Kurangi max tokens
  - Ganti ke provider yang lebih cepat
  - Cek koneksi internet

## 💡 Tips & Best Practices

### Untuk Performance Terbaik:
1. **Gunakan Gemini** untuk response cepat dan gratis
2. **Gunakan GPT-4** untuk kualitas terbaik (berbayar)
3. **Gunakan Local LLM** untuk privacy maksimal

### Untuk Privacy:
1. **Offline mode** = data tidak keluar dari device
2. **API key** disimpan lokal di device
3. **Chat history** tetap lokal di SQLite

### Untuk Cost Efficiency:
1. **Gemini** = gratis dengan quota besar
2. **OpenRouter** = akses model premium dengan harga murah
3. **Local LLM** = gratis setelah setup awal

## 🔒 Security & Privacy

### Data Storage:
- **API Keys**: Disimpan encrypted di SharedPreferences
- **Chat History**: Lokal di SQLite database
- **Settings**: Lokal di device storage

### Network:
- **HTTPS**: Semua API calls menggunakan HTTPS
- **No Logging**: Aplikasi tidak log API keys atau chat content
- **Local First**: Data tidak sync ke cloud

## 🚀 Quick Start Recommendations

### Untuk Coba-Coba (Gratis):
```
Provider: Google Gemini
API Key: Dari aistudio.google.com
Model: gemini-1.5-flash-latest
Max Tokens: 500
```

### Untuk Penggunaan Serius (Berbayar):
```
Provider: OpenAI GPT
API Key: Dari platform.openai.com
Model: gpt-3.5-turbo
Max Tokens: 1000
```

### Untuk Privacy Maksimal (Local):
```
Offline Mode: ON
Server URL: http://localhost:1234/v1/chat/completions
Model: llama-3.1-8b-instruct
Max Tokens: 500
```

## 📱 UI Guide

### Main Settings Screen:
- **Database Stats**: Info real-time database
- **Chat Analytics**: Statistik aktivitas chat
- **API Settings**: Konfigurasi provider & API key
- **Backup & Restore**: Export/import data
- **Maintenance**: Database management

### API Settings Screen:
- **Offline Mode Toggle**: Switch online/offline
- **Provider Grid**: Pilih dari 7+ providers
- **API Key Field**: Input dengan show/hide
- **Local Settings**: URL & model untuk offline
- **Advanced**: Max tokens configuration
- **Action Buttons**: Test & Save

## 🎯 Kesimpulan

Dengan fitur API Settings, kamu punya kontrol penuh atas:
- **Provider Choice**: 7+ options dari gratis sampai premium
- **Privacy Level**: Online vs offline mode
- **Cost Control**: Gratis, freemium, atau premium
- **Performance**: Sesuaikan dengan kebutuhan

**Akane siap chat dengan provider apapun yang kamu pilih!** 🌸✨