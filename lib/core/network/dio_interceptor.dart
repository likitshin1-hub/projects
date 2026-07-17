import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../services/secure_storage_service.dart';


// ─────────────────────────────────────────────
// Auth Interceptor
// ─────────────────────────────────────────────

/// Interceptor หลัก:
/// - เพิ่ม Authorization header ทุก request
/// - จัดการ 401 ด้วยการ refresh token อัตโนมัติ
/// - ถ้า refresh ไม่ได้ → clear token เพื่อให้ไป Login
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final Dio _dio;

  /// ป้องกัน refresh loop (ถ้า refresh request เองก็ 401)
  bool _isRefreshing = false;

  AuthInterceptor({
    required SecureStorageService storageService,
    required Dio dio,
  })  : _storageService = storageService,
        _dio = dio;

  // ─────────────────────────────
  // onRequest: ใส่ Bearer token
  // ─────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ข้าม header ของ endpoint ที่ไม่ต้องการ Token
    final skipAuth = options.extra['skipAuth'] as bool? ?? false;
    if (!skipAuth) {
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  // ─────────────────────────────
  // onResponse: pass through
  // ─────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  // ─────────────────────────────
  // onError: handle 401 → refresh
  // ─────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isRefreshEndpoint =
        err.requestOptions.path.contains('/auth/refresh');

    if (is401 && !isRefreshEndpoint && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _storageService.getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty) {
          final newAccessToken = await _doRefreshToken(refreshToken);

          if (newAccessToken != null) {
            // บันทึก token ใหม่
            await _storageService.saveAccessToken(newAccessToken);

            // Retry request เดิมด้วย token ใหม่
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await _dio.fetch(opts);
            _isRefreshing = false;
            return handler.resolve(response);
          }
        }
      } catch (_) {
        // Refresh ล้มเหลว
      } finally {
        _isRefreshing = false;
      }

      // Refresh ไม่สำเร็จ → ล้าง auth data ทิ้ง
      await _storageService.clearAuthData();
    }

    handler.next(err);
  }

  // ─────────────────────────────
  // Private: call refresh endpoint
  // ─────────────────────────────

  Future<String?> _doRefreshToken(String refreshToken) async {
    try {
      // ใช้ Dio instance ใหม่เพื่อหลีกเลี่ยง interceptor loop
      final tempDio = Dio(_dio.options);
      final response = await tempDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      return response.data['data']?['access_token'] as String?;
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────
// Logging Interceptor
// ─────────────────────────────────────────────

/// Log request / response / error แบบสวยงาม (Debug mode เท่านั้น)
class LoggingInterceptor extends Interceptor {
  static const _divider = '────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌$_divider');
      debugPrint('│ 🚀 ${options.method} ${options.uri}');

      if (options.headers.isNotEmpty) {
        debugPrint('│ Headers: ${_sanitizeHeaders(options.headers)}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│ Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└$_divider');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌$_divider');
      debugPrint(
        '│ ✅ ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
      debugPrint('│ Data: ${response.data}');
      debugPrint('└$_divider');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌$_divider');
      debugPrint('│ ❌ ${err.type.name} ${err.requestOptions.uri}');
      debugPrint('│ Status: ${err.response?.statusCode}');
      debugPrint('│ Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│ Response: ${err.response?.data}');
      }
      debugPrint('└$_divider');
    }
    handler.next(err);
  }

  /// ซ่อน Authorization token ใน log
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = 'Bearer [REDACTED]';
    }
    return sanitized;
  }
}
