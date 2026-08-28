import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_role_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../../admin/models/admin_models.dart';
import '../providers/driver_shift_provider.dart';
import '../../../shared/widgets/driver_drawer.dart';
import '../../../shared/widgets/driver_header.dart';
import '../../../shared/widgets/driver_bottom_navigation.dart';
import '../../home/widgets/location_selector.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0; // 0: หน้าหลัก / Main Rider Screen
  String _selectedLocation = 'ชลบุรี';
  String _selectedWalletFilter = 'ทั้งหมด';
  final Set<int> _expandedWalletItems = {};

  void _openOrderMatchingSheet(BuildContext context) {
    ref.read(driverShiftProvider.notifier).resumeWork();

    final orders = ref.read(adminOrdersProvider).value ?? [];
    final pendingOrders = orders.where((o) => o.status == AdminOrderStatus.pending).toList();

    final matchedOrder = pendingOrders.isNotEmpty
        ? pendingOrders.first
        : AdminOrderModel(
            orderNo: 'TB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            customerName: 'คุณณิชาภัทร (ผู้ใช้ใกล้คุณ)',
            customerPhone: '081-998-7766',
            driverName: 'ยังไม่มีคนขับ',
            driverPhone: '-',
            vehicleType: 'รถกระบะทึบ 4 ล้อ',
            pickupAddress: 'อาคารสาทรซิตี้ทาวเวอร์ ถนนสาทรใต้ กรุงเทพฯ (1.2 กม.)',
            dropoffAddress: 'คอนโดแอชตัน อโศก ถนนสุขุมวิท 21 กรุงเทพฯ',
            amount: 450.00,
            status: AdminOrderStatus.pending,
            pickupLat: 13.722,
            pickupLng: 100.530,
            dropoffLat: 13.738,
            dropoffLng: 100.560,
            currentDriverLat: 13.725,
            currentDriverLng: 100.533,
            createdAt: DateTime.now(),
          );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DriverOrderMatchingModal(
        order: matchedOrder,
        onAccept: (order) {
          _acceptJob(order);
        },
        onTakeBreak: () {
          ref.read(driverShiftProvider.notifier).takeBreak();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('☕ สลับสถานะเป็น "พักงานชั่วคราว"', style: GoogleFonts.kanit()),
              backgroundColor: const Color(0xFFF59E0B),
            ),
          );
        },
      ),
    );
  }

  void _acceptJob(AdminOrderModel order) {
    // Sync order status update with backend Riverpod provider
    ref.read(adminOrdersProvider.notifier).updateStatus(order.orderNo, AdminOrderStatus.accepted);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 รับงานสำเร็จแล้ว! #${order.orderNo} มุ่งหน้าไปยังจุดรับสินค้า', style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push(AppRoutes.jobDetail, extra: order);
  }

  void _showWithdrawModal(BuildContext context, bool isDarkMode) {
    final amountController = TextEditingController(text: '1250');
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payments_rounded, color: Color(0xFF3B82F6), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ถอนเงินรายได้เข้าบัญชีธนาคาร',
                        style: GoogleFonts.kanit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'โอนเข้าบัญชีที่ผูกไว้อัตโนมัติใน 15 นาที',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bank Account Details Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A950),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'K+',
                          style: GoogleFonts.kanit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ธนาคารกสิกรไทย (KBANK)',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'เลขที่บัญชี: xxx-x-x1234-x (คุณสมชาย)',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'ระบุจำนวนเงินที่ต้องการถอน (บาท)',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
                decoration: InputDecoration(
                  prefixText: '฿ ',
                  prefixStyle: GoogleFonts.kanit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '🎉 ยื่นคำขอถอนเงิน ฿${amountController.text} เรียบร้อยแล้ว! เงินจะเข้าบัญชีใน 15 นาที',
                          style: GoogleFonts.kanit(),
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  label: Text(
                    'ยืนยันส่งคำขอถอนเงิน',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final ordersState = ref.watch(adminOrdersProvider);
    final shiftStatus = ref.watch(driverShiftProvider);

    final bgBtnColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Scaffold(
      key: _scaffoldKey,
      drawer: DriverDrawer(
        onSelectTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onSelectWallet: () {
          setState(() {
            _currentIndex = 5;
          });
        },
      ),
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar: Full DriverHeader + LocationSelector for Main Home Tab (0 & 2), Compact SubHeader for Other Tabs
              if (_currentIndex == 0 || _currentIndex == 2) ...[
                DriverHeader(
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LocationSelector(
                      initialLocation: _selectedLocation,
                      onLocationChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),
                  ),
                ),
              ] else ...[
                _buildSubHeader(context, _currentIndex),
                const SizedBox(height: 20),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildTabBody(_currentIndex, user, isDarkMode, bgBtnColor, textColor, ordersState, shiftStatus),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DriverBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            _openOrderMatchingSheet(context);
          }
        },
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context, int index) {
    String title = '';
    switch (index) {
      case 1:
        title = 'ประวัติการจัดส่ง';
        break;
      case 3:
        title = 'แชท';
        break;
      case 4:
        title = 'โปรไฟล์';
        break;
      case 5:
        title = 'กระเป๋าเงิน';
        break;
      default:
        title = 'พาร์ทเนอร์ไรเดอร์';
    }

    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.kanit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔔 คุณมีการแจ้งเตือนใหม่ 3 รายการ', style: GoogleFonts.kanit()),
                      backgroundColor: const Color(0xFF1E3A8A),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '3',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(
    int index,
    dynamic user,
    bool isDarkMode,
    Color bgBtnColor,
    Color textColor,
    AsyncValue<List<AdminOrderModel>> ordersState,
    DriverShiftStatus shiftStatus,
  ) {
    switch (index) {
      case 1:
        return _buildHistoryTab(isDarkMode, bgBtnColor, textColor);
      case 3:
        return _buildChatTab(isDarkMode, bgBtnColor, textColor);
      case 4:
        return _buildProfileTab(user, isDarkMode, bgBtnColor, textColor);
      case 5:
        return _buildWalletTab(isDarkMode, bgBtnColor, textColor);
      case 0:
      case 2:
      default:
        return _buildMainHomeTab(user, isDarkMode, bgBtnColor, textColor, ordersState, shiftStatus);
    }
  }

  Widget _buildWalletTab(bool isDarkMode, Color bgBtnColor, Color textColor) {
    final mockTransactions = [
      _WalletTxItem(
        'เงินเข้า-งาน#3558',
        '18 พ.ค. 69',
        '10:06 น.',
        '+153',
        true,
        orderNo: '#TB-3558',
        pickup: 'ฟิวเจอร์พาร์ครังสิต ธัญบุรี ปทุมธานี',
        dropoff: 'แจ้งวัฒนะ ปากเกร็ด นนทบุรี',
        vehicle: 'รถเก๋ง 4 ประตู (14.2 กม.)',
        note: 'งานจัดส่งพัสดุด่วนสำเร็จเรียบร้อย',
      ),
      _WalletTxItem(
        'เงินเข้า-งาน#3558',
        '17 พ.ค. 69',
        '17:26 น.',
        '+232',
        true,
        orderNo: '#TB-3558',
        pickup: 'เซ็นทรัล ลาดพร้าว จตุจักร กรุงเทพฯ',
        dropoff: 'เดอะมอลล์ งามวงศ์วาน นนทบุรี',
        vehicle: 'รถกระบะตู้ทึบ 4 ล้อ (18.5 กม.)',
        note: 'งานจัดส่งย้ายของย้ายหอพักสำเร็จเรียบร้อย',
      ),
      _WalletTxItem(
        'เงินเข้า-งาน#3558',
        '17 พ.ค. 69',
        '16:48 น.',
        '+198',
        true,
        orderNo: '#TB-3558',
        pickup: 'สยามพารากอน ปทุมวัน กรุงเทพฯ',
        dropoff: 'บางนา ตราด กม.4 สมุทรปราการ',
        vehicle: 'รถจักรยานยนต์ส่งด่วน (12.0 กม.)',
        note: 'งานจัดส่งพัสดุเอกสารด่วนสำเร็จเรียบร้อย',
      ),
      _WalletTxItem(
        'ถอนเงินเข้าบัญชีธนาคาร',
        '16 พ.ค. 69',
        '20:56 น.',
        '-15,000',
        false,
        orderNo: '#WD-99201',
        pickup: 'ธนาคารกสิกรไทย (KBANK)',
        dropoff: 'เลขที่บัญชี: xxx-x-x1234-x (คุณสมชาย)',
        vehicle: 'ระบบโอนเงินอัตโนมัติ (15 นาที)',
        note: 'ถอนเงินรายได้สะสมเข้าบัญชีธนาคารเรียบร้อยแล้ว',
      ),
      _WalletTxItem(
        'เงินเข้า-งาน#3557',
        '16 พ.ค. 69',
        '14:15 น.',
        '+310',
        true,
        orderNo: '#TB-3557',
        pickup: 'พระราม 9 ซอย 7 กรุงเทพฯ',
        dropoff: 'ห้วยขวาง รัชดาภิเษก กรุงเทพฯ',
        vehicle: 'รถกระบะตู้ทึบ 4 ล้อ (9.8 กม.)',
        note: 'งานจัดส่งเฟอร์นิเจอร์สำเร็จเรียบร้อย',
      ),
      _WalletTxItem(
        'เงินเข้า-งาน#3556',
        '15 พ.ค. 69',
        '11:20 น.',
        '+245',
        true,
        orderNo: '#TB-3556',
        pickup: 'เมกาบางนา บางพลี สมุทรปราการ',
        dropoff: 'สนามบินสุวรรณภูมิ สมุทรปราการ',
        vehicle: 'รถเก๋ง 4 ประตู (16.4 กม.)',
        note: 'งานจัดส่งกระเป๋าเดินทางสำเร็จเรียบร้อย',
      ),
    ];

    final filteredList = mockTransactions.where((t) {
      if (_selectedWalletFilter == 'เงินเข้า') return t.isIncome;
      if (_selectedWalletFilter == 'เงินออก') return !t.isIncome;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // 1. TOP BLUE BALANCE CARD (1:1 with reference screenshot)
        // ======================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ยอดเงินคงเหลือ',
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '฿ 3,280',
                style: GoogleFonts.kanit(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'สามารถถอนเงินได้',
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showWithdrawModal(context, isDarkMode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'ถอนเงิน',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // 2. CATEGORY FILTER CHIPS (ทั้งหมด / เงินเข้า / เงินออก)
        // ======================================================
        Row(
          children: [
            _buildWalletFilterChip('ทั้งหมด'),
            const SizedBox(width: 10),
            _buildWalletFilterChip('เงินเข้า'),
            const SizedBox(width: 10),
            _buildWalletFilterChip('เงินออก'),
          ],
        ),

        const SizedBox(height: 16),

        // ======================================================
        // 3. EXPANDABLE TRANSACTION HISTORY LIST
        // ======================================================
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = filteredList[index];
            final bool isExpanded = _expandedWalletItems.contains(index);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedWalletItems.remove(index);
                  } else {
                    _expandedWalletItems.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgBtnColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded
                        ? const Color(0xFF1E3A8A)
                        : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isExpanded ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                      blurRadius: isExpanded ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Main Header Row (1:1 with collapsed screenshot)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Side: Title & Expand Indicator
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                color: isExpanded ? const Color(0xFF1E3A8A) : Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        // Right Side: Date/Time + Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.date}\n${item.time}',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                color: Colors.grey,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.amount,
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: item.isIncome
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // EXPANDED DETAILS SECTION (Shown when tapped)
                    if (isExpanded) ...[
                      const Divider(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '📋 รายละเอียดรายการ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: item.isIncome
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: item.isIncome
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Text(
                                    item.isIncome ? 'งานสำเร็จ' : 'ถอนสำเร็จ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: item.isIncome
                                          ? const Color(0xFF047857)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow('รหัสออร์เดอร์ / รายการ:', item.orderNo, isDarkMode),
                            _buildDetailRow(
                              item.isIncome ? '📍 จุดรับสินค้า:' : '🏦 ธนาคารปลายทาง:',
                              item.pickup,
                              isDarkMode,
                            ),
                            _buildDetailRow(
                              item.isIncome ? '🏁 จุดส่งสินค้า:' : '👤 บัญชีปลายทาง:',
                              item.dropoff,
                              isDarkMode,
                            ),
                            _buildDetailRow(
                              item.isIncome ? '🚗 พาหนะและระยะทาง:' : '⚡ ช่องทางโอน:',
                              item.vehicle,
                              isDarkMode,
                            ),
                            _buildDetailRow('📝 หมายเหตุ:', item.note, isDarkMode),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.kanit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletFilterChip(String label) {
    final isSelected = _selectedWalletFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWalletFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E3A8A),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDarkMode, Color bgBtnColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📜 ประวัติการรับส่งพัสดุของคุณ', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        Text('รายการจัดส่งสินค้าที่เสร็จสิ้นสมบูรณ์แล้ว', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: bgBtnColor, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('คำสั่งซื้อ #TB-88410', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: textColor, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('✅ สำเร็จแล้ว', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('📍 จุดรับ: พระราม 9 ซอย 7', style: GoogleFonts.kanit(fontSize: 13, color: textColor)),
              Text('🏁 จุดส่ง: ห้วยขวาง รัชดาภิเษก', style: GoogleFonts.kanit(fontSize: 13, color: textColor)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('26 ส.ค. 2026 • 15:40 น.', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                  Text('฿380.00', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatTab(bool isDarkMode, Color bgBtnColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('💬 ข้อความสนทนากับลูกค้า', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        Text('แชตติดต่อสอบถามตำแหน่งจุดรับส่งสินค้า', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgBtnColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('คุณณิชาภัทร (ลูกค้า #TB-99824)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: textColor)),
                    Text('ช่วยยกของขึ้นชั้น 2 ให้ด้วยนะคะ', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text('11:32 น.', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(dynamic user, bool isDarkMode, Color bgBtnColor, Color textColor) {
    final String driverName = (user?.name?.toString().isNotEmpty == true)
        ? user!.name.toString()
        : 'ชินจังสุดเฟี้ยว เลี้ยวลงบ่อ';
    final String driverPhone = (user?.phone?.toString().isNotEmpty == true)
        ? user!.phone.toString()
        : '085-368-1345';
    final String driverEmail = (user?.email?.toString().isNotEmpty == true)
        ? user!.email.toString()
        : 'likirtsjdgfc@gmail.com';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // TOP PROFILE AVATAR & INFO SECTION (Matching Screen 1)
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF3B82F6), width: 2.5),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: GestureDetector(
                        onTap: () => _showEditPersonalInfoModal(context, isDarkMode, driverName, driverPhone, driverEmail),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  driverName,
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  driverPhone,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  driverEmail,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // MAIN MENU CARD CONTAINER (Matching Screen 1 1:1)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgBtnColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileMenuItem(
                  icon: Icons.person_rounded,
                  title: 'ข้อมูลส่วนตัว',
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  onTap: () => _showEditPersonalInfoModal(context, isDarkMode, driverName, driverPhone, driverEmail),
                ),
                Divider(height: 1, indent: 56, endIndent: 16, color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                _buildProfileMenuItem(
                  icon: Icons.description_outlined,
                  title: 'เอกสารของฉัน',
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  onTap: () => _showMyDocumentsModal(context, isDarkMode),
                ),
                Divider(height: 1, indent: 56, endIndent: 16, color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                _buildProfileMenuItem(
                  icon: Icons.directions_car_filled_rounded,
                  title: 'ข้อมูลรถ',
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  onTap: () => _showVehicleInfoModal(context, isDarkMode),
                ),
                Divider(height: 1, indent: 56, endIndent: 16, color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                _buildProfileMenuItem(
                  icon: Icons.verified_user_outlined,
                  title: 'เปลี่ยนรหัสผ่าน',
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  onTap: () => _showChangePasswordModal(context, isDarkMode),
                ),
                Divider(height: 1, indent: 56, endIndent: 16, color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                _buildProfileMenuItem(
                  icon: Icons.power_settings_new_rounded,
                  title: 'ออกจากระบบงานไรเดอร์ (Clock Out)',
                  isDarkMode: isDarkMode,
                  textColor: const Color(0xFFEF4444),
                  onTap: () => _showClockOutConfirmDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showClockOutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ยืนยันการออกงาน',
                    style: GoogleFonts.kanit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '(Clock Out)',
              style: GoogleFonts.kanit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณต้องการออกจากระบบงานคนขับและสลับกลับเป็นผู้ใช้ทั่วไปหรือไม่?',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  'ยกเลิก',
                  style: GoogleFonts.kanit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(driverShiftProvider.notifier).clockOut();
                  ref.read(userActiveModeProvider.notifier).setMode(UserActiveMode.customer);
                  Navigator.of(dialogCtx).pop();
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  'ยืนยันออกงาน',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // SCREEN 2: ข้อมูลส่วนตัว (EDIT PERSONAL INFO MODAL)
  void _showEditPersonalInfoModal(
    BuildContext context,
    bool isDarkMode,
    String currentName,
    String currentPhone,
    String currentEmail,
  ) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final emailController = TextEditingController(text: currentEmail);
    final dobController = TextEditingController(text: '15/08/2538');

    String selectedGender = 'ชาย';

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.90),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Avatar Image Picker Circle
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF3B82F6), width: 2.5),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.photo_library_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 1. ชื่อ-นามสกุล
                  Text(
                    'ชื่อ-นามสกุล',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.kanit(fontSize: 14, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'กรอกชื่อ-นามสกุลของคุณ',
                      hintStyle: GoogleFonts.kanit(color: Colors.grey),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. เบอร์โทรศัพท์
                  Text(
                    'เบอร์โทรศัพท์',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.kanit(fontSize: 14, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'กรอกเบอร์โทรศัพท์ของคุณ',
                      hintStyle: GoogleFonts.kanit(color: Colors.grey),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. อีเมล
                  Text(
                    'อีเมล',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.kanit(fontSize: 14, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'กรอกอีเมลของคุณ',
                      hintStyle: GoogleFonts.kanit(color: Colors.grey),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. วันเกิด
                  Text(
                    'วันเกิด',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1995, 8, 15),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setModalState(() {
                          dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year + 543}';
                        });
                      }
                    },
                    style: GoogleFonts.kanit(fontSize: 14, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'กรอกวันเกิดของคุณ',
                      hintStyle: GoogleFonts.kanit(color: Colors.grey),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. เพศ (Segmented Selector: ชาย / หญิง / ไม่ระบุ)
                  Text(
                    'เพศ',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['ชาย', 'หญิง', 'ไม่ระบุ'].map((gender) {
                      final isSelected = selectedGender == gender;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedGender = gender;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : (isDarkMode ? const Color(0xFF0F172A) : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  gender,
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 6. ปุ่มบันทึกข้อมูล
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('🎉 บันทึกข้อมูลส่วนตัวเรียบร้อยแล้ว!', style: GoogleFonts.kanit()),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'บันทึกข้อมูล',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMyDocumentsModal(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'เอกสารของฉัน',
              style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            _buildDocItem('🪪 ใบอนุญาตขับขี่ (Driving License)', 'ตรวจสอบแล้ว • ตลอดชีพ', true, isDarkMode),
            const SizedBox(height: 10),
            _buildDocItem('🚗 สำเนารายการจดทะเบียนรถ', 'ตรวจสอบแล้ว • 1กข-9988', true, isDarkMode),
            const SizedBox(height: 10),
            _buildDocItem('🆔 บัตรประชาชน (National ID)', 'ตรวจสอบแล้ว • สมบูรณ์', true, isDarkMode),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDocItem(String title, String subtitle, bool isVerified, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                Text(subtitle, style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Text('อนุมัติแล้ว', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF047857))),
          ),
        ],
      ),
    );
  }

  void _showVehicleInfoModal(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ข้อมูลรถที่ใช้รับงาน',
              style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            _buildVehicleRow('ประเภทรถ', 'รถกระบะตู้ทึบ 4 ล้อ', isDarkMode),
            _buildVehicleRow('หมายเลขทะเบียน', '1กข-9988 กรุงเทพมหานคร', isDarkMode),
            _buildVehicleRow('ยี่ห้อ / รุ่น', 'Toyota Hilux Revo', isDarkMode),
            _buildVehicleRow('สีรถ', 'สีขาว', isDarkMode),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey)),
          Text(value, style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'เปลี่ยนรหัสผ่าน',
                style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'รหัสผ่านปัจจุบัน',
                  labelStyle: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'รหัสผ่านใหม่',
                  labelStyle: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่านใหม่',
                  labelStyle: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('🎉 อัปเดตรหัสผ่านใหม่เรียบร้อยแล้ว!', style: GoogleFonts.kanit()),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('อัปเดตรหัสผ่าน', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // DRIVER REVIEWS MODAL ("คะแนนของฉัน" - Matching Image 1 1:1)
  void _showDriverReviewsModal(BuildContext context, bool isDarkMode) {
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.90),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'คะแนนของฉัน',
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 1. OVERALL RATINGS BREAKDOWN CARD (Matching Image 1 1:1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'รีวิวทั้งหมด',
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Left side: Rating Bars (5, 4, 3, 2, 1)
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildRatingBarRow('5', 1.0, isDarkMode),
                                  const SizedBox(height: 4),
                                  _buildRatingBarRow('4', 0.0, isDarkMode),
                                  const SizedBox(height: 4),
                                  _buildRatingBarRow('3', 0.0, isDarkMode),
                                  const SizedBox(height: 4),
                                  _buildRatingBarRow('2', 0.0, isDarkMode),
                                  const SizedBox(height: 4),
                                  _buildRatingBarRow('1', 0.0, isDarkMode),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Right side: Score 5 & Stars
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '5',
                                    style: GoogleFonts.kanit(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (index) => const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFC107),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '(1)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: Colors.grey,
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

                  const SizedBox(height: 24),

                  // 2. RECENT REVIEWS SECTION ("ล่าสุด")
                  Text(
                    'ล่าสุด',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // REVIEW ITEM CARD (Matching Image 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Row
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6528F7),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  'N',
                                  style: GoogleFonts.kanit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'นายชินจัง สุดหล่อ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'สาธารณะ • แก้ไขเมื่อ 9 ก.ย. 2025',
                                    style: GoogleFonts.kanit(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.more_vert_rounded,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Stars Row
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC107),
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Review Text
                        Text(
                          'ส่งไว คนขับสุภาพมากครับ',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF1E293B),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Reply TextField
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: replyController,
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'ตอบกลับ...',
                              hintStyle: GoogleFonts.kanit(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send_rounded, size: 18, color: Color(0xFF2563EB)),
                                onPressed: () {
                                  if (replyController.text.trim().isNotEmpty) {
                                    final messenger = ScaffoldMessenger.of(context);
                                    replyController.clear();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('🎉 ตอบกลับรีวิวเรียบร้อยแล้ว!', style: GoogleFonts.kanit()),
                                        backgroundColor: const Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Date Text
                        Text(
                          'เผยแพร่เมื่อ 10 Sep 2025',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: Colors.grey,
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
      ),
    );
  }

  Widget _buildRatingBarRow(String starLabel, double percentage, bool isDarkMode) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            starLabel,
            style: GoogleFonts.kanit(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainHomeTab(
    dynamic user,
    bool isDarkMode,
    Color bgBtnColor,
    Color textColor,
    AsyncValue<List<AdminOrderModel>> ordersState,
    DriverShiftStatus shiftStatus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // 1. TOP BLUE WALLET BALANCE CARD (ยอดเงินคงเหลือ)
        // ======================================================
        GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = 5;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ยอดเงินคงเหลือ',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showWithdrawModal(context, isDarkMode),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '฿ 3,280',
                  style: GoogleFonts.kanit(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ส่งสำเร็จแล้ว 112 งาน',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ======================================================
        // 2. BOTTOM STATS ROW (จำนวนงานวันนี้ & คะแนนรีวิว)
        // ======================================================
        Row(
          children: [
            // Left Card: จำนวนงานวันนี้
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgBtnColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'จำนวนงานวันนี้',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '1',
                          style: GoogleFonts.kanit(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'งาน',
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Right Card: คะแนนรีวิว
            Expanded(
              child: GestureDetector(
                onTap: () => _showDriverReviewsModal(context, isDarkMode),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgBtnColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'คะแนนรีวิว',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '5',
                            style: GoogleFonts.kanit(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFC107),
                                size: 24,
                              ),
                              Text(
                                'จาก 1 รีวิว',
                                style: GoogleFonts.kanit(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  height: 1.1,
                                ),
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
          ],
        ),
      ],
    );
  }
}

class _DriverOrderMatchingModal extends StatefulWidget {
  final AdminOrderModel order;
  final ValueChanged<AdminOrderModel> onAccept;
  final VoidCallback onTakeBreak;

  const _DriverOrderMatchingModal({
    required this.order,
    required this.onAccept,
    required this.onTakeBreak,
  });

  @override
  State<_DriverOrderMatchingModal> createState() => _DriverOrderMatchingModalState();
}

class _DriverOrderMatchingModalState extends State<_DriverOrderMatchingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  Timer? _countdownTimer;
  int _secondsLeft = 3;
  bool _isMatched = false;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _isMatched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 1:1 TOP BLUE HEADER BAR (Matching screenshot)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
              child: Column(
                children: [
                  Text(
                    _isMatched ? 'พบคำสั่งซื้อของลูกค้าใกล้คุณ!' : 'กำลังค้นหาออร์เดอร์ลูกค้า...',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'หมายเลขคำสั่งซื้อ #${widget.order.orderNo}',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 1:1 CONCENTRIC RADAR PULSE RIPPLE ANIMATION (Matching screenshot)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isMatched ? 160 : 200,
                    height: _isMatched ? 160 : 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RepaintBoundary(
                          child: Stack(
                            alignment: Alignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _radarController,
                                builder: (context, child) {
                                  final progress = (_radarController.value + (index * 0.33)) % 1.0;
                                  final maxRipple = _isMatched ? 90.0 : 110.0;
                                  return Container(
                                    width: (progress * maxRipple) + 70,
                                    height: (progress * maxRipple) + 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (_isMatched
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF1E3A8A))
                                          .withValues(alpha: (1.0 - progress) * 0.25),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isMatched ? 64 : 80,
                          height: _isMatched ? 64 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isMatched
                                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                  : [const Color(0xFF1E3A8A), const Color(0xFF1D4ED8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isMatched ? const Color(0xFF10B981) : const Color(0xFF1E3A8A)).withValues(alpha: 0.4),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.two_wheeler_rounded,
                            color: Colors.white,
                            size: _isMatched ? 32 : 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // 1:1 BOTTOM STATUS PILL BADGE (Matching screenshot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isMatched) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        _isMatched
                            ? '🎯 จับคู่ออร์เดอร์เรียลไทม์สำเร็จ! (ห่าง 1.2 กม.)'
                            : 'กำลังกระจายงานให้ไรเดอร์ในพื้นที่ ($_secondsLeft วินาที)...',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isMatched ? const Color(0xFF059669) : const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // MATCHED CUSTOMER ORDER DETAILS CARD
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isMatched ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox(height: 10),
                  secondChild: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'คำสั่งซื้อ #${widget.order.orderNo}',
                                style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '฿${widget.order.amount.toStringAsFixed(2)}',
                              style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text('👤 ลูกค้า: ${widget.order.customerName} (${widget.order.customerPhone})',
                            style: GoogleFonts.kanit(color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('🚚 รถ: ${widget.order.vehicleType}', style: GoogleFonts.kanit(color: Colors.grey.shade700, fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('จุดรับ: ${widget.order.pickupAddress}',
                                  style: GoogleFonts.kanit(color: const Color(0xFF0F172A), fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.flag, color: Colors.red, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('จุดส่ง: ${widget.order.dropoffAddress}',
                                  style: GoogleFonts.kanit(color: const Color(0xFF0F172A), fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('ยกเลิก', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isMatched
                            ? () {
                                Navigator.pop(context);
                                widget.onAccept(widget.order);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('รับงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _WalletTxItem {
  final String title;
  final String date;
  final String time;
  final String amount;
  final bool isIncome;
  final String orderNo;
  final String pickup;
  final String dropoff;
  final String vehicle;
  final String note;

  const _WalletTxItem(
    this.title,
    this.date,
    this.time,
    this.amount,
    this.isIncome, {
    this.orderNo = '#TB-3558',
    this.pickup = 'ฟิวเจอร์พาร์ครังสิต ธัญบุรี ปทุมธานี',
    this.dropoff = 'แจ้งวัฒนะ ปากเกร็ด นนทบุรี',
    this.vehicle = 'รถเก๋ง 4 ประตู (14.2 กม.)',
    this.note = 'โอนเงินเข้ากระเป๋าเงินไรเดอร์สำเร็จเรียบร้อย',
  });
}
