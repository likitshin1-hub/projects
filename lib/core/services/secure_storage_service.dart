import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service สำหรับเก็บข้อมูล sensitive ด้วย Secure Storage
///
/// Android ใช้ Android Keystore
/// iOS ใช้ Keychain
class SecureStorageService {
  late final FlutterSecureStorage _storage;

  // ─────────────────────────────────────────────
  // Storage Keys
  // ─────────────────────────────────────────────

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUserRole = 'user_role';
  static const _kUserEmail = 'user_email';

  // ─────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────

  SecureStorageService() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  // ─────────────────────────────────────────────
  // Access Token
  // ─────────────────────────────────────────────

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _kAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _kAccessToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _kAccessToken);
  }

  // ─────────────────────────────────────────────
  // Refresh Token
  // ─────────────────────────────────────────────

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _kRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _kRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _kRefreshToken);
  }

  // ─────────────────────────────────────────────
  // User ID
  // ─────────────────────────────────────────────

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _kUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _kUserId);
  }

  // ─────────────────────────────────────────────
  // User Role
  // customer / driver / admin
  // ─────────────────────────────────────────────

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _kUserRole, value: role);
  }

  Future<String?> getUserRole() async {
    return _storage.read(key: _kUserRole);
  }

  // ─────────────────────────────────────────────
  // User Email
  // ─────────────────────────────────────────────

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _kUserEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    return _storage.read(key: _kUserEmail);
  }

  // ─────────────────────────────────────────────
  // Composite Operations
  // ─────────────────────────────────────────────

  /// บันทึกข้อมูลหลัง Login สำเร็จ
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    String? userRole,
    String? userEmail,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUserId(userId),

      if (userRole != null) saveUserRole(userRole),

      if (userEmail != null) saveUserEmail(userEmail),
    ]);
  }

  /// ตรวจสอบ Token
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }

  /// Logout
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),

      _storage.delete(key: _kUserId),

      _storage.delete(key: _kUserRole),

      _storage.delete(key: _kUserEmail),
    ]);
  }

  /// ล้าง Storage ทั้งหมด
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
