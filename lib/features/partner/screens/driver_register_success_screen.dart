import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

class DriverRegisterSuccessScreen extends ConsumerWidget {
  const DriverRegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Royal Blue Banner Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D1C7FF6),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Glowing White Checkmark Circle Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: Color(0xFF1C7FF6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Success Title
                Text(
                  'ส่งใบสมัครสำเร็จ!',
                  style: GoogleFonts.kanit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Subtitle Description
                Text(
                  'เราได้รับข้อมูลของคุณเรียบร้อยแล้ว\nทีมงานจะตรวจสอบเอกสารและแจ้งผลภายใน 1–3 วันทำการ',
                  style: GoogleFonts.kanit(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Body Content Area: Clean Next Steps Guide Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: Color(0xFF1C7FF6), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'ขั้นตอนถัดไปของใบสมัคร',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildStepGuideItem(
                      stepNumber: '1',
                      title: 'ทีมงานตรวจสอบเอกสาร',
                      description: 'เอกสารและข้อมูลส่วนตัวของคุณจะได้รับการตรวจสอบภายใน 1–3 วันทำการ',
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildStepGuideItem(
                      stepNumber: '2',
                      title: 'แจ้งผลการสมัครผ่านระบบ',
                      description: 'เมื่อการตรวจสอบเสร็จสิ้น ระบบจะแจ้งเตือนผ่านแอปพลิเคชันและ SMS',
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildStepGuideItem(
                      stepNumber: '3',
                      title: 'เปิดระบบเริ่มรับงานทันที',
                      description: 'เมื่อได้รับการอนุมัติแล้ว คุณสามารถเปิดโหมดรับงานเพื่อเริ่มสร้างรายได้ทันที',
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                top: BorderSide(color: borderColor),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  context.go(AppRoutes.partnerStatus);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'ติดตามสถานะใบสมัคร',
                      style: GoogleFonts.kanit(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildStepGuideItem({
    required String stepNumber,
    required String title,
    required String description,
    required bool isDarkMode,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C7FF6),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  color: subTextColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
