import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/directions_service.dart';
import '../providers/booking_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const TrackingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0=รับออเดอร์, 1=กำลังไปรับ, 2=กำลังส่ง, 3=สำเร็จ
  Timer? _statusProgressTimer;
  BitmapDescriptor _riderMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  GoogleMapController? _mapController;
  late AnimationController _pulseController;

  bool _isLoadingRoute = true;
  String _distanceText = '82.9 กิโลเมตร';
  String _durationText = '1 ชั่วโมง 10 นาที';

  // Real GPS Coordinates: Central Chonburi (Origin) -> CentralWorld Bangkok (Destination)
  static const LatLng _centralChonburiLocation = LatLng(13.3361, 100.9702);
  static const LatLng _expresswayDriverLocation = LatLng(13.5412, 100.7510); // Burapha Withi Expressway (Bang Phli)
  static const LatLng _centralWorldLocation = LatLng(13.7466, 100.5393);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _liveRoutePoints = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initMapMarkersAndFetchProductionRoute();
    _startStatusSimulationTimer();
  }

  @override
  void dispose() {
    _statusProgressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStatusSimulationTimer() {
    _statusProgressTimer?.cancel();
    _statusProgressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
          _updateRiderMarkerForCurrentStep();
        });

        if (_currentStep == 3) {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              context.push(AppRoutes.deliverySuccess);
            }
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _updateRiderMarkerForCurrentStep() {
    if (_liveRoutePoints.isEmpty) return;

    double progressRatio = 0.0;
    if (_currentStep == 1) progressRatio = 0.25;
    if (_currentStep == 2) progressRatio = 0.65;
    if (_currentStep == 3) progressRatio = 1.0;

    int targetIndex = (progressRatio * (_liveRoutePoints.length - 1)).toInt();
    if (targetIndex >= _liveRoutePoints.length) targetIndex = _liveRoutePoints.length - 1;
    if (targetIndex < 0) targetIndex = 0;

    final newDriverLatLng = _liveRoutePoints[targetIndex];

    _markers.removeWhere((m) => m.markerId == const MarkerId('driver'));
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: newDriverLatLng,
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(
          title: 'ไรเดอร์ผู้จัดส่ง (สมปอง มีดี)',
          snippet: 'กำลังเดินทางส่งพัสดุตามเส้นทางเรียลไทม์',
        ),
        icon: _riderMarkerIcon,
      ),
    );

    try {
      _mapController?.animateCamera(CameraUpdate.newLatLng(newDriverLatLng));
    } catch (_) {}
  }

  String _getStatusTitle(int step, bool isEn) {
    switch (step) {
      case 0:
        return isEn ? 'Order Received & Driver En Route' : 'รับออเดอร์เรียบร้อยแล้ว ไรเดอร์กำลังไปรับพัสดุ';
      case 1:
        return isEn ? 'Package Picked Up & En Route' : 'ไรเดอร์รับพัสดุเรียบร้อยแล้ว กำลังมุ่งหน้าส่งสินค้า';
      case 2:
        return isEn ? 'Expressway Transit (In Progress)' : 'อยู่บนทางพิเศษบูรพาวิถี (กม.22 บางพลี)';
      case 3:
      default:
        return isEn ? 'Package Delivered Successfully! 🎉' : 'จัดส่งพัสดุถึงมือผู้รับสำเร็จเรียบร้อยแล้ว! 🎉';
    }
  }

  String _getEtaText(int step, bool isEn) {
    switch (step) {
      case 0:
        return isEn ? 'Est. 45 Mins' : 'ประมาณ 45 นาที';
      case 1:
        return isEn ? 'Est. 30 Mins' : 'ประมาณ 30 นาที';
      case 2:
        return isEn ? 'Est. 15 Mins' : 'ประมาณ 15 นาที';
      case 3:
      default:
        return isEn ? 'Delivered' : 'จัดส่งสำเร็จ';
    }
  }

  void _recenterMap() {
    final bookingState = ref.read(bookingProvider);
    final driverLocation = LatLng(
      (bookingState.pickupLat + bookingState.dropoffLat) / 2,
      (bookingState.pickupLng + bookingState.dropoffLng) / 2,
    );

    try {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: driverLocation,
            zoom: 10.5,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<BitmapDescriptor> _createCustomVehicleMarkerIcon(String vehicleType) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const double size = 110.0;

    // Outer shadow glow
    final shadowPaint = Paint()
      ..color = const Color(0xFF1C7FF6).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(const Offset(size / 2, size / 2), 44, shadowPaint);

    // Outer white border circle
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), 40, borderPaint);

    // Inner primary blue circle
    final circlePaint = Paint()
      ..color = const Color(0xFF1C7FF6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), 34, circlePaint);

    // Motorbike icon by default
    IconData iconData = Icons.two_wheeler_rounded;
    if (vehicleType.contains('เก๋ง')) {
      iconData = Icons.directions_car_rounded;
    } else if (vehicleType.contains('กระบะ')) {
      iconData = Icons.airport_shuttle_rounded;
    } else if (vehicleType.contains('ห้องเย็น') || vehicleType.contains('บรรทุก')) {
      iconData = Icons.local_shipping_rounded;
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 38,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    final Uint8List pngBytes = byteData.buffer.asUint8List();

    return BitmapDescriptor.bytes(pngBytes);
  }

  Future<void> _initMapMarkersAndFetchProductionRoute() async {
    final bookingState = ref.read(bookingProvider);
    final pickupLatLng = LatLng(bookingState.pickupLat, bookingState.pickupLng);
    final dropoffLatLng = LatLng(bookingState.dropoffLat, bookingState.dropoffLng);

    // Dynamic driver position along the route
    final driverLatLng = LatLng(
      (pickupLatLng.latitude + dropoffLatLng.latitude) / 2,
      (pickupLatLng.longitude + dropoffLatLng.longitude) / 2,
    );

    // Immediately show initial map markers synchronously to prevent flashing/glitching
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupLatLng,
            infoWindow: InfoWindow(
              title: 'จุดรับสินค้า',
              snippet: bookingState.pickupName.isNotEmpty ? bookingState.pickupName : 'จุดรับพัสดุ',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );

        _markers.add(
          Marker(
            markerId: const MarkerId('dropoff'),
            position: dropoffLatLng,
            infoWindow: InfoWindow(
              title: 'จุดส่งสินค้า',
              snippet: bookingState.dropoffName.isNotEmpty ? bookingState.dropoffName : 'จุดส่งพัสดุ',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );

        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: driverLatLng,
            anchor: const Offset(0.5, 0.5),
            infoWindow: const InfoWindow(
              title: 'ไรเดอร์ผู้จัดส่ง (สมปอง มีดี)',
              snippet: 'กำลังเดินทางส่งพัสดุตามเส้นทางเรียลไทม์',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });
    }

    // Generate custom canvas vehicle icon asynchronously & update rider marker cleanly
    try {
      _riderMarkerIcon = await _createCustomVehicleMarkerIcon(bookingState.vehicleType);
      if (mounted) {
        setState(() {
          _markers.removeWhere((m) => m.markerId == const MarkerId('driver'));
          _markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: driverLatLng,
              anchor: const Offset(0.5, 0.5),
              infoWindow: const InfoWindow(
                title: 'ไรเดอร์ผู้จัดส่ง (สมปอง มีดี)',
                snippet: 'กำลังเดินทางส่งพัสดุตามเส้นทางเรียลไทม์',
              ),
              icon: _riderMarkerIcon,
            ),
          );
        });
      }
    } catch (_) {}

    // Fetch Real Production Driving Route from Routing Engine (OSRM / Google)
    final result = await DirectionsService.getDrivingRoute(
      origin: pickupLatLng,
      destination: dropoffLatLng,
    );

    if (mounted) {
      setState(() {
        _isLoadingRoute = false;
        if (result != null && result.polylinePoints.isNotEmpty) {
          _liveRoutePoints = result.polylinePoints;

          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('real_production_route'),
              points: _liveRoutePoints,
              color: const Color(0xFF1C7FF6),
              width: 6,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

          _updateRiderMarkerForCurrentStep();
          _fitCameraToBounds();
        } else {
          // Fallback straight line polyline if no internet
          _liveRoutePoints = [pickupLatLng, driverLatLng, dropoffLatLng];
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('real_production_route'),
              points: _liveRoutePoints,
              color: const Color(0xFF1C7FF6),
              width: 5,
            ),
          );
          _fitCameraToBounds();
        }
      });
    }
  }

  void _fitCameraToBounds() {
    if (_mapController == null || _liveRoutePoints.isEmpty) return;

    double minLat = _liveRoutePoints.first.latitude;
    double maxLat = _liveRoutePoints.first.latitude;
    double minLng = _liveRoutePoints.first.longitude;
    double maxLng = _liveRoutePoints.first.longitude;

    for (var point in _liveRoutePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (_) {}
  }

  Widget _buildMapContent(bool isDarkMode) {
    final bookingState = ref.read(bookingProvider);
    final driverLatLng = LatLng(
      (bookingState.pickupLat + bookingState.dropoffLat) / 2,
      (bookingState.pickupLng + bookingState.dropoffLng) / 2,
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: driverLatLng,
        zoom: 10.5,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        if (_liveRoutePoints.isNotEmpty) {
          _fitCameraToBounds();
        }
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;
    final bookingState = ref.watch(bookingProvider);

    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final displayBookingId = widget.bookingId.isEmpty ? 'B25538914' : widget.bookingId;

    final dynamicPickup = bookingState.pickupName.isNotEmpty ? bookingState.pickupName : 'จุดรับสินค้า';
    final dynamicDropoff = bookingState.dropoffName.isNotEmpty ? bookingState.dropoffName : 'จุดส่งสินค้า';
    final dynamicDistance = '${bookingState.distanceKm} กิโลเมตร';
    final dynamicDuration = '${bookingState.estimatedDurationMinutes} นาที';

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // ==========================================
          // 1. FULL-SCREEN 100% GOOGLE MAPS BACKGROUND
          // ==========================================
          Positioned.fill(
            child: _buildMapContent(isDarkMode),
          ),

          // TOP LEFT: GOOGLE MAPS LIVE ROAD ROUTE BADGE
          Positioned(
            top: statusBarHeight + 74,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDarkMode ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLoadingRoute ? Icons.sync_rounded : Icons.alt_route_rounded,
                    color: const Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isLoadingRoute ? 'กำลังคำนวณเส้นทางถนนจริง...' : 'เส้นทางถนนจริง (Directions API)',
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF3C4043),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TOP RIGHT: FLOATING MAP RECENTER CONTROL
          Positioned(
            top: statusBarHeight + 74,
            right: 16,
            child: _buildMapControlButton(
              icon: Icons.my_location_rounded,
              color: const Color(0xFF1C7FF6),
              onTap: _recenterMap,
              isDark: isDarkMode,
              borderColor: borderColor,
            ),
          ),

          // ==========================================
          // 2. TOP FLOATING APP BAR
          // ==========================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentLang == AppLanguage.en ? 'Interprovincial Delivery Tracking' : 'ติดตามการจัดส่งพัสดุข้ามจังหวัด',
                          style: GoogleFonts.kanit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          currentLang == AppLanguage.en ? 'Live Road Navigation (Real-Time GPS)' : 'เส้นทางถนนจริง (Real-Time GPS)',
                          style: GoogleFonts.kanit(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    onPressed: () => context.push(AppRoutes.notification),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. INTERACTIVE DRAGGABLE DETAILS BOTTOM SHEET
          // ==========================================
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.16,
            maxChildSize: 0.86,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  children: [
                    // Sheet Drag Handle Pill Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  // CARD 1: DRIVER INFO CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1C7FF6).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(color: cardBg, width: 2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'นาย สมปอง มีดี',
                                      style: GoogleFonts.kanit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: Color(0xFF1C7FF6), size: 16),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Isuzu D-Max ตู้ทึบ (ทะเบียน 1กข-9999 ชลบุรี)',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: subTextColor,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    ' (326 รีวิว)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            InkWell(
                              onTap: () => context.push('${AppRoutes.chat}/driver_123'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.4)),
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1C7FF6), size: 19),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => context.push('${AppRoutes.call}/driver_123'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                                ),
                                child: const Icon(Icons.phone_outlined, color: Color(0xFF22C55E), size: 19),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CARD 2: TRACKING TIMELINE STATUS CARD
                  InkWell(
                    onTap: () => context.push('${AppRoutes.trackingDetail}/$displayBookingId'),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'สถานะการจัดส่งพัสดุข้ามจังหวัด',
                                      style: GoogleFonts.kanit(
                                        fontSize: 12.5,
                                        color: subTextColor,
                                      ),
                                    ),
                                    Text(
                                      _getStatusTitle(_currentStep, isEn),
                                      style: GoogleFonts.kanit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getEtaText(_currentStep, isEn),
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C7FF6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTimelineStep(0, Icons.assignment_turned_in_rounded, 'รับออเดอร์', isDarkMode),
                              _buildTimelineLine(0, isDarkMode),
                              _buildTimelineStep(1, Icons.directions_bike_rounded, 'รับพัสดุแล้ว', isDarkMode),
                              _buildTimelineLine(1, isDarkMode),
                              _buildTimelineStep(2, Icons.local_shipping_rounded, 'บนทางด่วน', isDarkMode),
                              _buildTimelineLine(2, isDarkMode),
                              _buildTimelineStep(3, Icons.check_circle_rounded, 'สำเร็จ', isDarkMode),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CARD 3: ORDER DETAILS SUMMARY CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_rounded, color: Color(0xFF1C7FF6), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'รายละเอียดการเดินทางข้ามจังหวัด',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryBox(
                                title: 'ต้นทาง ➔ ปลายทาง',
                                value: '$dynamicPickup ➔ $dynamicDropoff',
                                icon: Icons.map_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryBox(
                                title: 'ระยะทางทั้งหมด (คำนวณจริง)',
                                value: dynamicDistance,
                                icon: Icons.straighten_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSummaryBox(
                                title: 'เวลาเดินทางทั้งหมด',
                                value: dynamicDuration,
                                icon: Icons.access_time_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildSummaryBox(
                          title: 'ยานพาหนะและค่าบริการจัดส่ง',
                          value: '${bookingState.vehicleType} | ค่าบริการ net: ${bookingState.estimatedPrice.toInt()} บาท',
                          icon: Icons.local_shipping_rounded,
                          isDark: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // CARD 4: FULL DETAILS BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        context.push('${AppRoutes.trackingDetail}/$displayBookingId');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.format_list_bulleted_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ดูรายละเอียดพัสดุเต็มรูปแบบ',
                            style: GoogleFonts.kanit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );
}

  Widget _buildMapControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1C7FF6)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(int stepIndex, IconData icon, String label, bool isDark) {
    final bool isCompleted = stepIndex <= _currentStep;
    final bool isCurrent = stepIndex == _currentStep;

    final circleColor = isCompleted
        ? (isCurrent ? const Color(0xFF1C7FF6) : const Color(0xFF10B981))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final iconColor = isCompleted ? Colors.white : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8));

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent
                ? const Color(0xFF1C7FF6)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(int stepIndex, bool isDark) {
    final bool isCompleted = stepIndex < _currentStep;
    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}


