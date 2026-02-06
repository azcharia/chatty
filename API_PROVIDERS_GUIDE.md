# Groq API Guide - Chatty AI Companion 🌸

Panduan lengkap untuk setup dan optimasi Groq API dengan model Kimi K2 untuk chat dengan Akane.

## 🚀 Mengapa Groq + Kimi K2?

Chatty menggunakan **Groq** dengan model **Kimi K2 Instruct 0905** karena:

- **⚡ Lightning Fast**: Inference speed tercepat di dunia dengan Groq LPU
- **🧠 Advanced Model**: Kimi K2 dengan 256K context window
- **🆓 Generous Free Tier**: API key gratis dengan quota besar
- **🌐 Multilingual**: Excellent support untuk Bahasa Indonesia
- **🔒 Reliable**: High uptime dan stability
- **💰 Cost Effective**: Harga sangat kompetitif

## 📋 Setup Groq API

### 1. Daftar Account

1. **Kunjungi Groq Console**
   ```
   https://console.groq.com
   ```

2. **Sign Up**
   - Klik "Sign Up" 
   - Masukkan email dan password
   - Verifikasi email

3. **Login ke Console**
   - Login dengan credentials
   - Akan masuk ke Groq Console Dashboard

### 2. Buat API Key

1. **Navigate ke API Keys**
   - Di sidebar kiri, klik "API Keys"
   - Atau langsung ke https://console.groq.com/keys

2. **Create New Key**
   - Klik "Create API Key"
   - Beri nama key (misal: "Chatty App")
   - Copy API key yang dibuat
   - **PENTING**: Simpan key ini, tidak bisa dilihat lagi!

3. **Verify Key**
   - Key format: `gsk_...` (Groq Secret Key)
   - Pastikan key tersimpan aman

### 3. Setup di Chatty

1. **Buka Aplikasi**
   - Launch Chatty app
   - Tap Settings (⚙️) di pojok kanan atas

2. **Masuk ke API Settings**
   - Pilih "API Configuration"
   - Akan muncul form setup

3. **Input API Key**
   - Paste API key di field "Groq API Key"
   - Key akan di-obscure untuk keamanan

4. **Model Selection**
   - Model sudah fixed: `moonshotai/kimi-k2-instruct-0905`
   - Tidak perlu pilih model lain

5. **Set Parameters**
   - Max Tokens: 500 (default)
   - Temperature: 0.7 (optimal untuk Akane)

6. **Test & Save**
   - Tap "Test Connection" untuk verify
   - Jika berhasil, tap "Save Settings"

## 🧠 Model: Kimi K2 Instruct 0905

### Spesifikasi Model

```
Model: moonshotai/kimi-k2-instruct-0905
Context Window: 256K tokens (sangat besar!)
Best for: Conversational AI, multilingual chat
Speed: Ultra-fast dengan Groq LPU
Quality: State-of-the-art untuk conversation
Cost: Very competitive
Perfect for: Akane's natural & brief style
```

### Keunggulan Kimi K2

- **Massive Context**: 256K tokens = ~200,000 kata
- **Multilingual**: Native support Bahasa Indonesia
- **Conversational**: Dioptimasi untuk chat natural
- **Fast Inference**: <1 detik response time
- **Consistent**: Output yang stabil dan reliable

## ⚙️ Optimization Settings

### Untuk Akane Style (Brief & Natural)

```
Model: moonshotai/kimi-k2-instruct-0905 (FIXED)
Max Tokens: 300-500
Temperature: 0.7 (default)
Context: 20 pesan terakhir
```

**Mengapa Setting Ini:**
- Kimi K2 perfect untuk conversational AI
- Max tokens 300-500 = respon brief tapi complete
- Temperature 0.7 = natural tapi konsisten
- Context 20 pesan = cukup untuk continuity

### Untuk Detailed Conversations

```
Max Tokens: 800-1000
Temperature: 0.6 (lebih fokus)
Context: 30 pesan terakhir
```

### Untuk Creative Tasks

```
Max Tokens: 1000-1500
Temperature: 0.8 (lebih kreatif)
Context: Full available
```

## 📊 Usage & Monitoring

### Free Tier Limits

