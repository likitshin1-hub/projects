import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Response> login({
    required String email,
    required String password,
  }) {
    return _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
  }

  /// เรียก API ส่ง access_token ที่ได้จาก Facebook SDK ไปให้ Backend
  Future<Response> loginWithFacebook({required String accessToken}) {
    return _dioClient.post(
      ApiConstants.loginFacebook,
      data: {'access_token': accessToken},
    );
  }

  /// เรียก API ส่ง access_token ที่ได้จาก LINE SDK ไปให้ Backend
  Future<Response> loginWithLine({required String accessToken}) {
    return _dioClient.post(
      ApiConstants.loginLine,
      data: {'access_token': accessToken},
    );
  }

  Future<Response> register({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _dioClient.post(
      ApiConstants.register,
      data: {
        'username': username,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
  }
}
