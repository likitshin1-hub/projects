import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

enum _RewardLevelStatus { claimed, canClaim, inProgress, locked }

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

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _completedTrips = 7;
  final Set<int> _claimedMilestones = {5}; // Start with milestone 5 already claimed for realism

  int _getCurrentTarget() {
    if (_completedTrips < 5) return 5;
    if (_completedTrips < 10) return 10;
    if (_completedTrips < 20) return 20;
    if (_completedTrips < 30) return 30;
    return 50;
  }

  int _getNextMilestoneToUnlock() {
    for (final t in [5, 10, 20, 30, 50]) {
      if (_completedTrips < t) {
        return t;
      }
    }
    return 50;
  }

  _RewardLevelStatus _calculateStatus(int times) {
    if (_claimedMilestones.contains(times)) {
      return _RewardLevelStatus.claimed;
    }
    if (_completedTrips >= times) {
      return _RewardLevelStatus.canClaim;
    }
    if (_getNextMilestoneToUnlock() == times) {
      return _RewardLevelStatus.inProgress;
    }
    return _RewardLevelStatus.locked;
  }

  void _addMockTrip() {
    setState(() {
      _completedTrips++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'จำลองการวิ่งส่งพัสดุสำเร็จ! เที่ยวสะสมเพิ่มเป็น $_completedTrips ครั้ง',
          style: GoogleFonts.kanit(),
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: const Color(0xFF1C7FF6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetMockData() {
    setState(() {
      _completedTrips = 7;
      _claimedMilestones.clear();
      _claimedMilestones.add(5);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'รีเซ็ตข้อมูลทดสอบเรียบร้อยแล้ว',
          style: GoogleFonts.kanit(),
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _claimCoupon(int times, int discount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti / Trophy Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF10B981),
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'ยินดีด้วย!',
                style: GoogleFonts.kanit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'คุณได้รับคูปองส่วนลด $discount บาท\nจากการใช้บริการครบ $times ครั้งเรียบร้อยแล้ว!',
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  color: const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(คูปองถูกจัดเก็บในเมนู คูปองของฉัน)',
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _claimedMilestones.add(times);
                        });
                      },
                      child: Text(
                        'ปิด',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _claimedMilestones.add(times);
                        });
                        context.push(AppRoutes.claimCoupons);
                      },
                      child: Text(
                        'ดูคูปองของฉัน',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    String t(String key) => AppTranslations.getText(currentLang, key);

    final currentTarget = _getCurrentTarget();
    final progressVal = (_completedTrips / currentTarget).clamp(0.0, 1.0);

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
                  _buildMyUsageCard(currentLang, t, progressVal, currentTarget),
                  const SizedBox(height: 24),

                  // REWARDS SECTION TITLE
                  Text(
                    t('my_rewards_title'),
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TIMELINE OF REWARDS
                  _buildRewardsTimeline(currentLang, t),
                  const SizedBox(height: 24),

                  // MOCK SYSTEM TESTING CARD
                  _buildSimulationCard(isDarkMode),
                  const SizedBox(height: 20),
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
  Widget _buildMyUsageCard(AppLanguage currentLang, String Function(String) t, double progressVal, int currentTarget) {
    final isDarkMode = ref.watch(themeProvider);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                      value: progressVal,
                      strokeWidth: 8,
                      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade100,
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
                        currentLang == AppLanguage.en ? '$_completedTrips Trips' : '$_completedTrips ครั้ง',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C7FF6),
                        ),
                      ),
                      Text(
                        currentLang == AppLanguage.en ? 'of $currentTarget trips' : 'จาก $currentTarget ครั้ง',
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
                        color: textColor,
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
                      currentLang == AppLanguage.en ? '$_completedTrips Trips' : '$_completedTrips ครั้ง',
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
                            currentLang == AppLanguage.en 
                                ? 'Next Goal: $currentTarget Trips' 
                                : 'เป้าหมายต่อไป $currentTarget ครั้ง',
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
                            child: LinearProgressIndicator(
                              value: progressVal,
                              minHeight: 6,
                              backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1C7FF6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$_completedTrips / $currentTarget',
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

          // Under card banner: อีก X ครั้ง รับส่วนลด Y บาท
          _buildUsageBanner(currentLang),
        ],
      ),
    );
  }

  Widget _buildUsageBanner(AppLanguage currentLang) {
    int nextGoal = _getNextMilestoneToUnlock();
    int remaining = nextGoal - _completedTrips;
    int discount = 50;
    if (nextGoal == 5) discount = 20;
    if (nextGoal == 20) discount = 120;
    if (nextGoal == 30) discount = 200;
    if (nextGoal == 50) discount = 400;

    if (remaining <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.stars_rounded,
              color: Color(0xFF10B981),
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'บรรลุเป้าหมายการส่งแล้ว!',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                  Text(
                    'กรุณากดรับคูปองส่วนลดด้านล่างของคุณ',
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '🎉',
              style: GoogleFonts.kanit(fontSize: 22),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
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
                  currentLang == AppLanguage.en ? '$remaining more trips' : 'อีก $remaining ครั้ง',
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                Text(
                  currentLang == AppLanguage.en ? 'Get $discount THB discount' : 'รับส่วนลด $discount บาท',
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
    );
  }

  // ==========================================
  // REWARDS TIMELINE LIST WIDGET
  // ==========================================
  Widget _buildRewardsTimeline(AppLanguage currentLang, String Function(String) t) {
    final rewardLevels = [
      _RewardLevelData(
        times: 5,
        discount: 20,
        status: _calculateStatus(5),
        progressText: '',
      ),
      _RewardLevelData(
        times: 10,
        discount: 50,
        status: _calculateStatus(10),
        progressText: currentLang == AppLanguage.en ? '$_completedTrips / 10 Trips' : '$_completedTrips / 10 ครั้ง',
      ),
      _RewardLevelData(
        times: 20,
        discount: 120,
        status: _calculateStatus(20),
        progressText: currentLang == AppLanguage.en ? '0 / 20 Trips' : '0 / 20 ครั้ง',
      ),
      _RewardLevelData(
        times: 30,
        discount: 200,
        status: _calculateStatus(30),
        progressText: currentLang == AppLanguage.en ? '0 / 30 Trips' : '0 / 30 ครั้ง',
      ),
      _RewardLevelData(
        times: 50,
        discount: 400,
        status: _calculateStatus(50),
        progressText: currentLang == AppLanguage.en ? '0 / 50 Trips' : '0 / 50 ครั้ง',
      ),
    ];

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ปลดล็อกแล้ว (สามารถเคลมได้)',
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
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
                            child: LinearProgressIndicator(
                              value: _completedTrips / level.times,
                              minHeight: 4,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
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

            // Right Voucher Coupon Visual Panel / Claim Button
            GestureDetector(
              onTap: isCanClaim ? () => _claimCoupon(level.times, level.discount) : null,
              child: Container(
                width: 76,
                color: ticketSideBg,
                alignment: Alignment.center,
                child: isCanClaim
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'กดรับสิทธิ์',
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Column(
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
            ),
          ],
        ),
      ),
    );
  }

  // Developer Simulation Console Box
  Widget _buildSimulationCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: Color(0xFF64748B), size: 20),
              const SizedBox(width: 8),
              Text(
                'เครื่องมือทดสอบระบบรีวอร์ด (Simulation Console)',
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addMockTrip,
                  icon: const Icon(Icons.add_road_rounded, size: 16),
                  label: Text(
                    'จำลองส่งของ (+1 เที่ยว)',
                    style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C7FF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _resetMockData,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                label: Text(
                  'รีเซ็ตข้อมูล',
                  style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
