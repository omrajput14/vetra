import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';
import 'sanitized_log_interceptor.dart';

/// Centralized Dio HTTP client factory configured with environment-driven base URLs,
/// robust timeouts, authentication interceptors, retry backoff, and secure logging.
class ApiClient {
  static final ApiClient instance = ApiClient._();
  late final Dio dio;

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Auth Interceptor (Handles Bearer tokens & 401 refresh)
    dio.interceptors.add(AuthInterceptor(dio));

    // 2. Retry Interceptor (Handles transient 502/503/504 and network drops with exponential backoff)
    dio.interceptors.add(RetryInterceptor(dio: dio));

    // 3. Sanitized Logger (Securely redacts tokens/passwords in debug output)
    dio.interceptors.add(SanitizedLogInterceptor());
  }

  /// Updates the base URL dynamically when environment is switched.
  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }
}
