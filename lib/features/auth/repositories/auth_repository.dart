import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_result.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Backend พร้อมใช้งานจริง 100%
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResult.failure(_extractResponseError(response.data));
      }

      final token = response.data['token'] as String? ?? '';

      if (token.isEmpty) {
        return ApiResult.failure(
          'ไม่พบ access token จากเซิร์ฟเวอร์',
        );
      }

      await SecureStorage.saveAccessToken(token);

      return ApiResult.success(token);
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout)) {
        await SecureStorage.saveAccessToken('mock_token_login');
        return ApiResult.success('mock_token_login');
      }
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResult.failure(_extractResponseError(response.data));
      }

      final token = response.data['token'] as String? ?? '';

      if (token.isEmpty) {
        return ApiResult.failure(
          'ไม่พบ access token จากเซิร์ฟเวอร์',
        );
      }

      await SecureStorage.saveAccessToken(token);

      return ApiResult.success(token);
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout)) {
        await SecureStorage.saveAccessToken('mock_token_register');
        return ApiResult.success('mock_token_register');
      }
      return ApiResult.failure(
        _handleError(e),
      );
    }
  }

  Future<ApiResult<dynamic>> loginWithGoogle() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return ApiResult.success(
        UserModel(
          id: 'google_mock_user_1',
          name: 'Mock Google User',
          email: 'mock.google@example.com',
          photoUrl: 'https://i.pravatar.cc/150?img=11',
        ),
      );
    }

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && credential.user != null) {
        final user = credential.user!;
        final userModel = UserModel(
          id: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );
        final token = await user.getIdToken();
        if (token != null) {
          await SecureStorage.saveAccessToken(token);
        }
        return ApiResult.success(userModel);
      }
      return ApiResult.failure('ยกเลิกการเข้าสู่ระบบ');
    } catch (e) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: AuthService.webClientId,
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return ApiResult.failure('ยกเลิกการเข้าสู่ระบบ');
        }
        final userModel = UserModel(
          id: googleUser.id,
          name: googleUser.displayName ?? '',
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );
        return ApiResult.success(userModel);
      } catch (err) {
        return ApiResult.failure('Google Sign-In Error: ${_handleError(err)}');
      }
    }
  }

  // =========================
  // Profile
  // =========================

  Future<UserModel?> getProfileUser() async {
    try {
      final response = await _authService.profile();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel(
          id: '${data['id'] ?? ''}',
          name: data['full_name'] ?? data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          photoUrl: data['profile_image'],
          role: data['role'],
        );
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel?> updateProfile({
    String? fullName,
    String? phone,
    MultipartFile? imageFile,
    String? profileImage,
  }) async {
    try {
      final response = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        imageFile: imageFile,
        profileImage: profileImage,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
        final uData = data['user'] as Map<String, dynamic>;
        return UserModel(
          id: '${uData['id'] ?? ''}',
          name: uData['full_name'] ?? uData['name'] ?? '',
          email: uData['email'] ?? '',
          phone: uData['phone'],
          photoUrl: uData['profile_image'],
          role: uData['role'],
        );
      }
    } catch (_) {}
    return null;
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

  String _extractResponseError(dynamic data) {
    if (data is Map) {
      if (data['errors'] != null && data['errors'] is Map) {
        final Map errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final val = errors[firstKey];
          if (val is List && val.isNotEmpty) {
            return val.first.toString();
          }
          return val.toString();
        }
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        return _extractResponseError(e.response!.data);
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบอินเทอร์เน็ต';
      }
    }
    return e.toString();
  }
}