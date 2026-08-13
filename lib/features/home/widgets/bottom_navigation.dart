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

  Widget _buildTrackingIcon({
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required Color navBgColor,
  }) {
    final color = isActive ? activeColor : inactiveColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          color: color,
          size: 24,
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: navBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: color,
              size: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    Widget? customIcon,
    required String label,
    required bool isActive,
    required bool isDarkMode,
  }) {
    final activeColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey[600]!;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: activeColor.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
                child: Center(
                  child: customIcon ??
                      Icon(
                        icon,
                        color: isActive ? activeColor : inactiveColor,
                        size: 24,
                      ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    final navBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final activeColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey[600]!;

    String t(String key) => AppTranslations.getText(currentLang, key);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        height: 72,
        decoration: BoxDecoration(
          color: navBgColor,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tab 0: ติดตามพัสดุ
            _buildNavItem(
              index: 0,
              icon: Icons.inventory_2_outlined,
              customIcon: _buildTrackingIcon(
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                navBgColor: navBgColor,
              ),
              label: t('tracking'),
              isActive: currentIndex == 0,
              isDarkMode: isDarkMode,
            ),

            // Tab 1: ประวัติการส่ง
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_month_rounded,
              label: t('history'),
              isActive: currentIndex == 1,
              isDarkMode: isDarkMode,
            ),

            // Tab 2: หน้าหลัก (CENTER BUTTON)
            _buildCenterHomeNavItem(
              index: 2,
              isActive: currentIndex == 2,
              isDarkMode: isDarkMode,
              label: t('home'),
            ),

            // Tab 3: การแจ้งเตือน / แชท
            _buildNavItem(
              index: 3,
              icon: Icons.chat_bubble_outline_rounded,
              label: t('chat'),
              isActive: currentIndex == 3,
              isDarkMode: isDarkMode,
            ),

            // Tab 4: โปรไฟล์
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              label: t('profile'),
              isActive: currentIndex == 4,
              isDarkMode: isDarkMode,
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
  }) {
    final activeColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey[600]!;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -12,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
