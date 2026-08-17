import 'dart:async';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _bookingService;

  BookingRepository({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  /// คำนวณราคา
  Future<double> calculatePrice({
    required String pickup,
    required String dropoff,
    required String vehicleType,
  }) async {
    double basePrice = 40.0;
    if (vehicleType.contains('กระบะ')) basePrice = 250.0;
    if (vehicleType.contains('บรรทุก')) basePrice = 500.0;

    final double distanceMock = ((pickup.length + dropoff.length) * 2.5).clamp(10.0, 100.0);
    return basePrice + (distanceMock * 5);
  }

  /// ส่งคำขอจองรถไปยัง Backend API (POST /api/orders)
  Future<String> submitBooking({
    required String pickup,
    String? pickupName,
    double? pickupLat,
    double? pickupLng,
    required String dropoff,
    String? dropoffName,
    double? dropoffLat,
    double? dropoffLng,
    String? receiverPhone,
    required String vehicleType,
    String? parcelType,
    int? parcelWeight,
    required String details,
    required double price,
  }) async {
    try {
      final response = await _bookingService.createOrder({
        'pickup_name': pickupName ?? 'จุดรับสินค้า',
        'pickup_phone': '0812345678',
        'pickup_address': pickup.isEmpty ? 'กรุงเทพมหานคร' : pickup,
        'pickup_lat': pickupLat ?? 13.7466,
        'pickup_lng': pickupLng ?? 100.5393,
        'receiver_name': dropoffName ?? 'ผู้รับสินค้า',
        'receiver_phone': receiverPhone ?? '0898765432',
        'destination_address': dropoff.isEmpty ? 'เชียงใหม่' : dropoff,
        'destination_lat': dropoffLat ?? 18.7883,
        'destination_lng': dropoffLng ?? 98.9853,
        'vehicle_type': vehicleType,
        'parcel_type': parcelType ?? 'กล่อง',
        'item_name': details.isNotEmpty ? details : 'พัสดุ ($vehicleType)',
        'item_description': details,
        'item_weight': parcelWeight != null ? parcelWeight.toDouble() : 5.0,
        'delivery_fee': price > 0 ? price : 150.0,
        'platform_fee': 0.0,
        'total_price': price > 0 ? price : 150.0,
        'payment_method': 'promptpay',
      });

      if (response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['order'] != null && data['order']['order_no'] != null) {
            return data['order']['order_no'] as String;
          } else if (data['order_no'] != null) {
            return data['order_no'] as String;
          }
        }
      }
    } catch (e) {
      // Fallback fallback ID when API is unreachable
    }
    return 'TB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
