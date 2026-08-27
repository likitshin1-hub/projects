import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

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

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 2; // 2: เริ่มงาน / Main Rider Screen
  AdminOrderModel? _activeJob;

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
    setState(() {
      _activeJob = order.copyWith(
        status: AdminOrderStatus.accepted,
        driverName: 'คุณสมชาย สายบิด (ตัวคุณ)',
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 รับงานสำเร็จแล้ว! #${order.orderNo} มุ่งหน้าไปยังจุดรับสินค้า', style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _advanceJobStatus() {
    if (_activeJob == null) return;
    AdminOrderStatus nextStatus;
    String statusMsg;

    switch (_activeJob!.status) {
      case AdminOrderStatus.accepted:
        nextStatus = AdminOrderStatus.driverArriving;
        statusMsg = '🛵 ถึงจุดรับสินค้าแล้ว!';
        break;
      case AdminOrderStatus.driverArriving:
        nextStatus = AdminOrderStatus.pickedUp;
        statusMsg = '📦 ตรวจสอบและรับสินค้าขึ้นรถเรียบร้อย!';
        break;
      case AdminOrderStatus.pickedUp:
        nextStatus = AdminOrderStatus.inTransit;
        statusMsg = '🚚 กำลังเดินทางไปยังจุดส่งสินค้า!';
        break;
      case AdminOrderStatus.inTransit:
        nextStatus = AdminOrderStatus.completed;
        statusMsg = '✅ จัดส่งสำเร็จแล้ว! ได้รับค่าบริการ ฿${_activeJob!.amount.toStringAsFixed(2)}';
        break;
      default:
        nextStatus = AdminOrderStatus.completed;
        statusMsg = 'งานเสร็จสิ้น';
    }

    setState(() {
      if (nextStatus == AdminOrderStatus.completed) {
        _activeJob = null;
      } else {
        _activeJob = _activeJob!.copyWith(status: nextStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(statusMsg, style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF1C7FF6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmClockOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🔴 ยืนยันการออกงาน (Clock Out)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากระบบงานคนขับและสลับกลับเป็นผู้ใช้ทั่วไปหรือไม่?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ยกเลิก', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(driverShiftProvider.notifier).clockOut();
              ref.read(userActiveModeProvider.notifier).setMode(UserActiveMode.customer);
              context.go(AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('ยืนยันออกงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
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
      drawer: const DriverDrawer(),
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Top Header Bar (1:1 identical pattern to HomeHeader)
              DriverHeader(
                onMenuPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                onClockOutPressed: () => _confirmClockOut(context),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
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
      case 0:
        return _buildWalletTab(isDarkMode, bgBtnColor, textColor);
      case 1:
        return _buildHistoryTab(isDarkMode, bgBtnColor, textColor);
      case 3:
        return _buildChatTab(isDarkMode, bgBtnColor, textColor);
      case 4:
        return _buildProfileTab(user, isDarkMode, bgBtnColor, textColor);
      case 2:
      default:
        return _buildMainHomeTab(user, isDarkMode, bgBtnColor, textColor, ordersState, shiftStatus);
    }
  }

  Widget _buildWalletTab(bool isDarkMode, Color bgBtnColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F192C), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x4D1E3A8A), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('👛 กระเป๋าเงินคนขับ (Driver Wallet)', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                    child: Text('พร้อมถอนเงิน', style: GoogleFonts.kanit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('฿1,250.00', style: GoogleFonts.kanit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('💸 ส่งคำขอถอนเงินเข้าบัญชีเรียบร้อยแล้ว (รอโอนภายใน 15 นาที)', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF10B981)),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                      label: Text('ถอนเงินเข้าบัญชี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('📜 รายการธุรกรรมล่าสุด', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgBtnColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.add_task_rounded, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ค่าบริการคำสั่งซื้อ #TB-99824', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: textColor)),
                      Text('วันนี้ 11:30 น.', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Text('+฿450.00', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFF10B981), fontSize: 16)),
            ],
          ),
        ),
      ],
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
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: bgBtnColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              Text((user != null && user.name.isNotEmpty) ? user.name : 'คุณสมชาย สายบิด (พาร์ทเนอร์คนขับ)', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Text('ทะเบียน: 1กข-9988 • รถกระบะตู้ทึบ 4 ล้อ', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text('4.95 คะแนนประเมินจากลูกค้า', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _confirmClockOut(context),
          icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
          label: Text('🔴 ออกงาน (สลับเป็นผู้ใช้ทั่วไป)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    return const SizedBox.shrink();
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
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
                    color: Colors.white.withOpacity(0.85),
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
                SizedBox(
                  width: 240,
                  height: 240,
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
                                return Container(
                                  width: 110 + (progress * 120),
                                  height: 110 + (progress * 120),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (_isMatched
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF1C7FF6))
                                        .withOpacity((1.0 - progress) * 0.25),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isMatched
                                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                : [const Color(0xFF1C7FF6), const Color(0xFF0056C6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isMatched ? const Color(0xFF10B981) : const Color(0xFF1C7FF6)).withOpacity(0.4),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.two_wheeler_rounded,
                          color: Colors.white,
                          size: 40,
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
                            color: Color(0xFF1C7FF6),
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
                      border: Border.all(color: const Color(0xFF1C7FF6).withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1C7FF6).withOpacity(0.08),
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
                          widget.onTakeBreak();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('☕ พักงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
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
                        child: Text('✅ ตอบรับงานนี้', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15)),
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
    );
  }
}
