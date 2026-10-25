import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _firstNameKey = 'user_first_name';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';
  static const String _firebaseInstallationIdKey = 'firebase_installation_id';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveFirstName(String firstName) async {
    await _storage.write(key: _firstNameKey, value: firstName);
  }

  Future<String?> getFirstName() async {
    return await _storage.read(key: _firstNameKey);
  }

  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role.trim().toUpperCase());
  }

  Future<String?> getRole() async {
    final String? role = await _storage.read(key: _roleKey);
    if (role == null || role.trim().isEmpty) {
      return null;
    }
    return role.trim().toUpperCase();
  }

  Future<int?> getUserId() async {
    final String? userId = await _storage.read(key: _userIdKey);
    if (userId == null) {
      return null;
    }
    return int.tryParse(userId);
  }

  Future<void> saveFirebaseInstallationId(String firebaseInstallationId) async {
    await _storage.write(
      key: _firebaseInstallationIdKey,
      value: firebaseInstallationId.trim(),
    );
  }

  Future<String?> getFirebaseInstallationId() async {
    final String? value = await _storage.read(key: _firebaseInstallationIdKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _firstNameKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _roleKey);
    // Keep the Firebase Installation ID because it belongs to the app
    // installation rather than a specific authenticated session.
  }
}
