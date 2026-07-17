import 'package:dio/dio.dart';

import 'dio_provider.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = DioProvider.create();
  }

  Dio get client => dio;
}