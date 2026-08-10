import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class NotificationsListScreen extends StatelessWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                        ),
                        Text(
                          'แจ้งเตือน',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Right notification bell with active red badge dot
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            Positioned(
                              top: 1,
                              right: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Segmented Tab Overlapping Card
              Positioned(
                bottom: -28,
                left: 20,
                right: 20,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF1C7FF6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'แจ้งเตือนทั้งหมด',
                        style: GoogleFonts.kanit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C7FF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 44), // Gap for the overlapping card

          // ==========================================
          // SUB-FILTER CHIP ("วันนี้")
          // ==========================================
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                        color: const Color(0xFF1F2937),
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
                // Card 1: คำสั่งซื้อจัดส่งแล้ว (Blue theme)
                _buildNotificationCard(
                  context,
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
                        color: const Color(0xFF6B7280),
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
                        color: const Color(0xFF6B7280),
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
                        color: const Color(0xFF6B7280),
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
    BuildContext context, {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                  color: iconBgColor,
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
                          color: const Color(0xFF1F2937),
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
