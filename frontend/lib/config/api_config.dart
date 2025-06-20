import 'environment_config.dart';

class ApiConfig {
  // Get the base URL from the environment configuration
  // This will automatically use the correct URL based on the platform and environment
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
}
