import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  bool _is2FAEnabled = true;

  // List of other logged-in devices
  final List<_DeviceInfo> _otherDevices = [
    _DeviceInfo(
      id: 'dev_win_chrome',
      title: 'Chrome on Windows 11',
      location: 'ชลบุรี',
      timeAgo: '2 ชั่วโมงที่แล้ว',
      locationEn: 'Chonburi',
      timeAgoEn: '2 hours ago',
      icon: Icons.laptop_chromebook_rounded,
      ipAddress: '182.52.19.45',
      browser: 'Google Chrome 127.0',
    ),
    _DeviceInfo(
      id: 'dev_galaxy_s23',
      title: 'Samsung Galaxy S23',
      location: 'พัทยา',
      timeAgo: '3 วันที่แล้ว',
      locationEn: 'Pattaya',
      timeAgoEn: '3 days ago',
      icon: Icons.phone_android_rounded,
      ipAddress: '171.96.240.112',
      browser: 'TB Move Hub Mobile App 1.0.0',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isEn = currentLang == AppLanguage.en;

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF4F7FC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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
              clipper: DevicesHeaderClipper(),
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
                      right: 40,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.15,
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 95,
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
                                context.go(AppRoutes.security);
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
                              isEn ? 'Care & protect your account' : 'ดูแลและปกป้องบัญชีของคุณ',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),

                        // Logo & Shield on Top Right
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TB',
                                  style: GoogleFonts.kanit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 0.9,
                                  ),
                                ),
                                Text(
                                  'MOVE HUB',
                                  style: GoogleFonts.kanit(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // CONTENT OVERLAPPING THE APPBAR (ROCK SOLID)
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
                        // 1. 2FA TOGGLE HERO BANNER CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode
                                  ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                                  : const Color(0xFFBFDBFE),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
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
                                      isEn ? '2-Step Verification (2FA)' : 'การยืนยันตัวตน 2 ขั้นตอน (2FA)',
                                      style: GoogleFonts.kanit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isEn
                                          ? 'Enhanced protection with 2-step verification'
                                          : 'เพิ่มความปลอดภัยให้บัญชี ด้วยการยืนยันตัวตน 2 ชั้น',
                                      style: GoogleFonts.kanit(
                                        fontSize: 11.5,
                                        color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                            ? (isEn ? '2FA Enabled' : 'เปิดใช้งานการยืนยันตัวตน 2 ขั้นตอนแล้ว')
                                            : (isEn ? '2FA Disabled' : 'ปิดใช้งานการยืนยันตัวตน 2 ขั้นตอนแล้ว'),
                                      );
                                    },
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _is2FAEnabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        size: 12,
                                        color: _is2FAEnabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _is2FAEnabled
                                            ? (isEn ? 'Active' : 'เปิดใช้งานอยู่')
                                            : (isEn ? 'Disabled' : 'ปิดใช้งาน'),
                                        style: GoogleFonts.kanit(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: _is2FAEnabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 2. SECTION TITLE & INFO BUTTON
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.phone_android_rounded,
                                color: Color(0xFF1C7FF6),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEn ? 'Logged-in Devices' : 'อุปกรณ์ที่เข้าสู่ระบบ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    isEn
                                        ? 'Check and manage devices accessing your account'
                                        : 'ตรวจสอบและจัดการอุปกรณ์ที่ใช้เข้าสู่ระบบบัญชีของคุณ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 11.5,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF1C7FF6),
                                size: 24,
                              ),
                              onPressed: () => _showSecurityInfoDialog(context, isEn, isDarkMode),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 3. CURRENT ACTIVE DEVICE CARD
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1C7FF6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Active Badge Tab
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1C7FF6),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEn ? 'Currently Active Device' : 'อุปกรณ์ที่กำลังใช้งาน',
                                      style: GoogleFonts.kanit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Device details row
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F2FE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.phone_iphone_rounded,
                                        color: Color(0xFF1C7FF6),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isEn ? 'iPhone 14 Pro (This Device)' : 'iPhone 14 Pro',
                                            style: GoogleFonts.kanit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isEn ? 'Bangkok • Active now' : 'กรุงเทพมหานคร • ใช้งานอยู่ตอนนี้',
                                                style: GoogleFonts.kanit(
                                                  fontSize: 12,
                                                  color: subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFBAE6FD)),
                                      ),
                                      child: Text(
                                        isEn ? 'Online' : 'ออนไลน์',
                                        style: GoogleFonts.kanit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4. OTHER LOGGED-IN DEVICES SECTION
                        Row(
                          children: [
                            const Icon(
                              Icons.devices_other_rounded,
                              color: Color(0xFF1C7FF6),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEn ? 'Other Logged-in Devices' : 'อุปกรณ์อื่นที่เข้าสู่ระบบ',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F2FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isEn ? '${_otherDevices.length} Devices' : '${_otherDevices.length} เครื่อง',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C7FF6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // OTHER DEVICES LIST
                        if (_otherDevices.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderColor),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isEn ? 'No other active devices found' : 'ไม่มีอุปกรณ์อื่นที่เข้าสู่ระบบอยู่ในขณะนี้',
                              style: GoogleFonts.kanit(fontSize: 13, color: subTextColor),
                            ),
                          )
                        else
                          ..._otherDevices.map((device) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildOtherDeviceCard(
                                  device: device,
                                  isEn: isEn,
                                  isDarkMode: isDarkMode,
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                              )),

                        const SizedBox(height: 10),

                        // 5. SIGN OUT ALL DEVICES BANNER (ออกจากระบบทุกอุปกรณ์)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFFCA5A5),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEn ? 'Sign Out All Devices' : 'ออกจากระบบทุกอุปกรณ์',
                                    style: GoogleFonts.kanit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isEn
                                        ? 'If you suspect unauthorized access, click to sign out all other devices.'
                                        : 'หากคุณสงสัยว่า มีบุคคลอื่นเข้าถึงบัญชีของคุณ ให้กดปุ่มนี้เพื่อออกจากระบบจากอุปกรณ์ทั้งหมด ยกเว้นอุปกรณ์ที่ใช้งานอยู่',
                                    style: GoogleFonts.kanit(
                                      fontSize: 11,
                                      color: isDarkMode ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _otherDevices.isEmpty
                                  ? null
                                  : () => _confirmSignOutAll(context, isEn),
                              icon: const Icon(Icons.logout_rounded, size: 15),
                              label: Text(
                                isEn ? 'Sign Out All' : 'ออกจากระบบ\nทุกอุปกรณ์',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.kanit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. TIPS & RECOMMENDATIONS BOX (คำแนะนำ)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                                : const Color(0xFFDBEAFE),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1C7FF6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isEn ? 'Security Recommendations' : 'คำแนะนำ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C7FF6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            _buildTipItem(
                              isEn
                                  ? 'If you notice an unfamiliar device, tap "Sign Out" immediately to protect your account.'
                                  : 'หากคุณพบอุปกรณ์ที่ไม่รู้จัก ให้กด “ออกจากระบบ” เพื่อปกป้องบัญชีของคุณ',
                              isDarkMode,
                            ),
                            const SizedBox(height: 6),
                            _buildTipItem(
                              isEn
                                  ? 'Enable 2-Factor Authentication (2FA) for heightened security.'
                                  : 'ควรเปิดใช้งานการยืนยันตัวตน 2 ขั้นตอน (2FA) เพื่อเพิ่มความปลอดภัย',
                              isDarkMode,
                            ),
                            const SizedBox(height: 6),
                            _buildTipItem(
                              isEn
                                  ? 'You will be notified immediately if any device change or new login is detected.'
                                  : 'หากมีการเปลี่ยนแปลงอุปกรณ์หรือเข้าสู่ระบบจากที่อื่น คุณจะได้รับการแจ้งเตือนทันที',
                              isDarkMode,
                            ),
                          ],
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
  // HELPER WIDGETS
  // ==========================================

  Widget _buildOtherDeviceCard({
    required _DeviceInfo device,
    required bool isEn,
    required bool isDarkMode,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              device.icon,
              color: const Color(0xFF1C7FF6),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: InkWell(
              onTap: () => _showDeviceDetailModal(context, device, isEn, isDarkMode),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          device.title,
                          style: GoogleFonts.kanit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF1C7FF6),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        isEn ? '${device.locationEn} • ${device.timeAgoEn}' : '${device.location} • ${device.timeAgo}',
                        style: GoogleFonts.kanit(
                          fontSize: 11.5,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1C7FF6),
              side: const BorderSide(color: Color(0xFF1C7FF6)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _confirmSignOutSingle(context, device, isEn),
            icon: const Icon(Icons.logout_rounded, size: 14),
            label: Text(
              isEn ? 'Sign Out' : 'ออกจากระบบ',
              style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF1C7FF6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.kanit(
              fontSize: 12,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CONFIRMATION DIALOGS & MODALS
  // ==========================================

  void _confirmSignOutSingle(BuildContext context, _DeviceInfo device, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEn ? 'Sign Out Device?' : 'ออกจากระบบอุปกรณ์นี้?',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isEn
              ? 'Are you sure you want to sign out from ${device.title}?'
              : 'คุณต้องการออกจากระบบจาก ${device.title} ใช่หรือไม่?',
          style: GoogleFonts.kanit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _otherDevices.removeWhere((d) => d.id == device.id);
              });
              _showToast(isEn ? 'Signed out from ${device.title}' : 'ออกจากระบบจาก ${device.title} แล้ว');
            },
            child: Text(isEn ? 'Sign Out' : 'ออกจากระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOutAll(BuildContext context, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEn ? 'Sign Out All Devices?' : 'ออกจากระบบทุกอุปกรณ์?',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
        ),
        content: Text(
          isEn
              ? 'This will sign out your account from all other devices. Your current device will remain logged in.'
              : 'ระบบจะออกจากระบบจากอุปกรณ์อื่นทั้งหมดทันที โดยอุปกรณ์ปัจจุบันของคุณจะยังคงใช้งานได้ตามปกติ',
          style: GoogleFonts.kanit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _otherDevices.clear();
              });
              _showToast(isEn ? 'Signed out from all other devices' : 'ออกจากระบบจากอุปกรณ์อื่นทั้งหมดแล้ว');
            },
            child: Text(isEn ? 'Sign Out All' : 'ยืนยันออกจากระบบทั้งหมด', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetailModal(BuildContext context, _DeviceInfo device, bool isEn, bool isDarkMode) {
    final sheetBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              isEn ? 'Device Details' : 'รายละเอียดอุปกรณ์',
              style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 14),

            _buildDetailRow(Icons.device_hub_rounded, isEn ? 'Device Name' : 'ชื่ออุปกรณ์', device.title, textColor, subTextColor),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.web_rounded, isEn ? 'Client / App' : 'แอปพลิเคชัน/เบราว์เซอร์', device.browser, textColor, subTextColor),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.place_rounded, isEn ? 'Location' : 'พิกัดตำแหน่ง', isEn ? device.locationEn : device.location, textColor, subTextColor),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.pin_drop_rounded, 'IP Address', device.ipAddress, textColor, subTextColor),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time_rounded, isEn ? 'Last Active' : 'ใช้งานล่าสุด', isEn ? device.timeAgoEn : device.timeAgo, textColor, subTextColor),

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
                child: Text(isEn ? 'Close' : 'ปิด', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor, Color subTextColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1C7FF6)),
        const SizedBox(width: 10),
        Text('$label: ', style: GoogleFonts.kanit(fontSize: 13, color: subTextColor)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showSecurityInfoDialog(BuildContext context, bool isEn, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: Color(0xFF1C7FF6)),
            const SizedBox(width: 8),
            Text(
              isEn ? 'Device Management' : 'การจัดการอุปกรณ์',
              style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isEn
              ? 'You can review all active sessions logged into your account. If you spot any unfamiliar device or location, sign it out immediately to protect your account.'
              : 'คุณสามารถตรวจสอบอุปกรณ์ทั้งหมดที่มีการเข้าสู่ระบบบัญชีของคุณได้ หากพบอุปกรณ์หรือพิกัดที่ไม่คุ้นเคย ให้กดออกจากระบบทันทีเพื่อความปลอดภัยของข้อมูลและบัญชีของคุณ',
          style: GoogleFonts.kanit(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Got it' : 'เข้าใจแล้ว', style: GoogleFonts.kanit()),
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

class _DeviceInfo {
  final String id;
  final String title;
  final String location;
  final String timeAgo;
  final String locationEn;
  final String timeAgoEn;
  final IconData icon;
  final String ipAddress;
  final String browser;

  _DeviceInfo({
    required this.id,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.locationEn,
    required this.timeAgoEn,
    required this.icon,
    required this.ipAddress,
    required this.browser,
  });
}

class DevicesHeaderClipper extends CustomClipper<Path> {
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
