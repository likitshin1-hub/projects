import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
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

class _DeliveryHistoryPageState extends ConsumerState<DeliveryHistoryPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  int _selectedSubFilter = 0;

  final List<_HistoryItemData> _allHistoryItems = [
    _HistoryItemData(
      orderNo: 'TB504321-5598',
      route: 'บ้าน > ชลบุรี',
      dateTime: '20 เม.ย. 2569 14:00',
      price: '1,290.00',
      status: _HistoryStatus.inProgress,
      vehicle: '🚚',
    ),
    _HistoryItemData(
      orderNo: 'TB668511-6648',
      route: 'ชลบุรี > ชลบุรี',
      dateTime: '19 เม.ย. 2569 14:00',
      price: '500.00',
      status: _HistoryStatus.completed,
      vehicle: '🏍️',
    ),
    _HistoryItemData(
      orderNo: 'TB592488-2621',
      route: 'เก้ากิโล 5 > หน้าตึกคอนศรีราชา',
      dateTime: '11 เม.ย. 2569 11:00',
      price: '250.00',
      status: _HistoryStatus.cancelled,
      vehicle: '🚐',
    ),
    _HistoryItemData(
      orderNo: 'TB595688-2621',
      route: 'เก้ากิโล > บางพระ',
      dateTime: '9 เม.ย. 2569 11:00',
      price: '542.00',
      status: _HistoryStatus.completed,
      vehicle: '🚚',
    ),
    _HistoryItemData(
      orderNo: 'TB595688-2321',
      route: 'สุรศักดิ์ 2 > สุรศักดิ์ 11',
      dateTime: '3 เม.ย. 2569 15:00',
      price: '300.00',
      status: _HistoryStatus.inProgress,
      vehicle: '🏍️',
    ),
    _HistoryItemData(
      orderNo: 'TB506331-3622',
      route: 'สวนเสือ > โรบินสันศรีราชา',
      dateTime: '2 เม.ย. 2569 10:00',
      price: '420.00',
      status: _HistoryStatus.completed,
      vehicle: '🚐',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;

    final subFilters = isEn
        ? ['All', 'In Progress', 'Completed', 'Cancelled']
        : ['ทั้งหมด', 'กำลังดำเนินการ', 'เสร็จสิ้น', 'ยกเลิก'];

    // Colors matching app theme
    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

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
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==========================================
          // HEADER — matches app theme gradient + style
          // ==========================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 160 + statusBarHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 0),
                child: Stack(
                  children: [
                    // Decorative icon background (เหมือน settings)
                    Positioned(
                      right: -10,
                      bottom: 8,
                      child: Opacity(
                        opacity: 0.12,
                        child: const Icon(Icons.history_rounded, size: 100, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: 70,
                      bottom: 50,
                      child: Opacity(
                        opacity: 0.07,
                        child: const Icon(Icons.local_shipping_rounded, size: 52, color: Colors.white),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                                    IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                              onPressed: () {
                                if (widget.onMenuPressed != null) {
                                  widget.onMenuPressed!();
                                } else if (context.canPop()) {
                                  context.pop();
                                }
                              },
                            ),
                            Text(
                              isEn ? 'Delivery History' : 'ประวัติการขนส่ง',
                              style: GoogleFonts.kanit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.notification),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  Positioned(
                                    top: -1, right: -1,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text('3', style: GoogleFonts.kanit(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ],
                ),
              ),

              // Floating tab card — เหมือนของเดิม
              Positioned(
                bottom: -26,
                left: 20,
                right: 20,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildMainTabItem(0, isEn ? 'All Deliveries' : 'การจัดส่งทั้งหมด', Icons.inventory_2_outlined, isDarkMode),
                      _buildMainTabItem(1, isEn ? 'Delivery History' : 'ประวัติการจัดส่ง', Icons.access_time_rounded, isDarkMode),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 42),

          // ==========================================
          // FILTER CHIPS
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: subFilters.length,
                      itemBuilder: (context, index) {
                        final bool isSelected = _selectedSubFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSubFilter = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1C7FF6) : dividerColor,
                                ),
                              ),
                              child: Text(
                                subFilters[index],
                                style: GoogleFonts.kanit(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : secondaryTextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 16, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(isEn ? 'Filter' : 'ตัวกรอง', style: GoogleFonts.kanit(fontSize: 12, color: secondaryTextColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // LIST
          // ==========================================
          Expanded(
            child: finalFiltered.isEmpty
                ? _buildEmptyState(isDarkMode, isEn, primaryTextColor)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: finalFiltered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == finalFiltered.length) {
                        return _buildTrackingBannerCard(isDarkMode, isEn, cardBgColor, dividerColor);
                      }
                      return _buildHistoryOrderCard(
                        finalFiltered[index], isDarkMode, isEn,
                        primaryTextColor, secondaryTextColor, dividerColor, cardBgColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }



  Widget _buildMainTabItem(int index, String label, IconData icon, bool isDarkMode) {
    final bool isActive = _selectedTab == index;
    final activeColor = const Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = index;
          _selectedSubFilter = 0;
        }),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? activeColor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: isActive ? activeColor : inactiveColor),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryOrderCard(
    _HistoryItemData item,
    bool isDarkMode,
    bool isEn,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color dividerColor,
    Color cardBgColor,
  ) {
    Color sideColor;
    Color iconColor;
    Color iconBg;
    String statusLabel;
    Color statusTextCol;
    Color statusBg;

    switch (item.status) {
      case _HistoryStatus.inProgress:
        sideColor = const Color(0xFF1C7FF6);
        iconColor = const Color(0xFF1C7FF6);
        iconBg = isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE8F2FE);
        statusLabel = isEn ? 'In Progress' : 'กำลังดำเนินการ';
        statusTextCol = const Color(0xFF1C7FF6);
        statusBg = isDarkMode ? const Color(0xFF1E3A5F) : const Color(0xFFE8F2FE);
        break;
      case _HistoryStatus.completed:
        sideColor = const Color(0xFF22C55E);
        iconColor = const Color(0xFF22C55E);
        iconBg = isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F8EE);
        statusLabel = isEn ? 'Completed' : 'เสร็จสิ้น';
        statusTextCol = const Color(0xFF16A34A);
        statusBg = isDarkMode ? const Color(0xFF14532D).withValues(alpha: 0.5) : const Color(0xFFE8F8EE);
        break;
      case _HistoryStatus.cancelled:
        sideColor = const Color(0xFFEF4444);
        iconColor = const Color(0xFFEF4444);
        iconBg = isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        statusLabel = isEn ? 'Cancelled' : 'ยกเลิก';
        statusTextCol = const Color(0xFFDC2626);
        statusBg = isDarkMode ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('${AppRoutes.tracking}/${item.orderNo}'),
          child: Row(
            children: [
              // Left color bar
              Container(
                width: 4,
                height: 106,
                decoration: BoxDecoration(
                  color: sideColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Vehicle emoji circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Center(child: Text(item.vehicle, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),

              // Middle info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Order #${item.orderNo}' : 'เลขที่ : ${item.orderNo}',
                        style: GoogleFonts.kanit(fontSize: 12.5, fontWeight: FontWeight.bold, color: primaryTextColor),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: iconColor),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.route,
                              style: GoogleFonts.kanit(fontSize: 11.5, color: secondaryTextColor, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 5),
                          Text(item.dateTime, style: GoogleFonts.kanit(fontSize: 10.5, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right: status + price
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(statusLabel, style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextCol)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isEn ? '${item.price} THB' : '${item.price} บาท',
                      style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: const Color(0xFF1C7FF6).withValues(alpha: 0.8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isEn, Color primaryTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE8F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 40, color: Color(0xFF1C7FF6)),
          ),
          const SizedBox(height: 16),
          Text(isEn ? 'No orders found' : 'ไม่พบรายการ', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor)),
          const SizedBox(height: 6),
          Text(isEn ? 'Try changing the filter' : 'ลองเปลี่ยนตัวกรองดูครับ', style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildTrackingBannerCard(bool isDarkMode, bool isEn, Color cardBgColor, Color dividerColor) {
    final bannerBg = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFDBEAFE);
    final titleColor = isDarkMode ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Text('📍', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Track Delivery Live' : 'ติดตามสถานะพัสดุแบบเรียลไทม์',
                  style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: titleColor),
                ),
                Text(
                  isEn ? 'Check location & progress 24/7' : 'เช็คตำแหน่งและความคืบหน้าได้ตลอด 24 ชั่วโมง',
                  style: GoogleFonts.kanit(fontSize: 10.5, color: titleColor, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () => context.push('${AppRoutes.tracking}/TB504321-5598'),
            child: Text(isEn ? 'View Map' : 'ดูแผนที่', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

enum _HistoryStatus { inProgress, completed, cancelled }

class _HistoryItemData {
  final String orderNo;
  final String route;
  final String dateTime;
  final String price;
  final _HistoryStatus status;
  final String vehicle;

  _HistoryItemData({
    required this.orderNo,
    required this.route,
    required this.dateTime,
    required this.price,
    required this.status,
    required this.vehicle,
  });
}