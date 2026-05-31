import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/character_config.dart';
import '../services/llm_service.dart';

class OpenRouterSettingsScreen extends StatefulWidget {
  const OpenRouterSettingsScreen({super.key});

  @override
  State<OpenRouterSettingsScreen> createState() => _OpenRouterSettingsScreenState();
}

class _OpenRouterSettingsScreenState extends State<OpenRouterSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _tavilyApiKeyController = TextEditingController();
  final TextEditingController _maxTokensController = TextEditingController();
  final LLMService _llmService = LLMService();

  bool _isLoading = false;
  bool _obscureApiKey = true;
  bool _obscureTavilyApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _tavilyApiKeyController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final currentCharacter = CharacterConfig.current;

    if (mounted) {
      setState(() {
        _apiKeyController.text =
            prefs.getString(currentCharacter.apiKeyPref) ?? '';
        _tavilyApiKeyController.text =
            prefs.getString('tavily_api_key') ?? '';
        _maxTokensController.text =
            prefs.getInt('max_tokens')?.toString() ??
            ApiConfig.recommendedMaxTokens.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCharacter = CharacterConfig.current;
      await prefs.setString(
        currentCharacter.apiKeyPref,
        _apiKeyController.text,
      );
      await prefs.setString(
        'tavily_api_key',
        _tavilyApiKeyController.text,
      );
      await prefs.setInt(
        'max_tokens',
        int.tryParse(_maxTokensController.text) ??
            ApiConfig.recommendedMaxTokens,
      );

      // Update LLM service
      await _llmService.setApiKey(_apiKeyController.text);

      _showSnackBar('✅ Settings berhasil disimpan!');
    } catch (e) {
      _showSnackBar('❌ Gagal menyimpan settings: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);

    try {
      // Save settings first
      await _saveSettings();

      // Basic validation
      if (_apiKeyController.text.isEmpty ||
          _apiKeyController.text == 'YOUR_OPENROUTER_API_KEY_HERE') {
        _showSnackBar('❌ API Key OpenRouter diperlukan', isError: true);
        return;
      }

      if (!_apiKeyController.text.startsWith('sk-or-')) {
        _showSnackBar('❌ API Key harus dimulai dengan "sk-or-"', isError: true);
        return;
      }

      // Test actual API call
      final success = await _testOpenRouterAPI();

      if (success) {
        _showSnackBar('✅ Koneksi berhasil! Siap chat dengan ${CharacterConfig.current.name}!');
      } else {
        _showSnackBar(
          '❌ Test gagal. Periksa API key dan coba lagi.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('❌ Test gagal: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _testOpenRouterAPI() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/chat/completions');

      final requestBody = {
        'model': ApiConfig.model,
        'messages': [
          {'role': 'user', 'content': 'Hello, test connection'},
        ],
        'max_completion_tokens': 50,
        'temperature': 0.7,
        'stream': false,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${_apiKeyController.text}',
          'HTTP-Referer': 'https://github.com/user/chatty',
          'X-OpenRouter-Title': 'Chatty - AI Companion',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      developer.log(
        'Test API Response: ${response.statusCode}',
        name: 'OpenRouterSettings',
      );
      developer.log('Test API Body: ${response.body}', name: 'OpenRouterSettings');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'] != null && data['choices'].isNotEmpty;
      } else {
        developer.log(
          'API Error: ${response.statusCode} - ${response.body}',
          name: 'OpenRouterSettings',
        );
        return false;
      }
    } catch (e) {
      developer.log('Test API Exception: $e', name: 'OpenRouterSettings');
      return false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚡ ${CharacterConfig.current.name} API Settings'),
        backgroundColor: Colors.purple.shade100,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Info Card
                    Card(
                      color: Colors.purple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.psychology,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Model Information',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '🤖 ${ApiConfig.modelName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ApiConfig.modelDescription,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Context Window: ${ApiConfig.contextWindow.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} tokens',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ Rate Limits:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '• ${ApiConfig.rateLimitRPM} requests/minute\n'
                                    '• ~${ApiConfig.rateLimitRPD} requests/day\n'
                                    '• ${ApiConfig.rateLimitTPM.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} tokens/minute\n'
                                    '• ${ApiConfig.rateLimitTPD.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} tokens/day',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // API Key Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.key, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'OpenRouter API Key',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _apiKeyController,
                              obscureText: _obscureApiKey,
                              decoration: InputDecoration(
                                labelText: 'API Key',
                                hintText: 'sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxx',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureApiKey
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () => _obscureApiKey = !_obscureApiKey,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tavily API Key Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.search, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Tavily API Key (Realtime Search)',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _tavilyApiKeyController,
                              obscureText: _obscureTavilyApiKey,
                              decoration: InputDecoration(
                                labelText: 'Tavily API Key',
                                hintText: 'tvly-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                                border: const OutlineInputBorder(),
                                helperText: 'Digunakan untuk realtime web search (opsional)',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureTavilyApiKey
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () => _obscureTavilyApiKey = !_obscureTavilyApiKey,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Settings Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Settings',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _maxTokensController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Tokens',
                                hintText: '500',
                                border: OutlineInputBorder(),
                                helperText:
                                    'Maksimal token untuk response (100-2000)',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _testConnection,
                            icon: const Icon(Icons.wifi_tethering),
                            label: const Text('Test Connection'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveSettings,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Settings'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Setup Guide',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '1. Daftar gratis di https://openrouter.ai\n'
                              '2. Buat API key di menu Dashboard -> Keys\n'
                              '3. Copy API key (format: sk-or-v1-...)\n'
                              '4. Paste di field API Key di atas\n'
                              '5. Test connection dan save settings\n'
                              '6. Mulai chat dengan Akane!',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Debug Info Card
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bug_report,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Debug Info',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Model: ${ApiConfig.model}\n'
                              'Base URL: ${ApiConfig.baseUrl}\n'
                              'API Key Format: ${_apiKeyController.text.isNotEmpty ? (_apiKeyController.text.startsWith('sk-or-') ? '✅ Valid' : '❌ Invalid (harus dimulai dengan sk-or-)') : '❌ Empty'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
