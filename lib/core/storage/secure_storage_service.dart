import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._();
  SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userRole,
    required String userId,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserRole, value: userRole);
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
