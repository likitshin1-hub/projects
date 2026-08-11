import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(bottom: 2),
                child: customIcon ?? Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: isActive ? 24 : 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.kanit(
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(label),
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
    final navBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final activeColor = isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey[600]!;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        height: 76,
        decoration: BoxDecoration(
          color: navBgColor,
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                label: 'ติดตามพัสดุ',
                isActive: currentIndex == 0,
                isDarkMode: isDarkMode,
              ),

              // Tab 1: ประวัติการส่ง
              _buildNavItem(
                index: 1,
                icon: Icons.calendar_month_rounded,
                label: 'ประวัติการส่ง',
                isActive: currentIndex == 1,
                isDarkMode: isDarkMode,
              ),

              // Tab 2: หน้าหลัก
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? const [Color(0xFF0284C7), Color(0xFF2563EB)]
                                : const [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'หน้าหลัก',
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          fontWeight: currentIndex == 2 ? FontWeight.w600 : FontWeight.normal,
                          color: currentIndex == 2 ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab 3: ข้อความ
              _buildNavItem(
                index: 3,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'ข้อความ',
                isActive: currentIndex == 3,
                isDarkMode: isDarkMode,
              ),

              // Tab 4: บัญชีของฉัน
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                label: 'บัญชีของฉัน',
                isActive: currentIndex == 4,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
