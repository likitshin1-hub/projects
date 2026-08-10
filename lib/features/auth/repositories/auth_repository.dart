import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/auth_service.dart';

/// Backend พร้อมใช้งานจริงแล้ว
const bool _useMock = false;

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

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

  // =========================
  // Facebook Login
  // =========================

  Future<ApiResult> loginWithFacebook({
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

  // =========================
  // LINE Login
  // =========================

  Future<ApiResult> loginWithLine({
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

  // =========================
  // Google Login
  // =========================

  Future<ApiResult<UserCredential?>> loginWithGoogle() async {
    // =========================
    // Mock Mode
    // =========================

    if (_useMock) {
      return ApiResult.success(null);
    }

    try {
      final UserCredential? userCredential =
          await _authService.signInWithGoogle();

      if (userCredential == null) {
        return ApiResult.failure(
          'ยกเลิกการเข้าสู่ระบบ',
        );
      }

      final String? token =
          await userCredential.user?.getIdToken();

      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveAccessToken(token);
      }

      return ApiResult.success(userCredential);
    } catch (e) {
      debugPrint(
        'Google Sign-In Exception: $e',
      );

      return ApiResult.failure(
        'ไม่สามารถเปิด Google Sign-In ได้: ${_handleError(e)}',
      );
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
      await _authService.logout();
    } catch (e) {
      debugPrint(
        'Backend logout error: $e',
      );
    }

    await SecureStorage.clear();
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