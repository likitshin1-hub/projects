import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  int _activeTab = 0; // 0: คูปองที่ใช้ได้, 1: คูปองที่ใช้แล้ว, 2: หมดอายุ

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    String t(String key) => AppTranslations.getText(currentLang, key);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
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
                      t('my_coupons'),
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
                  currentLang == AppLanguage.en
                      ? 'Save more on every delivery trip'
                      : 'ใช้คูปองให้คุ้มค่า ประหยัดทุกการเดินทาง',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

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
            child: _buildCouponsContent(t, isDarkMode, currentLang),
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

  Widget _buildCouponsContent(String Function(String) t, bool isDarkMode, AppLanguage currentLang) {
    if (_activeTab == 0) {
      return ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCouponCard(
            discountText: '50',
            unitText: t('baht_unit'),
            badgeText: t('discount_coupon'),
            title: currentLang == AppLanguage.en ? 'Discount 50 THB' : 'ส่วนลด 50 บาท',
            subtitle: currentLang == AppLanguage.en ? 'Min. spend 399 THB' : 'เมื่อใช้บริการครบ 399 บาทขึ้นไป',
            expiryText: currentLang == AppLanguage.en ? 'Expires 31 Aug 2026' : 'หมดอายุ 31 ส.ค. 2569',
            badgeBgColor: const Color(0xFFE8F2FE),
            badgeTextColor: const Color(0xFF1C7FF6),
            cardColor: const Color(0xFF1C7FF6),
            isDarkMode: isDarkMode,
            t: t,
          ),
          const SizedBox(height: 12),
          _buildCouponCard(
            discountText: '20',
            unitText: t('baht_unit'),
            badgeText: t('discount_coupon'),
            title: currentLang == AppLanguage.en ? 'Discount 20 THB' : 'ส่วนลด 20 บาท',
            subtitle: currentLang == AppLanguage.en ? 'Min. spend 150 THB' : 'เมื่อใช้บริการครบ 150 บาทขึ้นไป',
            expiryText: currentLang == AppLanguage.en ? 'Expires 25 Jul 2026' : 'หมดอายุ 25 ก.ย. 2569',
            badgeBgColor: const Color(0xFFECFDF5),
            badgeTextColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF10B981),
            isDarkMode: isDarkMode,
            t: t,
          ),
        ],
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
  }) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Ticket Ribbon Badge
          Container(
            width: 55,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  discountText,
                  style: GoogleFonts.kanit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  unitText,
                  style: GoogleFonts.kanit(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.kanit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiryText,
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t('use_coupon'),
                style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
