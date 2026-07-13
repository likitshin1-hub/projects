import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_result.dart';
import '../services/auth_service.dart';

// ===== ตั้งค่า Mock Mode =====
// เปลี่ยนเป็น false เมื่อ Backend พร้อมใช้งานจริงครับ
const bool _useMock = true;

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  AuthRepository({
    AuthService? authService,
    FlutterSecureStorage? storage,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<ApiResult<String>> login({
    required String email,
    required String password,
  }) async {
    // ===== Mock Mode: ข้าม API ไปยังหน้า Home ได้เลย =====
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _storage.write(key: 'auth_token', value: 'mock_token_login');
      } catch (_) {}
      return ApiResult.success('mock_token_login');
    }

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      final token = response.data['token'] as String? ?? '';
      await _storage.write(key: 'auth_token', value: token);
      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  Future<ApiResult<String>> register({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // ===== Mock Mode: ข้าม API ไปยังหน้า Home ได้เลย =====
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _storage.write(key: 'auth_token', value: 'mock_token_register');
      } catch (_) {}
      return ApiResult.success('mock_token_register');
    }

    try {
      final response = await _authService.register(
        username: username,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      final token = response.data['token'] as String? ?? '';
      await _storage.write(key: 'auth_token', value: token);
      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  String _handleError(dynamic e) {
    return e.toString();
  }
}
