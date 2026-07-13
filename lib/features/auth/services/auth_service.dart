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
