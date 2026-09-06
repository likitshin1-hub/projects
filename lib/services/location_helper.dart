import 'dart:async';

import 'location_helper_web.dart' if (dart.library.io) 'location_helper_io.dart';

class DeviceLocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String addressName;
  final bool isSuccess;
  final String? errorMessage;

  DeviceLocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.addressName,
    required this.isSuccess,
    this.errorMessage,
  });
}

class LocationService {
  static Future<DeviceLocationResult> getCurrentDeviceLocation() async {
    return await getPlatformLocation();
  }
}
