import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

class DioProvider {
  DioProvider._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        contentType: ApiConstants.applicationJson,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggerInterceptor.create(),
    ]);

    return dio;
  }
}