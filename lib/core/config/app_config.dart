class AppConfig {
  AppConfig._();

  // Configurable at compile time via --dart-define=API_BASE_URL=https://your-api.com
  // Defaults to an https URL in production; use --dart-define=API_BASE_URL=http://... for local dev
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.aura.app',
  );

  static const String appName = 'Aura';
  static const String clientHeaderValue = 'mobile';
}
