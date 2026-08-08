import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoggerInterceptor {
  LoggerInterceptor._();

  static PrettyDioLogger create() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 120,
    );
  }
}
