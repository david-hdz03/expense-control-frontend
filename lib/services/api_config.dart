import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    final configured = _normalize(_baseUrlFromEnv);
    if (configured.isNotEmpty) return configured;

    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static String _normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
