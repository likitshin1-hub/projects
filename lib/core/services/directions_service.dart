import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final double distanceKm;
  final int durationMinutes;

  DirectionsResult({
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

class DirectionsService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Fetches real production-grade driving route geometry following actual roads
  /// using OSRM / Google Directions Routing Engine without cutting through buildings or rivers.
  static Future<DirectionsResult?> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    String? googleApiKey,
  }) async {
    // 1. First try Google Directions API if key provided
    if (googleApiKey != null && googleApiKey.isNotEmpty) {
      try {
        final googleUrl =
            'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$googleApiKey';

        final response = await _dio.get(googleUrl);
        if (response.statusCode == 200 && response.data['status'] == 'OK') {
          final routes = response.data['routes'] as List;
          if (routes.isNotEmpty) {
            final legs = routes[0]['legs'][0];
            final distanceMeters = (legs['distance']['value'] as num).toDouble();
            final durationSeconds = (legs['duration']['value'] as num).toInt();
            final encodedPolyline = routes[0]['overview_polyline']['points'] as String;

            final decodedPoints = _decodePolyline(encodedPolyline);
            return DirectionsResult(
              polylinePoints: decodedPoints,
              distanceKm: double.parse((distanceMeters / 1000).toStringAsFixed(1)),
              durationMinutes: (durationSeconds / 60).round(),
            );
          }
        }
      } catch (_) {
        // Fallback to OSRM Engine if Google Key has billing/restriction limits
      }
    }

    // 2. Production OSRM Global Routing Engine (100% Free, Zero Keys, 100% Accurate Road Geometry)
    try {
      final osrmUrl =
          'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

      final response = await _dio.get(osrmUrl);
      if (response.statusCode == 200 && response.data['code'] == 'Ok') {
        final routes = response.data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes[0];
          final distanceMeters = (route['distance'] as num).toDouble();
          final durationSeconds = (route['duration'] as num).toInt();
          final coordinates = route['geometry']['coordinates'] as List;

          final List<LatLng> polylinePoints = coordinates.map((coord) {
            final lng = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          return DirectionsResult(
            polylinePoints: polylinePoints,
            distanceKm: double.parse((distanceMeters / 1000).toStringAsFixed(1)),
            durationMinutes: (durationSeconds / 60).round(),
          );
        }
      }
    } catch (e) {
      // Return null on network error
    }

    return null;
  }

  /// Decode Google Encoded Polyline String
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}
