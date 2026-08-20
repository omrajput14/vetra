import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Secure HTTP logging interceptor that automatically strips and redacts
/// sensitive credentials (JWT access/refresh tokens, passwords, authorization headers)
/// from debug output to prevent credential leakage.
class SanitizedLogInterceptor extends Interceptor {
  final bool enableLogging;

  SanitizedLogInterceptor({this.enableLogging = kDebugMode});

  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-auth-token',
  };

  static const _sensitiveBodyKeys = {
    'password',
    'currentpassword',
    'newpassword',
    'refreshtoken',
    'accesstoken',
    'jwt',
    'secret',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableLogging) {
      final sanitizedHeaders = _sanitizeHeaders(options.headers);
      final sanitizedData = _sanitizeData(options.data);
      debugPrint('[HTTP -->] ${options.method} BaseUrl: "${options.baseUrl}" Path: "${options.path}" -> Full URI: "${options.uri}"');
      if (sanitizedHeaders.isNotEmpty) {
        debugPrint('[HTTP Headers] $sanitizedHeaders');
      }
      if (sanitizedData != null) {
        debugPrint('[HTTP Body] $sanitizedData');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableLogging) {
      debugPrint(
          '[HTTP <--] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
      final sanitizedData = _sanitizeData(response.data);
      if (sanitizedData != null) {
        debugPrint('[HTTP Response] $sanitizedData');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLogging) {
      debugPrint(
          '[HTTP ERROR] ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.method} ${err.requestOptions.uri} - ${err.message}');
    }
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final clean = <String, dynamic>{};
    headers.forEach((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        clean[key] = '[REDACTED]';
      } else {
        clean[key] = value;
      }
    });
    return clean;
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final clean = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();
        if (_sensitiveBodyKeys.contains(keyStr)) {
          clean[key.toString()] = '[REDACTED]';
        } else if (value is Map || value is List) {
          clean[key.toString()] = _sanitizeData(value);
        } else {
          clean[key.toString()] = value;
        }
      });
      return clean;
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    return data;
  }
}
