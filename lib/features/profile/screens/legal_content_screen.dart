import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class LegalContentScreen extends ConsumerWidget {
  final bool isPrivacy;

  const LegalContentScreen({
    super.key,
    required this.isPrivacy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final isEn = currentLang == AppLanguage.en;

    final String title = isPrivacy
        ? (isEn ? 'Privacy Policy' : 'นโยบายความเป็นส่วนตัว')
        : (isEn ? 'Terms of Service' : 'ข้อตกลงและเงื่อนไขการใช้งาน');

    final String subtitle = isPrivacy
        ? (isEn ? 'How we protect your data' : 'การปกป้องและจัดการข้อมูลของคุณ')
        : (isEn ? 'Rules and conditions of use' : 'ข้อกำหนดและเงื่อนไขการใช้บริการ');

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==========================================
          // WAVE GRADIENT BLUE APPBAR
          // ==========================================
          ClipPath(
            clipper: LegalHeaderClipper(),
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
                  Positioned(
                    right: -10,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(
                        isPrivacy ? Icons.privacy_tip_rounded : Icons.description_rounded,
                        size: 96,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          onPressed: () => context.pop(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.kanit(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.kanit(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // CONTENT BODY
          // ==========================================
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(22),
                      child: isPrivacy
                          ? _buildPrivacyPolicy(isEn, primaryTextColor, secondaryTextColor, dividerColor)
                          : _buildTermsOfService(isEn, primaryTextColor, secondaryTextColor, dividerColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy(bool isEn, Color titleColor, Color bodyColor, Color divColor) {
    if (isEn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('1. Information We Collect', titleColor),
          _bodyText(
              '• Personal Information: Name, surname, phone number, email, and profile image.\n'
              '• Location Data: Real-time GPS coordinates of your location during order creation and parcel delivery.\n'
              '• Device Info: IP Address, device model, operating system, and unique identifiers.',
              bodyColor),
          _divider(divColor),
          _sectionTitle('2. How We Use Information', titleColor),
          _bodyText(
              '• To provide, maintain, and optimize our delivery matchmaking services.\n'
              '• To verify identity of users and matching drivers for security.\n'
              '• To facilitate communication between sender, recipient, and driver.',
              bodyColor),
          _divider(divColor),
          _sectionTitle('3. Security & Retention', titleColor),
          _bodyText(
              'We employ bank-grade encryption to protect your data. Your data is kept for as long as your account remains active or to comply with law.',
              bodyColor),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('1. ข้อมูลที่เราเก็บรวบรวม', titleColor),
          _bodyText(
              '• ข้อมูลส่วนบุคคล: ชื่อ-นามสกุล, เบอร์โทรศัพท์, อีเมล, รูปถ่ายโปรไฟล์ และเอกสารยืนยันตัวตน (สำหรับคนขับ)\n'
              '• ข้อมูลพิกัดตำแหน่ง: ข้อมูล GPS แบบเรียลไทม์ระหว่างเรียกใช้งานเพื่อแสดงตำแหน่งพัสดุและคนขับ\n'
              '• ข้อมูลอุปกรณ์: หมายเลขไอพี (IP Address), รุ่นอุปกรณ์, ระบบปฏิบัติการ และประวัติการเข้าใช้งานแอปพลิเคชัน',
              bodyColor),
          _divider(divColor),
          _sectionTitle('2. การนำข้อมูลไปใช้งาน', titleColor),
          _bodyText(
              '• เพื่อให้บริการจัดส่งพัสดุเป็นไปอย่างมีประสิทธิภาพและติดตามได้แม่นยำ\n'
              '• เพื่อยืนยันตัวตน ป้องกันการทุจริต และรักษาความปลอดภัยในระบบ\n'
              '• เพื่อการติดต่อประสานงานระหว่างผู้ส่งสินค้า พาร์ทเนอร์คนขับ และผู้รับพัสดุปลายทาง',
              bodyColor),
          _divider(divColor),
          _sectionTitle('3. การรักษาความปลอดภัยและการเก็บรักษา', titleColor),
          _bodyText(
              'เราใช้มาตรการเข้ารหัสข้อมูลที่ได้มาตรฐานสากลเพื่อความปลอดภัยขั้นสูงสุด และจะจัดเก็บข้อมูลไว้ตราบเท่าที่บัญชีของคุณเปิดใช้งาน หรือระยะเวลาที่กฎหมายกำหนด',
              bodyColor),
        ],
      );
    }
  }

  Widget _buildTermsOfService(bool isEn, Color titleColor, Color bodyColor, Color divColor) {
    if (isEn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('1. Scope of Service', titleColor),
          _bodyText(
              'TBMOVEHUB operates as an intermediary platform connecting package senders with partner delivery drivers. We are not a direct transport company.',
              bodyColor),
          _divider(divColor),
          _sectionTitle('2. User Registration & Verification', titleColor),
          _bodyText(
              '• Senders must provide true information and avoid sending illegal, hazardous, or prohibited goods.\n'
              '• Drivers must undergo background checks and upload active driver licenses and vehicle registrations.',
              bodyColor),
          _divider(divColor),
          _sectionTitle('3. Compensation & Insurance', titleColor),
          _bodyText(
              'We offer packages of protection and insurance for lost or damaged goods under terms defined in the current service rate policy.',
              bodyColor),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('1. ขอบเขตการให้บริการ', titleColor),
          _bodyText(
              'TBMOVEHUB เป็นผู้ให้บริการแพลตฟอร์มตัวกลางเชื่อมโยงระหว่างผู้ส่งพัสดุและพาร์ทเนอร์คนขับรถอิสระ เราไม่ใช่ผู้ประกอบการขนส่งโดยตรง',
              bodyColor),
          _divider(divColor),
          _sectionTitle('2. เงื่อนไขการลงทะเบียนและการใช้งาน', titleColor),
          _bodyText(
              '• ผู้ใช้บริการต้องลงทะเบียนด้วยข้อมูลที่เป็นจริงและห้ามส่งสิ่งของผิดกฎหมาย สารเคมีอันตราย หรือสิ่งของต้องห้าม\n'
              '• พาร์ทเนอร์คนขับต้องผ่านการตรวจประวัติ อาชญากรรม และอัปโหลดใบอนุญาตขับขี่พร้อมสำเนาทะเบียนรถที่ถูกต้อง',
              bodyColor),
          _divider(divColor),
          _sectionTitle('3. การชดเชยค่าเสียหายและประกันภัย', titleColor),
          _bodyText(
              'ระบบมีวงเงินประกันความเสียหายสำหรับพัสดุตามรายละเอียดและเงื่อนไขที่กำหนดไว้ในแต่ละประเภทบริการ โดยผู้ใช้สามารถยื่นเคลมผ่านฝ่ายบริการลูกค้าได้ภายในเวลาที่กำหนด',
              bodyColor),
        ],
      );
    }
  }

  Widget _sectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.kanit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _bodyText(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.kanit(
        fontSize: 13.5,
        height: 1.6,
        color: color,
      ),
    );
  }

  Widget _divider(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: color, height: 1),
    );
  }
}

class LegalHeaderClipper extends CustomClipper<Path> {
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
