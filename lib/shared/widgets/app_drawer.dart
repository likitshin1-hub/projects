import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_assets.dart';
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
    final isDriver = user?.role == 'driver';

    final drawerBg = isDarkMode ? const Color(0xFF0B0F17) : Colors.white;
    final headerGradient = isDarkMode
        ? const [Color(0xFF0284C7), Color(0xFF1E293B)]
        : const [Color(0xFF1C7FF6), Color(0xFF0056C6)];
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final itemBg = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Drawer(
      backgroundColor: drawerBg,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage(AppAssets.logo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? user.name : 'ยินดีต้อนรับสู่ TBMoveHub',
                            style: GoogleFonts.kanit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLoggedIn
                                ? (isDriver ? 'พาร์ทเนอร์คนขับ (Driver)' : 'ผู้ใช้บริการ (Customer)')
                                ? : 'กรุณาเข้าสู่ระบบเพื่อใช้งานเต็มรูปแบบ',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // 1. หน้าหลัก (Home)
                _buildDrawerTile(
                  context,
                  icon: Icons.home_rounded,
                  title: 'หน้าหลัก',
                  subtitle: 'ค้นหาบริการขนส่งและเรียกใช้บริการ',
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.home);
                  },
                ),

                // Logic 1: ยังไม่ได้ล็อกอิน -> แสดงเมนู "เข้าสู่ระบบ / สมัครสมาชิก"
                if (!isLoggedIn) ...[
                  _buildDrawerTile(
                    context,
                    icon: Icons.login_rounded,
                    title: 'เข้าสู่ระบบ / สมัครสมาชิก',
                    subtitle: 'เข้าสู่ระบบบัญชีของคุณ',
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: itemBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.login);
                    },
                  ),
                ],

                // Logic 2: ล็อกอินแล้ว แต่ยังไม่ได้เป็นคนขับ -> แสดงเมนู "สมัครสมาชิกพาร์ทเนอร์คนขับ"
                if (isLoggedIn && !isDriver) ...[
                  _buildDrawerTile(
                    context,
                    icon: Icons.local_shipping_rounded,
                    title: 'สมัครพาร์ทเนอร์คนขับ',
                    subtitle: 'ร่วมสร้างรายได้กับเรา ขับง่าย ได้เงินไว',
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor: itemBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.registerPartner);
                    },
                  ),
                ],

                // Logic 3: ล็อกอินแล้ว และเป็นคนขับแล้ว -> แสดงเมนู "ศูนย์พาร์ทเนอร์คนขับ"
                if (isLoggedIn && isDriver) ...[
                  _buildDrawerTile(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'ศูนย์พาร์ทเนอร์คนขับ',
                    subtitle: 'ระบบจัดการงานสำหรับคนขับ',
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: itemBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.partner);
                    },
                  ),
                ],

                // 4. ลืมรหัสผ่าน (Forgot Password)
                if (!isLoggedIn) ...[
                  _buildDrawerTile(
                    context,
                    icon: Icons.lock_reset_rounded,
                    title: 'ลืมรหัสผ่าน',
                    subtitle: 'กู้คืนหรือรีเซ็ตรหัสผ่านบัญชี',
                    iconColor: const Color(0xFFEC4899),
                    iconBgColor: itemBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.forgotPassword);
                    },
                  ),
                ],

                Divider(height: 24, indent: 20, endIndent: 20, color: dividerColor),

                // Additional items
                _buildDrawerTile(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'การตั้งค่าระบบ & เลือกธีม',
                  subtitle: 'ปรับแต่งการแสดงผลโหมดมืด/สว่าง',
                  iconColor: const Color(0xFF6366F1),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),

                _buildDrawerTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'ความช่วยเหลือ / ติดต่อเรา',
                  subtitle: 'คำถามที่พบบ่อยและศูนย์ช่วยเหลือ',
                  iconColor: const Color(0xFF64748B),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.help);
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer (Logout when logged in)
          if (isLoggedIn) ...[
            Divider(height: 1, color: dividerColor),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                width: double.infinity,
                child: Row(
                  children: [
                    const Icon(
                      Icons.power_settings_new_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ออกจากระบบ',
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.kanit(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.kanit(
            fontSize: 11.5,
            color: subTextColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
