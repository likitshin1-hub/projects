import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _is2FAEnabled = true;
  bool _isBiometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isEn = currentLang == AppLanguage.en;

    final notifications = ref.watch(notificationsProvider);
    final unreadNotifs = notifications.where((n) => !n.isRead).length;

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF4F7FC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE8EDF5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ==========================================
            // APP STANDARD CURVED BLUE APPBAR
            // ==========================================
            ClipPath(
              clipper: SecurityHeaderClipper(),
              child: Container(
                width: double.infinity,
                height: 155 + statusBarHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C7FF6),
                      Color(0xFF0056C6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 0),
                child: Stack(
                  children: [
                    // Subtle background watermark icons
                    Positioned(
                      right: -10,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.15,
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 105,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 75,
                      bottom: 35,
                      child: Opacity(
                        opacity: 0.1,
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Top Header Content Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button with dark translucent circle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.settings);
                              }
                            },
                          ),
                        ),

                        // Center Title & Subtitle
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isEn ? 'Security' : 'ความปลอดภัย',
                              style: GoogleFonts.kanit(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isEn ? 'Account & Protection' : 'การปกป้องบัญชีและข้อมูลของคุณ',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),

                        // Notification Bell
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.notification),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                if (unreadNotifs > 0)
                                  Positioned(
                                    top: 8,
                                    right: 9,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF3B30),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // RESPONSIVE CENTERED SCROLLABLE CONTENT
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. HERO BANNER CARD (ความปลอดภัย)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                                  const Color(0xFF1E293B),
                                ]
                              : [
                                  const Color(0xFFE8F3FF),
                                  const Color(0xFFD9ECFE),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                              : const Color(0xFFBFDBFE),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Lock Shield Icon Box
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEn ? 'Security Protection' : 'ความปลอดภัย',
                                  style: GoogleFonts.kanit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isEn
                                      ? 'Protect your account and personal data'
                                      : 'ปกป้องบัญชีและข้อมูลของคุณให้ปลอดภัยยิ่งขึ้น',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF475569),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Glowing Checkmark Shield Illustration
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. MAIN SECURITY SETTINGS GROUP CARD
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Item 1: การยืนยันตัวตน
                          _buildSettingRow(
                            icon: Icons.phonelink_lock_rounded,
                            iconBgColor: const Color(0xFFE8F2FE),
                            iconColor: const Color(0xFF1C7FF6),
                            title: isEn ? 'Identity Verification' : 'การยืนยันตัวตน',
                            badgeText: isEn ? '✦ Recommended ✦' : '✦ แนะนำ ✦',
                            subtitle: isEn
                                ? 'Verify with OTP & enable 2-step verification'
                                : 'ยืนยันตัวตนด้วย OTP และเปิดใช้งาน 2 ขั้นตอน',
                            textColor: textColor,
                            subTextColor: subTextColor,
                            isDarkMode: isDarkMode,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch.adaptive(
                                  value: _is2FAEnabled,
                                  activeThumbColor: const Color(0xFF1C7FF6),
                                  onChanged: (val) {
                                    setState(() {
                                      _is2FAEnabled = val;
                                    });
                                    _showToast(
                                      val
                                          ? (isEn ? '2-Step Verification enabled' : 'เปิดใช้งานการยืนยันตัวตน 2 ขั้นตอนแล้ว')
                                          : (isEn ? '2-Step Verification disabled' : 'ปิดใช้งานการยืนยันตัวตน 2 ขั้นตอนแล้ว'),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF1C7FF6),
                                  size: 22,
                                ),
                              ],
                            ),
                            onTap: () => _show2FAModal(context, isEn, isDarkMode),
                          ),

                          Divider(height: 1, indent: 68, endIndent: 16, color: dividerColor),

                          // Item 2: อุปกรณ์ที่เข้าสู่ระบบ
                          _buildSettingRow(
                            icon: Icons.devices_rounded,
                            iconBgColor: const Color(0xFFE8F2FE),
                            iconColor: const Color(0xFF1C7FF6),
                            title: isEn ? 'Logged-in Devices' : 'อุปกรณ์ที่เข้าสู่ระบบ',
                            subtitle: isEn
                                ? 'Manage devices you are currently using'
                                : 'จัดการอุปกรณ์ที่คุณใช้งานอยู่',
                            textColor: textColor,
                            subTextColor: subTextColor,
                            isDarkMode: isDarkMode,
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF1C7FF6),
                              size: 22,
                            ),
                            onTap: () => context.push(AppRoutes.devices),
                          ),

                          Divider(height: 1, indent: 68, endIndent: 16, color: dividerColor),

                          // Item 3: ประวัติการเข้าสู่ระบบ
                          _buildSettingRow(
                            icon: Icons.access_time_rounded,
                            iconBgColor: const Color(0xFFE8F2FE),
                            iconColor: const Color(0xFF1C7FF6),
                            title: isEn ? 'Login History' : 'ประวัติการเข้าสู่ระบบ',
                            subtitle: isEn
                                ? 'Check account login activity & sessions'
                                : 'ตรวจสอบกิจกรรมการเข้าสู่ระบบบัญชี',
                            textColor: textColor,
                            subTextColor: subTextColor,
                            isDarkMode: isDarkMode,
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF1C7FF6),
                              size: 22,
                            ),
                            onTap: () => _showLoginHistoryModal(context, isEn, isDarkMode),
                          ),

                          Divider(height: 1, indent: 68, endIndent: 16, color: dividerColor),

                          // Item 4: ความเป็นส่วนตัว
                          _buildSettingRow(
                            icon: Icons.admin_panel_settings_rounded,
                            iconBgColor: const Color(0xFFE8F2FE),
                            iconColor: const Color(0xFF1C7FF6),
                            title: isEn ? 'Privacy' : 'ความเป็นส่วนตัว',
                            subtitle: isEn
                                ? 'Manage personal data & permissions'
                                : 'จัดการข้อมูลส่วนตัวและสิทธิ์การเข้าถึง',
                            textColor: textColor,
                            subTextColor: subTextColor,
                            isDarkMode: isDarkMode,
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF1C7FF6),
                              size: 22,
                            ),
                            onTap: () {
                              context.push(AppRoutes.legal, extra: {'isPrivacy': true});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. BOTTOM TIP BANNER (ดูแลความปลอดภัยให้มากขึ้น)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                              : const Color(0xFFDBEAFE),
                          width: 1.2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _show2FAModal(context, isEn, isDarkMode),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1C7FF6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isEn ? 'Enhance Your Security' : 'ดูแลความปลอดภัยให้มากขึ้น',
                                        style: GoogleFonts.kanit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1C7FF6),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isEn
                                            ? 'Enable 2-Factor Authentication (2FA) for extra protection.'
                                            : 'เปิดใช้งานการยืนยันตัวตน 2 ขั้นตอน (2FA) เพื่อเพิ่มความปลอดภัยให้กับบัญชีของคุณ',
                                        style: GoogleFonts.kanit(
                                          fontSize: 11.5,
                                          color: isDarkMode
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF475569),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF1C7FF6),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
}

  // ==========================================
  // HELPER: SETTING ROW BUILDER
  // ==========================================
  Widget _buildSettingRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? badgeText,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                      : iconBgColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.kanit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4B4B), Color(0xFFFF6B6B)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.kanit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.kanit(
                        fontSize: 11.5,
                        color: subTextColor,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              trailing,
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODALS & DIALOGS
  // ==========================================

  void _show2FAModal(BuildContext context, bool isEn, bool isDarkMode) {
    final sheetBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? '2-Step Verification Settings' : 'การยืนยันตัวตน 2 ขั้นตอน (2FA)',
                style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                isEn
                    ? 'Adds an extra layer of protection when logging in from new devices.'
                    : 'เพิ่มความปลอดภัยอีกขั้นด้วยการยืนยันรหัส OTP ทุกครั้งที่มีการเข้าสู่ระบบจากเครื่องใหม่',
                style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isEn ? 'SMS OTP Authentication' : 'ยืนยันตัวตนผ่าน SMS OTP',
                  style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                ),
                subtitle: Text(
                  isEn ? 'Send code to registered phone' : 'ส่งรหัส 6 หลักไปยังเบอร์โทรศัพท์ที่ลงทะเบียน',
                  style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
                value: _is2FAEnabled,
                activeThumbColor: const Color(0xFF1C7FF6),
                onChanged: (val) {
                  setModalState(() => _is2FAEnabled = val);
                  setState(() => _is2FAEnabled = val);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isEn ? 'Biometric Login (Fingerprint / Face ID)' : 'เข้าสู่ระบบด้วยสแกนลายนิ้วมือ / ใบหน้า',
                  style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                ),
                subtitle: Text(
                  isEn ? 'Unlock quickly and safely' : 'ปลดล็อกเข้าสู่ระบบอย่างรวดเร็วและปลอดภัย',
                  style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
                value: _isBiometricEnabled,
                activeThumbColor: const Color(0xFF1C7FF6),
                onChanged: (val) {
                  setModalState(() => _isBiometricEnabled = val);
                  setState(() => _isBiometricEnabled = val);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C7FF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showToast(isEn ? 'Security settings saved' : 'บันทึกการตั้งค่าความปลอดภัยแล้ว');
                  },
                  child: Text(isEn ? 'Save' : 'บันทึกข้อมูล', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginHistoryModal(BuildContext context, bool isEn, bool isDarkMode) {
    final sheetBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEn ? 'Recent Login Activity' : 'ประวัติกิจกรรมการเข้าสู่ระบบ',
              style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 14),
            _buildHistoryItem('เข้าสู่ระบบสำเร็จ (Mobile App)', '28 ส.ค. 2569, 12:30 น. • IP: 182.52.19.45', isSuccess: true, isDarkMode: isDarkMode, textColor: textColor),
            const SizedBox(height: 8),
            _buildHistoryItem('เข้าสู่ระบบสำเร็จ (Web Browser)', '27 ส.ค. 2569, 15:40 น. • IP: 182.52.19.45', isSuccess: true, isDarkMode: isDarkMode, textColor: textColor),
            const SizedBox(height: 8),
            _buildHistoryItem('เปลี่ยนรหัสผ่านสำเร็จ', '20 ส.ค. 2569, 09:12 น. • IP: 182.52.19.45', isSuccess: true, isDarkMode: isDarkMode, textColor: textColor),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C7FF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(isEn ? 'Close' : 'ปิดหน้าต่าง', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String subtitle, {required bool isSuccess, required bool isDarkMode, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                Text(subtitle, style: GoogleFonts.kanit(fontSize: 11, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF1C7FF6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class SecurityHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
