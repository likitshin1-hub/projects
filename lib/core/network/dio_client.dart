import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient([Dio? dio]) : dio = dio ?? Dio();

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
}
