import 'dart:async';

class BookingRepository {
  /// จำลองการคำนวณราคา
  Future<double> calculatePrice({
    required String pickup,
    required String dropoff,
    required String vehicleType,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock API delay

    double basePrice = 0.0;
    switch (vehicleType) {
      case 'มอเตอร์ไซค์':
        basePrice = 40.0;
        break;
      case 'รถกระบะ':
        basePrice = 250.0;
        break;
      case 'รถบรรทุก':
        basePrice = 500.0;
        break;
      default:
        basePrice = 40.0;
    }

    // Mock distance calculation based on length of string just for variation
    final double distanceMock =
        ((pickup.length + dropoff.length) * 2.5).clamp(10.0, 100.0);

    return basePrice + (distanceMock * 5); // 5 THB per km mock
  }

  /// จำลองการส่งคำขอจองรถ
  Future<String> submitBooking({
    required String pickup,
    required String dropoff,
    required String vehicleType,
    required String details,
    required double price,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Mock API delay
    // Mock booking ID
    return 'TB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
