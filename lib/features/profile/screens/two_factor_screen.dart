import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/two_factor_provider.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  // Steps:
  // 0 = Main Status screen (either Disabled or Enabled status)
  // 1 = Choose Method screen
  // 2 = OTP Verification input screen
  // 3 = Success activation screen
  // 4 = Info / Help page ("ข้อมูลเกี่ยวกับ 2 ขั้นตอน")
  int _currentStep = 0;

  // Selected method in Setup
  // 0 = SMS OTP, 1 = Google Authenticator
  int _selectedMethod = 0;

  // OTP controller and focus nodes
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final is2FAEnabled = ref.watch(twoFactorProvider);
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── HEADER ──
          _buildHeader(statusBarHeight, isEn),

          // ── BODY CONTENT ──
          Expanded(
            child: _buildBodyContent(is2FAEnabled, isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HEADER BUILDER
  // ==========================================

  Widget _buildHeader(double statusBarHeight, bool isEn) {
    String title = '';
    String subtitle = '';

    switch (_currentStep) {
      case 0:
        title = isEn ? '2-Step Verification' : 'การยืนยันตัวตน 2 ขั้นตอน';
        subtitle = isEn ? 'Add extra protection to your account' : 'เพิ่มความปลอดภัยให้กับบัญชีของคุณ';
        break;
      case 1:
        title = isEn ? 'Setup 2-Step Verification' : 'ตั้งค่าการยืนยันตัวตน 2 ขั้นตอน';
        subtitle = isEn ? 'Choose verification method' : 'เลือกวิธีการยืนยันตัวตนที่คุณต้องการใช้';
        break;
      case 2:
        title = isEn ? 'Verify with OTP' : 'ยืนยันตัวตนด้วยรหัส OTP';
        subtitle = isEn ? 'We sent a verification code to your device' : 'ระบบส่งรหัสยืนยันไปยังเบอร์โทรศัพท์ของคุณ';
        break;
      case 3:
        title = isEn ? '2FA Enabled Successfully' : 'เปิดใช้งานการยืนยันตัวตนสำเร็จ';
        subtitle = isEn ? 'Your account is now protected' : 'บัญชีได้รับการปกป้องด้วยความปลอดภัยสูงสุด';
        break;
      case 4:
        title = isEn ? 'About 2-Step Verification' : 'ข้อมูลเกี่ยวกับ 2 ขั้นตอน';
        subtitle = isEn ? 'Learn how 2FA secures your account' : 'ทำความเข้าใจหลักการทำงานของ 2FA';
        break;
    }

    return Container(
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
          // Back Button
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
                if (_currentStep == 0) {
                  context.pop();
                } else if (_currentStep == 4) {
                  setState(() => _currentStep = 0);
                } else if (_currentStep == 3) {
                  setState(() => _currentStep = 0);
                } else {
                  setState(() => _currentStep--);
                }
              },
            ),
          ),
          // Title / Subtitle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info Button
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _currentStep == 4 ? Icons.help_outline_rounded : Icons.info_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                if (_currentStep != 4) {
                  setState(() => _currentStep = 4);
                } else {
                  setState(() => _currentStep = 0);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BODY CONTENT SWITCHER
  // ==========================================

  Widget _buildBodyContent(
    bool is2FAEnabled,
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    switch (_currentStep) {
      case 0:
        return is2FAEnabled
            ? _buildManageScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor)
            : _buildDisabledMainScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 1:
        return _buildChooseMethodScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 2:
        return _buildOtpScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 3:
        return _buildSuccessScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 4:
        return _buildInfoScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      default:
        return const SizedBox();
    }
  }

  // ==========================================
  // SCREEN 1: DISABLED MAIN SCREEN
  // ==========================================

  Widget _buildDisabledMainScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        // Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEn ? 'Verification Status' : 'สถานะการยืนยันตัวตน 2 ขั้นตอน',
                          style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEn ? 'Disabled' : 'ยังไม่เปิดใช้งาน',
                            style: GoogleFonts.kanit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn ? 'Activate 2FA to protect your account' : 'เปิดใช้งาน 2FA เพื่อเพิ่มความปลอดภัยให้กับบัญชีของคุณ',
                      style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D6)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Method Title
        Text(
          isEn ? '2-Step Verification Methods' : 'วิธีการยืนยันตัวตน 2 ขั้นตอน',
          style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          isEn ? 'Choose the verification method to secure your account' : 'เลือกวิธีการที่คุณต้องการใช้เพื่อยืนยันตัวตน',
          style: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
        ),
        const SizedBox(height: 12),

        // OTP Method Card (Selected by default)
        _buildMethodSelectorCard(
          title: isEn ? 'Verify with OTP (SMS)' : 'ยืนยันด้วยรหัส OTP (SMS)',
          subtitle: isEn ? 'Receive 6-digit code via mobile phone SMS' : 'รับรหัสยืนยัน 6 หลักผ่านเบอร์โทรศัพท์มือถือ',
          badgeText: isEn ? 'Recommended' : 'แนะนำ',
          icon: Icons.phone_android_rounded,
          isSelected: _selectedMethod == 0,
          onTap: () => setState(() => _selectedMethod = 0),
          cardBg: cardBg,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        const SizedBox(height: 12),

        // Google Authenticator Method Card
        _buildMethodSelectorCard(
          title: isEn ? 'Verify with Google Authenticator' : 'ยืนยันด้วย Google Authenticator',
          subtitle: isEn ? 'Generate verification codes from Google Authenticator app' : 'ใช้รหัสยืนยันจากแอป Google Authenticator',
          badgeText: null,
          icon: Icons.star_border_purple500_rounded,
          isSelected: _selectedMethod == 1,
          onTap: () => setState(() => _selectedMethod = 1),
          cardBg: cardBg,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        const SizedBox(height: 24),

        // Why Enable Info Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2FE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF1C7FF6), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Why enable 2-Step Verification?' : 'ทำไมต้องเปิดใช้งาน 2 ขั้นตอน?',
                    style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1C7FF6)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBulletItem(isEn ? 'Protects your account even if someone knows your password.' : 'ป้องกันการเข้าถึงบัญชีของคุณ แม้รหัสผ่านจะรั่วไหล', const Color(0xFF1C7FF6)),
              _buildBulletItem(isEn ? 'Adds an extra layer of security to your profile data.' : 'เพิ่มความปลอดภัยให้บัญชีมากยิ่งขึ้น', const Color(0xFF1C7FF6)),
              _buildBulletItem(isEn ? 'Significantly reduces risk of account takeovers.' : 'ช่วยลดความเสี่ยงจากการถูกแฮกบัญชี', const Color(0xFF1C7FF6)),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Setup Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => _currentStep = 1);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isEn ? 'Configure 2-Step Verification' : 'ตั้งค่าการยืนยันตัวตน 2 ขั้นตอน',
                  style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelectorCard({
    required String title,
    required String subtitle,
    required String? badgeText,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C7FF6) : borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1C7FF6).withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFF64748B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.kanit(fontSize: 8.5, fontWeight: FontWeight.bold, color: const Color(0xFF1C7FF6)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(fontSize: 11, color: subTextColor),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1C7FF6),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 2: CHOOSE METHOD SCREEN
  // ==========================================

  Widget _buildChooseMethodScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        Text(
          isEn ? 'Select your preferred verification method:' : 'เลือกวิธีการยืนยันตัวตนที่คุณต้องการใช้:',
          style: GoogleFonts.kanit(fontSize: 14.5, color: textColor),
        ),
        const SizedBox(height: 14),

        // Method 1 SMS Card
        _buildMethodSetupCard(
          title: isEn ? 'Verify with OTP (SMS)' : 'ยืนยันด้วยรหัส OTP (SMS)',
          subtitle: isEn ? 'Get a 6-digit SMS code on your mobile phone' : 'รับรหัสยืนยัน 6 หลักผ่านเบอร์โทรศัพท์มือถือ',
          badgeText: isEn ? 'Easy to use' : 'ใช้งานง่าย',
          icon: Icons.phone_android_rounded,
          isSelected: _selectedMethod == 0,
          onTap: () => setState(() => _selectedMethod = 0),
          cardBg: cardBg,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        const SizedBox(height: 12),

        // Method 2 Auth App Card
        _buildMethodSetupCard(
          title: isEn ? 'Verify with Google Authenticator' : 'ยืนยันด้วย Google Authenticator',
          subtitle: isEn ? 'Get validation codes from Google Authenticator App' : 'ใช้รหัสยืนยันจากแอป Google Authenticator',
          badgeText: null,
          icon: Icons.star_border_purple500_rounded,
          isSelected: _selectedMethod == 1,
          onTap: () => setState(() => _selectedMethod = 1),
          cardBg: cardBg,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        const SizedBox(height: 24),

        // Info Recommendation Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Setup Guidelines' : 'คำแนะนำ',
                    style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBulletItem(
                isEn ? 'Choosing OTP (SMS) does not require installing any additional application.' : 'หากคุณเลือก OTP (SMS) ไม่จำเป็นต้องติดตั้งแอปเพิ่มเติม',
                subTextColor,
              ),
              _buildBulletItem(
                isEn ? 'If you choose Google Authenticator, you need to install it before setting up.' : 'หากคุณเลือก Google Authenticator จะต้องติดตั้งแอปก่อนใช้งาน',
                subTextColor,
              ),
              _buildBulletItem(
                isEn ? 'You can easily change the verification method later in settings.' : 'คุณสามารถเปลี่ยนวิธีการยืนยันตัวตนได้ภายหลังในหน้าหลัก',
                subTextColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Nav Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1C7FF6),
                    side: const BorderSide(color: Color(0xFF1C7FF6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => _currentStep = 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chevron_left_rounded, size: 18),
                      Text(isEn ? 'Back' : 'ย้อนกลับ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C7FF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_selectedMethod == 0) {
                      _clearOtp();
                      setState(() => _currentStep = 2);
                    } else {
                      _showToast(isEn ? 'Google Authenticator setup is coming soon!' : 'ระบบสำหรับ Google Authenticator จะพร้อมใช้งานเร็วๆ นี้');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isEn ? 'Next' : 'ถัดไป', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                      const Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodSetupCard({
    required String title,
    required String subtitle,
    required String? badgeText,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C7FF6) : borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1C7FF6).withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFF64748B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.kanit(fontSize: 8.5, fontWeight: FontWeight.bold, color: const Color(0xFF137333)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(fontSize: 10.5, color: subTextColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 3: OTP VERIFICATION SCREEN
  // ==========================================

  Widget _buildOtpScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      children: [
        // Phone/OTP Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phonelink_ring_rounded, color: Color(0xFF1C7FF6), size: 36),
          ),
        ),
        const SizedBox(height: 18),

        // OTP title
        Center(
          child: Text(
            isEn
                ? 'We sent a 6-digit code to your phone number'
                : 'เราได้ส่งรหัสยืนยัน 6 หลักไปที่เบอร์โทรศัพท์',
            style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '•••• •••• 1234',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C7FF6)),
              ),
              const SizedBox(width: 6),
              Text(
                isEn ? '(Change)' : '(เปลี่ยนเบอร์)',
                style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF1C7FF6), decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 6 digit inputs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 52,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1C7FF6), width: 1.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  filled: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // OTP expiration note
        Center(
          child: Text(
            isEn ? 'Code expires in 5 minutes' : 'รหัสยืนยันมีอายุ 5 นาที',
            style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
          ),
        ),
        const SizedBox(height: 32),

        // Verify OTP Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              // Ensure OTP is filled
              String otp = _otpControllers.map((c) => c.text).join();
              if (otp.length < 6) {
                _showToast(isEn ? 'Please enter 6-digit OTP code' : 'โปรดกรอกรหัสยืนยันให้ครบ 6 หลัก');
                return;
              }

              // Successfully set 2FA state to Enabled!
              await ref.read(twoFactorProvider.notifier).setEnabled(true);

              setState(() => _currentStep = 3);
            },
            child: Text(
              isEn ? 'Verify' : 'ยืนยันตัวตน',
              style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Resend code link
        Center(
          child: InkWell(
            onTap: () {
              _clearOtp();
              _showToast(isEn ? 'OTP code resent successfully' : 'ส่งรหัสยืนยันใหม่อีกครั้งแล้ว');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 4),
                Text(
                  isEn ? 'Resend Code' : 'ส่งรหัสอีกครั้ง',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 4: SUCCESS VIEW SCREEN
  // ==========================================

  Widget _buildSuccessScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
      children: [
        // Giant Shield Checkmark
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 68),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Enabled Success Title
        Center(
          child: Text(
            isEn ? '2-Step Verification Enabled' : 'เปิดใช้งานการยืนยันตัวตน 2 ขั้นตอนแล้ว',
            style: GoogleFonts.kanit(fontSize: 16.5, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            isEn
                ? 'Your account is now protected with enhanced security'
                : 'บัญชีของคุณได้รับการปกป้องด้วยความปลอดภัยระดับสูง',
            style: GoogleFonts.kanit(fontSize: 12.5, color: subTextColor),
          ),
        ),
        const SizedBox(height: 28),

        // Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Security Details' : 'รายละเอียดการใช้งาน',
                    style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildBulletItem(
                isEn ? 'System will ask for OTP code (SMS) on every sign-in attempt.' : 'ระบบจะส่งรหัสยืนยัน (OTP) ทุกครั้งที่คุณเข้าสู่ระบบ',
                subTextColor,
                const Color(0xFF10B981),
              ),
              _buildBulletItem(
                isEn ? 'Helps prevent unauthorized login attempts to your profile.' : 'ช่วยป้องกันการเข้าถึงบัญชีโดยไม่ได้รับอนุญาต',
                subTextColor,
                const Color(0xFF10B981),
              ),
              _buildBulletItem(
                isEn ? 'You can disable or manage 2FA settings at any time.' : 'คุณสามารถปิดหรือแก้ไขการใช้งาน 2FA ได้ตลอดเวลาจากหน้านี้',
                subTextColor,
                const Color(0xFF10B981),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Finish button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => _currentStep = 0);
            },
            child: Text(
              isEn ? 'Finish' : 'เสร็จสิ้น',
              style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 6: MANAGE ACTIVE SCREEN (ENABLED STATE)
  // ==========================================

  Widget _buildManageScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        // Status Card (Activated)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEn ? 'Verification Status' : 'สถานะการยืนยันตัวตน',
                          style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEn ? 'Enabled' : 'เปิดใช้งานแล้ว',
                            style: GoogleFonts.kanit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF137333)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn ? 'Your account is secured with 2FA protection.' : 'บัญชีของคุณได้รับการปกป้องด้วย 2FA',
                      style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D6)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Active Method Header
        Text(
          isEn ? 'Active Verification Method' : 'วิธีการยืนยันตัวตนที่ใช้งานอยู่',
          style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),

        // Active Method Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded, color: Color(0xFF1C7FF6), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Verify with OTP (SMS)' : 'ยืนยันด้วยรหัส OTP (SMS)',
                      style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '•••• •••• 1234',
                      style: GoogleFonts.kanit(fontSize: 13, color: subTextColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Management Header
        Text(
          isEn ? 'Management' : 'การจัดการ',
          style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),

        // Change Method Row
        _buildManageActionRow(
          title: isEn ? 'Change Verification Method' : 'เปลี่ยนวิธีการยืนยันตัวตน',
          subtitle: isEn ? 'Select a different option for 2-step logins' : 'เลือกวิธีการยืนยันตัวตนอื่นๆ ที่ต้องการใช้งาน',
          icon: Icons.edit_rounded,
          iconBgColor: const Color(0xFFE8F2FE),
          iconColor: const Color(0xFF1C7FF6),
          onTap: () => setState(() => _currentStep = 1),
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        const SizedBox(height: 12),

        // Disable 2FA Row
        _buildManageActionRow(
          title: isEn ? 'Disable 2-Step Verification' : 'ปิดการยืนยันตัวตน 2 ขั้นตอน',
          subtitle: isEn ? 'Removes security code prompt on logins' : 'คุณจะสูญเสียความปลอดภัยของบัญชี',
          icon: Icons.power_settings_new_rounded,
          iconBgColor: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFEF4444),
          onTap: () => _confirmDisable2FA(context, isEn),
          borderColor: borderColor,
          textColor: const Color(0xFFEF4444),
          subTextColor: subTextColor,
        ),
        const SizedBox(height: 24),

        // Tip Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'If you change your mobile phone number, make sure to update it in your profile to prevent losing access to your account.'
                      : 'หากคุณเปลี่ยนเบอร์โทรศัพท์ หรืออุปกรณ์ที่ใช้ยืนยันตัวตน กรุณาอัปเดตข้อมูลเพื่อความปลอดภัยของบัญชี',
                  style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManageActionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(fontSize: 11, color: subTextColor),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D6)),
          ],
        ),
      ),
    );
  }

  void _confirmDisable2FA(BuildContext context, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEn ? 'Disable 2-Step Verification?' : 'ปิดการยืนยันตัวตน 2 ขั้นตอน?',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
        ),
        content: Text(
          isEn
              ? 'This will lower your account security. Are you sure you want to disable 2FA?'
              : 'ความปลอดภัยของบัญชีคุณจะลดลงอย่างมากเมื่อปิดการใช้งาน คุณแน่ใจที่จะปิดใช้งาน 2FA ใช่หรือไม่?',
          style: GoogleFonts.kanit(height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(twoFactorProvider.notifier).setEnabled(false);
              _showToast(isEn ? '2FA disabled successfully' : 'ปิดการใช้งาน 2FA เรียบร้อยแล้ว');
              setState(() => _currentStep = 0);
            },
            child: Text(isEn ? 'Disable' : 'ปิดใช้งาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SCREEN 5: HELP / INFO SCREEN
  // ==========================================

  Widget _buildInfoScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        // Info Q&A Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF1C7FF6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEn ? 'What is 2-Step Verification?' : 'การยืนยันตัวตน 2 ขั้นตอน คืออะไร?',
                      style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isEn
                    ? '2-Step Verification (Two-Factor Authentication: 2FA) is an extra security layer that ensures only you can access your account, even if someone else knows your password. It requires entering a password AND a verification code sent to your phone or generated by an app.'
                    : 'การยืนยันตัวตน 2 ขั้นตอน (Two-Factor Authentication: 2FA) คือระบบความปลอดภัยที่ช่วยยืนยันตัวตนของคุณเพิ่มเติม นอกจากการกรอกรหัสผ่าน โดยใช้ข้อมูลอีกหนึ่งชั้น เช่น รหัส OTP หรือรหัสจากแอป เพื่อให้แน่ใจว่าเป็นคุณจริงๆ',
                style: GoogleFonts.kanit(fontSize: 12, color: subTextColor, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Workflow diagram
        Text(
          isEn ? 'How it works' : 'วิธีการทำงาน',
          style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 14),

        // Workflow steps
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildWorkflowStep(
                stepNum: '1',
                title: isEn ? 'Sign In' : 'เข้าสู่ระบบ',
                subtitle: isEn ? 'Enter password' : 'ด้วยรหัสผ่าน',
                icon: Icons.login_rounded,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Icon(Icons.chevron_right_rounded, color: subTextColor, size: 16),
            ),
            Expanded(
              child: _buildWorkflowStep(
                stepNum: '2',
                title: isEn ? 'Verify' : 'ยืนยันตัวตน',
                subtitle: isEn ? 'Enter OTP' : 'ด้วยรหัส OTP',
                icon: Icons.security_rounded,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Icon(Icons.chevron_right_rounded, color: subTextColor, size: 16),
            ),
            Expanded(
              child: _buildWorkflowStep(
                stepNum: '3',
                title: isEn ? 'Success' : 'เข้าระบบ',
                subtitle: isEn ? 'Log in safely' : 'ได้อย่างปลอดภัย',
                icon: Icons.verified_user_rounded,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Close/Back Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => _currentStep = 0);
            },
            child: Text(
              isEn ? 'I Understand' : 'ตกลง',
              style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkflowStep({
    required String stepNum,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDarkMode,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1C7FF6), size: 24),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF1C7FF6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                stepNum,
                style: GoogleFonts.kanit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.kanit(fontSize: 10.5, color: subTextColor),
        ),
      ],
    );
  }

  // ==========================================
  // SHARED UTILITIES
  // ==========================================

  Widget _buildBulletItem(String text, Color color, [Color iconColor = const Color(0xFF1C7FF6)]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 6, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.kanit(fontSize: 11.5, color: color, height: 1.35),
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


