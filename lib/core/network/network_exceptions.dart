import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory NetworkException.fromDioError(DioException error) {
    if (kDebugMode) {
      debugPrint(
        '[NetworkException] Endpoint: "${error.requestOptions.method} ${error.requestOptions.uri}" '
        'Status: ${error.response?.statusCode ?? "N/A"} '
        'Type: ${error.type} '
        'Error: ${error.error}',
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Please check your internet connection.');

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String msg = 'An unexpected server error occurred.';
        if (data is Map) {
          if (data.containsKey('message') && data['message'] != null) {
            msg = data['message'].toString();
          }
          if (data.containsKey('errors') && data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            final errorList = (data['errors'] as List)
                .map((e) {
                  if (e is Map) {
                    final field = e['field']?.toString() ?? '';
                    final message = e['message']?.toString() ?? '';
                    return field.isNotEmpty ? '$field: $message' : message;
                  }
                  return e.toString();
                })
                .where((s) => s.isNotEmpty)
                .join(', ');
            if (errorList.isNotEmpty) {
              msg = '$msg ($errorList)';
            }
          }
        }
        if (status == 401) {
          return NetworkException(msg.isNotEmpty ? msg : 'Unauthorized access. Please login again.', statusCode: 401);
        } else if (status == 403) {
          return NetworkException(msg.isNotEmpty ? msg : 'Access forbidden.', statusCode: 403);
        } else if (status == 404) {
          return NetworkException(msg.isNotEmpty ? msg : 'Resource not found.', statusCode: 404);
        } else if (status != null && status >= 500) {
          return NetworkException('$msg (server error $status). Please try again later.', statusCode: status);
        }
        return NetworkException(msg, statusCode: status);

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return NetworkException('Unable to connect to PASHU SATHI services. Please try again later.');

      case DioExceptionType.unknown:
      default:
        return NetworkException('Please check your internet connection.');
    }
  }
}

/// True when the server actually answered with an HTTP error (4xx/5xx).
///
/// Such an answer is final: replaying the same request later gets the same
/// rejection, so it must be shown to the user rather than queued for sync.
/// Anything else (no connection, timeout) means the request never got an answer.
bool isServerRejection(Object error) =>
    (error is NetworkException && error.statusCode != null) ||
    (error is DioException && error.response != null);

