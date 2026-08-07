import 'package:dio/dio.dart';

import 'dio_provider.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = DioProvider.create();
  }

  Dio get client => dio;


  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }


  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.post(
      path,
      data: data,
      options: options,
    );
  }


  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.put(
      path,
      data: data,
      options: options,
    );
  }


  Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.delete(
      path,
      data: data,
      options: options,
    );
  }
}