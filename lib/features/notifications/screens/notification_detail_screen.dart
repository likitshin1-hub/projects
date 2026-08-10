import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../booking/providers/booking_provider.dart';

class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bookingState = ref.watch(bookingProvider);
    final String bookingId = bookingState.bookingId ?? 'B2553';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER WITH BACK BUTTON
          // ==========================================
          Container(
            width: double.infinity,
            height: 80 + statusBarHeight,
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
            child: Row(
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
          ),
          const SizedBox(height: 20),

          // ==========================================
          // MAIN SCROLLABLE CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Notification Summary Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        // Details Header Title Line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 1.5,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Color(0xFF1C7FF6)],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1C7FF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'รายละเอียดแจ้งเตือน',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1C7FF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 1.5,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1C7FF6), Colors.transparent],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Center Graphic with sparkles
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Faded circular background
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C7FF6).withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // 3D Box Illustration
                            Image.asset(
                              AppAssets.trustShieldBox,
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.all_inbox_rounded,
                                size: 80,
                                color: Color(0xFF1C7FF6),
                              ),
                            ),
                            // Green check circle badge
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 32,
                                ),
                              ),
                            ),
                            // Sparkles around (Visual styling matching sparkles in mockup)
                            Positioned(
                              top: 20,
                              left: 10,
                              child: Transform.rotate(
                                angle: 0.5,
                                child: const Icon(Icons.star_rounded, color: Color(0xFF1C7FF6), size: 10),
                              ),
                            ),
                            Positioned(
                              top: 22,
                              right: 20,
                              child: Transform.rotate(
                                angle: -0.3,
                                child: const Icon(Icons.star_rounded, color: Color(0xFF1C7FF6), size: 10),
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              left: 0,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1C7FF6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 44,
                              right: 10,
                              child: const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Notification Head Text
                        Text(
                          'คำสั่งซื้อจัดส่งแล้ว',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'คำสั่งซื้อ #$bookingId ของคุณ\nถูกจัดส่งเรียบร้อยแล้ว',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            fontSize: 13.5,
                            color: const Color(0xFF6B7280),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Details Box
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Details
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment_rounded,
                              color: Color(0xFF1C7FF6),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'รายละเอียด',
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Info rows
                        _buildInfoRow(
                          icon: Icons.inventory_2_rounded,
                          title: 'หมายเลขพัสดุ',
                          value: 'TH21549666541A',
                          isBold: true,
                        ),
                        _buildInfoRow(
                          icon: Icons.calendar_today_rounded,
                          title: 'วันที่จัดส่ง',
                          value: '18 พ.ค. 2569 15:30น.',
                        ),
                        _buildInfoRow(
                          icon: Icons.local_shipping_rounded,
                          title: 'จัดส่งโดย',
                          value: 'TB MOVEHUB',
                        ),
                        _buildInfoRow(
                          icon: Icons.badge_rounded,
                          title: 'หมายเลขของเดอร์', // Typo matching the mockup exactly
                          value: bookingId,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Action Track Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        context.push('${AppRoutes.tracking}/$bookingId');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'ติดตามพัสดุ',
                                style: GoogleFonts.kanit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF1C7FF6),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 13.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(
            height: 1,
            color: Colors.grey.shade100,
          ),
        ],
      ),
    );
  }
}
