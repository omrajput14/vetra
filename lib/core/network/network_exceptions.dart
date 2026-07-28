import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String msg = 'An unexpected server error occurred ($status).';
        if (data is Map && data.containsKey('message') && data['message'] != null) {
          msg = data['message'].toString();
        }
        if (status == 401) {
          return NetworkException(msg.isEmpty ? 'Unauthorized access. Please login again.' : msg, statusCode: 401);
        } else if (status == 403) {
          return NetworkException(msg.isEmpty ? 'Access forbidden.' : msg, statusCode: 403);
        } else if (status == 404) {
          return NetworkException(msg.isEmpty ? 'Resource not found.' : msg, statusCode: 404);
        } else if (status != null && status >= 500) {
          return NetworkException('Server is temporarily unavailable ($status). Please try again later.', statusCode: status);
        }
        return NetworkException(msg, statusCode: status);
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return NetworkException('No internet connection or backend server is offline.');
    }
  }
}
