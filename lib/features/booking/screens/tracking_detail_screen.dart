import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class TrackingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const TrackingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    String t(String key) => AppTranslations.getText(currentLang, key);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final displayBookingId = bookingId.isEmpty ? 'B25538914' : bookingId;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==========================================
          // 1. TOP HEADER WITH GRADIENT BAR
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
                    t('full_tracking_detail'),
                    style: GoogleFonts.kanit(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {
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
          ),

          // ==========================================
          // 2. SCROLLABLE BODY WITH FULL DETAILS
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ------------------------------------------
                  // CARD 1: ORDER ID & STATUS BADGE
                  // ------------------------------------------
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF1C7FF6), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'รหัสออเดอร์: $displayBookingId',
                                        style: GoogleFonts.kanit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
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
                                        child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF1C7FF6)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'สั่งซื้อเมื่อ: 18 พ.ค. 2569 | 15:20 น.',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping_rounded, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'สถานะปัจจุบัน: ',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'กำลังจัดส่งพัสดุข้ามจังหวัด (บนทางด่วน)',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ------------------------------------------
                  // CARD 2: SENDER & RECIPIENT ADDRESS DETAILS
                  // ------------------------------------------
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
                            const Icon(Icons.location_on_rounded, color: Color(0xFF1C7FF6), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ข้อมูลสถานที่รับ-ส่งพัสดุ',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // SENDER (PICKUP)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.store_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'จุดรับสินค้า (ผู้ส่ง): ',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          color: subTextColor,
                                        ),
                                      ),
                                      Text(
                                        'นาย กิตติพงษ์ ใจดี',
                                        style: GoogleFonts.kanit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'คลัง TB MOVEHUB (เซ็นทรัล ชลบุรี)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1C7FF6),
                                    ),
                                  ),
                                  Text(
                                    '55/1 หมู่ 1 ถนนสุขุมวิท ต.เสม็ด อ.เมืองชลบุรี จ.ชลบุรี 20000 (โทร 081-234-5678)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: subTextColor,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // CONNECTING LINE
                        Container(
                          margin: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
                          width: 2,
                          height: 22,
                          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),

                        // RECIPIENT (DROPOFF)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'จุดส่งสินค้า (ผู้รับ): ',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          color: subTextColor,
                                        ),
                                      ),
                                      Text(
                                        'นางสาว ณิชา สมบูรณ์',
                                        style: GoogleFonts.kanit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'เซ็นทรัลเวิลด์ กรุงเทพฯ (CentralWorld)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFEF4444),
                                    ),
                                  ),
                                  Text(
                                    '999/9 ถนนพระราม 1 แขวงปทุมวัน เขตปทุมวัน กรุงเทพมหานคร 10330 (โทร 089-876-5432)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: subTextColor,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ------------------------------------------
                  // CARD 3: DRIVER & VEHICLE INFO
                  // ------------------------------------------
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
                            const Icon(Icons.badge_rounded, color: Color(0xFF1C7FF6), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ข้อมูลคนขับและยานพาหนะ',
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
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                                ),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'นาย สมปอง มีดี',
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
                                    'Isuzu D-Max ตู้ทึบ (ทะเบียน 1กข-9999 ชลบุรี)',
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
                                        '4.9 (326 รีวิว)',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
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
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.4)),
                                    ),
                                    child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1C7FF6), size: 18),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => context.push('${AppRoutes.call}/driver_123'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                                    ),
                                    child: const Icon(Icons.phone_outlined, color: Color(0xFF22C55E), size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ------------------------------------------
                  // CARD 4: PARCEL ITEM SPECIFICATIONS
                  // ------------------------------------------
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
                            const Icon(Icons.widgets_rounded, color: Color(0xFF1C7FF6), size: 20),
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
                        const SizedBox(height: 12),

                        _buildInfoRow('ประเภทสินค้า:', 'เอกสารสำคัญ / อุปกรณ์อิเล็กทรอนิกส์', isDarkMode),
                        _buildInfoRow('ขนาดพัสดุ:', 'กล่องใหญ่ Size L (40 x 50 x 30 ซม.)', isDarkMode),
                        _buildInfoRow('น้ำหนักพัสดุ:', '1.2 กิโลกรัม', isDarkMode),
                        _buildInfoRow('ประกันสินค้า:', 'วงเงินคุ้มครองสูงสุด 5,000 บาท', isDarkMode),
                        _buildInfoRow('คำสั่งพิเศษ:', 'พัสดุระวังแตก โปรดวางระมัดระวัง', isDarkMode),
                        const SizedBox(height: 10),

                        // PARCEL PHOTO ATTACHMENT PREVIEW
                        Text(
                          'รูปภาพพัสดุแนบ:',
                          style: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.inventory_2_rounded, color: Color(0xFF1C7FF6), size: 28),
                                    const SizedBox(height: 4),
                                    Text('รูปพัสดุชิ้นที่ 1', style: GoogleFonts.kanit(fontSize: 11, color: textColor)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.qr_code_2_rounded, color: Color(0xFF10B981), size: 28),
                                    const SizedBox(height: 4),
                                    Text('ใบลาเบลพัสดุ', style: GoogleFonts.kanit(fontSize: 11, color: textColor)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ------------------------------------------
                  // CARD 5: PAYMENT BREAKDOWN
                  // ------------------------------------------
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
                            const Icon(Icons.payments_rounded, color: Color(0xFF1C7FF6), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'สรุปรายการค่าบริการและชำระเงิน',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildPriceRow('ค่าบริการขนส่งข้ามจังหวัด (76.5 กม.)', '450 บาท', isDarkMode),
                        _buildPriceRow('ค่าประกันสินค้าคุ้มครองพัสดุ', '30 บาท', isDarkMode),
                        _buildPriceRow('ส่วนลดคูปองส่วนลดพิเศษ', '-50 บาท', isDarkMode, isDiscount: true),
                        const Divider(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ยอดชำระสุทธิ:',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '430 บาท',
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C7FF6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'ชำระเงินเรียบร้อยแล้ว (ผ่าน QR PromptPay)',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ------------------------------------------
                  // CARD 6: FULL ACTIVITY LOG TIMELINE
                  // ------------------------------------------
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
                            const Icon(Icons.history_rounded, color: Color(0xFF1C7FF6), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ประวัติสถานะการจัดส่งแบบละเอียด',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildLogStep(
                          time: '16:30 น.',
                          title: 'กำลังเดินทางบนทางด่วนบูรพาวิถี (กม.22 บางพลี)',
                          subtitle: 'คนขับกำลังมุ่งหน้าสู่จุดส่งสินค้า เซ็นทรัลเวิลด์ กรุงเทพฯ',
                          isCurrent: true,
                          isLast: true,
                          isDark: isDarkMode,
                        ),
                        _buildLogStep(
                          time: '16:15 น.',
                          title: 'ผ่านด่านบางนา มุ่งหน้าทางด่วนเฉลิมมหานคร',
                          subtitle: 'ระบบ GPS บันทึกพิกัดผ่านด่านบางนาสำเร็จ',
                          isCurrent: false,
                          isLast: false,
                          isDark: isDarkMode,
                        ),
                        _buildLogStep(
                          time: '15:45 น.',
                          title: 'รับพัสดุและออกเดินทางจากคลัง ชลบุรี',
                          subtitle: 'คนขับถ่ายรูปยืนยันสภาพกล่องพัสดุเรียบร้อย',
                          isCurrent: false,
                          isLast: false,
                          isDark: isDarkMode,
                        ),
                        _buildLogStep(
                          time: '15:35 น.',
                          title: 'คนขับถึงจุดรับพัสดุ (เซ็นทรัล ชลบุรี)',
                          subtitle: 'นาย สมปอง มีดี ถึงจุดรับพัสดุตรงเวลา',
                          isCurrent: false,
                          isLast: false,
                          isDark: isDarkMode,
                        ),
                        _buildLogStep(
                          time: '15:20 น.',
                          title: 'สร้างออเดอร์ในระบบสำเร็จ',
                          subtitle: 'ชำระเงินเรียบร้อยแล้ว รอมอบหมายคนขับ',
                          isCurrent: false,
                          isLast: false,
                          isDark: isDarkMode,
                        ),
                      ],
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

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 12.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String price, bool isDark, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Text(
            price,
            style: GoogleFonts.kanit(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isDiscount ? const Color(0xFFEF4444) : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogStep({
    required String time,
    required String title,
    required String subtitle,
    required bool isCurrent,
    required bool isLast,
    required bool isDark,
  }) {
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
              color: isCurrent ? const Color(0xFF1C7FF6) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                color: isCurrent ? const Color(0xFF1C7FF6) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? const Color(0xFF1C7FF6) : (isDark ? Colors.white : const Color(0xFF0F172A)),
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
