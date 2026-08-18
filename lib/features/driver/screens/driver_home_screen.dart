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

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _isOnline = true;
  String _activeTab = 'jobs'; // 'jobs', 'earnings', 'profile'
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final ordersState = ref.watch(adminOrdersProvider);

    final bgBtnColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF1C7FF6),
        elevation: 0,
        leading: const Icon(Icons.two_wheeler_rounded, color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TBMoveHub Driver Panel', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('คนขับ/ผู้ให้บริการขนส่ง', style: GoogleFonts.kanit(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          // Switch back to Customer Mode
          TextButton.icon(
            onPressed: () {
              ref.read(userActiveModeProvider.notifier).setMode(UserActiveMode.customer);
              context.go(AppRoutes.home);
            },
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
            label: Text('สลับเป็นลูกค้า', style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Switch Banner (Online / Offline Toggle)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _isOnline
                    ? (isDarkMode ? Colors.green.shade900.withValues(alpha: 0.4) : const Color(0xFFECFDF5))
                    : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
                border: Border(bottom: BorderSide(color: _isOnline ? Colors.green.shade400 : Colors.grey.shade400)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOnline ? Colors.greenAccent : Colors.grey,
                          boxShadow: [
                            if (_isOnline)
                              BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? '🟢 ออนไลน์ (พร้อมรับงาน)' : '⚪ ออฟไลน์ (ปิดรับงาน)',
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isOnline ? (isDarkMode ? Colors.greenAccent : const Color(0xFF065F46)) : textColor,
                            ),
                          ),
                          Text(
                            _isOnline ? 'พร้อมรับคำสั่งซื้อใกล้เคียงตลอดเวลา' : 'เลื่อนเพื่อเปิดระบบรับงาน',
                            style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isOnline,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() => _isOnline = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? '🟢 เปิดสถานะพร้อมรับงานแล้ว' : '⚪ ปิดสถานะรับงานแล้ว', style: GoogleFonts.kanit()),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
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

                  if (!_isOnline) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(color: bgBtnColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          const Icon(Icons.power_settings_new_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('คุณกำลังออฟไลน์อยู่', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          Text('สไลด์ปุ่มเปิดระบบออนไลน์ด้านบนเพื่อเริ่มรับงานขนส่ง', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
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
