import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          "${ApiConstants.bearer} $token";
    }

    handler.next(options);
  }
}