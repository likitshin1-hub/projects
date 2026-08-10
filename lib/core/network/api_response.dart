/// Generic wrapper ที่ match กับ JSON response จาก Backend:
/// {
///   "success": true,
///   "message": "สำเร็จ",
///   "data": { ... },
///   "meta": { "page": 1, "total": 100, "per_page": 20 }
/// }
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final PaginationMeta? meta;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.meta,
  });

  // ─────────────────────────────────────────────
  // Factory constructors
  // ─────────────────────────────────────────────

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      statusCode: json['status_code'] as int?,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    PaginationMeta? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      meta: meta,
    );
  }

  factory ApiResponse.error({required String message, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  bool get hasData => data != null;
  bool get isSuccess => success;
  bool get hasMeta => meta != null;

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
}

// ─────────────────────────────────────────────
// Pagination Meta
// ─────────────────────────────────────────────

class PaginationMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final bool hasNextPage;

  const PaginationMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasNextPage = false,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final current = json['current_page'] as int? ?? json['page'] as int?;
    final last = json['last_page'] as int?;
    return PaginationMeta(
      currentPage: current,
      lastPage: last,
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
      hasNextPage: last != null && current != null && current < last,
    );
  }

  @override
  String toString() =>
      'PaginationMeta(page: $currentPage/$lastPage, total: $total)';
}
