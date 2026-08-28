import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  void _showHowToPlayModal(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text(
              'วิธีการเล่นและรับรางวัล',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHowToStep('1', 'กดรับงานและส่งพัสดุให้สำเร็จในแต่ละวัน'),
            const SizedBox(height: 10),
            _buildHowToStep('2', 'เมื่อสะสมจำนวนงานครบตามเป้าหมาย (10, 30, 60 ครั้ง) ระบบจะปลดล็อกโบนัสทันที'),
            const SizedBox(height: 10),
            _buildHowToStep('3', 'เงินโบนัสพิเศษจะถูกโอนเข้ากระเป๋าเงินไรเดอร์โดยอัตโนมัติ'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('เข้าใจแล้ว', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToStep(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final pageBg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: pageBg,
      body: Column(
        children: [
          // 1. TOP APP BAR (RIDER THEME ROYAL NAVY BLUE)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A), // Royal Navy Blue Rider Theme
            ),
            padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.driver);
                    }
                  },
                ),
                Text(
                  'รางวัลของฉัน',
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: () => _showHowToPlayModal(context, isDarkMode),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'วิธีการเล่น',
                          style: GoogleFonts.kanit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. MAIN SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MAIN TOP MISSION CARD ("ภารกิจส่งของ")
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ภารกิจส่งของ',
                          style: GoogleFonts.kanit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ยิ่งส่งมาก ยิ่งได้โบนัส!',
                          style: GoogleFonts.kanit(
                            fontSize: 13.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Chips Row (รอบปัจจุบัน & Date)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'รอบปัจจุบัน',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '1 พ.ค. 68 - 31 พ.ค. 68',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Delivery Progress Row
                        Text(
                          'ส่งสำเร็จแล้ว',
                          style: GoogleFonts.kanit(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '18',
                              style: GoogleFonts.kanit(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E3A8A),
                                height: 1.0,
                              ),
                            ),
                            Text(
                              ' / 30 ครั้ง',
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 18 / 30,
                            minHeight: 10,
                            backgroundColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // BONUS REWARD HIGHLIGHT BOX
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.card_giftcard_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'อีก 12 ครั้ง รับโบนัส',
                                    style: GoogleFonts.kanit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '฿50',
                                style: GoogleFonts.kanit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. REWARD TIER ROADMAP SECTION ("ระดับรางวัล")
                  Text(
                    '🏆 ระดับรางวัล',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ROADMAP LIST (Tier 1: 10, Tier 2: 30, Tier 3: 60)
                  _buildRewardTierItem(
                    tierNumber: '10',
                    title: 'ส่งครบ 10 ครั้ง',
                    bonusAmount: '฿20',
                    statusText: 'สำเร็จแล้ว',
                    statusType: _RewardTierStatus.completed,
                    isFirst: true,
                    isLast: false,
                    isDarkMode: isDarkMode,
                  ),
                  _buildRewardTierItem(
                    tierNumber: '30',
                    title: 'ส่งครบ 30 ครั้ง',
                    bonusAmount: '฿50',
                    statusText: 'กำลังทำการกิจ',
                    statusType: _RewardTierStatus.inProgress,
                    progressText: '18 / 30 ครั้ง',
                    remainingText: 'อีก 12 ครั้ง รับโบนัส!',
                    progressRatio: 18 / 30,
                    isFirst: false,
                    isLast: false,
                    isDarkMode: isDarkMode,
                  ),
                  _buildRewardTierItem(
                    tierNumber: '60',
                    title: 'ส่งครบ 60 ครั้ง',
                    bonusAmount: '฿100',
                    statusText: 'ยังไม่ปลดล็อก',
                    statusType: _RewardTierStatus.locked,
                    isFirst: false,
                    isLast: true,
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 24),

                  // 4. TERMS & CONDITIONS CARD ("เงื่อนไขภารกิจ")
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'เงื่อนไขภารกิจ',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildConditionBullet('นับเฉพาะงานที่ส่งสำเร็จเท่านั้น', isDarkMode),
                                  const SizedBox(height: 6),
                                  _buildConditionBullet('ยกเลิกงานจะไม่นับในภารกิจ', isDarkMode),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildConditionBullet('รางวัลจะเข้ากระเป๋าเงินอัตโนมัติ', isDarkMode),
                                  const SizedBox(height: 6),
                                  _buildConditionBullet('1 ภารกิจ = ส่งงานครบตามจำนวนที่กำหนด', isDarkMode),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionBullet(String text, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.kanit(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardTierItem({
    required String tierNumber,
    required String title,
    required String bonusAmount,
    required String statusText,
    required _RewardTierStatus statusType,
    String? progressText,
    String? remainingText,
    double? progressRatio,
    required bool isFirst,
    required bool isLast,
    required bool isDarkMode,
  }) {
    Color borderColor;
    Color cardBgColor;
    Color buttonColor;
    Widget timelineNode;

    switch (statusType) {
      case _RewardTierStatus.completed:
        borderColor = const Color(0xFF10B981);
        cardBgColor = isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4);
        buttonColor = const Color(0xFF10B981);
        timelineNode = Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
        );
        break;
      case _RewardTierStatus.inProgress:
        borderColor = const Color(0xFF2563EB);
        cardBgColor = isDarkMode ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF);
        buttonColor = const Color(0xFF2563EB);
        timelineNode = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 16),
        );
        break;
      case _RewardTierStatus.locked:
        borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
        cardBgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        buttonColor = const Color(0xFF94A3B8);
        timelineNode = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_rounded, color: isDarkMode ? Colors.white54 : const Color(0xFF64748B), size: 16),
        );
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline Axis
          SizedBox(
            width: 32,
            child: Column(
              children: [
                timelineNode,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: statusType == _RewardTierStatus.completed
                          ? const Color(0xFF10B981)
                          : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Card Box
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medal Badge
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusType == _RewardTierStatus.completed
                                ? const Color(0xFFF59E0B)
                                : statusType == _RewardTierStatus.inProgress
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFD97706),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tierNumber,
                                  style: GoogleFonts.kanit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Bonus
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'โบนัส',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                bonusAmount,
                                style: GoogleFonts.kanit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: statusType == _RewardTierStatus.completed
                                      ? const Color(0xFF10B981)
                                      : statusType == _RewardTierStatus.inProgress
                                          ? const Color(0xFF2563EB)
                                          : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status Pill Button
                        ElevatedButton(
                          onPressed: () {
                            if (statusType == _RewardTierStatus.completed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 รับโบนัส $bonusAmount เรียบร้อยแล้ว (เข้ากระเป๋าเงินอัตโนมัติ)', style: GoogleFonts.kanit()),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // In-Progress details (if present)
                    if (statusType == _RewardTierStatus.inProgress && progressRatio != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progressRatio,
                                minHeight: 8,
                                backgroundColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            progressText ?? '',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      if (remainingText != null) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            remainingText,
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RewardTierStatus { completed, inProgress, locked }
