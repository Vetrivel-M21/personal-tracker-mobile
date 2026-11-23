class AppConfig {
  AppConfig._();

  // Configurable at compile time via --dart-define=API_BASE_URL=https://your-api.com
  // Defaults to 10.0.2.2 for Android emulator or localhost for desktop/testing
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String appName = 'Aura Fitness Challenge';
  static const String clientHeaderValue = 'mobile';
}

