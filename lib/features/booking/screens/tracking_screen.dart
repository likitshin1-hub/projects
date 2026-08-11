import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const TrackingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> with SingleTickerProviderStateMixin {
  final int _currentStep = 2; // 0=รับออเดอร์, 1=กำลังไปรับ, 2=กำลังส่ง, 3=สำเร็จ
  GoogleMapController? _mapController;
  late AnimationController _pulseController;

  bool _useCanvasMap = false;
  double _zoomLevel = 1.0;
  Offset _mapOffset = Offset.zero;

  // Real GPS Coordinates (Chonburi / Bangsaen Route)
  static const LatLng _pickupLocation = LatLng(13.2849, 100.9238);
  static const LatLng _driverLocation = LatLng(13.2895, 100.9285);
  static const LatLng _dropoffLocation = LatLng(13.2970, 100.9350);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initMapMarkersAndRoutes();
  }

  void _initMapMarkersAndRoutes() {
    // Pickup Marker (Green)
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        infoWindow: const InfoWindow(title: 'จุดรับสินค้า', snippet: 'คลัง TB MOVEHUB'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // Dropoff Marker (Red)
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: _dropoffLocation,
        infoWindow: const InfoWindow(title: 'จุดส่งสินค้า', snippet: 'บ้านบางแสน ชลบุรี'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Driver Marker (Blue)
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation,
        infoWindow: const InfoWindow(title: 'คนขับ (สมปอง มีดี)', snippet: 'กำลังเดินทางไปส่งสินค้า'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Polyline Route Path Line
    _polylines.add(
      const Polyline(
        polylineId: PolylineId('route'),
        points: [_pickupLocation, _driverLocation, _dropoffLocation],
        color: Color(0xFF1C7FF6),
        width: 6,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _recenterMap() {
    setState(() {
      _mapOffset = Offset.zero;
      _zoomLevel = 1.0;
    });

    try {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: _driverLocation,
            zoom: 15.0,
          ),
        ),
      );
    } catch (_) {}
  }

  Widget _buildMapContent(bool isDarkMode) {
    if (_useCanvasMap) {
      return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _mapOffset += details.delta;
          });
        },
        child: Transform.translate(
          offset: _mapOffset,
          child: Transform.scale(
            scale: _zoomLevel,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _RealisticGoogleMapPainter(
                    isDarkMode: isDarkMode,
                    pulseProgress: _pulseController.value,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _driverLocation,
        zoom: 14.5,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
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

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final displayBookingId = widget.bookingId.isEmpty ? 'B25538914' : widget.bookingId;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==========================================
          // 1. TOP APP BAR
          // ==========================================
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                  child: Text(
                    'ติดตามพัสดุแบบเรียลไทม์',
                    style: GoogleFonts.kanit(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.notification),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. REAL GOOGLE MAPS SECTION (TOP HALF)
          // ==========================================
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
            child: ClipRect(
              child: Stack(
                children: [
                  _buildMapContent(isDarkMode),

                  // TOP LEFT: GOOGLE MAPS LIVE BADGE & MODE TOGGLE
                  Positioned(
                    top: 12,
                    left: 14,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _useCanvasMap = !_useCanvasMap;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (isDarkMode ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_rounded, color: Color(0xFF4285F4), size: 15),
                            const SizedBox(width: 5),
                            Text(
                              _useCanvasMap ? 'Google Maps 3D Live' : 'Google Maps Official SDK',
                              style: GoogleFonts.kanit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF3C4043),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF1C7FF6)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // BOTTOM RIGHT: MAP CONTROLS
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMapControlButton(
                          icon: Icons.my_location_rounded,
                          color: const Color(0xFF1C7FF6),
                          onTap: _recenterMap,
                          isDark: isDarkMode,
                          borderColor: borderColor,
                        ),
                        if (_useCanvasMap) ...[
                          const SizedBox(height: 8),
                          _buildMapControlButton(
                            icon: Icons.add_rounded,
                            color: isDarkMode ? Colors.white : const Color(0xFF3C4043),
                            onTap: () {
                              setState(() {
                                _zoomLevel = (_zoomLevel + 0.15).clamp(0.8, 2.0);
                              });
                            },
                            isDark: isDarkMode,
                            borderColor: borderColor,
                          ),
                          const SizedBox(height: 6),
                          _buildMapControlButton(
                            icon: Icons.remove_rounded,
                            color: isDarkMode ? Colors.white : const Color(0xFF3C4043),
                            onTap: () {
                              setState(() {
                                _zoomLevel = (_zoomLevel - 0.15).clamp(0.8, 2.0);
                              });
                            },
                            isDark: isDarkMode,
                            borderColor: borderColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider Line
          Container(
            height: 3,
            color: const Color(0xFF1C7FF6),
          ),

          // ==========================================
          // 3. SCROLLABLE DETAILS SHEET (BOTTOM HALF)
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                                'Honda Wave 125i สีดำ (ทะเบียน 1กข-9999)',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'สถานะการจัดส่งพัสดุ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12.5,
                                      color: subTextColor,
                                    ),
                                  ),
                                  Text(
                                    'คนขับกำลังเดินทางไปรับสินค้า',
                                    style: GoogleFonts.kanit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ประมาณ 15 นาที',
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
                              _buildTimelineStep(1, Icons.directions_bike_rounded, 'กำลังไปรับ', isDarkMode),
                              _buildTimelineLine(1, isDarkMode),
                              _buildTimelineStep(2, Icons.local_shipping_rounded, 'กำลังส่ง', isDarkMode),
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
                              'รายละเอียดออเดอร์',
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
                                title: 'รหัสออเดอร์',
                                value: displayBookingId,
                                icon: Icons.tag_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSummaryBox(
                                title: 'วันที่ / เวลา',
                                value: '18 พ.ค. | 15:20น.',
                                icon: Icons.calendar_today_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildSummaryBox(
                          title: 'ระยะทาง / น้ำหนักสินค้า',
                          value: '3.8 กิโลเมตร  •  1.2 กิโลกรัม',
                          icon: Icons.straighten_rounded,
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
            ),
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

// Custom Painter for Realistic Google Maps Rendering
class _RealisticGoogleMapPainter extends CustomPainter {
  final bool isDarkMode;
  final double pulseProgress;

  _RealisticGoogleMapPainter({
    required this.isDarkMode,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Map Background Tile Color
    final baseLandColor = isDarkMode ? const Color(0xFF191A1A) : const Color(0xFFF4F3F0);
    canvas.drawRect(Offset.zero & size, Paint()..color = baseLandColor);

    // 2. Draw Parks / Greenery Areas
    final parkPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1D2B24) : const Color(0xFFC8E6C9).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final parkPath1 = Path()
      ..addOval(Rect.fromLTWH(size.width * 0.05, size.height * 0.1, 140, 90));
    final parkPath2 = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.55, 120, 110),
        const Radius.circular(16),
      ));
    canvas.drawPath(parkPath1, parkPaint);
    canvas.drawPath(parkPath2, parkPaint);

    // 3. Draw Water River Stream
    final waterPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF121E2C) : const Color(0xFFAAD3DF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(-20, size.height * 0.85);
    riverPath.cubicTo(
      size.width * 0.3, size.height * 0.95,
      size.width * 0.5, size.height * 0.65,
      size.width + 20, size.height * 0.75,
    );
    canvas.drawPath(riverPath, waterPaint);

    // 4. Draw Minor & Major Roads (Google Maps Road Styling)
    final minorRoadPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF2C2D2E) : Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final majorRoadPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF38393A) : const Color(0xFFFFD54F)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // Secondary streets
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), minorRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), minorRoadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), minorRoadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), minorRoadPaint);

    // Highway / Main Road
    final highwayPath = Path();
    highwayPath.moveTo(size.width * 0.1, 0);
    highwayPath.lineTo(size.width * 0.85, size.height);
    canvas.drawPath(highwayPath, majorRoadPaint);

    // 5. Draw GPS Navigation Route Line (Vibrant Blue Google Route)
    final routeGlowPaint = Paint()
      ..color = const Color(0xFF4285F4).withValues(alpha: 0.35)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePathPaint = Paint()
      ..color = const Color(0xFF1A73E8)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routePath = Path();
    final startPt = Offset(size.width * 0.18, size.height * 0.78);
    final driverPt = Offset(size.width * 0.42, size.height * 0.52);
    final midPt = Offset(size.width * 0.62, size.height * 0.42);
    final destPt = Offset(size.width * 0.82, size.height * 0.22);

    routePath.moveTo(startPt.dx, startPt.dy);
    routePath.lineTo(driverPt.dx, driverPt.dy);
    routePath.lineTo(midPt.dx, midPt.dy);
    routePath.lineTo(destPt.dx, destPt.dy);

    canvas.drawPath(routePath, routeGlowPaint);
    canvas.drawPath(routePath, routePathPaint);

    // 6. Draw Pickup Pin (Green)
    _drawLocationPin(
      canvas,
      startPt,
      const Color(0xFF22C55E),
      'จุดรับ',
      Icons.store_rounded,
      isDarkMode,
    );

    // 7. Draw Dropoff Pin (Red)
    _drawLocationPin(
      canvas,
      destPt,
      const Color(0xFFEF4444),
      'จุดส่ง (บ้านบางแสน)',
      Icons.location_on_rounded,
      isDarkMode,
    );

    // 8. Draw Live Driver Vehicle Pin with Pulse Ring
    final pulseRadius = 14 + (pulseProgress * 16);
    final pulseOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0);
    final pulsePaint = Paint()
      ..color = const Color(0xFF1C7FF6).withValues(alpha: pulseOpacity * 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(driverPt, pulseRadius, pulsePaint);

    // Driver vehicle circle marker
    final vehicleBgPaint = Paint()..color = const Color(0xFF1C7FF6);
    final vehicleBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(driverPt, 16, vehicleBgPaint);
    canvas.drawCircle(driverPt, 16, vehicleBorderPaint);

    // Draw driver popup bubble above marker
    _drawDriverBubble(canvas, Offset(driverPt.dx, driverPt.dy - 28), isDarkMode);
  }

  void _drawLocationPin(
    Canvas canvas,
    Offset position,
    Color color,
    String label,
    IconData icon,
    bool isDark,
  ) {
    // Pin Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(position.dx, position.dy + 2), 10, shadowPaint);

    // Pin Body
    final pinPaint = Paint()..color = color;
    final pinBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, 10, pinPaint);
    canvas.drawCircle(position, 10, pinBorder);

    // Label Text Box above Pin
    final textSpan = TextSpan(
      text: label,
      style: GoogleFonts.kanit(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1F2937),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(position.dx, position.dy - 22),
        width: textPainter.width + 12,
        height: textPainter.height + 6,
      ),
      const Radius.circular(8),
    );

    final bgPaint = Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, borderPaint);

    textPainter.paint(
      canvas,
      Offset(position.dx - (textPainter.width / 2), position.dy - 22 - (textPainter.height / 2)),
    );
  }

  void _drawDriverBubble(Canvas canvas, Offset position, bool isDark) {
    final textSpan = TextSpan(
      text: '🛵 คนขับกำลังไป (15 นาที)',
      style: GoogleFonts.kanit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: textPainter.width + 16,
        height: textPainter.height + 8,
      ),
      const Radius.circular(10),
    );

    final bgPaint = Paint()..color = const Color(0xFF1C7FF6);
    canvas.drawRRect(bgRect, bgPaint);

    textPainter.paint(
      canvas,
      Offset(position.dx - (textPainter.width / 2), position.dy - (textPainter.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _RealisticGoogleMapPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode || oldDelegate.pulseProgress != pulseProgress;
  }
}
