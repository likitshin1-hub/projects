import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../rewards/providers/rewards_provider.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  int _activeTab = 0; // 0: คูปองที่ใช้ได้, 1: คูปองที่ใช้แล้ว, 2: หมดอายุ

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final rewardsState = ref.watch(rewardsProvider).state;

    String t(String key) => AppTranslations.getText(currentLang, key);

    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final pageBg = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          t('my_coupons'),
          style: GoogleFonts.kanit(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Clock History button
          TextButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.access_time_rounded,
              size: 18,
              color: textColor,
            ),
            label: Text(
              currentLang == AppLanguage.en ? 'History' : 'ประวัติ',
              style: GoogleFonts.kanit(
                color: textColor,
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
          const SizedBox(height: 16),

          // ==========================================
          // TAB BAR / SEGMENTED CONTROL
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabItem(0, t('usable_coupons')),
                _buildTabItem(1, t('used_coupons')),
                _buildTabItem(2, t('expired_coupons')),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),

          // ==========================================
          // COUPONS LIST CONTENT
          // ==========================================
          Expanded(
            child: _buildCouponsContent(t, isDarkMode, currentLang, rewardsState.userCoupons),
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

  Widget _buildCouponsContent(String Function(String) t, bool isDarkMode, AppLanguage currentLang, List<UserCoupon> userCoupons) {
    if (_activeTab == 0) {
      if (userCoupons.isEmpty) {
        return Center(
          child: Text(
            currentLang == AppLanguage.en ? 'No coupons in this category' : 'ไม่มีคูปองในหมวดหมู่นี้',
            style: GoogleFonts.kanit(
              fontSize: 14,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: userCoupons.length,
        itemBuilder: (context, index) {
          final item = userCoupons[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCouponCard(
              discountText: item.discountText,
              unitText: item.unitText,
              badgeText: item.badgeText,
              title: item.title,
              subtitle: item.subtitle,
              expiryText: item.expiryText,
              badgeBgColor: item.badgeBgColor,
              badgeTextColor: item.badgeTextColor,
              cardColor: item.cardColor,
              illustrationIcon: item.illustrationIcon,
              isDarkMode: isDarkMode,
              t: t,
            ),
          );
        },
      );
    }

    return Center(
      child: Text(
        currentLang == AppLanguage.en ? 'No coupons in this category' : 'ไม่มีคูปองในหมวดหมู่นี้',
        style: GoogleFonts.kanit(
          fontSize: 14,
          color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildCouponCard({
    required String discountText,
    required String unitText,
    required String badgeText,
    required String title,
    required String subtitle,
    required String expiryText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required Color cardColor,
    required bool isDarkMode,
    required String Function(String) t,
    IconData illustrationIcon = Icons.local_shipping_outlined,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Left Panel (Voucher visual representation)
            Container(
              width: 104,
              color: cardColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Semi-circle ticket cuts
                  Positioned(
                    top: -7,
                    right: -7,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFFAFAFA),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -7,
                    right: -7,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFFAFAFA),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Voucher Left Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ส่วนลด',
                          style: GoogleFonts.kanit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            discountText,
                            style: GoogleFonts.kanit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            unitText,
                            style: GoogleFonts.kanit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.kanit(
                          fontSize: 9.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Middle Content Panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.kanit(
                        fontSize: 11.5,
                        color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expiryText,
                          style: GoogleFonts.kanit(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Vertical Dashed Line
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(),
            ),

            // Right Panel (Action Button / Icon)
            Container(
              width: 106,
              padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      illustrationIcon,
                      size: 38,
                      color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'นำส่วนลดคูปองไปใช้งานเรียบร้อยแล้ว!',
                              style: GoogleFonts.kanit(),
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        context.push(AppRoutes.booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B774),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'ใช้คูปอง',
                        style: GoogleFonts.kanit(
                          fontSize: 11.5,
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
    ),
  );
}
}

// Custom Painter for dashed line divider
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
