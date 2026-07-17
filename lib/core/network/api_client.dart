import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);


  // GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
    );
  }


  // POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }


  // PUT
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }


  // PATCH
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }


  // DELETE
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
    );
  }


  // Upload File
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
  }) async {
    return await _dio.post<T>(
      path,
      data: formData,
      options: Options(
        contentType: "multipart/form-data",
      ),
    );
  }
}