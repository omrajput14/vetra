import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../config/api_config.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService _storage = SecureStorageService.instance;
  bool _isRefreshing = false;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      final requestOptions = err.requestOptions;
      if (!requestOptions.path.contains('/auth/login') &&
          !requestOptions.path.contains('/auth/register') &&
          !requestOptions.path.contains('/auth/refresh')) {
        _isRefreshing = true;
        try {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final refreshResponse = await dio.post(
              ApiConfig.refresh,
              data: {'refreshToken': refreshToken},
            );

            if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
              final newAccessToken = refreshResponse.data['data']['accessToken'];
              final newRefreshToken = refreshResponse.data['data']['refreshToken'];

              await _storage.saveAccessToken(newAccessToken);
              if (newRefreshToken != null) {
                final role = await _storage.getUserRole() ?? '';
                final userId = await _storage.getUserId() ?? '';
                await _storage.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                  userRole: role,
                  userId: userId,
                );
              }

              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(requestOptions);
              _isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          }
        } catch (e) {
          await _storage.clearAll();
        } finally {
          _isRefreshing = false;
        }
      }
    }
    handler.next(err);
  }
}
