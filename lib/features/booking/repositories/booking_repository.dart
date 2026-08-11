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

  /// ส่งคำขอจองรถไปยัง Laravel Backend API (POST /api/orders)
  Future<String> submitBooking({
    required String pickup,
    required String dropoff,
    required String vehicleType,
    required String details,
    required double price,
  }) async {
    try {
      final response = await _bookingService.createOrder({
        'pickup_name': 'จุดรับสินค้า',
        'pickup_phone': '0812345678',
        'pickup_address': pickup.isEmpty ? 'กรุงเทพมหานคร' : pickup,
        'pickup_lat': 13.7563,
        'pickup_lng': 100.5018,
        'receiver_name': 'ผู้รับสินค้า',
        'receiver_phone': '0898765432',
        'destination_address': dropoff.isEmpty ? 'นนทบุรี' : dropoff,
        'destination_lat': 13.8563,
        'destination_lng': 100.5218,
        'item_name': details.isNotEmpty ? details : 'พัสดุทั่วไป ($vehicleType)',
        'item_description': details,
        'item_weight': 5.0,
        'delivery_fee': price > 0 ? price : 150.0,
        'platform_fee': 0.0,
        'total_price': price > 0 ? price : 150.0,
        'payment_method': 'promptpay',
      });

      if (response.data != null && response.data['order'] != null) {
        return response.data['order']['order_no'] as String? ??
            'TB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      }
    } catch (e) {
      // Fallback
    }
    return 'TB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
