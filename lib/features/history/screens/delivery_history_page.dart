import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../home/widgets/bottom_navigation.dart';

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
  int _selectedTab = 0; // 0 = ประวัติทั้งหมด, 1 = จัดส่งสำเร็จ, 2 = ยกเลิก
  int _selectedSubFilter = 0; // 0 = ทั้งหมด (เสร็จสิ้น+ยกเลิก), 1 = เสร็จสิ้น, 2 = ยกเลิก
  final DioClient _dioClient = DioClient();

  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _vehicleFilter = 'all'; // all, 🛵, 🚗, 🚚, 🚛

  // History dataset containing ONLY completed and cancelled orders
  final List<_HistoryItemData> _defaultHistoryItems = [
    _HistoryItemData(
      orderNo: 'TB491022-1029',
      pickupAddress: 'นิคมอุตสาหกรรมบางปู สมุทรปราการ',
      destinationAddress: 'ท่าเรือแหลมฉบัง ชลบุรี',
      route: 'บางปู > แหลมฉบัง ชลบุรี',
      dateTime: '14 ส.ค. 2026 16:45 น.',
      price: '1,250.00',
      status: _HistoryStatus.completed,
      vehicle: '🚚',
      vehicleName: 'รถกระบะตู้ทึบ',
      statusText: 'จัดส่งสำเร็จ (ผู้รับเซ็นชื่อเรียบร้อย)',
      driverName: 'มานิตย์ ขยันส่ง',
      driverPhone: '086-555-4444',
    ),
    _HistoryItemData(
      orderNo: 'TB488102-3921',
      pickupAddress: 'ศูนย์การค้าเซ็นทรัลเวิลด์',
      destinationAddress: 'อาคารสาทรธานี กรุงเทพฯ',
      route: 'เซ็นทรัลเวิลด์ > ออฟฟิศสาทร',
      dateTime: '12 ส.ค. 2026 10:20 น.',
      price: '85.00',
      status: _HistoryStatus.completed,
      vehicle: '🛵',
      vehicleName: 'มอเตอร์ไซค์',
      statusText: 'จัดส่งสำเร็จ',
      driverName: 'สมชาย ใจดี',
      driverPhone: '089-999-8888',
    ),
    _HistoryItemData(
      orderNo: 'TB470129-8812',
      pickupAddress: 'ตลาดสี่มุมเมือง ปทุมธานี',
      destinationAddress: 'ตลาดคลองเตย กรุงเทพฯ',
      route: 'ตลาดสี่มุมเมือง > ตลาดคลองเตย',
      dateTime: '10 ส.ค. 2026 09:00 น.',
      price: '480.00',
      status: _HistoryStatus.cancelled,
      vehicle: '🚛',
      vehicleName: 'รถห้องเย็น',
      statusText: 'ยกเลิกรายการ (ผู้ส่งขอยกเลิก)',
      driverName: 'กิตติศักดิ์ มั่นคง',
      driverPhone: '082-111-9999',
    ),
    _HistoryItemData(
      orderNo: 'TB451009-7711',
      pickupAddress: 'ห้างสรรพสินค้าเมกาบางนา',
      destinationAddress: 'สนามบินสุวรรณภูมิ',
      route: 'บางนา > สุวรรณภูมิ',
      dateTime: '05 ส.ค. 2026 18:30 น.',
      price: '220.00',
      status: _HistoryStatus.completed,
      vehicle: '🚗',
      vehicleName: 'รถเก๋ง 4 ประตู',
      statusText: 'จัดส่งสำเร็จ',
      driverName: 'วิชัย มั่นคง',
      driverPhone: '081-222-3333',
    ),
    _HistoryItemData(
      orderNo: 'TB440218-4433',
      pickupAddress: 'สถานีรถไฟหัวลำโพง',
      destinationAddress: 'ตลาดน้อย สัมพันธวงศ์',
      route: 'หัวลำโพง > ตลาดน้อย',
      dateTime: '01 ส.ค. 2026 11:00 น.',
      price: '65.00',
      status: _HistoryStatus.cancelled,
      vehicle: '🛵',
      vehicleName: 'มอเตอร์ไซค์',
      statusText: 'ยกเลิกรายการ (ระบบยกเลิกอัตโนมัติ)',
      driverName: 'สมศักดิ์ สุขใจ',
      driverPhone: '083-444-5555',
    ),
  ];

  late List<_HistoryItemData> _allHistoryItems;

  @override
  void initState() {
    super.initState();
    _allHistoryItems = List.from(_defaultHistoryItems);
    _fetchRealOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRealOrders() async {
    try {
      final response = await _dioClient.get('/orders');
      if (response.data is List) {
        final List list = response.data as List;
        final List<_HistoryItemData> realItems = [];
        for (var item in list) {
          final statusStr = item['status'] as String? ?? 'completed';
          // Filter out in_progress items from history page
          if (statusStr == 'in_progress' || statusStr == 'waiting_driver' || statusStr == 'delivering') {
            continue;
          }

          _HistoryStatus status = _HistoryStatus.completed;
          if (statusStr == 'cancelled') {
            status = _HistoryStatus.cancelled;
          }

          final priceVal = item['total_price'] != null ? '${item['total_price']}' : '0.00';
          final pickupStr = item['pickup_address'] as String? ?? 'จุดรับ';
          final destStr = item['destination_address'] as String? ?? 'จุดส่ง';
          final rawDate = item['created_at'] as String?;
          String formattedDate = 'เมื่อสักครู่';
          if (rawDate != null && rawDate.length >= 16) {
            formattedDate = rawDate.substring(0, 16).replaceAll('T', ' ');
          }

          realItems.add(
            _HistoryItemData(
              orderNo: item['order_no'] as String? ?? 'TB-${item['id']}',
              pickupAddress: pickupStr,
              destinationAddress: destStr,
              route: '$pickupStr > $destStr',
              dateTime: formattedDate,
              price: priceVal,
              status: status,
              vehicle: '📦',
              vehicleName: 'พัสดุทั่วไป',
              statusText: status == _HistoryStatus.completed ? 'จัดส่งเสร็จสิ้น' : 'ยกเลิกคำสั่งซื้อ',
              driverName: 'ไรเดอร์ประจำพื้นที่',
              driverPhone: '081-999-0000',
            ),
          );
        }

        if (mounted && realItems.isNotEmpty) {
          setState(() {
            for (var item in realItems.reversed) {
              if (!_allHistoryItems.any((e) => e.orderNo == item.orderNo)) {
                _allHistoryItems.insert(0, item);
              }
            }
          });
        }
      }
    } catch (_) {}
  }

  void _showFilterBottomSheet(bool isDarkMode, bool isEn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEn ? 'Filter History' : 'ตัวกรองประวัติการขนส่ง',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEn ? 'Vehicle Type' : 'ประเภทรถขนส่ง',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip('ทั้งหมด', _vehicleFilter == 'all', () {
                        setModalState(() => _vehicleFilter = 'all');
                      }, isDarkMode),
                      _buildFilterChip('🛵 มอเตอร์ไซค์', _vehicleFilter == '🛵', () {
                        setModalState(() => _vehicleFilter = '🛵');
                      }, isDarkMode),
                      _buildFilterChip('🚗 รถเก๋ง', _vehicleFilter == '🚗', () {
                        setModalState(() => _vehicleFilter = '🚗');
                      }, isDarkMode),
                      _buildFilterChip('🚚 รถกระบะ', _vehicleFilter == '🚚', () {
                        setModalState(() => _vehicleFilter = '🚚');
                      }, isDarkMode),
                      _buildFilterChip('🚛 รถห้องเย็น', _vehicleFilter == '🚛', () {
                        setModalState(() => _vehicleFilter = '🚛');
                      }, isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _vehicleFilter = 'all';
                            });
                            setState(() {
                              _vehicleFilter = 'all';
                              _selectedSubFilter = 0;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                            Navigator.pop(context);
                          },
                          child: Text('รีเซ็ตตัวกรอง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C7FF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text('นำไปใช้', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, bool isDarkMode) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C7FF6) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : const Color(0xFF4B5563)),
          ),
        ),
      ),
    );
  }

  void _reorderItem(_HistoryItemData item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'คัดลอกข้อมูลคำสั่งซื้อแล้ว กำลังนำท่านไปหน้าสร้างออเดอร์...',
                style: GoogleFonts.kanit(),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.push(AppRoutes.booking);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;

    // Subfilters only feature: ทั้งหมด, เสร็จสิ้น, ยกเลิก
    final subFilters = isEn
        ? ['All History', 'Completed', 'Cancelled']
        : ['ทั้งหมด', 'เสร็จสิ้น', 'ยกเลิก'];

    // Theme Colors
    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    // Filter Logic — ONLY Completed & Cancelled orders in history!
    List<_HistoryItemData> filteredList = _allHistoryItems;

    // Filter by Tab (0 = ทั้งหมด, 1 = เสร็จสิ้น, 2 = ยกเลิก)
    if (_selectedTab == 1) {
      filteredList = filteredList.where((item) => item.status == _HistoryStatus.completed).toList();
    } else if (_selectedTab == 2) {
      filteredList = filteredList.where((item) => item.status == _HistoryStatus.cancelled).toList();
    }

    // Filter by Subfilter chips (0 = ทั้งหมด, 1 = เสร็จสิ้น, 2 = ยกเลิก)
    if (_selectedSubFilter == 1) {
      filteredList = filteredList.where((item) => item.status == _HistoryStatus.completed).toList();
    } else if (_selectedSubFilter == 2) {
      filteredList = filteredList.where((item) => item.status == _HistoryStatus.cancelled).toList();
    }

    // Filter by Vehicle Type
    if (_vehicleFilter != 'all') {
      filteredList = filteredList.where((item) => item.vehicle == _vehicleFilter).toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredList = filteredList.where((item) {
        return item.orderNo.toLowerCase().contains(q) ||
            item.route.toLowerCase().contains(q) ||
            item.vehicleName.toLowerCase().contains(q) ||
            item.pickupAddress.toLowerCase().contains(q) ||
            item.destinationAddress.toLowerCase().contains(q);
      }).toList();
    }

    final int completedCount = _allHistoryItems.where((i) => i.status == _HistoryStatus.completed).length;
    final int cancelledCount = _allHistoryItems.where((i) => i.status == _HistoryStatus.cancelled).length;

    Widget contentBody = RefreshIndicator(
      onRefresh: () async {
        await _fetchRealOrders();
      },
      color: const Color(0xFF1C7FF6),
      child: Column(
        children: [
          // ==========================================
          // HEADER — Premium gradient with navigation
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
                              icon: Icon(
                                widget.onMenuPressed != null ? Icons.menu_rounded : Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                if (widget.onMenuPressed != null) {
                                  widget.onMenuPressed!();
                                } else if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.home);
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
                                    top: -1,
                                    right: -1,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
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
                  ],
                ),
              ),

              // Floating main tab card
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
                      _buildMainTabItem(0, isEn ? 'All History' : 'ประวัติทั้งหมด (${_allHistoryItems.length})', Icons.inventory_2_outlined, isDarkMode),
                      _buildMainTabItem(1, isEn ? 'Completed' : 'เสร็จสิ้น ($completedCount)', Icons.check_circle_outline_rounded, isDarkMode),
                      _buildMainTabItem(2, isEn ? 'Cancelled' : 'ยกเลิก ($cancelledCount)', Icons.cancel_outlined, isDarkMode),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 38),

          // NOTICE BANNER TO SWITCH TO IN-PROGRESS TRACKING PAGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: Color(0xFF1C7FF6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Looking for active deliveries?' : 'ติดตามพัสดุที่กำลังดำเนินการ?',
                          style: GoogleFonts.kanit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1C7FF6)),
                        ),
                        Text(
                          isEn ? 'View real-time progress on Tracking tab' : 'เช็คสถานะสดเรียลไทม์ได้ที่แท็บ "ติดตามพัสดุ"',
                          style: GoogleFonts.kanit(fontSize: 11, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C7FF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(isEn ? 'Go Track' : 'ไปติดตาม', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ==========================================
          // SEARCH INPUT BOX
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.kanit(fontSize: 13, color: primaryTextColor),
                decoration: InputDecoration(
                  hintText: isEn ? 'Search completed/cancelled order no., route...' : 'ค้นหาประวัติรหัสพัสดุ, เส้นทาง, หรือจุดส่ง...',
                  hintStyle: GoogleFonts.kanit(fontSize: 12.5, color: secondaryTextColor),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF1C7FF6)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // ==========================================
          // SUBFILTER CHIPS & FILTER BUTTON
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
                                color: isSelected
                                    ? const Color(0xFF1C7FF6)
                                    : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
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
                                  color: isSelected ? Colors.white : secondaryTextColor,
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
                InkWell(
                  onTap: () => _showFilterBottomSheet(isDarkMode, isEn),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _vehicleFilter != 'all' ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _vehicleFilter != 'all' ? const Color(0xFF1C7FF6) : dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          size: 16,
                          color: _vehicleFilter != 'all' ? Colors.white : secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isEn ? 'Filter' : 'ตัวกรอง',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: _vehicleFilter != 'all' ? FontWeight.bold : FontWeight.normal,
                            color: _vehicleFilter != 'all' ? Colors.white : secondaryTextColor,
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
          // ORDERS LIST (Completed & Cancelled only)
          // ==========================================
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState(isDarkMode, isEn, primaryTextColor)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryOrderCard(
                        filteredList[index],
                        isDarkMode,
                        isEn,
                        primaryTextColor,
                        secondaryTextColor,
                        dividerColor,
                        cardBgColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (widget.onMenuPressed == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: contentBody,
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: 1, // Highlighting 'ประวัติการส่ง'
          onTap: (index) {
            if (index == 0) {
              context.go(AppRoutes.home);
            } else if (index == 2) {
              context.go(AppRoutes.home);
            } else if (index == 3) {
              context.go(AppRoutes.chat);
            } else if (index == 4) {
              context.go(AppRoutes.profile);
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: contentBody,
    );
  }

  Widget _buildMainTabItem(int index, String label, IconData icon, bool isDarkMode) {
    final bool isActive = _selectedTab == index;
    const activeColor = Color(0xFF1C7FF6);
    final inactiveColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = index;
          _selectedSubFilter = index;
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
              Icon(icon, size: 15, color: isActive ? activeColor : inactiveColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.kanit(
                    fontSize: 11.5,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  overflow: TextOverflow.ellipsis,
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
    Color iconBg;
    String statusLabel;
    Color statusTextCol;
    Color statusBg;

    switch (item.status) {
      case _HistoryStatus.completed:
        sideColor = const Color(0xFF22C55E);
        iconBg = isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F8EE);
        statusLabel = isEn ? 'Completed' : 'เสร็จสิ้น';
        statusTextCol = const Color(0xFF16A34A);
        statusBg = isDarkMode ? const Color(0xFF14532D).withValues(alpha: 0.5) : const Color(0xFFE8F8EE);
        break;
      case _HistoryStatus.cancelled:
        sideColor = const Color(0xFFEF4444);
        iconBg = isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        statusLabel = isEn ? 'Cancelled' : 'ยกเลิก';
        statusTextCol = const Color(0xFFDC2626);
        statusBg = isDarkMode ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2);
        break;
      case _HistoryStatus.inProgress:
        sideColor = const Color(0xFF1C7FF6);
        iconBg = isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE8F2FE);
        statusLabel = isEn ? 'In Progress' : 'กำลังดำเนินการ';
        statusTextCol = const Color(0xFF1C7FF6);
        statusBg = isDarkMode ? const Color(0xFF1E3A5F) : const Color(0xFFE8F2FE);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('${AppRoutes.trackingDetail}/${item.orderNo}');
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Top Row: Vehicle, OrderNo, Status Badge
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(item.vehicle, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Order #${item.orderNo}' : 'เลขที่ : ${item.orderNo}',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.vehicleName} • ${item.dateTime}',
                            style: GoogleFonts.kanit(
                              fontSize: 11.5,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusTextCol,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: dividerColor, height: 1),
                const SizedBox(height: 10),

                // Middle Row: Route (Pickup > Dropoff) & Status Note
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: sideColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.route,
                        style: GoogleFonts.kanit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (item.statusText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.statusText,
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Bottom Row: Price & Reorder / View Detail Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: isEn ? 'Price: ' : 'ค่าขนส่ง: ',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                          TextSpan(
                            text: isEn ? '${item.price} THB' : '${item.price} บาท',
                            style: GoogleFonts.kanit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh_rounded, size: 13),
                          label: Text('สั่งอีกครั้ง', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 32),
                            side: const BorderSide(color: Color(0xFF1C7FF6)),
                            foregroundColor: const Color(0xFF1C7FF6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _reorderItem(item),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.receipt_long_rounded, size: 14, color: Colors.white),
                          label: Text(
                            isEn ? 'View Detail' : 'ดูรายละเอียด',
                            style: GoogleFonts.kanit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.status == _HistoryStatus.completed
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7280),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.push('${AppRoutes.trackingDetail}/${item.orderNo}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isEn, Color primaryTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
              child: const Icon(Icons.history_toggle_off_rounded, size: 40, color: Color(0xFF1C7FF6)),
            ),
            const SizedBox(height: 16),
            Text(
              isEn ? 'No history orders found' : 'ไม่พบประวัติการจัดส่ง',
              style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 6),
            Text(
              isEn ? 'Completed and cancelled orders will appear here' : 'รายการที่จัดส่งเสร็จสิ้นและยกเลิกจะแสดงในหน้านี้ครับ',
              style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('ล้างตัวกรองทั้งหมด', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C7FF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedSubFilter = 0;
                  _selectedTab = 0;
                  _vehicleFilter = 'all';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _HistoryStatus { inProgress, completed, cancelled }

class _HistoryItemData {
  final String orderNo;
  final String pickupAddress;
  final String destinationAddress;
  final String route;
  final String dateTime;
  final String price;
  final _HistoryStatus status;
  final String vehicle;
  final String vehicleName;
  final String statusText;
  final String driverName;
  final String driverPhone;

  _HistoryItemData({
    required this.orderNo,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.route,
    required this.dateTime,
    required this.price,
    required this.status,
    required this.vehicle,
    required this.vehicleName,
    required this.statusText,
    required this.driverName,
    required this.driverPhone,
  });
}