import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

import '../../partner/providers/partner_application_provider.dart';

class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final partnerApp = ref.watch(partnerApplicationProvider);

    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER WITH APP BAR
          // ==========================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 140 + statusBarHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C7FF6),
                      Color(0xFF0056C6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'แจ้งเตือน',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // TOP SUMMARY FLOATING CARD
              Positioned(
                left: 20,
                right: 20,
                bottom: -32,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2FE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF1C7FF6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'แจ้งเตือนทั้งหมด',
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              partnerApp != null ? 'มี 4 รายการใหม่ที่คุณยังไม่อ่าน' : 'มี 3 รายการใหม่ที่คุณยังไม่อ่าน',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                color: subTextColor,
                              ),
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

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: Color(0xFF1C7FF6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'วันนี้',
                      style: GoogleFonts.kanit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // SCROLLABLE NOTIFICATIONS LIST
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                if (partnerApp != null) ...[
                  // Card 0: สถานะการสมัครพาร์ทเนอร์คนขับ (Dynamic Periodic System Notification)
                  _buildNotificationCard(
                    context,
                    ref,
                    sideColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    icon: Icons.badge_rounded,
                    title: 'สถานะใบสมัครพาร์ทเนอร์คนขับ',
                    time: 'เมื่อครู่',
                    dotColor: const Color(0xFF10B981),
                    customSubtitle: RichText(
                      text: TextSpan(
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          color: subTextColor,
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(
                            text: 'อัปเดตระบบตรวจสอบ: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: partnerApp.currentStatusText),
                        ],
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'สถานะใบสมัครปัจจุบัน: ${partnerApp.currentStatusText}',
                            style: GoogleFonts.kanit(),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],

                // Card 1: คำสั่งซื้อจัดส่งแล้ว (Blue theme)
                _buildNotificationCard(
                  context,
                  ref,
                  sideColor: const Color(0xFF1C7FF6),
                  iconBgColor: const Color(0xFFE8F2FE),
                  iconColor: const Color(0xFF1C7FF6),
                  icon: Icons.inventory_2_outlined,
                  title: 'คำสั่งซื้อจัดส่งแล้ว',
                  time: '10:30 น.',
                  dotColor: const Color(0xFF1C7FF6),
                  customSubtitle: RichText(
                    text: TextSpan(
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.35,
                      ),
                      children: const [
                        TextSpan(text: 'คำสั่งซื้อ #TH21549666541A ของคุณ\nถูกจัดส่งเรียบร้อยแล้ว'),
                      ],
                    ),
                  ),
                  onTap: () {
                    context.push(AppRoutes.notificationDetail);
                  },
                ),

                // Card 2: ชำระเงินสำเร็จ (Green theme)
                _buildNotificationCard(
                  context,
                  ref,
                  sideColor: const Color(0xFF22C55E),
                  iconBgColor: const Color(0xFFE8F8EE),
                  iconColor: const Color(0xFF22C55E),
                  icon: Icons.check_circle_outline_rounded,
                  title: 'ชำระเงินสำเร็จ',
                  time: '09:30 น.',
                  dotColor: const Color(0xFF22C55E),
                  customSubtitle: RichText(
                    text: TextSpan(
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.35,
                      ),
                      children: const [
                        TextSpan(text: 'คุณได้ชำระเงินจำนวน '),
                        TextSpan(
                          text: '1,590.00 บาท',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' เรียบร้อย'),
                      ],
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'ชำระเงินสำเร็จเรียบร้อยแล้ว',
                          style: GoogleFonts.kanit(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                // Card 3: แจ้งเตือนโปรโมชั่น (Orange theme)
                _buildNotificationCard(
                  context,
                  ref,
                  sideColor: const Color(0xFFFFB300),
                  iconBgColor: const Color(0xFFFFF8E1),
                  iconColor: const Color(0xFFFFB300),
                  icon: Icons.notifications_none_rounded,
                  title: 'แจ้งเตือนโปรโมชั่น',
                  time: '08:30 น.',
                  dotColor: const Color(0xFFFFB300),
                  customSubtitle: RichText(
                    text: TextSpan(
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.35,
                      ),
                      children: const [
                        TextSpan(text: 'โปรโมชั่นพิเศษสำหรับคุณ รับส่วนลด '),
                        TextSpan(
                          text: '10%',
                          style: TextStyle(
                            color: Color(0xFFFFB300),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' เมื่อช้อปครบ '),
                        TextSpan(
                          text: '1,000 บาท',
                          style: TextStyle(
                            color: Color(0xFFFFB300),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'รับสิทธิ์ส่วนลดโปรโมชั่น 10% เรียบร้อย',
                          style: GoogleFonts.kanit(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NOTIFICATION LIST CARD HELPER
  // ==========================================
  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref, {
    required Color sideColor,
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String time,
    required Color dotColor,
    required Widget customSubtitle,
    required VoidCallback onTap,
  }) {
    final isDarkMode = ref.watch(themeProvider);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // Left color side bar indicator
              Container(
                width: 4,
                height: 96,
                color: sideColor,
              ),
              const SizedBox(width: 14),

              // Circle Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDarkMode ? sideColor.withValues(alpha: 0.2) : iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Info and Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.kanit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Dynamic Rich Text subtitle
                      customSubtitle,
                    ],
                  ),
                ),
              ),

              // Time & Unread dot on the right
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
