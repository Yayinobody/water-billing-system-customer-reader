import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // Save access token
  static Future<void> saveToken(String token) async =>
      await _storage.write(key: _accessKey, value: token);

  // Get access token
  static Future<String?> getToken() async =>
      await _storage.read(key: _accessKey);

  // Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async =>
      await _storage.write(key: _refreshKey, value: refreshToken);

  // Get refresh token
  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshKey);

  // Delete both tokens
  static Future<void> deleteToken() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}