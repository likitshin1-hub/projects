import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptPrivacy = false;
  bool _acceptPartner = false;

  final String _termsText = '''
1. ข้อกำหนดและเงื่อนไขการใช้งาน (Terms of Service)
1.1 ขอบเขตการให้บริการ
• TBMOVEHUB เป็นแพลตฟอร์มตัวกลางเชื่อมต่อผู้ใช้บริการ (ผู้ส่ง) กับคนขับ/พาร์ทเนอร์ขนส่ง (ผู้รับงาน) ไม่ใช่ผู้ขนส่งเอง
• บริการครอบคลุม: จองรถขนส่งพัสดุ/สินค้า, เลือกประเภทรถ, ติดตามสถานะแบบเรียลไทม์, ประเมินค่าบริการ, แชทระหว่างผู้ใช้-คนขับ

1.2 บัญชีผู้ใช้งาน
• ผู้ใช้ต้องมีอายุ 18 ปีขึ้นไป หรือได้รับความยินยอมจากผู้ปกครอง
• คนขับต้องยืนยันตัวตน (ใบขับขี่, ทะเบียนรถ, ประวัติอาชญากรรมถ้ามี) ก่อนเริ่มรับงาน

1.3 ความรับผิดชอบของแต่ละฝ่าย
• ผู้ใช้: ต้องให้ข้อมูลสินค้า/น้ำหนัก/ขนาดที่ถูกต้อง ห้ามส่งสิ่งผิดกฎหมาย/อันตราย
• คนขับ: ต้องขนส่งตามที่ตกลง ดูแลสินค้าด้วยความระมัดระวัง
• แพลตฟอร์ม: ไม่รับผิดต่อความเสียหายที่เกิดจากการขนส่งโดยตรง (มีระบบเคลมความเสียหาย/ประกันแยก)

1.4 การยกเลิก/คืนเงิน
• ระบุเงื่อนไขยกเลิกก่อน/หลังคนขับรับงาน ค่าธรรมเนียมยกเลิก

2. นโยบายความเป็นส่วนตัว (Privacy Policy)
2.1 ข้อมูลที่เก็บรวบรวม
• ข้อมูลส่วนตัว: ชื่อ-นามสกุล, เบอร์โทร, อีเมล, รูปโปรไฟล์
• ข้อมูลคนขับ: เลขใบขับขี่, ทะเบียนรถ, เอกสารยืนยันตัวตน
• ตำแหน่งที่ตั้ง: GPS แบบเรียลไทม์ (ระหว่างใช้งาน/ขนส่ง)
• ข้อมูลการชำระเงิน: ผ่าน payment gateway ที่ได้มาตรฐานความปลอดภัย
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ข้อกำหนดและเงื่อนไข',
          style: GoogleFonts.kanit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(false),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _termsText,
                        style: GoogleFonts.kanit(
                          fontSize: 13.5,
                          color: const Color(0xFFE2E8F0),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _acceptPrivacy,
                              activeColor: const Color(0xFF38BDF8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (v) => setState(() => _acceptPrivacy = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ข้าพเจ้ายินยอมให้เก็บรวบรวม ใช้ และเปิดเผยข้อมูลส่วนบุคคลตามนโยบายความเป็นส่วนตัว',
                              style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _acceptPartner,
                              activeColor: const Color(0xFF38BDF8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (v) => setState(() => _acceptPartner = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ยอมรับข้อกำหนดและเงื่อนไขการใช้บริการของ TBMove Hub',
                              style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: (_acceptPrivacy && _acceptPartner)
                            ? const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF2563EB)])
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: (_acceptPrivacy && _acceptPartner)
                            ? () => context.pop(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_acceptPrivacy && _acceptPartner) ? Colors.transparent : Colors.white10,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'ยอมรับเงื่อนไข',
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
