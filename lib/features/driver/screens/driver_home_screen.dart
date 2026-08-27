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

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _activeTab = 'jobs'; // 'jobs', 'earnings', 'profile'
  AdminOrderModel? _activeJob;

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
              Navigator.pop(ctx);
              ref.read(driverShiftProvider.notifier).clockOut();
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

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DriverDrawer(),
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Driver Top Header Bar (Matching HomeHeader pattern)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF047857),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33047857),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TBMoveHub Driver Panel',
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'คนขับ/ผู้ให้บริการขนส่ง',
                          style: GoogleFonts.kanit(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _confirmClockOut(context),
                    icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 16),
                    label: Text('ออกงาน', style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            // Driver Shift Status Manager Banner (🟢 เข้างาน | ☕ พักงาน | 🔴 ออกงาน)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: shiftStatus == DriverShiftStatus.working
                    ? (isDarkMode ? Colors.green.shade900.withValues(alpha: 0.35) : const Color(0xFFECFDF5))
                    : shiftStatus == DriverShiftStatus.breakTime
                        ? (isDarkMode ? Colors.amber.shade900.withValues(alpha: 0.35) : const Color(0xFFFFFBEB))
                        : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
                border: Border(
                  bottom: BorderSide(
                    color: shiftStatus == DriverShiftStatus.working
                        ? Colors.green.shade400
                        : shiftStatus == DriverShiftStatus.breakTime
                            ? Colors.amber.shade400
                            : Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: shiftStatus == DriverShiftStatus.working
                                  ? Colors.greenAccent
                                  : shiftStatus == DriverShiftStatus.breakTime
                                      ? Colors.amberAccent
                                      : Colors.redAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: (shiftStatus == DriverShiftStatus.working
                                          ? Colors.greenAccent
                                          : shiftStatus == DriverShiftStatus.breakTime
                                              ? Colors.amberAccent
                                              : Colors.redAccent)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shiftStatus == DriverShiftStatus.working
                                    ? '🟢 เข้างาน (พร้อมรับงาน)'
                                    : shiftStatus == DriverShiftStatus.breakTime
                                        ? '☕ พักงาน (หยุดรับงานชั่วคราว)'
                                        : '🔴 ออกงาน (หยุดการทำงานแล้ว)',
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: shiftStatus == DriverShiftStatus.working
                                      ? (isDarkMode ? Colors.greenAccent : const Color(0xFF065F46))
                                      : shiftStatus == DriverShiftStatus.breakTime
                                          ? (isDarkMode ? Colors.amberAccent : const Color(0xFF92400E))
                                          : textColor,
                                ),
                              ),
                              Text(
                                shiftStatus == DriverShiftStatus.working
                                    ? 'พร้อมรับคำสั่งซื้อใกล้เคียงตลอดเวลา'
                                    : shiftStatus == DriverShiftStatus.breakTime
                                        ? 'ระบบระงับการส่งงานให้อัตโนมัติ'
                                        : 'กดเข้างานเพื่อเริ่มรับส่งพัสดุ',
                                style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3-State Shift Segment Control Bar
                  Row(
                    children: [
                      // 1. เข้างาน (Working)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(driverShiftProvider.notifier).resumeWork();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🟢 สลับสถานะเป็น "เข้างานพร้อมรับงาน"', style: GoogleFonts.kanit()),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: shiftStatus == DriverShiftStatus.working
                                  ? const Color(0xFF10B981)
                                  : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '🟢 เข้างาน',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: shiftStatus == DriverShiftStatus.working ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. พักงาน (Break)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(driverShiftProvider.notifier).takeBreak();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('☕ สลับสถานะเป็น "พักงานชั่วคราว"', style: GoogleFonts.kanit()),
                                backgroundColor: const Color(0xFFF59E0B),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: shiftStatus == DriverShiftStatus.breakTime
                                  ? const Color(0xFFF59E0B)
                                  : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '☕ พักงาน',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: shiftStatus == DriverShiftStatus.breakTime ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 3. ออกงาน (Clock Out)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _confirmClockOut(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                            ),
                            child: Center(
                              child: Text(
                                '🔴 ออกงาน',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Info & Today's Earnings Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: bgBtnColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF1C7FF6),
                          child: Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name.isNotEmpty == true ? user!.name : 'คุณสมชาย สายบิด (คนขับอนุมัติแล้ว)',
                                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('4.95 (148 รีวิว) • ทะเบียน 1กข-9988', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('รายได้วันนี้', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                            Text('฿1,250.00', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Active Delivery Progress Bar (If Driver has accepted a job)
                  if (_activeJob != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1C7FF6), width: 2),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF1C7FF6).withValues(alpha: 0.3), blurRadius: 12),
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
                                decoration: BoxDecoration(color: const Color(0xFF1C7FF6), borderRadius: BorderRadius.circular(8)),
                                child: Text('🚚 งานที่คุณกำลังจัดส่งอยู่ออนไลน์', style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              Text('฿${_activeJob!.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('คำสั่งซื้อ #${_activeJob!.orderNo}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('ลูกค้า: ${_activeJob!.customerName} (${_activeJob!.customerPhone})', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.greenAccent, size: 18),
                              const SizedBox(width: 6),
                              Expanded(child: Text('รับสินค้า: ${_activeJob!.pickupAddress}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.flag_rounded, color: Colors.amberAccent, size: 18),
                              const SizedBox(width: 6),
                              Expanded(child: Text('จุดส่งสินค้า: ${_activeJob!.dropoffAddress}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _advanceJobStatus,
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              label: Text(
                                _activeJob!.status == AdminOrderStatus.accepted
                                    ? '🛵 ถึงจุดรับสินค้าแล้ว'
                                    : _activeJob!.status == AdminOrderStatus.driverArriving
                                        ? '📦 รับสินค้าขึ้นรถเรียบร้อย'
                                        : _activeJob!.status == AdminOrderStatus.pickedUp
                                            ? '🚚 เริ่มต้นออกเดินทางส่งสินค้า'
                                            : '✅ ปิดงาน - จัดส่งสินค้าเรียบร้อย',
                                style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C7FF6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Available Incoming Order Requests Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📦 งานที่รอคนขับรับงาน (Order Available)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                      Text('อัปเดตเรียลไทม์', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (shiftStatus == DriverShiftStatus.breakTime) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.coffee_rounded, size: 48, color: Color(0xFFF59E0B)),
                          const SizedBox(height: 12),
                          Text('คุณกำลังอยู่ในช่วง "พักงาน"', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          Text('ระบบระงับการจ่ายงานให้อัตโนมัติ เพื่อให้คุณพักผ่อนอย่างเต็มที่', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(driverShiftProvider.notifier).resumeWork();
                            },
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                            label: Text('▶️ สิ้นสุดการพัก & พร้อมรับงานต่อ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ordersState.when(
                      data: (orders) {
                        final pendingOrders = orders.where((o) => o.status == AdminOrderStatus.pending).toList();

                        if (pendingOrders.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(color: bgBtnColor, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                const Icon(Icons.inbox_rounded, size: 48, color: Color(0xFF10B981)),
                                const SizedBox(height: 12),
                                Text('ยังไม่มีคำสั่งซื้อใหม่ในขณะนี้', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                Text('ระบบกำลังค้นหาคำสั่งซื้อในรัศมีของคุณ...', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final order = pendingOrders[index];
                            return Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: bgBtnColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.local_shipping, color: Color(0xFF10B981), size: 18),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('#${order.orderNo}', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                        ],
                                      ),
                                      Text('฿${order.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Text('ลูกค้า: ${order.customerName}', style: GoogleFonts.kanit(fontSize: 13, color: textColor, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.green),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text('จุดรับ: ${order.pickupAddress}', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.flag_outlined, size: 16, color: Colors.red),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text('จุดส่ง: ${order.dropoffAddress}', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _acceptJob(order),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF10B981),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: Text('✅ รับงานนี้', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
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
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Text('เกิดข้อผิดพลาดในการโหลดงาน', style: GoogleFonts.kanit(color: Colors.red)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
