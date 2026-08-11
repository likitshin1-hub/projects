import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/partner_application_provider.dart';

class DriverApplicationStatusScreen extends ConsumerWidget {
  const DriverApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final app = ref.watch(partnerApplicationProvider);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C7FF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'สถานะใบสมัคร',
          style: GoogleFonts.kanit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (app == null) ...[
              // No Application Submitted Yet State
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: Color(0xFF1C7FF6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ยังไม่มีข้อมูลใบสมัคร',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'คุณยังไม่ได้ยื่นใบสมัครเป็นพาร์ทเนอร์คนขับ\nกรุณากรอกข้อมูลเพื่อยื่นใบสมัครร่วมงานกับเรา',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C7FF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => context.push(AppRoutes.registerPartner),
                        child: Text(
                          'สมัครเป็นพาร์ทเนอร์คนขับ',
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Submitted Application Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.assignment_turned_in_rounded,
                          color: Color(0xFF1C7FF6), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'อยู่ระหว่างตรวจสอบเอกสาร',
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'ทีมงานกำลังตรวจสอบข้อมูลของคุณ',
                            style: GoogleFonts.kanit(
                              fontSize: 12.5,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actual Submitted Driver Info Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, color: Color(0xFF1C7FF6), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'ข้อมูลใบสมัครที่ยื่นจริง',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('ชื่อ-นามสกุล', app.fullName, textColor, subTextColor),
                    _buildInfoRow('เบอร์โทรศัพท์', app.phone, textColor, subTextColor),
                    _buildInfoRow('อีเมล', app.email, textColor, subTextColor),
                    _buildInfoRow('ประเภทรถ', app.vehicleType, textColor, subTextColor),
                    _buildInfoRow('ยี่ห้อ/รุ่น', '${app.brand} ${app.model}'.trim(), textColor, subTextColor),
                    _buildInfoRow('ทะเบียนรถ', app.plate, textColor, subTextColor),
                    const SizedBox(height: 6),
                    _buildStatusBadgeRow('บัตรประชาชน', app.idCardUploaded, textColor),
                    _buildStatusBadgeRow('ใบขับขี่', app.driverLicenseUploaded, textColor),
                    _buildStatusBadgeRow('เอกสารรถ', app.vehicleDocUploaded, textColor),
                    _buildStatusBadgeRow('สมุดบัญชี', app.bankBookUploaded, textColor),
                    _buildStatusBadgeRow('รูปรถ 4 มุม', app.photosUploadedCount > 0, textColor,
                        customText: app.photosUploadedCount > 0
                            ? 'อัปโหลดแล้ว (${app.photosUploadedCount}/4)'
                            : 'ยังไม่ได้อัปโหลด'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Timeline Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildTimelineStep(
                      icon: Icons.upload_file_rounded,
                      title: 'ส่งใบสมัคร',
                      subtitle: 'ยืนยันข้อมูลเรียบร้อย',
                      timeText:
                          '${app.submittedAt.day}/${app.submittedAt.month}/${app.submittedAt.year + 543} ${app.submittedAt.hour.toString().padLeft(2, '0')}:${app.submittedAt.minute.toString().padLeft(2, '0')}',
                      isDone: true,
                      isActive: false,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isDark: isDarkMode,
                    ),
                    _buildTimelineDivider(isDone: true),
                    _buildTimelineStep(
                      icon: Icons.search_rounded,
                      title: 'กำลังตรวจสอบเอกสาร',
                      subtitle: 'ทีมงานกำลังตรวจสอบเอกสารของคุณ',
                      timeText: '',
                      isDone: false,
                      isActive: true,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isDark: isDarkMode,
                    ),
                    _buildTimelineDivider(isDone: false),
                    _buildTimelineStep(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'อนุมัติใบสมัคร',
                      subtitle: 'รอการอนุมัติจากทีมงาน',
                      timeText: '',
                      isDone: false,
                      isActive: false,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isDark: isDarkMode,
                    ),
                    _buildTimelineDivider(isDone: false),
                    _buildTimelineStep(
                      icon: Icons.done_all_rounded,
                      title: 'พร้อมเริ่มงาน',
                      subtitle: 'เปิดรับงานได้ทันที',
                      timeText: '',
                      isDone: false,
                      isActive: false,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isDark: isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Help Contact Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFD6E4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'หากมีข้อสงสัยติดต่อทีมงานได้ที่',
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '02-123-4567  |  LINE @TBMoveHub',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF93C5FD) : const Color(0xFF1C7FF6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Color textColor, Color subTextColor) {
    final displayValue = value.trim().isEmpty ? 'ยังไม่ได้ระบุ' : value;
    final isNotEntered = value.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.kanit(fontSize: 13, color: subTextColor)),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: isNotEntered ? FontWeight.normal : FontWeight.w600,
                color: isNotEntered ? subTextColor : textColor,
                fontStyle: isNotEntered ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadgeRow(String label, bool isDone, Color textColor,
      {String? customText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.kanit(fontSize: 13, color: textColor)),
          Row(
            children: [
              Text(
                isDone
                    ? (customText ?? 'อัปโหลดแล้ว')
                    : (customText ?? 'ยังไม่ได้อัปโหลด'),
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  color: isDone ? const Color(0xFF10B981) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.cancel_outlined,
                color: isDone ? const Color(0xFF10B981) : Colors.redAccent,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required String timeText,
    required bool isDone,
    required bool isActive,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    Color iconColor;
    Color iconBg;

    if (isDone) {
      iconColor = Colors.white;
      iconBg = const Color(0xFF1C7FF6);
    } else if (isActive) {
      iconColor = const Color(0xFF1C7FF6);
      iconBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0F2FE);
    } else {
      iconColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      iconBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: (isDone || isActive) ? textColor : subTextColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
        if (timeText.isNotEmpty)
          Text(
            timeText,
            style: GoogleFonts.kanit(
              fontSize: 11,
              color: subTextColor,
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineDivider({required bool isDone}) {
    return Container(
      margin: const EdgeInsets.only(left: 21, top: 4, bottom: 4),
      width: 2,
      height: 28,
      color: isDone ? const Color(0xFF1C7FF6) : const Color(0xFFCBD5E1),
    );
  }
}
