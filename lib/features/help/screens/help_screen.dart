import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _faqList = [
    {
      'icon': Icons.description_outlined,
      'question': 'ใช้เอกสารอะไรบ้างในการสมัคร?',
      'answer':
          'เอกสารที่ต้องใช้ในการสมัครพาร์ทเนอร์คนขับ มีดังนี้:\n\n'
          '• สำเนาบัตรประชาชน (ยังไม่หมดอายุ)\n'
          '• ใบอนุญาตขับขี่ที่ยังไม่หมดอายุ\n'
          '• ใบคู่มือจดทะเบียนรถ (หน้าเจ้าของรถและภาษีล่าสุด)\n'
          '• รูปถ่ายหน้าตรง (ไม่ใส่หมวกหรือแว่นดำ)\n'
          '• หน้าแรกสมุดบัญชีธนาคารสำหรับรับโอนเงินรายได้',
    },
    {
      'icon': Icons.search_rounded,
      'question': 'ใช้เวลาตรวจสอบเอกสาร กี่วัน?',
      'answer':
          'โดยปกติระบบจะใช้เวลาตรวจสอบและอนุมัติเอกสารภายใน 1 - 3 วันทำการ '
          '(ไม่รวมวันหยุดเสาร์-อาทิตย์ และวันหยุดนักขัตฤกษ์)\n\n'
          'เมื่อผลการอนุมัติเรียบร้อย ระบบจะส่งข้อความแจ้งเตือนผ่านแอปพลิเคชันให้คุณทราบทันที',
    },
    {
      'icon': Icons.autorenew_rounded,
      'question': 'สามารถเปลี่ยนประเภทรถ ภายหลังได้ไหม?',
      'answer':
          'สามารถเปลี่ยนประเภทรถหรือเพิ่มยานพาหนะได้ทุกเมื่อ โดยส่งเรื่องยื่นเอกสารรถคันใหม่'
          'ผ่านเมนู "แก้ไขโปรไฟล์" หรือติดต่อเจ้าหน้าที่บริการลูกค้าเพื่ออัปเดตข้อมูล',
    },
    {
      'icon': Icons.find_in_page_outlined,
      'question': 'หากเอกสารไม่ผ่านต้องทำอย่างไร?',
      'answer':
          'หากเอกสารไม่ผ่านการอนุมัติ ระบบจะระบุสาเหตุอย่างชัดเจน (เช่น ภาพไม่ชัดเจน หรือเอกสารหมดอายุ)\n\n'
          'คุณสามารถถ่ายภาพเอกสารใหม่และกดอัปโหลดส่งตรวจสอบซ้ำได้ทันทีที่เมนู "เอกสารของฉัน"',
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
      'question': 'รายได้ของพาร์ทเนอร์คนขับ เป็นอย่างไร?',
      'answer':
          'รายได้คำนวณตามระยะทางจริงและประเภทของรถที่ใช้จัดส่ง นอกจากนี้ยังมีโบนัสรอบวิ่งพิเศษและอินเซนทีฟตามช่วงเวลา\n\n'
          'พาร์ทเนอร์สามารถกดถอนเงินรายได้เข้าบัญชีธนาคารที่ลงทะเบียนไว้ได้ทุกวัน',
    },
    {
      'icon': Icons.headset_mic_outlined,
      'question': 'ติดต่อกับทีมงานได้ทางไหน?',
      'answer':
          'สามารถติดต่อทีมงานได้ตลอด 24 ชั่วโมง ผ่านทางปุ่ม "โทรหาเรา" (Call Center 02-123-4567) '
          'หรือปุ่ม "แชทกับเรา" ที่อยู่บริเวณด้านล่างของหน้านี้',
    },
  ];

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _showCallDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF3FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFF0052CC),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ศูนย์บริการลูกค้า',
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'โทรศัพท์: 02-123-4567\nพร้อมให้บริการตลอด 24 ชั่วโมง',
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'ยกเลิก',
                        style: GoogleFonts.kanit(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                      label: Text(
                        'โทรออก',
                        style: GoogleFonts.kanit(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'กำลังโทรออกไปยัง 02-123-4567...',
                              style: GoogleFonts.kanit(fontSize: 15),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF0052CC),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: ref.watch(themeProvider) ? const Color(0xFF0B0F17) : const Color(0xFFEBF3FE),
        body: Stack(
          children: [
            // Decorative background graphics
            Positioned(
              top: statusBarHeight - 20,
              right: -30,
              child: Opacity(
                opacity: 0.10,
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 270,
                  color: const Color(0xFF0052CC),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar & Header section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _handleBack,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF0052CC),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Header title & Illustration
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'คำถามที่พบบ่อย',
                                style: GoogleFonts.kanit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0040A8),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'รวบรวมคำถามและคำตอบที่พบบ่อย\nเพื่อช่วยให้คุณใช้งานได้ง่ายขึ้น',
                                style: GoogleFonts.kanit(
                                  fontSize: 14.5,
                                  color: const Color(0xFF64748B),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 3D-styled Question mark illustration badge
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.question_mark_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FAQ List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 200),
                      itemCount: _faqList.length,
                      itemBuilder: (context, index) {
                        final item = _faqList[index];
                        final isExpanded = _expandedIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  _expandedIndex = isExpanded ? null : index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Left Icon container
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEBF3FE),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            item['icon'] as IconData,
                                            color: const Color(0xFF0052CC),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Question Text
                                        Expanded(
                                          child: Text(
                                            item['question'] as String,
                                            style: GoogleFonts.kanit(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Expand indicator arrow icon
                                        AnimatedRotation(
                                          turns: isExpanded ? 0.5 : 0.0,
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: isExpanded
                                                ? const Color(0xFF0052CC)
                                                : const Color(0xFF94A3B8),
                                            size: 26,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Expandable Answer Section
                                    AnimatedCrossFade(
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: const Color(0xFFCBD5E1),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            item['answer'] as String,
                                            style: GoogleFonts.kanit(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF1E293B),
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                      ),
                                      crossFadeState: isExpanded
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration: const Duration(milliseconds: 200),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Contact Card
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F2B66).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFDCE9FE), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Info Row
                    Row(
                      children: [
                        // Agent Avatar Icon
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.headset_mic_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            Positioned(
                              right: -1,
                              bottom: -1,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ยังไม่พบคำตอบที่ต้องการ?',
                                style: GoogleFonts.kanit(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'ทีมงานพร้อมดูแลและช่วยเหลือตลอด 24 ชม.',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Large Action Buttons Row (Equal height & proportions)
                    Row(
                      children: [
                        // โทรหาเรา (Call Us Button -> Navigates to Call Center Screen)
                        Expanded(
                          child: SizedBox(
                            height: 58,
                            child: Material(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  context.push('${AppRoutes.call}/call_center');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF2563EB),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFDBEAFE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.phone_in_talk_rounded,
                                          color: Color(0xFF1D4ED8),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'โทรหาเรา',
                                              style: GoogleFonts.kanit(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1D4ED8),
                                                height: 1.1,
                                              ),
                                            ),
                                            Text(
                                              'Call Center',
                                              style: GoogleFonts.kanit(
                                                fontSize: 11.5,
                                                color: const Color(0xFF2563EB),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // แชทกับเรา (Chat with Us Button)
                        Expanded(
                          child: SizedBox(
                            height: 58,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0052CC), Color(0xFF1D4ED8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    context.push('${AppRoutes.chat}/call_center');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Colors.white24,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.chat_bubble_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'แชทกับเรา',
                                                style: GoogleFonts.kanit(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  height: 1.1,
                                                ),
                                              ),
                                              Text(
                                                'ตอบกลับทันที',
                                                style: GoogleFonts.kanit(
                                                  fontSize: 11.5,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
