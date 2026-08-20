import 'package:flutter/foundation.dart';

/// Supported deployment environments.
enum Environment {
  development,
  staging,
  production,
}

/// Central application configuration providing authoritative environment settings,
/// base URLs, timeouts, and network policies.
class AppConfig {
  AppConfig._();

  static Environment _environment = Environment.staging;

  /// Returns the active environment.
  static Environment get environment => _environment;

  /// Updates the active environment.
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// Convenience preset for Development environment.
  static void useDevelopment() => setEnvironment(Environment.development);

  /// Convenience preset for Staging environment (AWS HTTPS).
  static void useStaging() => setEnvironment(Environment.staging);

  /// Convenience preset for Production environment.
  static void useProduction() => setEnvironment(Environment.production);

  /// Canonical Base URL for API requests.
  static String get baseUrl {
    const String overrideUrl = String.fromEnvironment('BACKEND_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }
    switch (_environment) {
      case Environment.staging:
        return 'https://api.vetra.dpdns.org';
      case Environment.production:
        return 'https://api.vetra.app';
      case Environment.development:
        if (kIsWeb) return 'http://localhost:8080';
        return defaultTargetPlatform == TargetPlatform.android
            ? 'http://127.0.0.1:8080'
            : 'http://localhost:8080';
    }
  }

  /// Base URL including API version prefix for convenience.
  static String get apiBaseUrl => '$baseUrl/api/v1';

  /// Connection timeout for HTTP requests.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Receive timeout for HTTP responses.
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Send timeout for HTTP payload transmission.
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Maximum retry attempts for transient network failures.
  static const int maxRetries = 3;

  /// Base delay for exponential backoff retries.
  static const Duration retryBaseDelay = Duration(milliseconds: 500);

  /// Maximum delay ceiling for exponential backoff.
  static const Duration retryMaxDelay = Duration(seconds: 3);
}
