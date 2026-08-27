import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/theme_provider.dart';

class DriverBottomNavigation extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DriverBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    Color activeColor,
    Color inactiveColor,
    Color dividerColor,
    bool hasRightDivider,
  ) {
    final isActive = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: hasRightDivider ? Border(right: BorderSide(color: dividerColor, width: 0.8)) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isActive ? activeIcon : icon, color: isActive ? activeColor : inactiveColor, size: 24),
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
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 20 : 0,
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
    );
  }

  Widget _buildCenterNavItem(
    int index,
    String label,
    Color activeColor,
    Color inactiveColor,
    Color dividerColor,
  ) {
    final isActive = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: dividerColor, width: 0.8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F192C), Color(0xFF1E3A8A)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x4D1E3A8A), blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final navBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final activeColor = isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        height: 72,
        decoration: BoxDecoration(
          color: navBgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF334155) : Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(isDarkMode ? 0.25 : 0.15),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(0, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'กระเป๋าเงิน', activeColor, inactiveColor, dividerColor, true),
            _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'ประวัติการขนส่ง', activeColor, inactiveColor, dividerColor, true),
            _buildCenterNavItem(2, 'เริ่มงาน', activeColor, inactiveColor, dividerColor),
            _buildNavItem(3, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'แชต', activeColor, inactiveColor, dividerColor, true),
            _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'โปรไฟล์', activeColor, inactiveColor, dividerColor, false),
          ],
        ),
      ),
    );
  }
}
