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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
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
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
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
                            isLoggedIn ? user.name : 'TB MOVE HUB',
                            style: GoogleFonts.kanit(
                              fontSize: 18,
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
                                : 'บริการขนส่งมืออาชีพ',
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // 1. หน้าหลัก (Home)
                _buildDrawerTile(
                  context,
                  icon: Icons.home_rounded,
                  title: 'หน้าหลัก',
                  subtitle: 'ศูนย์รวมบริการขนส่งพัสดุและเรียกรถ',
                  iconColor: const Color(0xFF1C7FF6),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.home);
                  },
                ),

                // 2. เรียกใช้บริการจัดส่ง (Booking)
                _buildDrawerTile(
                  context,
                  icon: Icons.add_box_rounded,
                  title: 'เรียกใช้บริการจัดส่ง',
                  subtitle: 'จองรถขนส่งพัสดุและย้ายของ',
                  iconColor: const Color(0xFF0284C7),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.booking);
                  },
                ),

                // 3. สมัครพาร์ทเนอร์คนขับ / ไรเดอร์ (Rider/Driver Signup - New Menu Feature!)
                _buildDrawerTile(
                  context,
                  icon: Icons.two_wheeler_rounded,
                  title: 'สมัครพาร์ทเนอร์คนขับ / ไรเดอร์ 🛵',
                  subtitle: 'ร่วมสร้างรายได้กับเรา ขับง่าย ได้เงินไว',
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: isDarkMode ? const Color(0xFF3B2D11) : const Color(0xFFFFF8E1),
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.partnerLanding);
                  },
                ),

                // 4. ศูนย์พาร์ทเนอร์คนขับ (แสดงเฉพาะคนขับ)
                if (isLoggedIn && isDriver) ...[
                  _buildDrawerTile(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'ศูนย์พาร์ทเนอร์คนขับ',
                    subtitle: 'แดชบอร์ดและจัดการงานจัดส่ง',
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

                // 5. คูปองของฉัน (Coupons)
                _buildDrawerTile(
                  context,
                  icon: Icons.local_activity_rounded,
                  title: 'คูปองของฉัน',
                  subtitle: 'เก็บและใช้โค้ดส่วนลดขนส่ง',
                  iconColor: const Color(0xFF10B981),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.coupons);
                  },
                ),

                // 6. สะสมรีวอร์ด (Rewards)
                _buildDrawerTile(
                  context,
                  icon: Icons.emoji_events_rounded,
                  title: 'สะสมรีวอร์ด',
                  subtitle: 'แลกแต้มรับของรางวัลและสิทธิพิเศษ',
                  iconColor: const Color(0xFFFFB300),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rewards);
                  },
                ),

                // 7. ประวัติการจัดส่ง (History)
                _buildDrawerTile(
                  context,
                  icon: Icons.calendar_month_rounded,
                  title: 'ประวัติการจัดส่ง',
                  subtitle: 'รายการคำสั่งซื้อและสถานะพัสดุ',
                  iconColor: const Color(0xFF8B5CF6),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.history);
                  },
                ),

                // 8. แก้ไขโปรไฟล์ (Edit Profile)
                if (isLoggedIn) ...[
                  _buildDrawerTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'แก้ไขโปรไฟล์',
                    subtitle: 'จัดการข้อมูลส่วนตัวและที่อยู่',
                    iconColor: const Color(0xFFEC4899),
                    iconBgColor: itemBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.editProfile);
                    },
                  ),
                ],

                Divider(height: 24, indent: 20, endIndent: 20, color: dividerColor),

                // 9. ตั้งค่าระบบ (Settings & Theme)
                _buildDrawerTile(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'ตั้งค่าระบบ & เลือกธีม',
                  subtitle: 'ปรับแต่งโหมดสว่าง / โหมดมืด',
                  iconColor: const Color(0xFF6366F1),
                  iconBgColor: itemBg,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),

                // 10. ความช่วยเหลือ / ติดต่อเรา (Help)
                _buildDrawerTile(
                  context,
                  icon: Icons.info_outline_rounded,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.kanit(
            fontSize: 11,
            color: subTextColor,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color: Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }
}
