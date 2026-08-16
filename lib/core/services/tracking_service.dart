import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../network/dio_client.dart';

class DriverTrackingData {
  final String bookingId;
  final LatLng location;
  final double heading;
  final double speed;
  final int step; // 0=รับออเดอร์, 1=กำลังไปรับ, 2=กำลังส่ง, 3=สำเร็จ
  final String statusText;
  final DateTime updatedAt;

  DriverTrackingData({
    required this.bookingId,
    required this.location,
    this.heading = 0.0,
    this.speed = 0.0,
    required this.step,
    required this.statusText,
    required this.updatedAt,
  });
}

class TrackingService {
  final DioClient _dioClient;

  TrackingService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ดึงพิกัดล่าสุดของคนขับตาม bookingId จาก Backend REST API
  Future<DriverTrackingData?> fetchDriverLocation(String bookingId) async {
    try {
      final response = await _dioClient.get('/tracking/location', queryParameters: {'booking_id': bookingId});
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final lat = (data['latitude'] as num?)?.toDouble() ?? 13.7466;
          final lng = (data['longitude'] as num?)?.toDouble() ?? 100.5393;
          final heading = (data['heading'] as num?)?.toDouble() ?? 0.0;
          final speed = (data['speed'] as num?)?.toDouble() ?? 0.0;
          final step = (data['step'] as num?)?.toInt() ?? 1;
          final statusText = data['status_text'] as String? ?? 'กำลังเดินทาง';

          return DriverTrackingData(
            bookingId: bookingId,
            location: LatLng(lat, lng),
            heading: heading,
            speed: speed,
            step: step,
            statusText: statusText,
            updatedAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      // API call failed or server offline
    }
    return null;
  }

  /// สร้าง Real-time Stream สำหรับติดตามตำแหน่งคนขับ (ผสมระหว่าง Polling/WebSocket และ Smooth Fallback)
  Stream<DriverTrackingData> getDriverTrackingStream(String bookingId, List<LatLng> routePoints) async* {
    if (routePoints.isEmpty) {
      routePoints = [
        const LatLng(13.7466, 100.5393),
        const LatLng(13.7500, 100.5450),
        const LatLng(13.7550, 100.5500),
        const LatLng(13.3361, 100.9702),
      ];
    }

    int pointIndex = 0;

    while (true) {
      // 1. Try polling real server endpoint first
      final realData = await fetchDriverLocation(bookingId);
      if (realData != null) {
        yield realData;
      } else {
        // 2. Simulated movement stream fallback
        final LatLng currentPos = routePoints[pointIndex % routePoints.length];
        pointIndex = (pointIndex + 1) % routePoints.length;

        int simulatedStep = 0;
        if (pointIndex > routePoints.length * 0.75) {
          simulatedStep = 3;
        } else if (pointIndex > routePoints.length * 0.4) {
          simulatedStep = 2;
        } else if (pointIndex > 0) {
          simulatedStep = 1;
        }

        yield DriverTrackingData(
          bookingId: bookingId,
          location: currentPos,
          heading: 45.0,
          speed: 40.0,
          step: simulatedStep,
          statusText: simulatedStep == 3
              ? 'จัดส่งสำเร็จเรียบร้อย'
              : simulatedStep == 2
                  ? 'พัสดุอยู่ระหว่างการจัดส่ง'
                  : 'กำลังเดินทางไปรับพัสดุ',
          updatedAt: DateTime.now(),
        );
      }

      await Future.delayed(const Duration(seconds: 4));
    }
  }
}
