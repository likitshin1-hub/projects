import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class DeliveryHistoryPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const DeliveryHistoryPage({
    super.key,
    this.onMenuPressed,
  });

  @override
  State<DeliveryHistoryPage> createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  int _selectedTab = 0; // 0: การจัดส่งทั้งหมด, 1: ประวัติการจัดส่ง
  int _selectedSubFilter = 0; // 0: ทั้งหมด, 1: กำลังดำเนินการ, 2: เสร็จสิ้น, 3: ยกเลิก

  final List<String> _subFilters = ['ทั้งหมด', 'กำลังดำเนินการ', 'เสร็จสิ้น', 'ยกเลิก'];

  // Mock data list matching the mockup image exactly
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

    // Filter items based on tab
    List<_HistoryItemData> tabFiltered = _allHistoryItems;
    if (_selectedTab == 1) {
      // "ประวัติการจัดส่ง" Tab shows only completed/cancelled
      tabFiltered = _allHistoryItems
          .where((item) =>
              item.status == _HistoryStatus.completed ||
              item.status == _HistoryStatus.cancelled)
          .toList();
    }

    // Filter items based on sub-chips
    List<_HistoryItemData> finalFiltered = tabFiltered;
    if (_selectedSubFilter == 1) {
      finalFiltered = tabFiltered.where((item) => item.status == _HistoryStatus.inProgress).toList();
    } else if (_selectedSubFilter == 2) {
      finalFiltered = tabFiltered.where((item) => item.status == _HistoryStatus.completed).toList();
    } else if (_selectedSubFilter == 3) {
      finalFiltered = tabFiltered.where((item) => item.status == _HistoryStatus.cancelled).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER + MAIN TABS STACK
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 0),
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
                            if (widget.onMenuPressed != null) {
                              widget.onMenuPressed!();
                            } else {
                              if (context.canPop()) {
                                context.pop();
                              }
                            }
                          },
                        ),
                        Text(
                          'ประวัติการขนส่ง',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Bell Notification icon with red badge count 3
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.notification);
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    '3',
                                    style: GoogleFonts.kanit(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Segmented Tabs Card
              Positioned(
                bottom: -28,
                left: 20,
                right: 20,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildMainTabItem(0, 'การจัดส่งทั้งหมด', Icons.inventory_2_outlined),
                      _buildMainTabItem(1, 'ประวัติการจัดส่ง', Icons.access_time_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 44), // Gap for the overlapping tabs card

          // ==========================================
          // SUB-CHIP FILTERS ROW
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _subFilters.length,
                      itemBuilder: (context, index) {
                        final bool isSelected = _selectedSubFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              _subFilters[index],
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1C7FF6),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            side: BorderSide.none,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedSubFilter = index;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Filter "ตัวกรอง" Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.filter_list_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ตัวกรอง',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // LIST OF LOGISTICS ORDERS
          // ==========================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: finalFiltered.length + 1, // +1 for the bottom Map tracking card banner
              itemBuilder: (context, index) {
                if (index == finalFiltered.length) {
                  // Render the bottom tracking card banner
                  return _buildTrackingBannerCard();
                }
                return _buildHistoryOrderCard(finalFiltered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEGMENTED MAIN TAB BAR ITEM HELPER
  // ==========================================
  Widget _buildMainTabItem(int index, String label, IconData icon) {
    final bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _selectedSubFilter = 0; // Reset sub chip index
          });
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF1C7FF6) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INDIVIDUAL LOGISTICS ORDER CARD HELPER
  // ==========================================
  Widget _buildHistoryOrderCard(_HistoryItemData item) {
    Color sideColor;
    Color iconColor;
    Color iconBg;
    IconData icon;
    String statusLabel;
    Color statusTextCol;
    Color statusBg;

    switch (item.status) {
      case _HistoryStatus.inProgress:
        sideColor = const Color(0xFF1C7FF6);
        iconColor = const Color(0xFF1C7FF6);
        iconBg = const Color(0xFFE8F2FE);
        icon = Icons.local_shipping_outlined;
        statusLabel = 'กำลังดำเนินการ';
        statusTextCol = const Color(0xFF1C7FF6);
        statusBg = const Color(0xFFE8F2FE);
        break;
      case _HistoryStatus.completed:
        sideColor = const Color(0xFF22C55E);
        iconColor = const Color(0xFF22C55E);
        iconBg = const Color(0xFFE8F8EE);
        icon = Icons.check_rounded;
        statusLabel = 'เสร็จสิ้น';
        statusTextCol = const Color(0xFF22C55E);
        statusBg = const Color(0xFFE8F8EE);
        break;
      case _HistoryStatus.cancelled:
        sideColor = const Color(0xFFEF4444);
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFFEE2E2);
        icon = Icons.close_rounded;
        statusLabel = 'ยกเลิก';
        statusTextCol = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            // Left color side bar indicator
            Container(
              width: 4,
              height: 104,
              color: sideColor,
            ),
            const SizedBox(width: 14),

            // Circle Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Details middle section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลขที่ออเดอร์ : ${item.orderNo}',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.route,
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.dateTime,
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Status badge and Price on the right
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.kanit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: statusTextCol,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${item.price} บาท',
                    style: GoogleFonts.kanit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron on far right
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM MAP TRACKING BANNER CARD HELPER
  // ==========================================
  Widget _buildTrackingBannerCard() {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 3D Box Map Illustration (Emoji / text mock style)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Text('📍', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),

          // Title & Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ติดตามสถานะพัสดุได้แบบเรียลไทม์',
                  style: GoogleFonts.kanit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  'เช็คตำแหน่งและความคืบหน้าการจัดส่ง ได้ตลอด 24 ชั่วโมง',
                  style: GoogleFonts.kanit(
                    fontSize: 10.5,
                    color: const Color(0xFF1E40AF),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: Text(
              'ดูแผนที่',
              style: GoogleFonts.kanit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  _HistoryItemData({
    required this.orderNo,
    required this.route,
    required this.dateTime,
    required this.price,
    required this.status,
  });
}