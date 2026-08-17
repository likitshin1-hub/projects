import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class AdminOrdersTab extends ConsumerStatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  ConsumerState<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends ConsumerState<AdminOrdersTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cancelReasonController = TextEditingController();

  String _statusFilter = 'All'; // All, Pending, Accepted, Driver Arriving, Picked Up, In Transit, Completed, Cancelled
  String _dateFilter = 'All'; // All, Today, This Week, This Month
  String _vehicleFilter = 'All'; // All, Motorcycle, Car, Van, Truck
  String _driverFilter = 'All'; // All, Assigned, Unassigned

  @override
  void dispose() {
    _searchController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  void _showCancelOrderDialog(AdminOrderModel order) {
    _cancelReasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('❌ ยกเลิกคำสั่งซื้อ #${order.orderNo}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),
                Text('ระบุเหตุผลในการยกเลิกคำสั่งซื้อ (บังคับ):', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1), fontSize: 13)),
                const SizedBox(height: 10),
                TextField(
                  controller: _cancelReasonController,
                  maxLines: 3,
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'เช่น ไม่พบผู้ให้บริการในพื้นที่ / ลูกค้าขอยกเลิกผ่าน Call Center',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final reason = _cancelReasonController.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาระบุเหตุผลในการยกเลิกคำสั่งซื้อ', style: GoogleFonts.kanit()), backgroundColor: Colors.orange));
                          return;
                        }
                        await ref.read(adminOrdersProvider.notifier).updateStatus(
                          order.orderNo,
                          AdminOrderStatus.cancelled,
                          reason: reason,
                          cancelledBy: 'Super Admin',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ยกเลิกคำสั่งซื้อ #${order.orderNo} เรียบร้อยแล้ว', style: GoogleFonts.kanit()), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      child: Text('ยืนยันยกเลิก Order', style: GoogleFonts.kanit()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderDetailModal(AdminOrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag_rounded, color: Color(0xFF1C7FF6), size: 24),
                          const SizedBox(width: 10),
                          Text('รายละเอียดคำสั่งซื้อ #${order.orderNo}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(color: Color(0xFF334155)),
                  const SizedBox(height: 12),

                  // Lifecycle Stepper Visualiser
                  _buildStepper(order.status),
                  const SizedBox(height: 20),

                  // Customer & Driver Information Cards Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('👤 ลูกค้า (Customer)', style: GoogleFonts.kanit(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(order.customerName, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('📞 ${order.customerPhone}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🛵 คนขับ/ไรเดอร์ (Driver)', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(order.driverName.isEmpty ? 'ยังไม่มีคนขับรับงาน' : order.driverName, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(order.driverPhone.isNotEmpty ? '📞 ${order.driverPhone}' : 'ยานพาหนะ: ${order.vehicleType}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Route Addresses Cards
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.greenAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('จุดรับสินค้า (Pickup): ${order.pickupAddress}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13))),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.more_vert, color: Color(0xFF64748B), size: 16)),
                        Row(
                          children: [
                            const Icon(Icons.flag, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('จุดส่งสินค้า (Destination): ${order.dropoffAddress}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pricing & Commission Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ประเภทรถ: ${order.vehicleType}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                          Text('เวลาสร้าง Order: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute}', style: GoogleFonts.kanit(color: const Color(0xFF64748B), fontSize: 11)),
                        ],
                      ),
                      Text('ค่าบริการรวม: ฿${order.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Customer Cancellation Policy Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: order.status.canCustomerCancel
                          ? Colors.green.shade900.withValues(alpha: 0.25)
                          : Colors.orange.shade900.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: order.status.canCustomerCancel ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          order.status.canCustomerCancel ? Icons.check_circle_outline : Icons.shield_outlined,
                          color: order.status.canCustomerCancel ? Colors.greenAccent : Colors.orangeAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order.status.canCustomerCancel
                                ? 'สถานะ ${order.status.name.toUpperCase()}: ลูกค้าสามารถกดยกเลิกผ่านแอปได้เอง'
                                : 'สถานะ ${order.status.name.toUpperCase()}: รับของแล้ว/กำลังส่ง (ลูกค้าไม่สามารถยกเลิกเองได้ - ต้องให้ Admin จัดการ)',
                            style: GoogleFonts.kanit(
                              color: order.status.canCustomerCancel ? Colors.greenAccent : Colors.orangeAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (order.status == AdminOrderStatus.cancelled) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.red.shade900.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade700)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('❌ รายละเอียดการยกเลิก (Cancelled Order Info)', style: GoogleFonts.kanit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('ยกเลิกโดย: ${order.cancelledBy ?? "Admin/System"}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 12)),
                          Text('เหตุผล: ${order.cancellationReason ?? "ไม่ระบุเหตุผล"}', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Admin Action Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (order.status != AdminOrderStatus.completed && order.status != AdminOrderStatus.cancelled)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showCancelOrderDialog(order);
                          },
                          icon: const Icon(Icons.cancel, size: 18),
                          label: Text('ยกเลิก Order นี้ (Cancel Order)', style: GoogleFonts.kanit()),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      Row(
                        children: [
                          if (order.status != AdminOrderStatus.completed && order.status != AdminOrderStatus.cancelled) ...[
                            ElevatedButton.icon(
                              onPressed: () async {
                                final next = _getNextStatus(order.status);
                                await ref.read(adminOrdersProvider.notifier).updateStatus(order.orderNo, next);
                                if (context.mounted) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text('ปรับสถานะขั้นต่อไป (${_getNextStatus(order.status).name.toUpperCase()})', style: GoogleFonts.kanit()),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AdminOrderStatus _getNextStatus(AdminOrderStatus current) {
    switch (current) {
      case AdminOrderStatus.pending:
        return AdminOrderStatus.accepted;
      case AdminOrderStatus.accepted:
        return AdminOrderStatus.driverArriving;
      case AdminOrderStatus.driverArriving:
        return AdminOrderStatus.pickedUp;
      case AdminOrderStatus.pickedUp:
        return AdminOrderStatus.inTransit;
      case AdminOrderStatus.inTransit:
        return AdminOrderStatus.completed;
      default:
        return AdminOrderStatus.completed;
    }
  }

  Widget _buildStepper(AdminOrderStatus currentStatus) {
    final steps = [
      AdminOrderStatus.pending,
      AdminOrderStatus.accepted,
      AdminOrderStatus.driverArriving,
      AdminOrderStatus.pickedUp,
      AdminOrderStatus.inTransit,
      AdminOrderStatus.completed,
    ];

    final isCancelled = currentStatus == AdminOrderStatus.cancelled;
    final currentIdx = isCancelled ? -1 : steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📍 Order Lifecycle Stepper สถานะการจัดส่ง:', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 10),
          if (isCancelled)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.red.shade900.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                child: Text('❌ CANCELLED (ยกเลิกแล้ว)', style: GoogleFonts.kanit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(steps.length, (index) {
                final isDone = index <= currentIdx;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isDone ? const Color(0xFF10B981) : const Color(0xFF334155),
                      child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[index].name.toUpperCase(), style: GoogleFonts.kanit(fontSize: 9, color: isDone ? Colors.white : const Color(0xFF64748B), fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(adminOrdersProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Toolbar Row (Search + 4 Filter Dropdowns)
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: '🔍 Search Order ID / Customer / Driver / Address',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Status Filter Dropdown
              _buildDropdown(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Status: ทั้งหมด')),
                  DropdownMenuItem(value: 'PENDING', child: Text('PENDING (รอรับงาน)')),
                  DropdownMenuItem(value: 'ACCEPTED', child: Text('ACCEPTED (รับงานแล้ว)')),
                  DropdownMenuItem(value: 'DRIVER_ARRIVING', child: Text('ARRIVING (ไรเดอร์กำลังไป)')),
                  DropdownMenuItem(value: 'PICKED_UP', child: Text('PICKED_UP (รับสินค้าแล้ว)')),
                  DropdownMenuItem(value: 'IN_TRANSIT', child: Text('IN_TRANSIT (กำลังจัดส่ง)')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED (สำเร็จ)')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED (ยกเลิก)')),
                ],
                onChanged: (val) => setState(() => _statusFilter = val!),
              ),
              const SizedBox(width: 10),

              // Date Filter Dropdown
              _buildDropdown(
                value: _dateFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Date: ทั้งหมด')),
                  DropdownMenuItem(value: 'Today', child: Text('วันนี้ (Today)')),
                  DropdownMenuItem(value: 'ThisWeek', child: Text('สัปดาห์นี้')),
                  DropdownMenuItem(value: 'ThisMonth', child: Text('เดือนนี้')),
                ],
                onChanged: (val) => setState(() => _dateFilter = val!),
              ),
              const SizedBox(width: 10),

              // Vehicle Filter Dropdown
              _buildDropdown(
                value: _vehicleFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Vehicle: ทั้งหมด')),
                  DropdownMenuItem(value: 'Motorcycle', child: Text('มอเตอร์ไซค์')),
                  DropdownMenuItem(value: 'Car', child: Text('รถเก๋ง/4 ประตู')),
                  DropdownMenuItem(value: 'Van', child: Text('รถตู้')),
                  DropdownMenuItem(value: 'Truck', child: Text('รถกระบะ')),
                ],
                onChanged: (val) => setState(() => _vehicleFilter = val!),
              ),
              const SizedBox(width: 10),

              // Driver Filter Dropdown
              _buildDropdown(
                value: _driverFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Driver: ทั้งหมด')),
                  DropdownMenuItem(value: 'Assigned', child: Text('มีคนขับรับงานแล้ว')),
                  DropdownMenuItem(value: 'Unassigned', child: Text('ยังไม่มีคนขับ')),
                ],
                onChanged: (val) => setState(() => _driverFilter = val!),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Orders DataTable
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
              child: ordersState.when(
                data: (list) {
                  final query = _searchController.text.toLowerCase();
                  var filtered = list.where((o) {
                    final matchQuery = o.orderNo.toLowerCase().contains(query) ||
                        o.customerName.toLowerCase().contains(query) ||
                        o.driverName.toLowerCase().contains(query) ||
                        o.pickupAddress.toLowerCase().contains(query) ||
                        o.dropoffAddress.toLowerCase().contains(query);

                    bool matchStatus = _statusFilter == 'All' || o.status.name.toUpperCase() == _statusFilter.toUpperCase();
                    bool matchDriver = true;
                    if (_driverFilter == 'Assigned') matchDriver = o.driverName.isNotEmpty;
                    if (_driverFilter == 'Unassigned') matchDriver = o.driverName.isEmpty;

                    bool matchVehicle = true;
                    if (_vehicleFilter != 'All') {
                      matchVehicle = o.vehicleType.toLowerCase().contains(_vehicleFilter.toLowerCase());
                    }

                    return matchQuery && matchStatus && matchDriver && matchVehicle;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text('ไม่พบข้อมูลคำสั่งซื้อที่ตรงตามเงื่อนไข', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))));
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                      columns: [
                        DataColumn(label: Text('Order ID', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Customer', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Driver', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Vehicle', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Pickup', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Destination', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Price', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Created At', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      ],
                      rows: filtered.map((o) {
                        final dt = o.createdAt;
                        final createdStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                        return DataRow(cells: [
                          DataCell(Text(o.orderNo, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text(o.customerName, style: GoogleFonts.kanit(color: Colors.white))),
                          DataCell(Text(o.driverName.isEmpty ? 'ยังไม่มีคนขับ' : o.driverName, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(Text(o.vehicleType, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: Text(o.pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))))),
                          DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: Text(o.dropoffAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))))),
                          DataCell(Text('฿${o.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold))),
                          DataCell(_buildStatusBadge(o.status)),
                          DataCell(Text(createdStr, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF3B82F6)),
                              onPressed: () => _showOrderDetailModal(o),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('เกิดข้อผิดพลาดในการโหลดคำสั่งซื้อ', style: GoogleFonts.kanit(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1E293B),
          style: GoogleFonts.kanit(color: Colors.white, fontSize: 13),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AdminOrderStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case AdminOrderStatus.pending:
        bg = Colors.amber.shade900.withValues(alpha: 0.3);
        fg = Colors.amberAccent;
        break;
      case AdminOrderStatus.accepted:
        bg = Colors.blue.shade900.withValues(alpha: 0.3);
        fg = Colors.blueAccent;
        break;
      case AdminOrderStatus.driverArriving:
        bg = Colors.cyan.shade900.withValues(alpha: 0.3);
        fg = Colors.cyanAccent;
        break;
      case AdminOrderStatus.pickedUp:
        bg = Colors.indigo.shade900.withValues(alpha: 0.3);
        fg = Colors.indigoAccent;
        break;
      case AdminOrderStatus.inTransit:
        bg = Colors.purple.shade900.withValues(alpha: 0.3);
        fg = Colors.purpleAccent;
        break;
      case AdminOrderStatus.completed:
        bg = Colors.green.shade900.withValues(alpha: 0.3);
        fg = Colors.greenAccent;
        break;
      case AdminOrderStatus.cancelled:
        bg = Colors.red.shade900.withValues(alpha: 0.3);
        fg = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.name.toUpperCase(), style: GoogleFonts.kanit(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
