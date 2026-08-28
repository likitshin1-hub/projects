import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/directions_service.dart';
import '../../admin/models/admin_models.dart';
import '../../admin/providers/admin_provider.dart';

class DriverJobNavigationScreen extends ConsumerStatefulWidget {
  final AdminOrderModel? order;

  const DriverJobNavigationScreen({super.key, this.order});

  @override
  ConsumerState<DriverJobNavigationScreen> createState() => _DriverJobNavigationScreenState();
}

class _DriverJobNavigationScreenState extends ConsumerState<DriverJobNavigationScreen> {
  GoogleMapController? _mapController;

  // Step 1: Traveling to Pickup Location
  // Step 2: Traveling to Dropoff Location
  int _currentStep = 1;
  bool _isLoadingRoute = true;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  double _distanceKm = 1.2;
  int _durationMinutes = 4;

  late AdminOrderModel _activeOrder;

  BitmapDescriptor _riderArrowIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  Future<BitmapDescriptor> _createArrowBitmapDescriptor() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 48.0;

    // 1. Outer Shadow Circle
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, shadowPaint);

    // 2. Inner Solid Circle (Royal Navy Blue Rider Theme)
    final Paint circlePaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 4, circlePaint);

    // 3. Crisp White Border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 4, borderPaint);

    // 4. White Sharp Navigation Arrow (Chevron)
    final Path arrowPath = Path();
    arrowPath.moveTo(size / 2, 11); // Top tip
    arrowPath.lineTo(size / 2 + 10, 34); // Right corner
    arrowPath.lineTo(size / 2, 28); // Inner notch
    arrowPath.lineTo(size / 2 - 10, 34); // Left corner
    arrowPath.close();

    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  @override
  void initState() {
    super.initState();
    _activeOrder = widget.order ?? AdminOrderModel(
      orderNo: 'TB112044-8812',
      customerName: 'คุณพรทิพย์ สดใส',
      customerPhone: '086-443-2211',
      driverName: 'สมชาย ไรเดอร์',
      driverPhone: '081-234-5678',
      vehicleType: 'รถเก๋ง 4 ประตู',
      pickupAddress: 'ฟิวเจอร์พาร์ครังสิต ธัญบุรี ปทุมธานี',
      dropoffAddress: 'แจ้งวัฒนะ ปากเกร็ด นนทบุรี',
      amount: 250.0,
      status: AdminOrderStatus.accepted,
      pickupLat: 13.989,
      pickupLng: 100.617,
      dropoffLat: 13.903,
      dropoffLng: 100.528,
      currentDriverLat: 13.970,
      currentDriverLng: 100.600,
      createdAt: DateTime.now(),
    );

    _createArrowBitmapDescriptor().then((icon) {
      if (mounted) {
        setState(() {
          _riderArrowIcon = icon;
        });
        _loadRouteForCurrentStep();
      }
    });
  }

  Future<void> _loadRouteForCurrentStep() async {
    if (!mounted) return;
    setState(() {
      _isLoadingRoute = true;
    });

    final LatLng driverLocation = LatLng(_activeOrder.currentDriverLat, _activeOrder.currentDriverLng);
    final LatLng targetLocation = _currentStep == 1
        ? LatLng(_activeOrder.pickupLat, _activeOrder.pickupLng)
        : LatLng(_activeOrder.dropoffLat, _activeOrder.dropoffLng);

    // Fetch driving route using production OSRM / Google Directions Engine
    final directions = await DirectionsService.getDrivingRoute(
      origin: driverLocation,
      destination: targetLocation,
    );

    List<LatLng> polylinePoints = [];
    if (directions != null && directions.polylinePoints.isNotEmpty) {
      polylinePoints = directions.polylinePoints;
      _distanceKm = directions.distanceKm;
      _durationMinutes = directions.durationMinutes;
    } else {
      // Fallback straight route line if offline
      polylinePoints = [driverLocation, targetLocation];
      _distanceKm = _currentStep == 1 ? 1.2 : 3.5;
      _durationMinutes = _currentStep == 1 ? 4 : 10;
    }

    _updateMarkersAndPolylines(driverLocation, targetLocation, polylinePoints);

    if (_mapController != null) {
      _fitMapBounds(driverLocation, targetLocation);
    }

    if (mounted) {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _updateMarkersAndPolylines(LatLng driverLocation, LatLng targetLocation, List<LatLng> polylinePoints) {
    _markers.clear();
    _polylines.clear();

    // 1. Rider Marker (Current position - GPS Navigation Arrow)
    _markers.add(
      Marker(
        markerId: const MarkerId('rider'),
        position: driverLocation,
        icon: _riderArrowIcon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        infoWindow: const InfoWindow(title: '📍 ตำแหน่งไรเดอร์ (ปัจจุบัน)'),
      ),
    );

    // 2. Target Marker (Pickup in Step 1, Dropoff in Step 2)
    if (_currentStep == 1) {
      _markers.add(
        Marker(
          markerId: const MarkerId('target_pickup'),
          position: targetLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: '📦 จุดรับสินค้า', snippet: _activeOrder.pickupAddress),
        ),
      );
    } else {
      _markers.add(
        Marker(
          markerId: const MarkerId('target_dropoff'),
          position: targetLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: '🚩 จุดส่งสินค้า', snippet: _activeOrder.dropoffAddress),
        ),
      );
    }

    // 3. Polyline Route (Rider Theme Royal Navy Blue - Zero Green)
    _polylines.add(
      Polyline(
        polylineId: PolylineId(_currentStep == 1 ? 'route_to_pickup' : 'route_to_dropoff'),
        points: polylinePoints,
        color: const Color(0xFF1E3A8A),
        width: 7,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  void _fitMapBounds(LatLng origin, LatLng destination) {
    double southLat = origin.latitude < destination.latitude ? origin.latitude : destination.latitude;
    double northLat = origin.latitude > destination.latitude ? origin.latitude : destination.latitude;
    double westLng = origin.longitude < destination.longitude ? origin.longitude : destination.longitude;
    double eastLng = origin.longitude > destination.longitude ? origin.longitude : destination.longitude;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(southLat - 0.005, westLng - 0.005),
          northeast: LatLng(northLat + 0.005, eastLng + 0.005),
        ),
        60,
      ),
    );
  }

  void _openNavigation() {
    final LatLng targetLocation = _currentStep == 1
        ? LatLng(_activeOrder.pickupLat, _activeOrder.pickupLng)
        : LatLng(_activeOrder.dropoffLat, _activeOrder.dropoffLng);

    final targetName = _currentStep == 1 ? 'จุดรับสินค้า' : 'จุดส่งสินค้า';

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: targetLocation,
          zoom: 16.5,
          tilt: 45,
          bearing: 30,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🧭 เริ่มระบบนำทาง GPS มุ่งหน้าไปยัง$targetName',
          style: GoogleFonts.kanit(),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onConfirmPickup() {
    setState(() {
      _currentStep = 2;
    });

    // Update order status in Riverpod Admin Orders Provider backend
    ref.read(adminOrdersProvider.notifier).updateStatus(_activeOrder.orderNo, AdminOrderStatus.inTransit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 ยืนยันรับพัสดุเรียบร้อย! ระบบสลับเส้นทางไปยังจุดส่งสินค้า',
          style: GoogleFonts.kanit(),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadRouteForCurrentStep();
  }

  void _onConfirmDeliverySuccess() {
    // Update order status to COMPLETED in Riverpod Admin Orders Provider backend
    ref.read(adminOrdersProvider.notifier).updateStatus(_activeOrder.orderNo, AdminOrderStatus.completed);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 54),
            ),
            const SizedBox(height: 16),
            Text(
              'จัดส่งพัสดุสำเร็จเรียบร้อย!',
              style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F1F2A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'คุณได้รับรายได้เข้ากระเป๋าเงิน\n+฿${_activeOrder.amount.toStringAsFixed(2)}',
              style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.driver);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('กลับสู่หน้าหลักไรเดอร์', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final LatLng initialCenter = LatLng(_activeOrder.currentDriverLat, _activeOrder.currentDriverLng);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              _currentStep == 1 ? 'เส้นทางไปจุดรับสินค้า' : 'เส้นทางไปจุดส่งสินค้า',
              style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'หมายเลขคำสั่งซื้อ #${_activeOrder.orderNo}',
              style: GoogleFonts.kanit(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. REAL GOOGLE MAP VIEW
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              final driverLocation = LatLng(_activeOrder.currentDriverLat, _activeOrder.currentDriverLng);
              final targetLocation = _currentStep == 1
                  ? LatLng(_activeOrder.pickupLat, _activeOrder.pickupLng)
                  : LatLng(_activeOrder.dropoffLat, _activeOrder.dropoffLng);
              _fitMapBounds(driverLocation, targetLocation);
            },
          ),

          // Loading Overlay Indicator
          if (_isLoadingRoute)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'กำลังคำนวณเส้นทางจราจร...',
                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 2. FLOATING DISTANCE & TIME BADGE
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentStep == 1 ? Icons.navigation_rounded : Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_distanceKm กม. (ประมาณ $_durationMinutes นาที)',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BOTTOM ORDER SHEET & STEP NAVIGATION ACTION
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentStep == 1 ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _currentStep == 1 ? const Color(0xFFBFDBFE) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Text(
                        _currentStep == 1
                            ? '📍 ขั้นตอนที่ 1/2: กำลังเดินทางไปจุดรับสินค้า'
                            : '🚩 ขั้นตอนที่ 2/2: กำลังนำส่งพัสดุไปยังจุดส่งสินค้า',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _currentStep == 1 ? const Color(0xFF1D4ED8) : const Color(0xFF047857),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Customer Details Card & Call / Chat Actions
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: Color(0xFF1E3A8A), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ลูกค้า: ${_activeOrder.customerName}',
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  _activeOrder.customerPhone,
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('📞 โทรหาลูกค้า ${_activeOrder.customerPhone}...', style: GoogleFonts.kanit()),
                                  backgroundColor: const Color(0xFF1E3A8A),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981)),
                            tooltip: 'โทรหาลูกค้า',
                          ),
                          IconButton(
                            onPressed: () {
                              context.push(AppRoutes.chatDetail);
                            },
                            icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF3B82F6)),
                            tooltip: 'แชตกับลูกค้า',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pickup & Dropoff Address Highlight
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: _currentStep == 1 ? const Color(0xFF10B981) : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'จุดรับ: ${_activeOrder.pickupAddress}',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
                                    color: _currentStep == 1
                                        ? (isDarkMode ? Colors.white : const Color(0xFF0F172A))
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                color: _currentStep == 2 ? const Color(0xFFEF4444) : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'จุดส่ง: ${_activeOrder.dropoffAddress}',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
                                    color: _currentStep == 2
                                        ? (isDarkMode ? Colors.white : const Color(0xFF0F172A))
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Main Action Buttons Row (Navigation & Confirm Pickup / Delivery)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _openNavigation,
                              icon: const Icon(
                                Icons.near_me_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: Text(
                                'นำทาง',
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _currentStep == 1 ? _onConfirmPickup : _onConfirmDeliverySuccess,
                              icon: Icon(
                                _currentStep == 1 ? Icons.inventory_2_rounded : Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: Text(
                                _currentStep == 1
                                    ? 'ถึงจุดรับแล้ว • ยืนยันรับพัสดุ'
                                    : 'ถึงจุดส่งแล้ว • ยืนยันจัดส่งสำเร็จ',
                                style: GoogleFonts.kanit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
