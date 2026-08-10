import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigation extends StatelessWidget {
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
    required String label,
    required bool isActive,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: const Color(0xFF1C7FF6).withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  icon,
                  color: isActive ? const Color(0xFF1C7FF6) : Colors.grey[500],
                  size: isActive ? 24 : 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.kanit(
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? const Color(0xFF1C7FF6) : Colors.grey[600],
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
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 0: หน้าหลัก
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'หน้าหลัก',
              isActive: currentIndex == 0,
            ),
            // Tab 1: ประวัติการส่ง
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_month_rounded,
              label: 'ประวัติการส่ง',
              isActive: currentIndex == 1,
            ),
            
            // Tab 2: เรียกใช้บริการ (Center plus button)
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1C7FF6),
                            Color(0xFF0056C6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1C7FF6),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เรียกใช้บริการ',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight: currentIndex == 2 ? FontWeight.bold : FontWeight.normal,
                        color: currentIndex == 2 ? const Color(0xFF1C7FF6) : Colors.grey[600],
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
            ),
            // Tab 4: บัญชีของฉัน
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              label: 'บัญชีของฉัน',
              isActive: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }
}
