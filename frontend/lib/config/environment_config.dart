import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuration class to manage environment-specific settings
class EnvironmentConfig {
  /// Get the appropriate base URL based on the current environment
  static String get apiBaseUrl {
    // For web builds in production (Docker)
    if (kIsWeb) {
      // This will be replaced during Docker build with the environment variable
      const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
      if (envUrl.isNotEmpty) {
        return envUrl;
      }
      // Default for web if no environment variable is set
      return '/api'; // Relative URL for web production
    }
    
    // For Android emulator
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // Special IP for Android emulator to reach host
    }
    
    // For iOS simulator
    if (!kIsWeb && Platform.isIOS) {
      return 'http://localhost:8080';
    }
    
    // Default fallback
    return 'http://localhost:8080';
  }
}
