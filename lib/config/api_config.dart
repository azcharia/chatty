class ApiConfig {
  // Default API key - akan di-override dari settings
  static const String defaultApiKey = 'YOUR_OPENROUTER_API_KEY_HERE';

  // Fixed OpenRouter configuration
  static const String baseUrl = 'https://openrouter.ai/api/v1';
  static const String model = 'openrouter/owl-alpha';
  static const int defaultMaxTokens = 500;
  static const double defaultTemperature = 0.7;

  // Model info
  static const String modelName = 'Owl Alpha';
  static const String modelDescription =
      '🦉 Owl Alpha - 1M context, high-performance foundation model for agentic workloads (Free)';
  static const int contextWindow = 1000000; // 1M tokens

  // Rate Limits (Typical OpenRouter Free Tier limits)
  static const int rateLimitRPM = 20; // Requests per minute
  static const int rateLimitRPD = 200; // Requests per day (Estimated for free tiers)
  static const int rateLimitTPM = 80000; // Tokens per minute
  static const int rateLimitTPD = 500000; // Tokens per day

  // Recommended settings untuk optimal usage
  static const int recommendedMaxTokens =
      400; // Hemat quota, cukup untuk Akane style
  static const int recommendedContextMessages = 15; // Hemat TPM
}

// Simplified OpenRouter settings
class OpenRouterSettings {
  final String apiKey;
  final int maxTokens;
  final double temperature;

  const OpenRouterSettings({
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
    'HTTP-Referer': 'https://github.com/user/chatty', // Optional site URL for OpenRouter
    'X-OpenRouter-Title': 'Chatty - AI Companion', // Optional site title for OpenRouter
    'Content-Type': 'application/json',
  };
}
