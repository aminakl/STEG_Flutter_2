import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUtils {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _userInfoKey = 'user_info';

  // Save token to secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    try {
      Map<String, dynamic> decodedToken = _decodeJwt(token);
      Map<String, dynamic> userInfo = {
        'id': decodedToken['id'] ?? '',
        'matricule': decodedToken['sub'] ?? '',
        'email': decodedToken['email'] ?? '',
        'role': decodedToken['role'] ?? '',
      };
      await _storage.write(key: _userInfoKey, value: jsonEncode(userInfo));
    } catch (e) {
      print('Error decoding token: $e');
    }
  }

  // Get token from secure storage
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Check if token exists and is valid
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if (token == null) return false;
    try {
      bool isExpired = _isTokenExpired(token);
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  // Get user info from secure storage
  static Future<Map<String, dynamic>> getUserInfo() async {
    String? userInfoJson = await _storage.read(key: _userInfoKey);
    if (userInfoJson == null) return {};
    try {
      return jsonDecode(userInfoJson);
    } catch (e) {
      print('Error decoding user info: $e');
      return {};
    }
  }

  // Get user role
  static Future<String> getUserRole() async {
    Map<String, dynamic> userInfo = await getUserInfo();
    return userInfo['role'] ?? '';
  }

  // Logout - clear token and user info
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userInfoKey);
  }

  // Native JWT decode (no external package)
  static Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded);
  }

  static bool _isTokenExpired(String token) {
    final payload = _decodeJwt(token);
    if (!payload.containsKey('exp')) return true;
    final exp = payload['exp'];
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  }
}
