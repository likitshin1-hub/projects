import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class TrackingListScreen extends ConsumerWidget {
  final VoidCallback? onMenuPressed;

  const TrackingListScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    String t(String key) => AppTranslations.getText(currentLang, key);

    final List<_TrackingItemData> items = [
      _TrackingItemData(
        orderNo: 'TB504321-5598',
        route: 'กรุงเทพฯ • ชลบุรี',
        routeEn: 'Bangkok • Chonburi',
        dateTime: '8 พ.ค. 2568 10:00',
        dateTimeEn: '8 May 2025 10:00',
        isInProgress: true,
      ),
      _TrackingItemData(
        orderNo: 'TB668511-6448',
        route: 'เชียงใหม่ • บางกอกฯ',
        routeEn: 'Chiang Mai • Bangkok',
        dateTime: '28 เม.ย. 2568 14:00',
        dateTimeEn: '28 Apr 2025 14:00',
        isInProgress: false,
      ),
      _TrackingItemData(
        orderNo: 'TB649993-9995',
        route: 'ระยอง • ดอน 12',
        routeEn: 'Rayong • Don 12',
        dateTime: '12 ก.พ. 2568 14:00',
        dateTimeEn: '12 Feb 2025 14:00',
        isInProgress: false,
      ),
      _TrackingItemData(
        orderNo: 'TB908808-2023',
        route: 'เชียงราย • ลำพูน',
        routeEn: 'Chiang Rai • Lamphun',
        dateTime: '3 ม.ค. 2568 11:00',
        dateTimeEn: '3 Jan 2025 11:00',
        isInProgress: false,
      ),
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER
          // ==========================================
          Container(
            width: double.infinity,
            height: 150 + statusBarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1C7FF6),
                  Color(0xFF0056C6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Standard top bar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                      onPressed: () => onMenuPressed?.call(),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.notification),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                          Positioned(
                            top: -1, right: -1,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              child: Text('3', style: GoogleFonts.kanit(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title + Subtitle and 3D Graphic
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('tracking_list_title'),
                            style: GoogleFonts.kanit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t('realtime_status_sub'),
                            style: GoogleFonts.kanit(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 60,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: 0, top: -10,
                            child: Icon(Icons.location_on_rounded, size: 70, color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          Positioned(
                            right: 5, bottom: 5,
                            child: Icon(Icons.inventory_2_rounded, size: 36, color: Colors.orange.shade300),
                          ),
                          Positioned(
                            right: 35, bottom: 2,
                            child: Icon(Icons.inventory_2_rounded, size: 28, color: Colors.orange.shade400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // BODY LIST
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('latest_parcels'),
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.history),
                        child: Row(
                          children: [
                            Text(
                              t('view_all'),
                              style: GoogleFonts.kanit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C7FF6),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Color(0xFF1C7FF6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // List Cards
                  ...items.map((item) => _buildTrackingCard(item, isDarkMode, currentLang, t, context)),

                  const SizedBox(height: 16),

                  // Dynamic Expressway Banner Card
                  _buildInterprovincialBannerCard(isDarkMode, currentLang, context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(
      _TrackingItemData item, bool isDarkMode, AppLanguage currentLang, String Function(String) t, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(AppRoutes.tracking),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Status Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.isInProgress
                        ? const Color(0xFF1C7FF6).withValues(alpha: 0.1)
                        : const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isInProgress
                        ? Icons.inventory_2_rounded
                        : Icons.check_circle_rounded,
                    color: item.isInProgress
                        ? const Color(0xFF1C7FF6)
                        : const Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.orderNo,
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentLang == AppLanguage.en ? item.routeEn : item.route,
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentLang == AppLanguage.en ? item.dateTimeEn : item.dateTime,
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isInProgress
                        ? const Color(0xFF1C7FF6).withValues(alpha: 0.12)
                        : const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isInProgress ? t('status_in_progress') : t('status_delivered'),
                    style: GoogleFonts.kanit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: item.isInProgress
                          ? const Color(0xFF1C7FF6)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterprovincialBannerCard(bool isDarkMode, AppLanguage currentLang, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(AppRoutes.tracking),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C7FF6).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    color: Color(0xFF38BDF8),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLang == AppLanguage.en
                            ? 'Chonburi ➔ CentralWorld (Bangkok)'
                            : 'ชลบุรี ➔ เซ็นทรัลเวิลด์ (กทม.)',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentLang == AppLanguage.en
                            ? 'In transit on Burapha Withi Expressway (Live GPS)'
                            : 'กำลังขนส่งบนทางพิเศษบูรพาวิถี (Live GPS)',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackingItemData {
  final String orderNo;
  final String route;
  final String routeEn;
  final String dateTime;
  final String dateTimeEn;
  final bool isInProgress;

  _TrackingItemData({
    required this.orderNo,
    required this.route,
    required this.routeEn,
    required this.dateTime,
    required this.dateTimeEn,
    required this.isInProgress,
  });
}
