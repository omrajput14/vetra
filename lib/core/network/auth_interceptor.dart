import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../config/api_config.dart';

/// Interceptor managing JWT access token injection, automatic 401 token refresh,
/// concurrent request queuing, and graceful session invalidation.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService _storage = SecureStorageService.instance;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];

  AuthInterceptor(this.dio);

  static const _publicEndpoints = [
    '/auth/farmer/register',
    '/auth/vet/register',
    '/auth/farmer/login',
    '/auth/vet/login',
    '/auth/refresh',
  ];

  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Only attach Authorization header for non-public endpoints
    if (!_isPublicEndpoint(options.path)) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Handle 401 Unauthorized for authenticated endpoints
    if (statusCode == 401 && !_isPublicEndpoint(path)) {
      final requestOptions = err.requestOptions;

      // If a refresh is already in flight, wait for it rather than triggering another refresh
      if (_isRefreshing) {
        final completer = Completer<String?>();
        _refreshQueue.add(completer);

        final newToken = await completer.future;
        if (newToken != null && newToken.isNotEmpty) {
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } on DioException catch (retryErr) {
            return handler.next(retryErr);
          }
        } else {
          return handler.next(err);
        }
      }

      // Initiate token refresh
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshResponse = await dio.post(
            ApiConfig.refresh,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Authorization': null}, // Ensure no stale Bearer token on refresh
            ),
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final responseData = refreshResponse.data;
            final data = responseData is Map<String, dynamic> ? responseData['data'] : null;

            if (data != null && data['accessToken'] != null) {
              final newAccessToken = data['accessToken'].toString();
              final newRefreshToken = data['refreshToken']?.toString();

              await _storage.saveAccessToken(newAccessToken);
              if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                final role = await _storage.getUserRole() ?? '';
                final userId = await _storage.getUserId() ?? '';
                await _storage.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                  userRole: role,
                  userId: userId,
                );
              }

              // Release queued requests with new token
              for (final completer in _refreshQueue) {
                completer.complete(newAccessToken);
              }
              _refreshQueue.clear();

              // Retry original failed request
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(requestOptions);
              _isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          }
        }
        // If refresh token missing or refresh request failed
        await _handleRefreshFailure();
      } catch (e) {
        await _handleRefreshFailure();
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  Future<void> _handleRefreshFailure() async {
    await _storage.clearAll();
    for (final completer in _refreshQueue) {
      completer.complete(null);
    }
    _refreshQueue.clear();
  }
}
