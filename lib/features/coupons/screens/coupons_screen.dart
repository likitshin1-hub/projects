import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  int _activeTab = 0; // 0: คูปองที่ใช้ได้, 1: คูปองที่ใช้แล้ว, 2: หมดอายุ

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // HEADER (Gradient blue)
          // ==========================================
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A6CFF),
                  Color(0xFF0052CC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    Text(
                      'คูปองของฉัน',
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Ticket icon with badge count 3
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.local_activity_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '3',
                              style: GoogleFonts.kanit(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ใช้คูปองให้คุ้มค่า ประหยัดทุกการเดินทาง',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16), // Gap for the overlapping card

          // ==========================================
          // TAB BAR / SEGMENTED CONTROL
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabItem(0, 'คูปองที่ใช้ได้'),
                _buildTabItem(1, 'คูปองที่ใช้แล้ว'),
                _buildTabItem(2, 'หมดอายุ'),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // ==========================================
          // COUPONS LIST CONTENT
          // ==========================================
          Expanded(
            child: _buildCouponsContent(),
          ),
        ],
      ),
    );
  }



  Widget _buildTabItem(int index, String label) {
    final bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF1C7FF6) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponsContent() {
    // Tab 0: คูปองที่ใช้ได้
    if (_activeTab == 0) {
      return ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCouponCard(
            amount: 50,
            title: 'ส่วนลด 50 บาท',
            subtitle: 'เมื่อใช้บริการครบ 300 บาทขึ้นไป',
            expiry: 'หมดอายุ 31 ส.ค. 2569',
            badgeText: 'คูปองส่วนลด',
            badgeBgColor: const Color(0xFFE8F2FE),
            badgeTextColor: const Color(0xFF1C7FF6),
            leftPanelColor: const Color(0xFF0056C6),
            btnColor: const Color(0xFF0056C6),
            btnText: 'ใช้คูปอง',
            illustrationIcon: Icons.local_activity_outlined,
          ),
          const SizedBox(height: 16),
          _buildCouponCard(
            amount: 20,
            title: 'ส่วนลด 20 บาท',
            subtitle: 'เมื่อใช้บริการครบ 150 บาทขึ้นไป',
            expiry: 'หมดอายุ 25 ก.ค. 2569',
            badgeText: 'คูปองส่วนลด',
            badgeBgColor: const Color(0xFFE8F8EE),
            badgeTextColor: const Color(0xFF22C55E),
            leftPanelColor: const Color(0xFF22C55E),
            btnColor: const Color(0xFF22C55E),
            btnText: 'ใช้คูปอง',
            illustrationIcon: Icons.local_shipping_outlined,
          ),
        ],
      );
    }

    // Tab 1: คูปองที่ใช้แล้ว
    if (_activeTab == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 72,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              'ไม่มีคูปองที่ใช้แล้ว',
              style: GoogleFonts.kanit(
                fontSize: 16,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Tab 2: หมดอายุ
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCouponCard(
          amount: 30,
          title: 'ส่วนลด 30 บาท',
          subtitle: 'เมื่อใช้บริการครบ 200 บาทขึ้นไป',
          expiry: 'หมดอายุ 10 ก.ค. 2569',
          badgeText: 'หมดอายุ',
          badgeBgColor: const Color(0xFFF1F5F9),
          badgeTextColor: const Color(0xFF64748B),
          leftPanelColor: Colors.grey.shade400,
          btnColor: Colors.transparent,
          btnText: 'หมดอายุแล้ว',
          isExpired: true,
          illustrationIcon: Icons.local_shipping_outlined,
        ),
      ],
    );
  }

  Widget _buildCouponCard({
    required int amount,
    required String title,
    required String subtitle,
    required String expiry,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required Color leftPanelColor,
    required Color btnColor,
    required String btnText,
    required IconData illustrationIcon,
    bool isExpired = false,
  }) {
    return Container(
      height: 124,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Left Panel (Notched Voucher visual amount representation)
            _buildLeftCouponBadge(amount, leftPanelColor),

            // Middle Info Panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      title,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.grey.shade600 : const Color(0xFF1F2937),
                      ),
                    ),
                    // Subtitle
                    Text(
                      subtitle,
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Expiry info
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isExpired ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expiry,
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            color: isExpired ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Dashed Divider simulation
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(),
            ),

            // Right Action Panel containing Illustration + Button
            Container(
              width: 90,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Illustration icon
                  Icon(
                    illustrationIcon,
                    size: 40,
                    color: Colors.grey.shade100,
                  ),
                  // Button/Badge
                  isExpired
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            btnText,
                            style: GoogleFonts.kanit(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 28,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: btnColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              btnText,
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Beautiful voucher badge on the left side with ticket cuts
  Widget _buildLeftCouponBadge(int amount, Color color) {
    return Container(
      width: 66,
      height: double.infinity,
      color: color,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-circle ticket cuts (top and bottom)
          Positioned(
            top: -6,
            left: -6,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            left: -6,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            right: -6,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Coupon Amount Value
          RotatedBox(
            quarterTurns: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ส่วนลด',
                  style: GoogleFonts.kanit(
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '$amount',
                  style: GoogleFonts.kanit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'บาท',
                  style: GoogleFonts.kanit(
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw dashed line separating coupon panels
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double dashHeight = 4;
    const double dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
