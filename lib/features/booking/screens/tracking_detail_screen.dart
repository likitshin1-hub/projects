import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/driver_provider.dart';

class TrackingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const TrackingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final bookingState = ref.watch(bookingProvider);
    final driver = ref.watch(driverProvider);
    String t(String key) => AppTranslations.getText(currentLang, key);

    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final displayBookingId = (bookingId.isEmpty || bookingId == 'default') 
        ? (bookingState.bookingId ?? 'TB504321-5598') 
        : bookingId;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==========================================
          // 1. TOP PREMIUM HEADER WITH GRADIENT
          // ==========================================
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                    ),
                    Text(
                      t('full_tracking_detail'),
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'https://tbmovehub.com/track/$displayBookingId'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('คัดลอกลิงก์แชร์พัสดุเรียบร้อยแล้ว', style: GoogleFonts.kanit()),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'รหัสออเดอร์: $displayBookingId',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: displayBookingId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('คัดลอกรหัสออเดอร์แล้ว', style: GoogleFonts.kanit()),
                                  backgroundColor: const Color(0xFF1C7FF6),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(Icons.copy_rounded, size: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. SCROLLABLE BODY WITH REDESIGNED CARDS
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // STEPPER: HORIZONTAL PROGRESS PIPES
                  _buildHorizontalStepper(isDarkMode),
                  const SizedBox(height: 16),

                  // CARD 1: ROUTE & ADDRESS DETAILS (PICKUP & DROPOFF)
                  _buildRouteCard(bookingState, cardBg, borderColor, textColor, subTextColor, isDarkMode),
                  const SizedBox(height: 16),

                  // CARD 2: DRIVER & VEHICLE BANNER
                  _buildDriverCard(context, driver, cardBg, borderColor, textColor, subTextColor, isDarkMode),
                  const SizedBox(height: 16),

                  // CARD 3: PARCEL SPECIFICATIONS GRID
                  _buildParcelSpecsCard(bookingState, cardBg, borderColor, textColor, subTextColor, isDarkMode),
                  const SizedBox(height: 16),

                  // CARD 4: RECEIPT STYLE PAYMENT DETAILS
                  _buildReceiptCard(bookingState, cardBg, borderColor, textColor, subTextColor, isDarkMode),
                  const SizedBox(height: 16),

                  // CARD 5: DETAILED STATUS TIMELINE LOG
                  _buildTimelineCard(cardBg, borderColor, textColor, subTextColor, isDarkMode),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal stepper widget
  Widget _buildHorizontalStepper(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C7FF6).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'สถานะปัจจุบัน: กำลังจัดส่งพัสดุ',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ตรงเวลา',
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C7FF6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepNode(Icons.check_circle_rounded, 'สร้างออเดอร์', true),
              _buildStepLine(true),
              _buildStepNode(Icons.check_circle_rounded, 'เข้ารับพัสดุ', true),
              _buildStepLine(true),
              _buildStepNode(Icons.local_shipping_rounded, 'ระหว่างนำส่ง', true, isActive: true),
              _buildStepLine(false),
              _buildStepNode(Icons.stars_rounded, 'ส่งสำเร็จ', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(IconData icon, String title, bool isCompleted, {bool isActive = false}) {
    final activeColor = const Color(0xFF1C7FF6);
    final inactiveColor = const Color(0xFF94A3B8);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive 
                  ? activeColor 
                  : (isCompleted ? activeColor.withValues(alpha: 0.15) : Colors.transparent),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isActive ? activeColor : inactiveColor,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : (isCompleted ? activeColor : inactiveColor),
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.kanit(
              fontSize: 11,
              fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : (isCompleted ? const Color(0xFF1F2937) : inactiveColor),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 22,
      height: 2,
      color: isCompleted ? const Color(0xFF1C7FF6) : const Color(0xFFE2E8F0),
    );
  }

  // Route / Location Card
  Widget _buildRouteCard(BookingState bookingState, Color cardBg, Color borderColor, Color textColor, Color subTextColor, bool isDark) {
    final senderName = bookingState.pickupName.isNotEmpty ? bookingState.pickupName : 'ผู้ส่ง (ตำแหน่งปัจจุบัน)';
    final senderAddress = bookingState.pickup.isNotEmpty ? bookingState.pickup : '123 อาคาร ชั้น 5 ถนนสุขุมวิท กรุงเทพมหานคร';
    final receiverName = bookingState.dropoffName.isNotEmpty ? bookingState.dropoffName : 'ผู้รับปลายทาง';
    final receiverPhone = bookingState.receiverPhone.isNotEmpty ? ' (${bookingState.receiverPhone})' : '';
    final receiverAddress = bookingState.dropoff.isNotEmpty ? bookingState.dropoff : '88/9 หมู่ 3 ตำบลแม่เหียะ อำเภอเมืองเชียงใหม่';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF1C7FF6), size: 22),
              const SizedBox(width: 8),
              Text(
                'ข้อมูลการเดินทางและจุดรับ-ส่ง',
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store_rounded, color: Colors.white, size: 15),
                  ),
                  Container(
                    width: 2,
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFFEF4444)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 15),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Info
                    Text(
                      'ผู้ส่ง: $senderName',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      senderAddress,
                      style: GoogleFonts.kanit(fontSize: 12.5, color: subTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),

                    // Dropoff Info
                    Text(
                      'ผู้รับ: $receiverName$receiverPhone',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      receiverAddress,
                      style: GoogleFonts.kanit(fontSize: 12.5, color: subTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Driver details card
  Widget _buildDriverCard(BuildContext context, DriverModel driver, Color cardBg, Color borderColor, Color textColor, Color subTextColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_rounded, color: Color(0xFF1C7FF6), size: 22),
              const SizedBox(width: 8),
              Text(
                'พนักงานขับรถขนส่ง',
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: driver.avatarBgColor,
                  border: Border.all(color: const Color(0xFF1C7FF6), width: 1.5),
                ),
                child: Icon(driver.avatarIcon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          driver.name,
                          style: GoogleFonts.kanit(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: Color(0xFF1C7FF6), size: 16),
                      ],
                    ),
                    Text(
                      driver.fullVehicleInfo,
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 15),
                        const SizedBox(width: 3),
                        Text(
                          '${driver.rating} (${driver.reviewCount} รีวิว)',
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
                  // Chat button
                  InkWell(
                    onTap: () => context.push('${AppRoutes.chat}/active_driver'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F7FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF1C7FF6), size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Call button
                  InkWell(
                    onTap: () => context.push('${AppRoutes.call}/active_driver'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Parcel Specs Grid Card
  Widget _buildParcelSpecsCard(BookingState bookingState, Color cardBg, Color borderColor, Color textColor, Color subTextColor, bool isDark) {
    final pType = bookingState.parcelType.isNotEmpty ? bookingState.parcelType : 'กล่อง / เอกสาร';
    final vType = bookingState.vehicleType.isNotEmpty ? bookingState.vehicleType : 'มอเตอร์ไซค์';
    final weight = '${bookingState.parcelWeight} กิโลกรัม';
    final details = bookingState.details.isNotEmpty ? bookingState.details : 'ไม่มีระบุเพิ่มเติม';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.widgets_rounded, color: Color(0xFF1C7FF6), size: 22),
              const SizedBox(width: 8),
              Text(
                'รายละเอียดสินค้าในพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
            children: [
              _buildGridItem('ประเภทพัสดุ', pType, isDark),
              _buildGridItem('ยานพาหนะที่ใช้', vType, isDark),
              _buildGridItem('น้ำหนักพัสดุ', weight, isDark),
              _buildGridItem('รายละเอียดสินค้า', details, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'รูปพัสดุและเอกสารยืนยันการจัดส่ง:',
            style: GoogleFonts.kanit(fontSize: 12, color: subTextColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_rounded, color: Color(0xFF1C7FF6), size: 18),
                      const SizedBox(width: 6),
                      Text('ภาพถ่ายพัสดุ', style: GoogleFonts.kanit(fontSize: 12, color: textColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 6),
                      Text('บาร์โค้ดใบจ่าหน้า', style: GoogleFonts.kanit(fontSize: 12, color: textColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.kanit(fontSize: 11, color: const Color(0xFF94A3B8)),
          ),
          Text(
            value,
            style: GoogleFonts.kanit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Receipt Card
  Widget _buildReceiptCard(BookingState bookingState, Color cardBg, Color borderColor, Color textColor, Color subTextColor, bool isDark) {
    final priceStr = '${bookingState.estimatedPrice.toStringAsFixed(2)} บาท';
    final distanceStr = '${bookingState.distanceKm} กม.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF1C7FF6), size: 22),
              const SizedBox(width: 8),
              Text(
                'สรุปยอดการเรียกชำระเงิน',
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildReceiptRow('ค่าบริการขนส่ง ($distanceStr)', priceStr, textColor, subTextColor),
          _buildReceiptRow('ค่าประกันพัสดุและคุ้มครอง', 'ฟรี (รวมในระบบแล้ว)', const Color(0xFF10B981), subTextColor),
          
          const Divider(height: 24, color: Color(0xFFCBD5E1)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ยอดชำระเงินทั้งหมด:',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                priceStr,
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C7FF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Text(
                  'ชำระเงินสำเร็จแล้วผ่านระบบ TB MOVE HUB',
                  style: GoogleFonts.kanit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value, Color valColor, Color labelColor, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.kanit(fontSize: 12.5, color: labelColor),
          ),
          Text(
            value,
            style: GoogleFonts.kanit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  // Status timeline card
  Widget _buildTimelineCard(Color cardBg, Color borderColor, Color textColor, Color subTextColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: Color(0xFF1C7FF6), size: 22),
              const SizedBox(width: 8),
              Text(
                'ประวัติสถานะพัสดุและเวลาจัดส่ง',
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTimelineItem('16:30 น.', 'กำลังเดินทางบนทางด่วน (กม.22 บางพลี)', 'ไรเดอร์กำลังขับมุ่งหน้าเข้าสู่กรุงเทพมหานครปลายทาง', true, false, isDark),
          _buildTimelineItem('16:15 น.', 'ผ่านด่านทางด่วน บูรพาวิถี', 'ประมวลผลระบบ GPS ค้นพบคนขับผ่านด่านชำระเงินเรียบร้อย', false, false, isDark),
          _buildTimelineItem('15:45 น.', 'รับพัสดุขึ้นรถและออกนำส่งสำเร็จ', 'ตรวจยืนยันความเรียบร้อยและเริ่มกระบวนการจัดส่งนำของขึ้นตู้ทึบ', false, false, isDark),
          _buildTimelineItem('15:35 น.', 'คนขับถึงจุดรับเซ็นทรัล ชลบุรี', 'พนักงานไรเดอร์ถึงตำแหน่งเตรียมการตรวจสอบพัสดุ', false, false, isDark),
          _buildTimelineItem('15:20 น.', 'ชำระค่าบริการและออกออเดอร์ในระบบ', 'ระบบทำการบันทึกข้อมูลเรียบร้อย ค้นหาและมอบหมายคนขับรถ', false, true, isDark),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String title, String subtitle, bool isCurrent, bool isLast, bool isDark) {
    final activeColor = const Color(0xFF1C7FF6);
    final inactiveColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            time,
            style: GoogleFonts.kanit(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? activeColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent ? activeColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                border: isCurrent ? Border.all(color: Colors.white, width: 2.5) : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? activeColor : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.kanit(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
