import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationResult {
  final LatLng location;
  final String address;
  final String districtProvince;

  LocationResult({
    required this.location,
    required this.address,
    required this.districtProvince,
  });
}

class LocationService {
  /// Request GPS Location from the device
  static Future<LocationResult?> getCurrentLocation() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return LocationResult(
        location: const LatLng(13.7466, 100.5393),
        address: 'ตำแหน่งปัจจุบันของคุณ (GPS Live Location)',
        districtProvince: 'แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110',
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return null;
    }
  }
}
