import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/rewards_provider.dart';

enum _RewardLevelStatus { claimed, canClaim, inProgress }

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  void _claimRewardMilestone(int times, int discount) {
    ref.read(rewardsProvider).claimReward(1); // mark milestone claimed in provider if applicable

    // Add corresponding coupon into global User Coupons store
    ref.read(rewardsProvider).addUserCoupon(
      UserCoupon(
        id: 'reward_milestone_${times}_$discount',
        discountText: '$discount',
        unitText: 'บาท',
        badgeText: 'คูปองรางวัล',
        title: 'ส่วนลด $discount บาท',
        subtitle: 'ใช้บริการครบ $times ครั้ง',
        expiryText: 'หมดอายุ 31 ธ.ค. 2569',
        badgeBgColor: const Color(0xFFE8F8EE),
        badgeTextColor: const Color(0xFF16A34A),
        cardColor: const Color(0xFF16A34A),
        illustrationIcon: Icons.emoji_events_rounded,
      ),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'กดรับสิทธิ์คูปองส่วนลด $discount บาทเรียบร้อยแล้ว! คูปองอยู่ใน คูปองของฉัน',
          style: GoogleFonts.kanit(),
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ดูคูปอง',
          textColor: Colors.white,
          onPressed: () {
            context.push(AppRoutes.coupons);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    String t(String key) => AppTranslations.getText(currentLang, key);

    final pageBg = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: pageBg,
      body: Column(
        children: [
          // BLUE GRADIENT HEADER (Original Rewards Screen Header)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0052D4),
                  Color(0xFF1C7FF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 28),
            child: Column(
              children: [
                Row(
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
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        t('privileges_rewards'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        context.push(AppRoutes.coupons);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t('privileges_subtitle'),
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // SCROLLABLE CONTENT (Curved Container)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: pageBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MY USAGE CARD
                      _buildMyUsageCard(currentLang, t, isDarkMode),
                      const SizedBox(height: 24),

                      // REWARDS SECTION TITLE
                      Text(
                        t('my_rewards_title'),
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TIMELINE OF REWARDS
                      _buildRewardsTimeline(currentLang, t, isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MY USAGE CARD WIDGET
  // ==========================================
  Widget _buildMyUsageCard(AppLanguage currentLang, String Function(String) t, bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Progress on the Left
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: 0.7,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1C7FF6),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Little Truck image in center
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          AppAssets.pickup,
                          width: 45,
                          height: 35,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.local_shipping_rounded,
                            color: Color(0xFF1C7FF6),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentLang == AppLanguage.en ? '7 Trips' : '7 ครั้ง',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C7FF6),
                        ),
                      ),
                      Text(
                        currentLang == AppLanguage.en ? 'of 10 trips' : 'จาก 10 ครั้ง',
                        style: GoogleFonts.kanit(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Info on the Right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('my_usage'),
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      t('total_deliveries'),
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentLang == AppLanguage.en ? '7 Trips' : '7 ครั้ง',
                      style: GoogleFonts.kanit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Next goal pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 12,
                            color: Color(0xFF1C7FF6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentLang == AppLanguage.en ? 'Next Goal: 10 Trips' : 'เป้าหมายต่อไป 10 ครั้ง',
                            style: GoogleFonts.kanit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C7FF6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Progress bar & text
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.7,
                              minHeight: 6,
                              backgroundColor: Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1C7FF6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          currentLang == AppLanguage.en ? '7 / 10 Trips' : '7 / 10 ครั้ง',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Under card banner: อีก 3 ครั้ง รับส่วนลด 50 บาท
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF1C7FF6),
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLang == AppLanguage.en ? '3 more trips' : 'อีก 3 ครั้ง',
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                      Text(
                        currentLang == AppLanguage.en ? 'Get 50 THB discount' : 'รับส่วนลด 50 บาท',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Confetti/Popper representation + Arrow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎉',
                      style: GoogleFonts.kanit(fontSize: 22),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF1D4ED8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // REWARDS TIMELINE LIST WIDGET
  // ==========================================
  Widget _buildRewardsTimeline(AppLanguage currentLang, String Function(String) t, bool isDarkMode) {
    final currentTrips = ref.watch(rewardsProvider).state.currentTrips;
    final milestones = ref.watch(rewardsProvider).state.milestones;

    final rewardLevels = milestones.map((m) {
      _RewardLevelStatus st;
      if (m.isClaimed) {
        st = _RewardLevelStatus.claimed;
      } else if (currentTrips >= m.times) {
        st = _RewardLevelStatus.canClaim;
      } else {
        st = _RewardLevelStatus.inProgress;
      }
      return _RewardLevelData(
        times: m.times,
        discount: m.discount,
        status: st,
        progressText: currentLang == AppLanguage.en ? '$currentTrips / ${m.times} Trips' : '$currentTrips / ${m.times} ครั้ง',
      );
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewardLevels.length,
      itemBuilder: (context, index) {
        final level = rewardLevels[index];
        final isLast = index == rewardLevels.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Timeline indicator column
              Column(
                children: [
                  _buildTimelineNode(level, index + 1),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDarkMode ? const Color(0xFF334155) : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Right Ticket Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTicketCard(level, currentLang, t, isDarkMode),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineNode(_RewardLevelData level, int milestoneNumber) {
    final bool isCompletedOrCanClaim = level.status == _RewardLevelStatus.canClaim || level.status == _RewardLevelStatus.claimed;

    if (isCompletedOrCanClaim) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Color(0xFF00B774),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.star_rounded,
          color: Colors.white,
          size: 16,
        ),
      );
    } else {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Color(0xFF1C7FF6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$milestoneNumber',
          style: GoogleFonts.kanit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  // ==========================================
  // TICKET CARD DESIGN WIDGET
  // ==========================================
  Widget _buildTicketCard(_RewardLevelData level, AppLanguage currentLang, String Function(String) t, bool isDarkMode) {
    final bool isClaimed = level.status == _RewardLevelStatus.claimed;
    final bool isCanClaim = level.status == _RewardLevelStatus.canClaim;

    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    final bool isGreenTheme = isClaimed || isCanClaim;
    final Color ribbonBg = isGreenTheme ? const Color(0xFF00B774) : const Color(0xFF1C7FF6);
    final Color voucherRightBg = isGreenTheme
        ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F8EE))
        : (isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE8F2FE));
    final Color voucherTextColor = isGreenTheme ? const Color(0xFF00B774) : const Color(0xFF1C7FF6);

    final currentTrips = ref.watch(rewardsProvider).state.currentTrips;
    final double progressRatio = (currentTrips / level.times).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Left Rotated Ribbon Panel (5 ครั้ง, 10 ครั้ง, 20 ครั้ง)
            Container(
              width: 66,
              color: ribbonBg,
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${level.times}',
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      currentLang == AppLanguage.en ? 'Trips' : 'ครั้ง',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle Info Panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentLang == AppLanguage.en ? 'Complete ${level.times} deliveries' : 'ใช้บริการครบ ${level.times} ครั้ง',
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentLang == AppLanguage.en ? 'Get ${level.discount} THB discount' : 'รับส่วนลด ${level.discount} บาท',
                      style: GoogleFonts.kanit(
                        fontSize: 12.5,
                        color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (isCanClaim)
                      InkWell(
                        onTap: () => _claimRewardMilestone(level.times, level.discount),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B774),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                currentLang == AppLanguage.en ? 'Claim Reward' : 'กดรับสิทธิ์',
                                style: GoogleFonts.kanit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isClaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t('claimed_status'),
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00B774),
                          ),
                        ),
                      )
                    else ...[
                      // In Progress status badge & bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$currentTrips / ${level.times} ครั้ง',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Dashed Divider simulation
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(),
            ),

            // Right Panel (Voucher Discount Display)
            Container(
              width: 92,
              color: voucherRightBg,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentLang == AppLanguage.en ? 'Discount' : 'ส่วนลด',
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: voucherTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${level.discount}',
                    style: GoogleFonts.kanit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: voucherTextColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t('baht_unit'),
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: voucherTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _RewardLevelData {
  final int times;
  final int discount;
  final _RewardLevelStatus status;
  final String progressText;

  _RewardLevelData({
    required this.times,
    required this.discount,
    required this.status,
    required this.progressText,
  });
}

// Custom Painter to draw dashed line separating coupon panels
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashHeight = 4;
    const double dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
