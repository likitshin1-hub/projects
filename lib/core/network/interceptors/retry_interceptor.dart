import 'package:dio/dio.dart';

/// Retry interceptor สำหรับ retry request อัตโนมัติ
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration delay;

  RetryInterceptor({this.maxRetries = 3, this.delay = const Duration(seconds: 1)});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.type == DioExceptionType.connectionError && maxRetries > 0) {
      await Future.delayed(delay);
      final retriesLeft = maxRetries - 1;
      final retryInterceptor = RetryInterceptor(
        maxRetries: retriesLeft,
        delay: delay,
      );
      return retryInterceptor.onError(err, handler);
    }

    handler.next(err);
  }
}
