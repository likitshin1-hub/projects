import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../partner/providers/partner_application_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends ConsumerState<NotificationsListScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showClearAllConfirmDialog(BuildContext context, bool isDarkMode, AppLanguage currentLang) {
    final isEn = currentLang == AppLanguage.en;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 24),
            const SizedBox(width: 10),
            Text(
              isEn ? 'Clear All Notifications' : 'ลบการแจ้งเตือนทั้งหมด',
              style: GoogleFonts.kanit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          isEn
              ? 'Are you sure you want to delete all notifications? This action cannot be undone.'
              : 'คุณต้องการลบรายการแจ้งเตือนทั้งหมดใช่หรือไม่? (ไม่สามารถกู้คืนได้)',
          style: GoogleFonts.kanit(
            fontSize: 14,
            color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isEn ? 'Cancel' : 'ยกเลิก',
              style: GoogleFonts.kanit(
                color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref.read(notificationsProvider.notifier).clearAll();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn ? 'All notifications cleared' : 'ลบการแจ้งเตือนทั้งหมดแล้ว',
                    style: GoogleFonts.kanit(),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              isEn ? 'Delete All' : 'ลบทั้งหมด',
              style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;
    final partnerApp = ref.watch(partnerApplicationProvider);
    final notificationsList = ref.watch(notificationsProvider);

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
                    if (notificationsList.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
                        tooltip: isEn ? 'Clear All' : 'ลบการแจ้งเตือนทั้งหมด',
                        onPressed: () => _showClearAllConfirmDialog(context, isDarkMode, currentLang),
                      )
                    else
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'Notification Center' : 'ศูนย์รวมการแจ้งเตือน',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              isEn
                                  ? 'Real-time updates on orders and system'
                                  : 'ติดตามข่าวสารและสถานะคำสั่งซื้อแบบเรียลไทม์',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 44),

          // ==========================================
          // ACTION HEADER BAR (Count & Clear All)
          // ==========================================
          if (notificationsList.isNotEmpty || partnerApp != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEn
                        ? 'Notifications (${notificationsList.length})'
                        : 'รายการแจ้งเตือน (${notificationsList.length})',
                    style: GoogleFonts.kanit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  if (notificationsList.isNotEmpty)
                    InkWell(
                      onTap: () => _showClearAllConfirmDialog(context, isDarkMode, currentLang),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_sweep_rounded,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isEn ? 'Clear All' : 'ล้างทั้งหมด',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ==========================================
          // NOTIFICATIONS LIST / EMPTY STATE
          // ==========================================
          Expanded(
            child: (notificationsList.isEmpty && partnerApp == null)
                ? _buildEmptyState(isDarkMode, isEn)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (partnerApp != null) ...[
                        _buildNotificationCard(
                          context: context,
                          icon: Icons.assignment_ind_rounded,
                          iconBgColor: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                          iconColor: const Color(0xFF1C7FF6),
                          title: isEn
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
                      ...notificationsList.map((notif) {
                        IconData icon = Icons.notifications_active_rounded;
                        Color iconBg = const Color(0xFF1C7FF6).withValues(alpha: 0.12);
                        Color iconColor = const Color(0xFF1C7FF6);

                        if (notif.type == 'order') {
                          icon = Icons.local_shipping_rounded;
                          iconBg = const Color(0xFF10B981).withValues(alpha: 0.12);
                          iconColor = const Color(0xFF10B981);
                        } else if (notif.type == 'promo') {
                          icon = Icons.local_offer_rounded;
                          iconBg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
                          iconColor = const Color(0xFFF59E0B);
                        }

                        return Dismissible(
                          key: Key('notif_${notif.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  isEn ? 'Delete' : 'ลบ',
                                  style: GoogleFonts.kanit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) {
                            ref.read(notificationsProvider.notifier).removeNotification(notif.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEn ? 'Notification deleted' : 'ลบรายการแจ้งเตือนแล้ว',
                                  style: GoogleFonts.kanit(),
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationCard(
                              context: context,
                              icon: icon,
                              iconBgColor: iconBg,
                              iconColor: iconColor,
                              title: notif.title,
                              subtitle: notif.message,
                              time: notif.timeText,
                              isUnread: !notif.isRead,
                              isDarkMode: isDarkMode,
                              onTap: () {
                                ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                                if (notif.type == 'order') {
                                  context.push(AppRoutes.notificationDetail);
                                } else if (notif.type == 'promo') {
                                  context.push(AppRoutes.coupons);
                                }
                              },
                              onDelete: () {
                                ref.read(notificationsProvider.notifier).removeNotification(notif.id);
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isEn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE8F2FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 42,
                color: Color(0xFF1C7FF6),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEn ? 'No Notifications Yet' : 'ไม่มีรายการแจ้งเตือน',
              style: GoogleFonts.kanit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEn
                  ? 'Updates on your deliveries and exclusive promos will appear here.'
                  : 'อัปเดตสถานะคำสั่งซื้อพัสดุและโปรโมชั่นพิเศษจะแสดงที่หน้านี้ครับ',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(
                fontSize: 13,
                color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
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
    VoidCallback? onDelete,
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
                              margin: const EdgeInsets.only(left: 6, right: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1C7FF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (onDelete != null)
                            InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
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
