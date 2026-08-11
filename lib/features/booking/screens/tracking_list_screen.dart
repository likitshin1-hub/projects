import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';

class TrackingListScreen extends StatelessWidget {
  const TrackingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final List<_TrackingItemData> items = [
      _TrackingItemData(
        orderNo: 'TB504321-5598',
        route: 'กรุงเทพฯ • ชลบุรี',
        dateTime: '8 พ.ค. 2568 10:00',
        isInProgress: true,
      ),
      _TrackingItemData(
        orderNo: 'TB668511-6448',
        route: 'เชียงใหม่ • บางกอกฯ',
        dateTime: '28 เม.ย. 2568 14:00',
        isInProgress: false,
      ),
      _TrackingItemData(
        orderNo: 'TB649993-9995',
        route: 'ระยอง • ดอน 12',
        dateTime: '12 ก.พ. 2568 14:00',
        isInProgress: false,
      ),
      _TrackingItemData(
        orderNo: 'TB908808-2023',
        route: 'เชียงราย • ลำพูน',
        dateTime: '3 ม.ค. 2568 11:00',
        isInProgress: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER
          // ==========================================
          Container(
            width: double.infinity,
            height: 150 + statusBarHeight,
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
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Text Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ติดตามพัสดุ',
                      style: GoogleFonts.kanit(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'อัปเดตสถานะพัสดุแบบเรียลไทม์',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                // 3D Pin & Box illustration on the right
                Positioned(
                  right: -10,
                  bottom: -20,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      children: [
                        // Giant translucent map pin
                        Positioned(
                          right: 15,
                          top: 0,
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 110,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        // 3D Stack of cardboard boxes
                        Positioned(
                          right: 25,
                          bottom: 25,
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 48,
                            color: Colors.orange.shade300,
                          ),
                        ),
                        Positioned(
                          right: 65,
                          bottom: 20,
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 38,
                            color: Colors.orange.shade400,
                          ),
                        ),
                        Positioned(
                          right: 50,
                          bottom: 50,
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 32,
                            color: Colors.orange.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Notification Bell at top right
                Positioned(
                  right: 0,
                  top: 0,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => context.push(AppRoutes.notification),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
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
                ),
              ],
            ),
          ),

          // ==========================================
          // BODY LIST
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title: พัสดุล่าสุด & ดูทั้งหมด
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'พัสดุล่าสุด',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.history),
                        child: Row(
                          children: [
                            Text(
                              'ดูทั้งหมด',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                color: const Color(0xFF1C7FF6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Color(0xFF1C7FF6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List of items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildListItem(context, item);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bottom Security Banner
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Light blue tint
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE), // Subtle blue border
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Shield Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'พัสดุของคุณปลอดภัย',
                                style: GoogleFonts.kanit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'เราดูแลพัสดุทุกชิ้นด้วยความใส่ใจ',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  color: const Color(0xFF536E99),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Banner image placeholder matching mockup
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            AppAssets.trustShieldBox,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.security, color: Color(0xFF3B82F6), size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, _TrackingItemData item) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.tracking}/${item.orderNo}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Status Icon Circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.isInProgress
                    ? const Color(0xFFEFF6FF) // Light blue
                    : const Color(0xFFECFDF5), // Light green
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isInProgress
                    ? Icons.inventory_2_rounded
                    : Icons.check_circle_rounded,
                color: item.isInProgress
                    ? const Color(0xFF1C7FF6)
                    : const Color(0xFF10B981),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.orderNo,
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.route,
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.dateTime,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.isInProgress
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isInProgress ? 'กำลังดำเนินการ' : 'จัดส่งสำเร็จ',
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.isInProgress
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingItemData {
  final String orderNo;
  final String route;
  final String dateTime;
  final bool isInProgress;

  const _TrackingItemData({
    required this.orderNo,
    required this.route,
    required this.dateTime,
    required this.isInProgress,
  });
}
