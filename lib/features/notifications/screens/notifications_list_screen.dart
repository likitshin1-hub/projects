import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../partner/providers/partner_application_provider.dart';
import '../repositories/user_repository.dart';

class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends ConsumerState<NotificationsListScreen> {
  final UserRepository _userRepo = UserRepository();
  List<AppNotificationModel> _apiNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await _userRepo.getNotifications();
    setState(() {
      _apiNotifications = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final partnerApp = ref.watch(partnerApplicationProvider);

    String t(String key) => AppTranslations.getText(currentLang, key);

    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER WITH APP BAR
          // ==========================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 140 + statusBarHeight,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          t('notifications'),
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // TOP SUMMARY FLOATING CARD
              Positioned(
                left: 20,
                right: 20,
                bottom: -32,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF1C7FF6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentLang == AppLanguage.en ? 'Notification Center' : 'ศูนย์รวมการแจ้งเตือน',
                            style: GoogleFonts.kanit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            currentLang == AppLanguage.en
                                ? 'Real-time updates on orders and system'
                                : 'ติดตามข่าวสารและสถานะคำสั่งซื้อแบบเรียลไทม์',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: subTextColor,
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

          const SizedBox(height: 44),

          // ==========================================
          // NOTIFICATIONS LIST
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                ..._apiNotifications.map((notif) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNotificationCard(
                        context: context,
                        icon: notif.type == 'order' ? Icons.local_shipping_rounded : Icons.notifications_active_rounded,
                        iconBgColor: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                        iconColor: const Color(0xFF1C7FF6),
                        title: notif.title,
                        subtitle: notif.message,
                        time: notif.timeText,
                        isUnread: !notif.isRead,
                        isDarkMode: isDarkMode,
                        onTap: () {},
                      ),
                    )),
                if (partnerApp != null) ...[
                  _buildNotificationCard(
                    context: context,
                    icon: Icons.assignment_ind_rounded,
                    iconBgColor: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF1C7FF6),
                    title: currentLang == AppLanguage.en
                        ? 'Driver Partner Application Update'
                        : 'อัปเดตสถานะใบสมัครคนขับ / ไรเดอร์',
                    subtitle: partnerApp.currentStatusText,
                    time: 'เมื่อครู่',
                    isUnread: true,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      context.push(AppRoutes.partner);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                _buildNotificationCard(
                  context: context,
                  icon: Icons.local_offer_rounded,
                  iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  iconColor: const Color(0xFFF59E0B),
                  title: currentLang == AppLanguage.en
                      ? 'Special Discount Coupon Received!'
                      : 'คุณได้รับคูปองส่วนลดพิเศษ 50 บาท!',
                  subtitle: currentLang == AppLanguage.en
                      ? 'Use code FOR YOU for next interprovincial trip'
                      : 'กดใช้คูปองส่วนลดได้ทันทีเมื่อใช้บริการส่งของข้ามจังหวัด',
                  time: '2 ชั่วโมงที่แล้ว',
                  isUnread: false,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    context.push(AppRoutes.coupons);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF1C7FF6)
              : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.kanit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1C7FF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.kanit(
                          fontSize: 12.5,
                          color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        time,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
    );
  }
}
