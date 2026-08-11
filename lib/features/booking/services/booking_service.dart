import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class BookingService {
  final DioClient _dioClient;

  BookingService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// สร้างคำสั่งซื้อใหม่ (POST /api/orders)
  Future<Response> createOrder(Map<String, dynamic> orderData) {
    return _dioClient.post('/orders', data: orderData);
  }

  /// ดึงรายการคำสั่งซื้อทั้งหมด (GET /api/orders)
  Future<Response> getOrders({String? status}) {
    return _dioClient.get(
      '/orders',
      queryParameters: status != null ? {'status': status} : null,
    );
  }

  /// ดึงรายละเอียดออเดอร์ตาม ID (GET /api/orders/{id})
  Future<Response> getOrderDetail(dynamic id) {
    return _dioClient.get('/orders/$id');
  }

  /// คนขับกดรับงาน (POST /api/orders/{id}/accept)
  Future<Response> acceptOrder(dynamic id) {
    return _dioClient.post('/orders/$id/accept');
  }

  /// อัปเดตสถานะและพิกัดการจัดส่ง (POST /api/orders/{id}/status)
  Future<Response> updateOrderStatus(dynamic id, {
    required String status,
    String? note,
    double? latitude,
    double? longitude,
  }) {
    return _dioClient.post(
      '/orders/$id/status',
      data: {
        'status': status,
        if (note != null) 'note': note,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  /// ยกเลิกคำสั่งซื้อ (POST /api/orders/{id}/cancel)
  Future<Response> cancelOrder(dynamic id, {String? reason}) {
    return _dioClient.post(
      '/orders/$id/cancel',
      data: {
        if (reason != null) 'reason': reason,
      },
    );
  }
}
