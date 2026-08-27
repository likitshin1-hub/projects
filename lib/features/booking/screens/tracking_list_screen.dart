import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/tracking_provider.dart';

class TrackingListScreen extends ConsumerWidget {
  final VoidCallback? onMenuPressed;

  const TrackingListScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final bookingState = ref.watch(bookingProvider);
    final trackingState = ref.watch(trackingProvider);

    final bool isCompleted = trackingState.isCompleted || trackingState.currentStep >= 3;

    // Active in-progress orders list (พัสดุที่กำลังดำเนินการอยู่)
    final List<_ActiveTrackingData> activeItems = [];

    // Prepend user created booking if active and NOT completed
    final userOrderNo = (bookingState.bookingId != null && bookingState.bookingId!.isNotEmpty)
        ? bookingState.bookingId!
        : (bookingState.dropoffName.isNotEmpty ? 'TB504322-9981' : null);

    if (userOrderNo != null && !isCompleted) {
      final exists = activeItems.any((i) => i.orderNo == userOrderNo);
      if (!exists) {
        String emoji = '🛵';
        if (bookingState.vehicleType.contains('กระบะ') || bookingState.vehicleType.contains('บรรทุก')) emoji = '🚚';
        if (bookingState.vehicleType.contains('เก๋ง')) emoji = '🚗';
        if (bookingState.vehicleType.contains('ห้องเย็น')) emoji = '🚛';

        final pName = bookingState.pickupName.isNotEmpty ? bookingState.pickupName : 'ตำแหน่งปัจจุบันของคุณ';
        final dName = bookingState.dropoffName.isNotEmpty ? bookingState.dropoffName : 'ผู้รับปลายทาง';

        String statusStepText = 'ชำระเงินแล้ว - ไรเดอร์กำลังมุ่งหน้าไปรับพัสดุ';
        if (trackingState.currentStep == 1) statusStepText = 'ไรเดอร์รับพัสดุเรียบร้อยแล้ว';
        if (trackingState.currentStep == 2) statusStepText = 'พัสดุอยู่ระหว่างการนำส่ง (บนทางด่วน)';

        activeItems.insert(
          0,
          _ActiveTrackingData(
            orderNo: userOrderNo,
            pickupName: pName,
            dropoffName: dName,
            route: '$pName ➔ $dName',
            vehicle: emoji,
            vehicleName: bookingState.vehicleType,
            dateTime: 'เมื่อสักครู่',
            statusStep: statusStepText,
            driverName: 'สมชาย ใจดี',
            driverPhone: '089-999-8888',
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER
          // ==========================================
          Container(
            width: double.infinity,
            height: 155 + statusBarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1C7FF6),
                  Color(0xFF0056C6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar Row
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                      onPressed: () => onMenuPressed?.call(),
                    ),
                    Expanded(
                      child: Text(
                        currentLang == AppLanguage.en ? 'Live Parcel Tracking' : 'ติดตามพัสดุเรียลไทม์',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.notification),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                              Positioned(
                                top: -1,
                                right: -1,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: Text(
                                    '3',
                                    style: GoogleFonts.kanit(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${activeItems.length} ออเดอร์ที่กำลังดำเนินการอยู่',
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentLang == AppLanguage.en
                                ? 'Track live driver location and delivery progress 24/7'
                                : 'เช็คตำแหน่งคนขับและสถานะพัสดุเรียลไทม์บนแผนที่ได้ 24 ชม.',
                            style: GoogleFonts.kanit(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.my_location_rounded, size: 40, color: Colors.white24),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // ACTIVE IN-PROGRESS ORDERS LIST
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alt_route_rounded, color: Color(0xFF1C7FF6), size: 20),
                          const SizedBox(width: 6),
                          Text(
                            currentLang == AppLanguage.en ? 'Active Deliveries' : 'พัสดุที่กำลังดำเนินการ',
                            style: GoogleFonts.kanit(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.history),
                        child: Row(
                          children: [
                            Text(
                              currentLang == AppLanguage.en ? 'View History >' : 'ดูประวัติทั้งหมด >',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C7FF6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Active Orders List Cards
                  if (activeItems.isEmpty)
                    _buildEmptyActiveState(isDarkMode, currentLang, context)
                  else
                    ...activeItems.map((item) => _buildActiveTrackingCard(item, isDarkMode, currentLang, context)),

                  const SizedBox(height: 16),

                  // Live Map Banner Card
                  _buildLiveMapBannerCard(isDarkMode, currentLang, context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrackingCard(
      _ActiveTrackingData item, bool isDarkMode, AppLanguage currentLang, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C7FF6).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('${AppRoutes.tracking}/${item.orderNo}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Vehicle, OrderNo, LIVE Badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(item.vehicle, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'รหัส: ${item.orderNo}',
                                style: GoogleFonts.kanit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'กำลังส่งสด',
                                      style: GoogleFonts.kanit(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.vehicleName} • ${item.dateTime}',
                            style: GoogleFonts.kanit(
                              fontSize: 11.5,
                              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB), height: 1),
                const SizedBox(height: 10),

                // Route (Pickup > Dropoff)
                Row(
                  children: [
                    const Icon(Icons.near_me_rounded, size: 16, color: Color(0xFF1C7FF6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.route,
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Current Step Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C7FF6).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF1C7FF6)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.statusStep,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons: Call / Chat / Track Live GPS Map
                Row(
                  children: [
                    Flexible(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.call_rounded, color: Color(0xFF10B981), size: 15),
                        label: Text('โทรหาคนขับ', style: GoogleFonts.kanit(fontSize: 10.5, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 34),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.push('${AppRoutes.call}/driver_somchai'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF1C7FF6), size: 15),
                        label: Text('แชท', style: GoogleFonts.kanit(fontSize: 10.5, color: const Color(0xFF1C7FF6), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 34),
                          side: const BorderSide(color: Color(0xFF1C7FF6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.push('${AppRoutes.chat}/driver_somchai'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.my_location_rounded, size: 14, color: Colors.white),
                        label: Text('ติดตามสด', style: GoogleFonts.kanit(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(0, 34),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: () => context.push('${AppRoutes.tracking}/${item.orderNo}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyActiveState(bool isDarkMode, AppLanguage currentLang, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 52, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text(
              'ไม่มีพัสดุที่กำลังดำเนินการอยู่',
              style: GoogleFonts.kanit(fontSize: 15.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1F2937)),
            ),
            const SizedBox(height: 4),
            Text(
              'พัสดุล่าสุดจัดส่งสำเร็จแล้ว ย้ายไปที่ประวัติการขนส่งเรียบร้อยแล้ว',
              style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              icon: const Icon(Icons.history_rounded, size: 18, color: Colors.white),
              label: Text(
                'ดูประวัติการขนส่ง 📋',
                style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C7FF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => context.push(AppRoutes.history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMapBannerCard(bool isDarkMode, AppLanguage currentLang, BuildContext context) {
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final titleTextColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleTextColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final iconColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final iconBgColor = isDarkMode ? const Color(0xFF1C7FF6).withValues(alpha: 0.2) : const Color(0xFF1C7FF6).withValues(alpha: 0.12);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFF1C7FF6).withValues(alpha: 0.3);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : const Color(0xFF1C7FF6).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('${AppRoutes.tracking}/TB504321-5598'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.alt_route_rounded,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLang == AppLanguage.en
                            ? 'Bangkok ➔ Chiang Mai (Live GPS)'
                            : 'สุขุมวิท ➔ อ.เมือง (เชียงใหม่)',
                        style: GoogleFonts.kanit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: titleTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentLang == AppLanguage.en
                            ? 'In transit (Live GPS Tracking)'
                            : 'กำลังขนส่งบนเส้นทางหลัก (Live GPS)',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: iconColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveTrackingData {
  final String orderNo;
  final String pickupName;
  final String dropoffName;
  final String route;
  final String vehicle;
  final String vehicleName;
  final String dateTime;
  final String statusStep;
  final String driverName;
  final String driverPhone;

  _ActiveTrackingData({
    required this.orderNo,
    required this.pickupName,
    required this.dropoffName,
    required this.route,
    required this.vehicle,
    required this.vehicleName,
    required this.dateTime,
    required this.statusStep,
    required this.driverName,
    required this.driverPhone,
  });
}
