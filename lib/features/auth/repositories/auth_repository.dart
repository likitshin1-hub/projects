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
          // GoogleSignIn.instance.initialize(clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com');
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

  Future<ApiResult<String>> loginWithGoogle() async {
    try {
      // 1. เรียกหน้าต่าง Google Sign In
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // 2. ขอ Authentication Token
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
          
      final String? idToken = googleAuth.idToken;
      final String? accessToken = null; // No longer directly available in same way, usually idToken is enough

      // ในระบบจริง คุณต้องส่ง accessToken หรือ idToken ไปให้ Backend ตรวจสอบ
      // แต่ตอนนี้เราจะจำลองว่าล็อคอินสำเร็จและบันทึก mock token แทนไปก่อน
      
      if (_useMock) {
        try {
          await _storage.write(key: 'auth_token', value: 'google_mock_token');
        } catch (_) {}
        return ApiResult.success('google_mock_token');
      }

      // TODO: ส่ง Token ไป Backend
      // final response = await _authService.loginWithGoogle(token: idToken);
      // ...
      
      return ApiResult.success('google_mock_token');
    } on GoogleSignInException catch (e) {
      // ผู้ใช้กดยกเลิก หรือเกิดข้อผิดพลาดจาก Google
      return ApiResult.failure('ยกเลิกการเข้าสู่ระบบ หรือเกิดข้อผิดพลาด: ${e.code}');
    } catch (e) {
      // Fallback for Web if it throws UnimplementedError and mock is enabled
      if (_useMock) {
        try {
          await _storage.write(key: 'auth_token', value: 'google_mock_token');
        } catch (_) {}
        return ApiResult.success('google_mock_token');
      }
      return ApiResult.failure('Google Sign-In Error: ${_handleError(e)}');
    }
  }

  Future<void> logout() async {
    await GoogleSignIn.instance.signOut();
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  String _handleError(dynamic e) {
    return e.toString();
  }
}
