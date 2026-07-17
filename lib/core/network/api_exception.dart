import 'package:dio/dio.dart';

// ─────────────────────────────────────────────
// Base Exception
// ─────────────────────────────────────────────

abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => message;
}


// ─────────────────────────────────────────────
// Network Exceptions
// ─────────────────────────────────────────────

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้',
  });
}


class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่',
  });
}


class CancelledException extends AppException {
  const CancelledException({
    super.message = 'คำขอถูกยกเลิก',
  });
}


// ─────────────────────────────────────────────
// HTTP Exceptions
// ─────────────────────────────────────────────

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'กรุณาเข้าสู่ระบบใหม่อีกครั้ง',
    super.statusCode = 401,
  });
}


class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้',
    super.statusCode = 403,
  });
}


class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'ไม่พบข้อมูลที่ต้องการ',
    super.statusCode = 404,
  });
}


class ValidationException extends AppException {

  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง',
    super.statusCode = 422,
    this.errors,
  });


  String? firstErrorOf(String field) =>
      errors?[field]?.firstOrNull;


  String get allErrors {

    if (errors == null || errors!.isEmpty) {
      return message;
    }

    return errors!.values
        .expand((e) => e)
        .join('\n');

  }

}


class TooManyRequestsException extends AppException {
  const TooManyRequestsException({
    super.message = 'คำขอมากเกินไป กรุณารอสักครู่',
    super.statusCode = 429,
  });
}


class ServerException extends AppException {

  const ServerException({
    super.message = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ กรุณาลองใหม่',
    super.statusCode,
  });

}


class UnknownException extends AppException {
  const UnknownException({
    super.message = 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
  });
}


// ─────────────────────────────────────────────
// DioException → AppException Converter
// ─────────────────────────────────────────────

AppException handleDioException(DioException e) {

  switch (e.type) {

    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();


    case DioExceptionType.cancel:
      return const CancelledException();


    case DioExceptionType.connectionError:
      return const NetworkException();


    case DioExceptionType.badResponse:

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final message = _extractMessage(data);


      return switch (statusCode) {

        401 => UnauthorizedException(
            message: message ?? 'กรุณาเข้าสู่ระบบใหม่อีกครั้ง',
          ),


        403 => ForbiddenException(
            message: message ?? 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้',
          ),


        404 => NotFoundException(
            message: message ?? 'ไม่พบข้อมูลที่ต้องการ',
          ),


        422 => ValidationException(
            message: message ?? 'ข้อมูลไม่ถูกต้อง',
            errors: _extractValidationErrors(data),
          ),


        429 => TooManyRequestsException(
            message: message ?? 'คำขอมากเกินไป กรุณารอสักครู่',
          ),


        int code when code >= 500 => ServerException(
            message: message ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์',
            statusCode: code,
          ),


        _ => UnknownException(
            message: message ?? 'เกิดข้อผิดพลาด (HTTP $statusCode)',
          ),

      };


    default:

      return UnknownException(
        message: e.message ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
      );

  }

}


// ─────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────

String? _extractMessage(dynamic data) {

  if (data is Map<String, dynamic>) {

    return data['message'] as String? ??
        data['error'] as String?;

  }

  return null;

}



Map<String, List<String>>? _extractValidationErrors(dynamic data) {

  if (data is Map<String, dynamic>) {

    final raw = data['errors'];


    if (raw is Map) {

      return raw.map((key, value) {

        final messages = value is List
            ? value.map((e) => e.toString()).toList()
            : [value.toString()];


        return MapEntry(
          key.toString(),
          messages,
        );

      });

    }

  }

  return null;

}