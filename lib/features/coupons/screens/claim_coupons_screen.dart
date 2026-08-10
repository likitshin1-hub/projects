import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_routes.dart';

class ClaimCouponsScreen extends StatefulWidget {
  const ClaimCouponsScreen({super.key});

  @override
  State<ClaimCouponsScreen> createState() => _ClaimCouponsScreenState();
}

class _ClaimCouponsScreenState extends State<ClaimCouponsScreen> {
  int _selectedCategoryIndex = 0; // 0: ทั้งหมด, 1: คูปองส่วนลด, 2: คูปองส่งฟรี, 3: คูปองพิเศษ

  final List<String> _categories = [
    'ทั้งหมด (5)',
    'คูปองส่วนลด',
    'คูปองส่งฟรี',
    'คูปองพิเศษ',
  ];

  final List<IconData> _categoryIcons = [
    Icons.local_activity_rounded,
    Icons.shopping_bag_rounded,
    Icons.local_shipping_rounded,
    Icons.stars_rounded,
  ];

  final List<Color> _categoryColors = [
    const Color(0xFF1C7FF6),
    const Color(0xFF22C55E),
    const Color(0xFFA855F7),
    const Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // Clean white AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          'เก็บคูปอง',
          style: GoogleFonts.kanit(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Clock History button
          TextButton.icon(
            onPressed: () {
              context.push(AppRoutes.coupons);
            },
            icon: const Icon(
              Icons.access_time_rounded,
              size: 18,
              color: Color(0xFF1F2937),
            ),
            label: Text(
              'ประวัติ',
              style: GoogleFonts.kanit(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Selectors & Banner scroll area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // ==========================================
                // BLUE GRADIENT GRAPHIC BANNER CARD
                // ==========================================
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C7FF6).withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // Background Generated Banner Image
                        Image.asset(
                          AppAssets.claimCouponBanner,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            );
                          },
                        ),
                        // Soft overlay to ensure readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        // Banner text content overlay
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'รวมคูปองสุดคุ้ม',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ให้การขนส่งของคุณ\nคุ้มค่าทุกการใช้งาน',
                                style: GoogleFonts.kanit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'เก็บคูปองไว้ ใช้ลดค่าขนส่งได้ทันที',
                                style: GoogleFonts.kanit(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // HORIZONTAL CATEGORIES ROW SELECTOR
                // ==========================================
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = _selectedCategoryIndex == index;
                      final Color activeColor = _categoryColors[index];

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          avatar: Icon(
                            _categoryIcons[index],
                            size: 16,
                            color: isSelected ? Colors.white : activeColor,
                          ),
                          label: Text(
                            _categories[index],
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : const Color(0xFF4B5563),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: activeColor,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.shade200,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // SECTION TITLE & FILTER ROW
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'คูปองที่เก็บได้',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'เรียงตาม ล่าสุด',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ==========================================
                // LIST OF COUPONS
                // ==========================================
                _buildCouponList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    // Generate filtered list
    final allCoupons = [
      _ClaimCouponData(
        amount: '50',
        minSpend: 'ขั้นต่ำ 300 บาท',
        title: 'ส่วนลด 50 บาท',
        desc: 'ใช้ได้กับบริการขนส่งทุกประเภท',
        expiry: 'หมดอายุ 31 ส.ค. 2568',
        badge: 'คูปองส่วนลด',
        categoryIndex: 1, // คูปองส่วนลด
        leftColor: const Color(0xFF1C7FF6),
        badgeBg: const Color(0xFFE8F2FE),
        badgeTextCol: const Color(0xFF1C7FF6),
        btnBg: const Color(0xFF1C7FF6),
        illustrationIcon: Icons.local_shipping_outlined,
      ),
      _ClaimCouponData(
        amount: '20',
        minSpend: 'ขั้นต่ำ 150 บาท',
        title: 'ส่วนลด 20 บาท',
        desc: 'ใช้ได้กับบริการขนส่งทุกประเภท',
        expiry: 'หมดอายุ 15 ส.ค. 2568',
        badge: 'คูปองส่วนลด',
        categoryIndex: 1, // คูปองส่วนลด
        leftColor: const Color(0xFF22C55E),
        badgeBg: const Color(0xFFE8F8EE),
        badgeTextCol: const Color(0xFF22C55E),
        btnBg: const Color(0xFF22C55E),
        illustrationIcon: Icons.motorcycle_rounded,
      ),
      _ClaimCouponData(
        amount: 'ฟรี',
        minSpend: 'ไม่มีขั้นต่ำ',
        title: 'ส่งฟรีทั่วไทย',
        desc: 'รับส่วนลดค่าส่งสูงสุด 40 บาท',
        expiry: 'หมดอายุ 10 ส.ค. 2568',
        badge: 'คูปองส่งฟรี',
        categoryIndex: 2, // คูปองส่งฟรี
        leftColor: const Color(0xFF8B5CF6),
        badgeBg: const Color(0xFFF3E8FF),
        badgeTextCol: const Color(0xFF8B5CF6),
        btnBg: const Color(0xFF8B5CF6),
        illustrationIcon: Icons.local_shipping_outlined,
        isFreeShip: true,
      ),
      _ClaimCouponData(
        amount: '30',
        minSpend: 'ขั้นต่ำ 250 บาท',
        title: 'ส่วนลด 30 บาท',
        desc: 'สำหรับลูกค้าใหม่เท่านั้น',
        expiry: 'หมดอายุ 5 ส.ค. 2568',
        badge: 'คูปองพิเศษ',
        categoryIndex: 3, // คูปองพิเศษ
        leftColor: const Color(0xFFF97316),
        badgeBg: const Color(0xFFFFEDD5),
        badgeTextCol: const Color(0xFFF97316),
        btnBg: const Color(0xFFF97316),
        illustrationIcon: Icons.card_giftcard_rounded,
      ),
      _ClaimCouponData(
        amount: '15',
        minSpend: 'ขั้นต่ำ 100 บาท',
        title: 'ส่วนลด 15 บาท',
        desc: 'ใช้ได้กับบริการขนส่งทุกประเภท',
        expiry: 'หมดอายุ 1 ส.ค. 2568',
        badge: 'คูปองส่วนลด',
        categoryIndex: 1, // คูปองส่วนลด
        leftColor: Colors.grey.shade400,
        badgeBg: const Color(0xFFF1F5F9),
        badgeTextCol: const Color(0xFF64748B),
        btnBg: Colors.transparent,
        illustrationIcon: Icons.local_shipping_outlined,
        isExpired: true,
      ),
    ];

    // Filter based on selected category index
    final filtered = _selectedCategoryIndex == 0
        ? allCoupons
        : allCoupons.where((c) => c.categoryIndex == _selectedCategoryIndex).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 64,
                color: Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 12),
              Text(
                'ไม่มีคูปองประเภทนี้ให้เก็บ',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final coupon = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildClaimCard(coupon),
        );
      },
    );
  }

