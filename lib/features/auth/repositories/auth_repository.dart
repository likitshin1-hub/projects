import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_result.dart';
import '../services/auth_service.dart';


// ===== Mock Mode =====
// เปลี่ยนเป็น false เมื่อ Backend พร้อมใช้งานจริง
const bool _useMock = true;


class AuthRepository {

  final AuthService _authService;
  final FlutterSecureStorage _storage;


  AuthRepository({
    AuthService? authService,
    FlutterSecureStorage? storage,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? const FlutterSecureStorage();



  // ======================
  // Email Login
  // ======================

  Future<ApiResult> login({
    required String email,
    required String password,
  }) async {


    if (_useMock) {

      await Future.delayed(
        const Duration(milliseconds: 800),
      );


      await _storage.write(
        key: 'auth_token',
        value: 'mock_token_login',
      );


      return ApiResult.success(
        'mock_token_login',
      );
    }



    try {

      final response =
          await _authService.login(
        email: email,
        password: password,
      );


      final token =
          response.data['token'] as String? ?? '';


      await _storage.write(
        key: 'auth_token',
        value: token,
      );


      return ApiResult.success(token);


    } catch (e) {

      return ApiResult.failure(
        _handleError(e),
      );

    }
  }




  // ======================
  // Facebook Login
  // ======================

  Future<ApiResult> loginWithFacebook({
    required String accessToken,
  }) async {


    if (_useMock) {

      await Future.delayed(
        const Duration(milliseconds: 800),
      );


      await _storage.write(
        key: 'auth_token',
        value: 'mock_token_facebook',
      );


      return ApiResult.success(
        'mock_token_facebook',
      );

    }



    try {

      final response =
          await _authService.loginWithFacebook(
        accessToken: accessToken,
      );


      final token =
          response.data['token'] as String? ?? '';



      await _storage.write(
        key: 'auth_token',
        value: token,
      );


      return ApiResult.success(token);


    } catch(e) {

      return ApiResult.failure(
        _handleError(e),
      );

    }

  }





  // ======================
  // LINE Login
  // ======================

  Future<ApiResult> loginWithLine({
    required String accessToken,
  }) async {


    if (_useMock) {


      await Future.delayed(
        const Duration(milliseconds: 800),
      );


      await _storage.write(
        key: 'auth_token',
        value: 'mock_token_line',
      );


      return ApiResult.success(
        'mock_token_line',
      );

    }



    try {


      final response =
          await _authService.loginWithLine(
        accessToken: accessToken,
      );



      final token =
          response.data['token'] as String? ?? '';



      await _storage.write(
        key: 'auth_token',
        value: token,
      );



      return ApiResult.success(token);



    } catch(e) {


      return ApiResult.failure(
        _handleError(e),
      );


    }

  }





  // ======================
  // Register
  // ======================

  Future<ApiResult> register({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {


    if (_useMock) {


      await Future.delayed(
        const Duration(milliseconds: 800),
      );


      await _storage.write(
        key: 'auth_token',
        value: 'mock_token_register',
      );


      return ApiResult.success(
        'mock_token_register',
      );

    }




    try {


      final response =
          await _authService.register(
        username: username,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );



      final token =
          response.data['token'] as String? ?? '';



      await _storage.write(
        key: 'auth_token',
        value: token,
      );



      return ApiResult.success(token);



    } catch(e) {


      return ApiResult.failure(
        _handleError(e),
      );


    }

  }





  // ======================
  // Google Login
  // ======================

  Future<ApiResult<UserCredential?>> loginWithGoogle() async {


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



      if (token != null) {


        await _storage.write(
          key: 'auth_token',
          value: token,
        );


      }



      return ApiResult.success(
        userCredential,
      );



    } catch(e) {


      debugPrint(
        "Google Sign-In Exception: $e",
      );


      return ApiResult.failure(
        'ไม่สามารถเปิด Google Sign-In ได้: ${_handleError(e)}',
      );


    }

  }





  // ======================
  // Logout
  // ======================

  Future<void> logout() async {


    try {

      await GoogleSignIn().signOut();

    } catch (_) {}



    try {

      await FirebaseAuth.instance.signOut();

    } catch (_) {}



    try {

      await _storage.delete(
        key: 'auth_token',
      );

    } catch (_) {}

  }





  Future<String?> getToken() async {

    return _storage.read(
      key: 'auth_token',
    );

  }




  String _handleError(dynamic e) {

    return e.toString();

  }

}