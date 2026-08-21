import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._();
  SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, String> _memoryFallback = {};

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyPreferredLanguage = 'preferred_language';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userRole,
    required String userId,
  }) async {
    try {
      await _storage.write(key: _keyAccessToken, value: accessToken);
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
      await _storage.write(key: _keyUserRole, value: userRole);
      await _storage.write(key: _keyUserId, value: userId);
    } catch (_) {
      _memoryFallback[_keyAccessToken] = accessToken;
      _memoryFallback[_keyRefreshToken] = refreshToken;
      _memoryFallback[_keyUserRole] = userRole;
      _memoryFallback[_keyUserId] = userId;
    }
  }

  Future<void> saveAccessToken(String accessToken) async {
    try {
      await _storage.write(key: _keyAccessToken, value: accessToken);
    } catch (_) {
      _memoryFallback[_keyAccessToken] = accessToken;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (_) {
      return _memoryFallback[_keyAccessToken];
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (_) {
      return _memoryFallback[_keyRefreshToken];
    }
  }

  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _keyUserRole);
    } catch (_) {
      return _memoryFallback[_keyUserRole];
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (_) {
      return _memoryFallback[_keyUserId];
    }
  }

  Future<void> savePreferredLanguage(String languageCode) async {
    try {
      await _storage.write(key: _keyPreferredLanguage, value: languageCode);
    } catch (_) {
      _memoryFallback[_keyPreferredLanguage] = languageCode;
    }
  }

  Future<String?> getPreferredLanguage() async {
    try {
      return await _storage.read(key: _keyPreferredLanguage);
    } catch (_) {
      return _memoryFallback[_keyPreferredLanguage];
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    _memoryFallback.clear();
  }
}
