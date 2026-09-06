import 'dart:async';
import 'location_helper.dart';

Future<DeviceLocationResult> getPlatformLocation() async {
  return DeviceLocationResult(
    latitude: 13.3611,
    longitude: 100.9847,
    accuracy: 30.0,
    addressName: 'เมืองชลบุรี (พิกัดตรวจจับเซิร์ฟเวอร์)',
    isSuccess: true,
  );
}