  Widget _buildClaimCard(_ClaimCouponData coupon) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Left Panel (Voucher visual representation)
            Container(
              width: 76,
              color: coupon.leftColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Semi-circle ticket cuts
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
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
                        color: Color(0xFFFAFAFA),
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
                        color: Color(0xFFFAFAFA),
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
                        color: Color(0xFFFAFAFA),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Voucher Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          coupon.isFreeShip ? 'ส่งฟรี' : 'ส่วนลด',
                          style: GoogleFonts.kanit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            coupon.amount,
                            style: GoogleFonts.kanit(
                              fontSize: coupon.isFreeShip ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          if (!coupon.isFreeShip) ...[
                            const SizedBox(width: 1),
                            Text(
                              'บาท',
                              style: GoogleFonts.kanit(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coupon.minSpend,
                        style: GoogleFonts.kanit(
                          fontSize: 8,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Middle Description Panel
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
                        color: coupon.badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        coupon.badge,
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: coupon.badgeTextCol,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      coupon.title,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: coupon.isExpired ? Colors.grey.shade600 : const Color(0xFF1F2937),
                      ),
                    ),
                    // Subtitle
                    Text(
                      coupon.desc,
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
                          Icons.calendar_month_rounded,
                          size: 13,
                          color: coupon.isExpired ? Colors.red : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          coupon.expiry,
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            color: coupon.isExpired ? Colors.red : const Color(0xFF94A3B8),
                            fontWeight: coupon.isExpired ? FontWeight.bold : FontWeight.normal,
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

            // Right Action Panel containing Faded Icon + Button
            Container(
              width: 96,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Illustration icon
                  Icon(
                    coupon.illustrationIcon,
                    size: 40,
                    color: Colors.grey.shade100,
                  ),
                  // Button/Badge
                  coupon.isExpired
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'หมดอายุแล้ว',
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
                              backgroundColor: coupon.btnBg,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'ใช้คูปอง',
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
}

class _ClaimCouponData {
  final String amount;
  final String minSpend;
  final String title;
  final String desc;
  final String expiry;
  final String badge;
  final int categoryIndex;
  final Color leftColor;
  final Color badgeBg;
  final Color badgeTextCol;
  final Color btnBg;
  final IconData illustrationIcon;
  final bool isFreeShip;
  final bool isExpired;

  _ClaimCouponData({
    required this.amount,
    required this.minSpend,
    required this.title,
    required this.desc,
    required this.expiry,
    required this.badge,
    required this.categoryIndex,
    required this.leftColor,
    required this.badgeBg,
    required this.badgeTextCol,
    required this.btnBg,
    required this.illustrationIcon,
    this.isFreeShip = false,
    this.isExpired = false,
  });
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