- **Requests**: 30/minute, 14,400/day
- **Tokens**: Generous limits untuk daily usage
- **Models**: Access ke semua models termasuk Kimi K2
- **Rate Limits**: Sangat reasonable untuk personal use

### Best Practices

1. **Monitor Usage**: Check console dashboard regularly
2. **Optimize Tokens**: Set max_tokens sesuai kebutuhan
3. **Efficient Context**: Gunakan 20 pesan untuk daily chat
4. **Cache Responses**: App automatically handles this

### Cost Optimization

- Kimi K2 sudah sangat cost-effective
- Set max_tokens sesuai kebutuhan (300-500 untuk Akane)
- Monitor usage di Groq Console
- Upgrade ke paid plan jika perlu lebih banyak requests

## 🚨 Troubleshooting

### Common Issues

#### 1. API Key Invalid
```
Error: "api key groq belum dikonfigurasi nih"
```
**Solutions:**
- Verify API key format (starts with `gsk_`)
- Check if key is active in console
- Regenerate key if needed

#### 2. Connection Timeout
```
Error: "ada masalah teknis nih :("
```
**Solutions:**
- Check internet connection
- Verify Groq service status
- Try reducing max_tokens
- Check API key permissions

#### 3. Rate Limit Exceeded
```
Error: Rate limit exceeded
```
**Solutions:**
- Wait a few minutes
- Upgrade to paid plan
- Optimize request frequency

#### 4. Model Not Available
```
Error: Model not found
```
**Solutions:**
- Verify model name: `moonshotai/kimi-k2-instruct-0905`
- Check model availability in console
- Contact Groq support if persistent

### Debug Steps

1. **Test Connection**
   - Use "Test Connection" button
   - Check response in app logs

2. **Verify Settings**
   - Confirm API key is correct
   - Check model name spelling
   - Verify max_tokens range

3. **Check Console**
   - Login to Groq Console
   - Check API usage
   - Verify account status

## 🔒 Security Best Practices

### API Key Management

- **Never share** API key publicly
- **Store securely** in app only
- **Rotate regularly** for security
- **Monitor usage** for anomalies

### App Security

- API key encrypted in app storage
- No key transmission to third parties
- Local database for chat history
- No cloud sync of sensitive data

## 📈 Performance Tips

### For Best Speed & Efficiency

1. Use **max_tokens: 300-500** for brief responses
2. Keep **conversation history** reasonable (20 messages)
3. **Test connection** before important chats
4. Monitor **response times** in console

### Rate Limits & Quota Management

**Kimi K2 Instruct 0905 Limits:**
- **RPM**: 60 requests per minute
- **RPD**: 1,000 requests per day
- **TPM**: 10,000 tokens per minute  
- **TPD**: 300,000 tokens per day

**Daily Usage Estimates:**
- **Light Usage** (30 messages): ~12,000 tokens
- **Moderate Usage** (100 messages): ~40,000 tokens
- **Heavy Usage** (200 messages): ~80,000 tokens
- **Max Theoretical**: 300,000 tokens/day

**Optimized Settings (Recommended):**
- **Max Tokens**: 400 (hemat quota, cukup untuk Akane style)
- **Context Messages**: 15 (hemat TPM)
- **Temperature**: 0.6 (optimal balance)

**Tips Hemat Quota:**
- Gunakan max_tokens 400 untuk daily chat
- Batasi context ke 15 pesan terakhir
- Monitor usage di Groq Console
- Hindari spam requests (max 60/minute)

### For Best Quality

1. Use **clear, specific prompts**
2. Provide **relevant context** in messages
3. **Iterate** on prompts for optimization
4. Leverage **256K context window** untuk long conversations

## 🆕 Latest Updates

### Kimi K2 Improvements
- Enhanced multilingual capabilities
- Better Indonesian language support
- Improved context understanding
- Faster inference speeds

### Groq Platform Features
- Enhanced error handling
- Better rate limiting
- Improved monitoring tools
- New model releases

## 📞 Support

### Groq Support
- Documentation: https://console.groq.com/docs
- Support: Via console support chat
- Status: https://status.groq.com

### Chatty App Support
- Check app documentation
- Test with simple messages
- Restart app if issues persist
- Report bugs with detailed logs

---

Happy chatting dengan Akane menggunakan Groq + Kimi K2! 🌸⚡