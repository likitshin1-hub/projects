import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/two_factor_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final bool _isBiometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isEn = currentLang == AppLanguage.en;

    final is2FAEnabled = ref.watch(twoFactorProvider);
    final notifications = ref.watch(notificationsProvider);
    final unreadNotifs = notifications.where((n) => !n.isRead).length;

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFEEF2F8);

    final secScore = (is2FAEnabled ? 60 : 0) + (_isBiometricEnabled ? 40 : 0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 10, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.settings);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEn ? 'Security' : 'ความปลอดภัย',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEn ? 'Account & Protection' : 'การปกป้องบัญชีและข้อมูลของคุณ',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.notification),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 23),
                        if (unreadNotifs > 0)
                          Positioned(
                            top: 9,
                            right: 10,
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
          ),

          // ── BODY (FULL WIDTH) ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Security Score Card
                  _buildScoreCard(secScore, isDarkMode, isEn),
                  const SizedBox(height: 14),

                  // 2. Section label
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 8),
                    child: Text(
                      isEn ? 'Security Settings' : 'การตั้งค่าความปลอดภัย',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // 3. Settings card
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildRow(
                          icon: Icons.phonelink_lock_rounded,
                          title: isEn ? 'Identity Verification' : 'การยืนยันตัวตน',
                          badge: isEn ? '✦ Recommended ✦' : '✦ แนะนำ ✦',
                          subtitle: isEn
                              ? 'Verify with OTP & 2-step login'
                              : 'ยืนยันตัวตนด้วย OTP และเปิดใช้งาน 2 ขั้นตอน',
                          textColor: textColor,
                          sub: subTextColor,
                          dark: isDarkMode,
                          first: true,
                          trail: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: is2FAEnabled,
                                activeThumbColor: Colors.white,
                                activeTrackColor: const Color(0xFF1C7FF6),
                                onChanged: (val) => context.push(AppRoutes.twoFactor),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFFB8C4D6), size: 20),
                            ],
                          ),
                          tap: () => context.push(AppRoutes.twoFactor),
                        ),
                        _divider(dividerColor),
                        _buildRow(
                          icon: Icons.devices_rounded,
                          title: isEn ? 'Logged-in Devices' : 'อุปกรณ์ที่เข้าสู่ระบบ',
                          subtitle: isEn
                              ? 'Manage devices currently in use'
                              : 'จัดการอุปกรณ์ที่คุณใช้งานอยู่',
                          textColor: textColor,
                          sub: subTextColor,
                          dark: isDarkMode,
                          trail: const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFFB8C4D6), size: 20),
                          tap: () => context.push(AppRoutes.devices),
                        ),
                        _divider(dividerColor),
                        _buildRow(
                          icon: Icons.access_time_rounded,
                          title: isEn ? 'Login History' : 'ประวัติการเข้าสู่ระบบ',
                          subtitle: isEn
                              ? 'Review account activity & sessions'
                              : 'ตรวจสอบกิจกรรมการเข้าสู่ระบบบัญชี',
                          textColor: textColor,
                          sub: subTextColor,
                          dark: isDarkMode,
                          last: true,
                          trail: const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFFB8C4D6), size: 20),
                          tap: () => context.push(AppRoutes.loginHistory),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Tip banner
                  _buildTip(isEn, isDarkMode, context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECURITY SCORE CARD ─────────────────────────────────────────
  Widget _buildScoreCard(int score, bool isDark, bool isEn) {
    final Color c = score >= 80
        ? const Color(0xFF10B981)
        : score >= 50
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final String lbl = score >= 80
        ? (isEn ? 'Strong' : 'ปลอดภัยมาก')
        : score >= 50
            ? (isEn ? 'Moderate' : 'ปานกลาง')
            : (isEn ? 'Weak' : 'ต้องปรับปรุง');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.security_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Security Score' : 'ระดับความปลอดภัย',
                  style: GoogleFonts.kanit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4),
                    valueColor: AlwaysStoppedAnimation<Color>(c),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$score% — $lbl',
                  style: GoogleFonts.kanit(fontSize: 12, color: c, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: c.withValues(alpha: 0.30), width: 1.5),
            ),
            child: Center(
              child: Text(
                '$score',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: c),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TIP BANNER ──────────────────────────────────────────────────
  Widget _buildTip(bool isEn, bool isDark, BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E3A5F).withValues(alpha: 0.4)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A4A70) : const Color(0xFFCBDEFC),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.twoFactor),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Boost Your Security' : 'ดูแลความปลอดภัยให้มากขึ้น',
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C7FF6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? 'Enable 2FA to protect your account better'
                            : 'เปิดใช้งาน 2FA เพื่อเพิ่มความปลอดภัยให้บัญชีของคุณ',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5B7A9D),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF1C7FF6), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── SETTING ROW ──────────────────────────────────────────────────
  Widget _buildRow({
    required IconData icon,
    required String title,
    String? badge,
    required String subtitle,
    required Color textColor,
    required Color sub,
    required bool dark,
    required Widget trail,
    required VoidCallback tap,
    bool first = false,
    bool last = false,
  }) {
    final br = BorderRadius.only(
      topLeft: first ? const Radius.circular(20) : Radius.zero,
      topRight: first ? const Radius.circular(20) : Radius.zero,
      bottomLeft: last ? const Radius.circular(20) : Radius.zero,
      bottomRight: last ? const Radius.circular(20) : Radius.zero,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: br,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF1E3A8A).withValues(alpha: 0.30)
                      : const Color(0xFFE8F2FE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF1C7FF6), size: 22),
              ),
              const SizedBox(width: 14),
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
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFFFF4B4B), Color(0xFFFF6B6B)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.kanit(
                                fontSize: 9.5,
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
                      style: GoogleFonts.kanit(fontSize: 12, color: sub, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trail,
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(Color color) => Padding(
        padding: const EdgeInsets.only(left: 74, right: 16),
        child: Divider(height: 1, color: color),
      );





}
