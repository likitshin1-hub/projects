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

enum _RewardLevelStatus { claimed, canClaim, inProgress, locked }

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

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER
          // ==========================================
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A6CFF),
                  Color(0xFF0052CC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    Text(
                      t('privileges_rewards'),
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {},
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

          // ==========================================
          // SCROLLABLE CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MY USAGE CARD
                  _buildMyUsageCard(currentLang, t),
                  const SizedBox(height: 24),

                  // REWARDS SECTION TITLE
                  Text(
                    t('my_rewards_title'),
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TIMELINE OF REWARDS
                  _buildRewardsTimeline(currentLang, t),
                ],
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
  Widget _buildMyUsageCard(AppLanguage currentLang, String Function(String) t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
  Widget _buildRewardsTimeline(AppLanguage currentLang, String Function(String) t) {
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
                        color: Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Right Ticket Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTicketCard(level, currentLang, t),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineNode(_RewardLevelData level, int milestoneNumber) {
    switch (level.status) {
      case _RewardLevelStatus.claimed:
        return const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF22C55E),
          size: 24,
        );
      case _RewardLevelStatus.canClaim:
        return const Icon(
          Icons.stars_rounded,
          color: Color(0xFF10B981),
          size: 24,
        );
      case _RewardLevelStatus.inProgress:
        return Container(
          width: 24,
          height: 24,
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
      case _RewardLevelStatus.locked:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 12,
          ),
        );
    }
  }

  // ==========================================
  // TICKET CARD DESIGN WIDGET
  // ==========================================
  Widget _buildTicketCard(_RewardLevelData level, AppLanguage currentLang, String Function(String) t) {
    final bool isClaimed = level.status == _RewardLevelStatus.claimed;
    final bool isCanClaim = level.status == _RewardLevelStatus.canClaim;
    final bool isInProgress = level.status == _RewardLevelStatus.inProgress;
    final bool isLocked = level.status == _RewardLevelStatus.locked;

    // Card Colors based on status
    final Color badgeBg = isLocked ? Colors.grey.shade400 : (isCanClaim ? const Color(0xFF10B981) : const Color(0xFF1C7FF6));
    final Color ticketSideBg = isClaimed
        ? const Color(0xFFE8F8EE)
        : (isCanClaim
            ? const Color(0xFFECFDF5)
            : isInProgress
                ? const Color(0xFFE8F2FE)
                : const Color(0xFFF1F5F9));
    final Color ticketTextColor = isClaimed
        ? const Color(0xFF16A34A)
        : (isCanClaim
            ? const Color(0xFF10B981)
            : isInProgress
                ? const Color(0xFF1D4ED8)
                : const Color(0xFF64748B));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Left Panel (Pill badge representing number of times)
            Container(
              width: 56,
              decoration: BoxDecoration(
                color: badgeBg,
              ),
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${level.times}',
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      currentLang == AppLanguage.en ? 'Trips' : 'ครั้ง',
                      style: GoogleFonts.kanit(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle Description Panel
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      currentLang == AppLanguage.en ? 'Get ${level.discount} THB discount' : 'รับส่วนลด ${level.discount} บาท',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Status Badge or Progress bar
                    if (isClaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t('claimed_status'),
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      )
                    else if (isCanClaim)
                      InkWell(
                        onTap: () => _claimRewardMilestone(level.times, level.discount),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                currentLang == AppLanguage.en ? 'Claim Coupon' : 'กดรับสิทธิ์',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isInProgress)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level.progressText,
                              style: GoogleFonts.kanit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: const LinearProgressIndicator(
                              value: 0.7,
                              minHeight: 4,
                              backgroundColor: Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1C7FF6),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          level.progressText,
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Dashed Divider simulation
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(),
            ),

            // Right Voucher Coupon Visual Panel
            Container(
              width: 76,
              color: ticketSideBg,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentLang == AppLanguage.en ? 'Discount' : 'ส่วนลด',
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: ticketTextColor,
                    ),
                  ),
                  Text(
                    '${level.discount}',
                    style: GoogleFonts.kanit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ticketTextColor,
                    ),
                  ),
                  Text(
                    t('baht_unit'),
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: ticketTextColor,
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
