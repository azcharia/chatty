class ApiConfig {
  // Default API key - akan di-override dari settings
  static const String defaultApiKey = 'YOUR_GROQ_API_KEY_HERE';

  // Fixed Groq configuration
  static const String baseUrl = 'https://api.groq.com/openai/v1';
  static const String model = 'moonshotai/kimi-k2-instruct-0905';
  static const int defaultMaxTokens = 500;
  static const double defaultTemperature = 0.7;

  // Model info
  static const String modelName = 'Kimi K2 Instruct 0905';
  static const String modelDescription =
      '🌙 Moonshot AI - 256K context, ultra-fast conversation';
  static const int contextWindow = 256000; // 256K tokens

  // Rate Limits (Kimi K2 Instruct 0905)
  static const int rateLimitRPM = 60; // Requests per minute
  static const int rateLimitRPD = 1000; // Requests per day
  static const int rateLimitTPM = 10000; // Tokens per minute
  static const int rateLimitTPD = 300000; // Tokens per day

  // Recommended settings untuk optimal usage
  static const int recommendedMaxTokens =
      400; // Hemat quota, cukup untuk Akane style
  static const int recommendedContextMessages = 15; // Hemat TPM
}

// Simplified Groq settings
class GroqSettings {
  final String apiKey;
  final int maxTokens;
  final double temperature;

  const GroqSettings({
    required this.apiKey,
    this.maxTokens = ApiConfig.defaultMaxTokens,
    this.temperature = ApiConfig.defaultTemperature,
  });

  // Helper methods
  String get baseUrl => ApiConfig.baseUrl;
  String get model => ApiConfig.model;
  String get authHeader => 'Bearer $apiKey';

  Map<String, String> get headers => {
    'Authorization': authHeader,
    'Content-Type': 'application/json',
  };
}
