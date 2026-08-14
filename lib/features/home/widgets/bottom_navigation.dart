import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class CustomBottomNavigation extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    Widget? customIcon,
    required String label,
    required bool isActive,
    required bool isDarkMode,
    bool hasRightDivider = false,
  }) {
    final activeColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: activeColor.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      child: customIcon ??
                          Icon(
                            isActive ? activeIcon : icon,
                            color: isActive ? activeColor : inactiveColor,
                            size: 26,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? activeColor : inactiveColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Active blue underline indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 24 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasRightDivider)
            Positioned(
              right: 0,
              top: 16,
              bottom: 16,
              child: Container(
                width: 1,
                color: dividerColor,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    final navBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    String t(String key) => AppTranslations.getText(currentLang, key);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
        height: 76,
        decoration: BoxDecoration(
          color: navBgColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF334155) : Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.12),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tab 0: ติดตามพัสดุ
            _buildNavItem(
              index: 0,
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              label: t('tracking'),
              isActive: currentIndex == 0,
              isDarkMode: isDarkMode,
              hasRightDivider: true,
            ),

            // Tab 1: ประวัติการส่ง
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month_rounded,
              label: t('history'),
              isActive: currentIndex == 1,
              isDarkMode: isDarkMode,
              hasRightDivider: true,
            ),

            // Tab 2: หน้าหลัก (CENTER FLOATING CIRCLE BUTTON)
            _buildCenterHomeNavItem(
              index: 2,
              isActive: currentIndex == 2,
              isDarkMode: isDarkMode,
              label: t('home'),
              dividerColor: dividerColor,
            ),

            // Tab 3: การแจ้งเตือน / แชท
            _buildNavItem(
              index: 3,
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              label: t('chat'),
              isActive: currentIndex == 3,
              isDarkMode: isDarkMode,
              hasRightDivider: true,
            ),

            // Tab 4: โปรไฟล์
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: t('profile'),
              isActive: currentIndex == 4,
              isDarkMode: isDarkMode,
              hasRightDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHomeNavItem({
    required int index,
    required bool isActive,
    required bool isDarkMode,
    required String label,
    required Color dividerColor,
  }) {
    final activeColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -24,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1C7FF6)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.45),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 24 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 16,
            bottom: 16,
            child: Container(
              width: 1,
              color: dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}
