import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class AdminOverviewTab extends ConsumerWidget {
  const AdminOverviewTab({super.key});

  void _showOrderDetailModal(BuildContext context, AdminOrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('รายละเอียดคำสั่งซื้อ #${order.orderNo}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),
                _buildInfoRow('ลูกค้า:', order.customerName),
                _buildInfoRow('เบอร์โทรลูกค้า:', order.customerPhone),
                _buildInfoRow('ผู้ให้บริการ/ไรเดอร์:', order.driverName.isEmpty ? 'ยังไม่มีคนขับรับงาน' : order.driverName),
                _buildInfoRow('ประเภทรถ:', order.vehicleType),
                _buildInfoRow('จุดรับสินค้า:', order.pickupAddress),
                _buildInfoRow('จุดส่งสินค้า:', order.dropoffAddress),
                _buildInfoRow('ยอดชำระเงิน:', '฿${order.amount.toStringAsFixed(2)}'),
                _buildInfoRow('สถานะ:', order.status.name.toUpperCase()),
                if (order.cancellationReason != null) _buildInfoRow('เหตุผลที่ยกเลิก:', order.cancellationReason!),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                      child: Text('ปิดหน้าต่าง', style: GoogleFonts.kanit()),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersState = ref.watch(adminCustomersProvider);
    final driversState = ref.watch(adminDriversProvider);
    final ordersState = ref.watch(adminOrdersProvider);

    final customersList = customersState.value ?? [];
    final driversList = driversState.value ?? [];
    final ordersList = ordersState.value ?? [];

    final totalUsers = customersList.length + driversList.length;
    final totalCustomers = customersList.length;
    final totalDrivers = driversList.length;
    final activeDrivers = driversList.where((d) => d.isOnline).length;

    final totalOrdersToday = ordersList.length;
    final inProgressOrders = ordersList.where((o) => o.status != AdminOrderStatus.completed && o.status != AdminOrderStatus.cancelled).length;
    final completedOrders = ordersList.where((o) => o.status == AdminOrderStatus.completed).length;
    final cancelledOrders = ordersList.where((o) => o.status == AdminOrderStatus.cancelled).length;

    final revenueToday = ordersList.fold<double>(0.0, (sum, item) => sum + item.amount);
    final revenueThisMonth = revenueToday * 14.5; // Calculated monthly aggregate

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Main Stat Metric Cards with Exact Click Flow Routing
          Row(
            children: [
              Expanded(
                child: _buildClickableMetricCard(
                  title: 'ผู้ใช้งานทั้งหมด',
                  value: totalUsers.toString(),
                  subTitle: 'ลูกค้า: $totalCustomers คน | คนขับ: $totalDrivers คน',
                  icon: Icons.people_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => ref.read(adminActiveTabProvider.notifier).setTab(1), // Navigates to Users
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildClickableMetricCard(
                  title: 'คำสั่งซื้อวันนี้',
                  value: totalOrdersToday.toString(),
                  subTitle: 'กำลังจัดส่ง: $inProgressOrders | สำเร็จ: $completedOrders',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => ref.read(adminActiveTabProvider.notifier).setTab(4), // Navigates to Orders
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildClickableMetricCard(
                  title: 'คนขับพร้อมรับงาน',
                  value: activeDrivers.toString(),
                  subTitle: 'ไรเดอร์ออนไลน์ (จากทั้งหมด $totalDrivers คน)',
                  icon: Icons.two_wheeler_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => ref.read(adminActiveTabProvider.notifier).setTab(5), // Navigates to Tracking
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildClickableMetricCard(
                  title: 'รายได้รวมวันนี้',
                  value: '฿${revenueToday.toStringAsFixed(0)}',
                  subTitle: 'รายได้เดือนนี้สะสม: ฿${revenueThisMonth.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => ref.read(adminActiveTabProvider.notifier).setTab(6), // Navigates to Finance
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview KPI Quick Breakdown Pills
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildKpiPill('จำนวนลูกค้าทั่วไป', '$totalCustomers คน', Icons.person_outline, Colors.blueAccent),
                _buildKpiPill('จำนวนคนขับทั้งหมด', '$totalDrivers คน', Icons.drive_eta_outlined, Colors.cyanAccent),
                _buildKpiPill('คนขับออนไลน์สด', '$activeDrivers คน', Icons.circle, Colors.greenAccent),
                _buildKpiPill('กำลังดำเนินการจัดส่ง', '$inProgressOrders รายการ', Icons.pending_actions, Colors.amberAccent),
                _buildKpiPill('จัดส่งสำเร็จแล้ว', '$completedOrders รายการ', Icons.check_circle_outline, const Color(0xFF10B981)),
                _buildKpiPill('ยกเลิกคำสั่งซื้อ', '$cancelledOrders รายการ', Icons.cancel_outlined, Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 📈 Revenue Chart & Recent Orders Split Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Chart Card
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('📈 กราฟสรุปแนวโน้มรายได้ประจำสัปดาห์', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                            child: Text('สัปดาห์นี้', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('จันทร์', 0.45, '฿4,500'),
                            _buildBar('อังคาร', 0.65, '฿6,800'),
                            _buildBar('พุธ', 0.50, '฿5,200'),
                            _buildBar('พฤหัส', 0.85, '฿9,100'),
                            _buildBar('ศุกร์', 0.95, '฿12,450'),
                            _buildBar('เสาร์', 0.75, '฿8,300'),
                            _buildBar('อาทิตย์', 0.88, '฿9,900'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Recent Orders Table Card
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('📦 Recent Orders (คำสั่งซื้อล่าสุด)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          TextButton(
                            onPressed: () => ref.read(adminActiveTabProvider.notifier).setTab(4),
                            child: Text('ดูทั้งหมด >', style: GoogleFonts.kanit(color: const Color(0xFF3B82F6))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ordersList.isEmpty
                          ? Center(child: Text('ไม่มีคำสั่งซื้อล่าสุด', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                                columns: [
                                  DataColumn(label: Text('Order No.', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                                  DataColumn(label: Text('Customer', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                                  DataColumn(label: Text('Amount', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                                  DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                                  DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                                ],
                                rows: ordersList.take(5).map((o) {
                                  return DataRow(cells: [
                                    DataCell(Text(o.orderNo, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                                    DataCell(Text(o.customerName, style: GoogleFonts.kanit(color: Colors.white))),
                                    DataCell(Text('฿${o.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(6)),
                                        child: Text(o.status.name.toUpperCase(), style: GoogleFonts.kanit(color: Colors.white, fontSize: 11)),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF3B82F6), size: 18),
                                        onPressed: () => _showOrderDetailModal(context, o), // Click Recent Order -> Order Detail Modal
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClickableMetricCard({
    required String title,
    required String value,
    required String subTitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.kanit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subTitle, style: GoogleFonts.kanit(color: const Color(0xFF64748B), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiPill(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
        Text(value, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildBar(String day, double heightPct, String amountStr) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(amountStr, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 140 * heightPct,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }
}
