import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_routes.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoggedIn = authState.status == AuthStatus.success && user != null;

    final drawerBg = isDarkMode ? const Color(0xFF0B0F17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Drawer(
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header Matching Screenshot Exactly
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
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
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? user.name : 'TB MOVE HUB',
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'บริการขนส่งมืออาชีพ',
                        style: GoogleFonts.kanit(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Menu List (Exact items & styles as screenshot)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // 1. คูปองของฉัน
                _buildDrawerItem(
                  icon: Icons.confirmation_number_rounded,
                  title: 'คูปองของฉัน',
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.coupons);
                  },
                ),

                // 2. สะสมรีวอร์ด
                _buildDrawerItem(
                  icon: Icons.emoji_events_rounded,
                  title: 'สะสมรีวอร์ด',
                  iconColor: const Color(0xFFFFB300),
                  iconBgColor: isDarkMode ? const Color(0xFF3B2D11) : const Color(0xFFFFF8E1),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rewards);
                  },
                ),

                // 3. ประวัติการจัดส่ง
                _buildDrawerItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'ประวัติการจัดส่ง',
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.history);
                  },
                ),

                // 4. ข้อความแชท
                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'ข้อความแชท',
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('${AppRoutes.chat}/driver_1');
                  },
                ),

                // 5. แก้ไขโปรไฟล์
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'แก้ไขโปรไฟล์',
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.editProfile);
                  },
                ),

                // 6. สมัครพาร์ทเนอร์คนขับ / ไรเดอร์
                _buildDrawerItem(
                  icon: Icons.two_wheeler_rounded,
                  title: 'สมัครพาร์ทเนอร์คนขับ / ไรเดอร์ 🛵',
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: isDarkMode ? const Color(0xFF3B2D11) : const Color(0xFFFFF8E1),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.partnerLanding);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor),
                ),

                // 7. ตั้งค่าระบบ
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'ตั้งค่าระบบ',
                  iconColor: const Color(0xFF64748B),
                  iconBgColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),

                // 8. ความช่วยเหลือ / ติดต่อเรา
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'ความช่วยเหลือ / ติดต่อเรา',
                  iconColor: const Color(0xFF64748B),
                  iconBgColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.help);
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer with Logout Button
          Divider(height: 1, color: dividerColor),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              if (isLoggedIn) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              } else {
                context.push(AppRoutes.login);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              width: double.infinity,
              child: Row(
                children: [
                  Icon(
                    isLoggedIn ? Icons.power_settings_new_rounded : Icons.login_rounded,
                    color: isLoggedIn ? Colors.redAccent : const Color(0xFF10B981),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isLoggedIn ? 'ออกจากระบบ' : 'เข้าสู่ระบบ / สมัครสมาชิก',
                    style: GoogleFonts.kanit(
                      fontSize: 14.5,
                      color: isLoggedIn ? Colors.redAccent : const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
    required Color iconBgColor,
    required Color textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFF94A3B8),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
