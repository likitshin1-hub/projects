import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class DeliveryHistoryPage extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;

  const DeliveryHistoryPage({
    super.key,
    this.onMenuPressed,
  });

  @override
  ConsumerState<DeliveryHistoryPage> createState() => _DeliveryHistoryPageState();
}

enum _HistoryStatus { inProgress, completed, cancelled }

class _HistoryItemData {
  final String orderNo;
  final String route;
  final String dateTime;
  final String price;
  final _HistoryStatus status;

  _HistoryItemData({
    required this.orderNo,
    required this.route,
    required this.dateTime,
    required this.price,
    required this.status,
  });
}

class _DeliveryHistoryPageState extends ConsumerState<DeliveryHistoryPage> {
  int _selectedTab = 0; // 0: การจัดส่งทั้งหมด, 1: ประวัติการจัดส่ง
  int _selectedSubFilter = 0; // 0: ทั้งหมด, 1: กำลังดำเนินการ, 2: เสร็จสิ้น, 3: ยกเลิก

  final List<_HistoryItemData> _allHistoryItems = [
    _HistoryItemData(
      orderNo: 'TB504321-5598',
      route: 'บ้าน > ชลบุรี',
      dateTime: '20 เม.ย. 2569 14:00',
      price: '1,290.00',
      status: _HistoryStatus.inProgress,
    ),
    _HistoryItemData(
      orderNo: 'TB668511-6648',
      route: 'ชลบุรี > ชลบุรี',
      dateTime: '19 เม.ย. 2569 14:00',
      price: '500.00',
      status: _HistoryStatus.completed,
    ),
    _HistoryItemData(
      orderNo: 'TB592488-2621',
      route: 'เก้ากิโล 5 > หน้าตึกคอนศรีราชา',
      dateTime: '11 เม.ย. 2569 11:00',
      price: '250.00',
      status: _HistoryStatus.cancelled,
    ),
    _HistoryItemData(
      orderNo: 'TB595688-2621',
      route: 'เก้ากิโล > บางพระ',
      dateTime: '9 เม.ย. 2569 11:00',
      price: '542.00',
      status: _HistoryStatus.completed,
    ),
    _HistoryItemData(
      orderNo: 'TB595688-2321',
      route: 'สุรศักดิ์ 2 > สุรศักดิ์ 11',
      dateTime: '3 เม.ย. 2569 15:00',
      price: '300.00',
      status: _HistoryStatus.inProgress,
    ),
    _HistoryItemData(
      orderNo: 'TB506331-3622',
      route: 'สวนเสือ > โรบินสันศรีราชา',
      dateTime: '2 เม.ย. 2569 10:00',
      price: '420.00',
      status: _HistoryStatus.completed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    String t(String key) => AppTranslations.getText(currentLang, key);

    final subFilterLabels = [
      t('filter_all'),
      t('filter_in_progress'),
      t('filter_completed'),
      t('filter_cancelled'),
    ];

    List<_HistoryItemData> tabFiltered = _allHistoryItems;
    if (_selectedTab == 1) {
      tabFiltered = _allHistoryItems
          .where((item) =>
              item.status == _HistoryStatus.completed ||
              item.status == _HistoryStatus.cancelled)
          .toList();
    }

    List<_HistoryItemData> finalFiltered = tabFiltered;
    if (_selectedSubFilter == 1) {
      finalFiltered = tabFiltered.where((item) => item.status == _HistoryStatus.inProgress).toList();
    } else if (_selectedSubFilter == 2) {
      finalFiltered = tabFiltered.where((item) => item.status == _HistoryStatus.completed).toList();
    } else if (_selectedSubFilter == 3) {
      finalFiltered = tabFiltered.where((item) => item.status == _HistoryStatus.cancelled).toList();
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // HEADER BAR
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                ),
                Text(
                  t('delivery_history_title'),
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.notification),
                ),
              ],
            ),
          ),

          // TAB BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0 ? const Color(0xFF1C7FF6) : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        t('all_deliveries_tab'),
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedTab == 0 ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1 ? const Color(0xFF1C7FF6) : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        t('history_deliveries_tab'),
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedTab == 1 ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SUB-FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(subFilterLabels.length, (index) {
                final isSelected = _selectedSubFilter == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      subFilterLabels[index],
                      style: GoogleFonts.kanit(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1C7FF6),
                    backgroundColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSubFilter = index);
                    },
                  ),
                );
              }),
            ),
          ),

          // HISTORY LIST
          Expanded(
            child: finalFiltered.isEmpty
                ? Center(
                    child: Text(
                      currentLang == AppLanguage.en ? 'No delivery history found' : 'ไม่พบประวัติการจัดส่ง',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    physics: const BouncingScrollPhysics(),
                    itemCount: finalFiltered.length,
                    itemBuilder: (context, index) {
                      final item = finalFiltered[index];
                      return _buildHistoryCard(item, isDarkMode, t);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(_HistoryItemData item, bool isDarkMode, String Function(String) t) {
    Color statusBg;
    Color statusTextColor;
    String statusLabel;
    IconData statusIcon;

    switch (item.status) {
      case _HistoryStatus.inProgress:
        statusBg = const Color(0xFF1C7FF6).withValues(alpha: 0.12);
        statusTextColor = const Color(0xFF1C7FF6);
        statusLabel = t('filter_in_progress');
        statusIcon = Icons.local_shipping_rounded;
        break;
      case _HistoryStatus.completed:
        statusBg = const Color(0xFF10B981).withValues(alpha: 0.12);
        statusTextColor = const Color(0xFF10B981);
        statusLabel = t('filter_completed');
        statusIcon = Icons.check_circle_rounded;
        break;
      case _HistoryStatus.cancelled:
        statusBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
        statusTextColor = const Color(0xFFEF4444);
        statusLabel = t('filter_cancelled');
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusBg,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusTextColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t('order_no_prefix')}: ${item.orderNo}',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.route,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.dateTime,
                      style: GoogleFonts.kanit(
                        fontSize: 11.5,
                        color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      '${item.price} ${t('baht_unit')}',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                      ),
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
}