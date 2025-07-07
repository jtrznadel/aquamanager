class ApiConfig {
  // Environment-based configuration
  static const String _localBaseUrl = 'http://localhost:3000';
  static const String _productionBaseUrl =
      'https://your-ec2-instance.com'; // Update with actual URL

  // Determine environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  // Base URL based on environment
  static String get baseUrl =>
      isProduction ? _productionBaseUrl : _localBaseUrl;

  // API endpoints
  static String get apiUrl => '$baseUrl/api';

  // Specific endpoints
  static String get aquariumsEndpoint => '$apiUrl/aquariums';
  static String get fishEndpoint => '$apiUrl/fish';
  static String get tasksEndpoint => '$apiUrl/tasks';
  static String get healthEndpoint => '$baseUrl/health';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Debug info
  static void printConfig() {
    print('🔧 API Configuration:');
    print('   Environment: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}');
    print('   Base URL: $baseUrl');
    print('   API URL: $apiUrl');
  }
}
