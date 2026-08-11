import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const TrackingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final int _currentStep = 2; // Step index: 0=รับออเดอร์, 1=คนขับกำลังไป, 2=กำลังเดินทาง, 3=ใกล้ถึง, 4=สำเร็จ

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
          // 1. TOP HEADER WITH GRADIENT BAR
          // ==========================================
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 16),
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
                    'ติดตามพัสดุ',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
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
          // 2. MAIN BODY (MAP + OVERLAY CONTENT)
          // ==========================================
          Expanded(
            child: Stack(
              children: [
                // MAP BACKGROUND & ROUTE PAINTER
                Positioned.fill(
                  child: Container(
                    color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    child: Stack(
                      children: [
                        // Map Grid Lines (Dark / Light pattern)
                        CustomPaint(
                          size: Size.infinite,
                          painter: _MapGridPainter(isDarkMode: isDarkMode),
                        ),

                        // Fake Animated Route Path Line
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _FakeRoutePainter(isDarkMode: isDarkMode),
                          ),
                        ),

                        // Destination Pin Badge
                        Positioned(
                          top: 40,
                          right: 40,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.flag_rounded, color: Color(0xFFEF4444), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'จุดส่งสินค้า',
                                      style: GoogleFonts.kanit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 36),
                            ],
                          ),
                        ),

                        // Driver Live Location Pin Badge
                        Positioned(
                          bottom: 240,
                          left: 60,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C7FF6),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_car_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'คนขับอยู่ตรงนี้',
                                  style: GoogleFonts.kanit(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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

                // SCROLLABLE OVERLAY CARDS AT BOTTOM
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ------------------------------------------
                          // CARD 1: DRIVER INFORMATION CARD
                          // ------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Driver Avatar with Online Glow Ring
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
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
                                      child: const Icon(Icons.person_rounded, size: 34, color: Colors.white),
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

                                // Driver Details Text
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
                                          fontSize: 12.5,
                                          color: subTextColor,
                                          height: 1.25,
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
                                              fontSize: 12.5,
                                              color: subTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Buttons (Chat & Call)
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => context.push('${AppRoutes.chat}/driver_123'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.4)),
                                        ),
                                        child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1C7FF6), size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => context.push('${AppRoutes.call}/driver_123'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                                        ),
                                        child: const Icon(Icons.phone_outlined, color: Color(0xFF22C55E), size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ------------------------------------------
                          // CARD 2: TIMELINE PROGRESS CARD
                          // ------------------------------------------
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
                                    color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
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
                                            'สถานะการจัดส่ง',
                                            style: GoogleFonts.kanit(
                                              fontSize: 13,
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

                                  // Timeline Steps Bar
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

                          // ------------------------------------------
                          // CARD 3: ORDER SUMMARY GRID CARD
                          // ------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
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

                          // ------------------------------------------
                          // CARD 4: VIEW FULL DETAILS BUTTON
                          // ------------------------------------------
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
                ),
              ],
            ),
          ),
        ],
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
          width: 36,
          height: 36,
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
          child: Icon(icon, size: 18, color: iconColor),
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

// Background Grid Painter for Stylized Map View
class _MapGridPainter extends CustomPainter {
  final bool isDarkMode;

  _MapGridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    const double step = 40.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter to draw a smooth route line on the map
class _FakeRoutePainter extends CustomPainter {
  final bool isDarkMode;

  _FakeRoutePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF1C7FF6)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF1C7FF6).withValues(alpha: 0.3)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width * 0.45, size.height * 0.6);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.lineTo(size.width * 0.75, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height * 0.12);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
