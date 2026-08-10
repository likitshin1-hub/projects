import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        _storage = storage ?? const FlutterSecureStorage() {
          // TODO: ใส่ Client ID ของ Web / iOS ที่ได้จาก Firebase/Google Cloud ตรงนี้
          // GoogleSignIn().initialize(clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com');
        }

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

  /// Login ด้วย Facebook
  /// เมื่อเชื่อม SDK จริง: รับ [accessToken] มาจาก flutter_facebook_auth
  /// แล้วส่งไปยัง Backend เพื่อแลกเปลี่ยนเป็น App Token
  Future<ApiResult<String>> loginWithFacebook({
    required String accessToken,
  }) async {
    // ===== Mock Mode =====
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _storage.write(key: 'auth_token', value: 'mock_token_facebook');
      } catch (_) {}
      return ApiResult.success('mock_token_facebook');
    }

    try {
      final response = await _authService.loginWithFacebook(
        accessToken: accessToken,
      );
      final token = response.data['token'] as String? ?? '';
      await _storage.write(key: 'auth_token', value: token);
      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  /// Login ด้วย LINE
  /// เมื่อเชื่อม SDK จริง: รับ [accessToken] มาจาก flutter_line_sdk
  /// แล้วส่งไปยัง Backend เพื่อแลกเปลี่ยนเป็น App Token
  Future<ApiResult<String>> loginWithLine({
    required String accessToken,
  }) async {
    // ===== Mock Mode =====
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _storage.write(key: 'auth_token', value: 'mock_token_line');
      } catch (_) {}
      return ApiResult.success('mock_token_line');
    }

    try {
      final response = await _authService.loginWithLine(
        accessToken: accessToken,
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

  Future<ApiResult<UserCredential?>> loginWithGoogle() async {
    // ===== Mock Mode =====
    if (_useMock) {
      try {
        await _storage.write(key: 'auth_token', value: 'google_mock_token');
      } catch (_) {}
      return ApiResult.success(null);
    }

    try {
      final UserCredential? userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        return ApiResult.failure('ยกเลิกการเข้าสู่ระบบ');
      }

      final String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }

      return ApiResult.success(userCredential);
    } catch (e) {
      return ApiResult.failure('ไม่สามารถเปิด Google Sign-In ได้: ${_handleError(e)}');
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      await _storage.delete(key: 'auth_token');
    } catch (_) {}
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  String _handleError(dynamic e) {
    return e.toString();
  }
}
