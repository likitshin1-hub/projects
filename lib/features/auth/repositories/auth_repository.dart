import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_result.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/auth_service.dart';

/// Backend พร้อมใช้งานจริงแล้ว
const bool _useMock = false;

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    AuthService? authService,
    FlutterSecureStorage? storage,
    GoogleSignIn? googleSignIn,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? const FlutterSecureStorage(),
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // =========================
  // Email Login
  // =========================

  Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    if (_useMock) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      await SecureStorage.saveAccessToken(
        'mock_token_login',
      );

      return ApiResult.success('mock_token_login');
    }

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      final token = response.data['token'] as String? ?? '';

      if (token.isEmpty) {
        return ApiResult.failure(
          'ไม่พบ access token จากเซิร์ฟเวอร์',
        );
      }

      await SecureStorage.saveAccessToken(token);

      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(
        _handleError(e),
      );
    }
  }

  /// Login ด้วย Facebook
  Future<ApiResult<String>> loginWithFacebook({
    required String accessToken,
  }) async {
    if (_useMock) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      await SecureStorage.saveAccessToken(
        'mock_token_facebook',
      );

      return ApiResult.success(
        'mock_token_facebook',
      );
    }

    try {
      final response = await _authService.loginWithFacebook(
        accessToken: accessToken,
      );

      final token = response.data['token'] as String? ?? '';

      if (token.isEmpty) {
        return ApiResult.failure(
          'ไม่พบ access token จากเซิร์ฟเวอร์',
        );
      }

      await SecureStorage.saveAccessToken(token);

      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(
        _handleError(e),
      );
    }
  }

  /// Login ด้วย LINE
  Future<ApiResult<String>> loginWithLine({
    required String accessToken,
  }) async {
    if (_useMock) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      await SecureStorage.saveAccessToken(
        'mock_token_line',
      );

      return ApiResult.success(
        'mock_token_line',
      );
    }

    try {
      final response = await _authService.loginWithLine(
        accessToken: accessToken,
      );

      final token = response.data['token'] as String? ?? '';

      if (token.isEmpty) {
        return ApiResult.failure(
          'ไม่พบ access token จากเซิร์ฟเวอร์',
        );
      }

      await SecureStorage.saveAccessToken(token);

      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(
        _handleError(e),
      );
    }
  }

  // =========================
  // Register
  // =========================

  Future<ApiResult> register({
    required String role,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (_useMock) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      await SecureStorage.saveAccessToken(
        'mock_token_register',
      );

      return ApiResult.success(
        'mock_token_register',
      );
    }

    try {
      final response = await _authService.register(
        role: role,
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final token = response.data['token'] as String? ?? '';

      if (token.isEmpty) {
        return ApiResult.failure(
          'ไม่พบ access token จากเซิร์ฟเวอร์',
        );
      }

      await SecureStorage.saveAccessToken(token);

      return ApiResult.success(token);
    } catch (e) {
      return ApiResult.failure(
        _handleError(e),
      );
    }
  }

  Future<ApiResult<String>> loginWithGoogle() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _storage.write(key: 'auth_token', value: 'google_mock_token');
      } catch (_) {}
      return ApiResult.success('google_mock_token');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResult.failure('ยกเลิกการเข้าสู่ระบบ');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      await _storage.write(key: 'auth_token', value: idToken ?? 'google_mock_token');
      return ApiResult.success(idToken ?? 'google_mock_token');
    } catch (e) {
      return ApiResult.failure('Google Sign-In Error: ${_handleError(e)}');
    }
  }

  // =========================
  // Profile
  // =========================

  Future<dynamic> profile() async {
    try {
      return await _authService.profile();
    } catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // =========================
  // Logout
  // =========================

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _storage.delete(key: 'auth_token');
  }

  // =========================
  // Get Token
  // =========================

  Future<String?> getToken() async {
    return SecureStorage.getAccessToken();
  }

  // =========================
  // Error Handler
  // =========================

  String _handleError(dynamic e) {
    return e.toString();
  }
}