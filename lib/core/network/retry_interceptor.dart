import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Interceptor providing bounded exponential backoff for transient network errors
/// (timeouts, connection drops, HTTP 502/503/504) on idempotent HTTP requests.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = AppConfig.maxRetries,
    this.baseDelay = AppConfig.retryBaseDelay,
    this.maxDelay = AppConfig.retryMaxDelay,
  });

  static const _retryCountKey = 'x-vetra-retry-count';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_retryCountKey] as int? ?? 0);

    if (_shouldRetry(err, options, attempt)) {
      final nextAttempt = attempt + 1;
      options.extra[_retryCountKey] = nextAttempt;

      final delay = _calculateDelay(nextAttempt);
      await Future.delayed(delay);

      try {
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err, RequestOptions options, int attempt) {
    if (attempt >= maxRetries) return false;

    // Do not retry non-idempotent mutations blindly
    final method = options.method.toUpperCase();
    final isIdempotent = method == 'GET' || method == 'HEAD' || method == 'OPTIONS';
    final isExplicitlyRetryable = options.extra['retryable'] == true;

    if (!isIdempotent && !isExplicitlyRetryable) {
      return false;
    }

    // Transient timeout or connection error
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Transient server errors (502 Bad Gateway, 503 Service Unavailable, 504 Gateway Timeout)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && (statusCode == 502 || statusCode == 503 || statusCode == 504)) {
      return true;
    }

    return false;
  }

  Duration _calculateDelay(int attempt) {
    final exp = pow(2, attempt - 1).toInt();
    final rawDelayMs = baseDelay.inMilliseconds * exp;
    // Add 10% random jitter to avoid thundering herd
    final jitterMs = Random().nextInt(100);
    final totalMs = min(rawDelayMs + jitterMs, maxDelay.inMilliseconds);
    return Duration(milliseconds: totalMs);
  }
}
