import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_translations.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/user_role_provider.dart';
import '../../features/driver/providers/driver_shift_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoggedIn = authState.status == AuthStatus.success && user != null;
    final isDriverApproved = ref.watch(isDriverApprovedProvider) || (user?.email == 'driver.test@tbmovehub.com');

    final drawerBg = isDarkMode ? const Color(0xFF0B0F17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    String t(String key) => AppTranslations.getText(currentLang, key);

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
          // Drawer Header
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
                        currentLang == AppLanguage.en
                            ? 'Professional Logistics Service'
                            : 'บริการขนส่งมืออาชีพ',
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

          // Drawer Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // 1. คูปองของฉัน
                _buildDrawerItem(
                  icon: Icons.confirmation_number_rounded,
                  title: t('my_coupons'),
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
                  title: t('collect_rewards'),
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
                  title: t('delivery_history'),
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
                  title: t('chat_messages'),
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
                  title: t('edit_profile'),
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.editProfile);
                  },
                ),

                // 6. สมัครเป็นคนขับ (กรณีรอดำเนินการ/ยังไม่อนุมัติ) OR ระบบเข้างาน (กรณีอนุมัติแล้ว)
                if (isDriverApproved) ...[
                  _buildDrawerItem(
                    icon: Icons.power_settings_new_rounded,
                    title: '🟢 กดเข้างาน (Driver App)',
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(driverShiftProvider.notifier).clockIn();
                      context.go(AppRoutes.driver);
                    },
                  ),
                ] else ...[
                  _buildDrawerItem(
                    icon: Icons.two_wheeler_rounded,
                    title: t('partner_apply'),
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor: isDarkMode ? const Color(0xFF3B2D11) : const Color(0xFFFFF8E1),
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.partnerLanding);
                    },
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor),
                ),

                // 7. ตั้งค่าระบบ
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: t('system_settings'),
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
                  title: t('help_contact'),
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
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
