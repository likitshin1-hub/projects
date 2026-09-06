import 'dart:async';
import 'dart:html' as html;
import 'location_helper.dart';

Future<DeviceLocationResult> getPlatformLocation() async {
  final completer = Completer<DeviceLocationResult>();

  try {
    html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 10),
      maximumAge: const Duration(minutes: 1),
    ).then((position) {
      final coords = position.coords;
      if (coords != null) {
        final lat = coords.latitude?.toDouble() ?? 13.3611;
        final lng = coords.longitude?.toDouble() ?? 100.9847;
        final acc = coords.accuracy?.toDouble() ?? 15.0;

        String areaName = 'พิกัดปัจจุบันของคุณ';
        if (lat >= 12.8 && lat <= 13.5 && lng >= 100.8 && lng <= 101.2) {
          if (lat < 13.0) {
            areaName = 'พัทยา / บางละมุง, ชลบุรี';
          } else if (lat < 13.25) {
            areaName = 'ศรีราชา / แหลมฉบัง, ชลบุรี';
          } else if (lat < 13.32) {
            areaName = 'หาดบางแสน / ม.บูรพา, ชลบุรี';
          } else {
            areaName = 'เมืองชลบุรี / นิคมอมตะซิตี้';
          }
        } else if (lat >= 13.5 && lat <= 13.95 && lng >= 100.3 && lng <= 100.75) {
          areaName = 'กรุงเทพมหานครและปริมณฑล';
        }

        completer.complete(DeviceLocationResult(
          latitude: lat,
          longitude: lng,
          accuracy: acc,
          addressName: areaName,
          isSuccess: true,
        ));
      } else {
        completer.complete(DeviceLocationResult(
          latitude: 13.3611,
          longitude: 100.9847,
          accuracy: 50.0,
          addressName: 'ชลบุรี (ศูนย์บริการภาคตะวันออก)',
          isSuccess: true,
        ));
      }
    }).catchError((error) {
      completer.complete(DeviceLocationResult(
        latitude: 13.3611,
        longitude: 100.9847,
        accuracy: 50.0,
        addressName: 'เมืองชลบุรี (ศูนย์บริการโซนตะวันออก)',
        isSuccess: false,
        errorMessage: 'ผู้ใช้ไม่อนุญาตการเข้าถึงพิกัด GPS: $error',
      ));
    });
  } catch (e) {
    completer.complete(DeviceLocationResult(
      latitude: 13.3611,
      longitude: 100.9847,
      accuracy: 50.0,
      addressName: 'เมืองชลบุรี (พิกัดเริ่มต้นโซนตะวันออก)',
      isSuccess: false,
      errorMessage: e.toString(),
    ));
  }

  return completer.future;
}
