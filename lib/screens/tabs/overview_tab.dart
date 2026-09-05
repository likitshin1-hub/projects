import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class OverviewTab extends StatelessWidget {
  final AdminDataService dataService;
  final Function(int) onNavigateTab;

  const OverviewTab({
    super.key,
    required this.dataService,
    required this.onNavigateTab,
  });

  String _formatTodayDate() {
    try {
      return DateFormat('EEEE d MMMM yyyy', 'th').format(DateTime.now());
    } catch (_) {
      final now = DateTime.now();
      return '${now.day}/${now.month}/${now.year + 543}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFmt = NumberFormat("#,##0", "en_US");

    final pendingDrivers = dataService.drivers.where((d) => d.status == DriverVerificationStatus.pending).length;
    final onlineDrivers = dataService.drivers.where((d) => d.isOnline).length;
    final inTransitOrders = dataService.orders.where((o) => o.status == AdminOrderStatus.inTransit).length;
    final totalRevenueToday = 87450.0;
    final platformProfit = totalRevenueToday * (dataService.platformFeePercent / 100);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ศูนย์ควบคุมภาพรวมระบบ (Command Center)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'สรุปสถานะการปฏิบัติงาน รายได้แบบเรียลไทม์ และการแจ้งเตือนสำคัญ',
                    style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AdminTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      _formatTodayDate(),
                      style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pending Approvals Alert Banner
          if (pendingDrivers > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'แจ้งเตือน: มีไรเดอร์สมัครใหม่ $pendingDrivers คน รอการตรวจสอบเอกสารและอนุมัติ',
                          style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFB45309)),
                        ),
                        Text(
                          'กรุณาตรวจสอบบัตรประชาชน ใบขับขี่ และ พ.ร.บ. เพื่อให้ไรเดอร์เริ่มรับงานได้',
                          style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => onNavigateTab(2), // Go to Drivers tab
                    child: Text('ไปตรวจสอบทันที', style: GoogleFonts.kanit(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                children: [
                  _buildStatCard(
                    title: 'ยอดขายวันนี้ (Total Gross)',
                    value: '฿ ${currencyFmt.format(totalRevenueToday)}',
                    subtitle: 'กำไรแพลตฟอร์ม: ฿${currencyFmt.format(platformProfit)}',
                    icon: Icons.monetization_on_rounded,
                    color: AdminTheme.accentGreen,
                    trend: '+8.3%',
                    onTap: () => onNavigateTab(5), // Finance
                  ),
                  _buildStatCard(
                    title: 'ออเดอร์กำลังนำส่ง (Live Deliveries)',
                    value: '$inTransitOrders งาน',
                    subtitle: 'ทั้งหมดวันนี้: 1,284 รายการ',
                    icon: Icons.local_shipping_rounded,
                    color: AdminTheme.primaryBlue,
                    trend: 'กำลังวิ่ง',
                    onTap: () => onNavigateTab(3), // Orders
                  ),
                  _buildStatCard(
                    title: 'ไรเดอร์ออนไลน์ (Active Riders)',
                    value: '$onlineDrivers คน',
                    subtitle: 'พร้อมรับงานทั่วกรุงเทพฯ',
                    icon: Icons.two_wheeler_rounded,
                    color: AdminTheme.accentOrange,
                    trend: '94% พร้อม',
                    onTap: () => onNavigateTab(4), // Live Tracking
                  ),
                  _buildStatCard(
                    title: 'ลูกค้าทั้งหมด (Active Users)',
                    value: '${dataService.customers.length * 480}',
                    subtitle: 'VIP สมาชิกพิเศษ: ${dataService.customers.where((c) => c.isVip).length * 45} บัญชี',
                    icon: Icons.people_alt_rounded,
                    color: AdminTheme.accentPurple,
                    trend: '+14%',
                    onTap: () => onNavigateTab(1), // Customers
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Charts Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 16) * 0.65 : constraints.maxWidth,
                    child: _buildOrdersChartCard(isDark),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 16) * 0.35 : constraints.maxWidth,
                    child: _buildVehicleShareCard(isDark),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Live Activity & Recent Orders Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: AdminTheme.accentOrange),
                          const SizedBox(width: 8),
                          Text(
                            'รายการคำสั่งซื้อเรียลไทม์ล่าสุด (Live Orders Feed)',
                            style: GoogleFonts.kanit(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => onNavigateTab(3), // Go to Orders tab
                        icon: const Icon(Icons.list_alt_rounded, size: 16),
                        label: Text('ดูคำสั่งซื้อทั้งหมด (${dataService.orders.length})', style: GoogleFonts.kanit(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? const Color(0xFF1C7FF6).withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                      ),
                      columns: [
                        DataColumn(label: Text('เลขออเดอร์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ลูกค้า', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ไรเดอร์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ยานพาหนะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('พัสดุ / บริการ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ระยะทาง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ยอดชำระ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('สถานะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('การจัดการ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                      ],
                      rows: dataService.orders.map((order) {
                        return DataRow(
                          cells: [
                            DataCell(Text(order.orderNo, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue))),
                            DataCell(Text(order.customerName, style: GoogleFonts.kanit())),
                            DataCell(Text(order.driverName, style: GoogleFonts.kanit())),
                            DataCell(Text(order.vehicleType, style: GoogleFonts.kanit())),
                            DataCell(SizedBox(width: 120, child: Text(order.parcelType, style: GoogleFonts.kanit(fontSize: 12), overflow: TextOverflow.ellipsis))),
                            DataCell(Text('${order.distanceKm} กม.', style: GoogleFonts.kanit())),
                            DataCell(Text('฿ ${order.amount.toInt()}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                            DataCell(_buildStatusBadge(order.status)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AdminTheme.primaryBlue),
                                tooltip: 'ดูรายละเอียดออเดอร์',
                                onPressed: () => _showOrderModal(context, order),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value, style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                    Text(title, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(trend, style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersChartCard(bool isDark) {
    final days = ['30 ส.ค.', '31 ส.ค.', '1 ก.ย.', '2 ก.ย.', '3 ก.ย.', '4 ก.ย.', '5 ก.ย.'];
    final counts = [987, 1124, 1056, 1234, 1198, 1312, 1284];
    final maxCount = 1400;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('กราฟสถิติออเดอร์ 7 วันล่าสุด', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('เฉลี่ย 1,170 ออเดอร์/วัน', style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(days.length, (i) {
                  final heightRatio = counts[i] / maxCount;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${counts[i]}', style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Container(
                        width: 28,
                        height: 110 * heightRatio,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AdminTheme.primaryBlue, AdminTheme.darkBlue],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(days[i], style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleShareCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('สัดส่วนประเภทรถที่ใช้งาน', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            _buildVehicleBar('🛵 มอเตอร์ไซค์', 58, AdminTheme.primaryBlue),
            const SizedBox(height: 10),
            _buildVehicleBar('🚗 รถกระบะตู้ทึบ', 29, AdminTheme.accentGreen),
            const SizedBox(height: 10),
            _buildVehicleBar('🚛 รถบรรทุก 4 ล้อใหญ่', 9, AdminTheme.accentOrange),
            const SizedBox(height: 10),
            _buildVehicleBar('🚚 รถบรรทุก 6 ล้อ', 4, AdminTheme.accentPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleBar(String label, int percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.kanit(fontSize: 12)),
            Text('$percent%', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            color: color,
          ),
        ),
      ],
    );
  }

  void _showOrderModal(BuildContext context, AdminOrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AdminTheme.primaryBlue),
            const SizedBox(width: 8),
            Text('รายละเอียดคำสั่งซื้อ: ${order.orderNo}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ชื่อลูกค้า:', '${order.customerName} (${order.customerPhone})'),
            _buildDetailRow('ชื่อไรเดอร์:', '${order.driverName} (${order.driverPhone})'),
            _buildDetailRow('ประเภทรถ:', order.vehicleType),
            _buildDetailRow('ประเภทพัสดุ:', order.parcelType),
            _buildDetailRow('วิธีการชำระเงิน:', order.paymentMethod),
            _buildDetailRow('ระยะทางจัดส่ง:', '${order.distanceKm} กิโลเมตร'),
            _buildDetailRow('จุดรับ:', order.pickupAddress),
            _buildDetailRow('จุดส่ง:', order.dropoffAddress),
            _buildDetailRow('ยอดชำระเงิน:', '฿ ${order.amount.toInt()} บาท'),
            _buildDetailRow('สถานะปัจจุบัน:', order.status.thaiLabel),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ปิด', style: GoogleFonts.kanit()),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🖨️ พิมพ์ใบเสร็จคำสั่งซื้อ ${order.orderNo} เรียบร้อย')));
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: Text('พิมพ์ใบส่งของ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: GoogleFonts.kanit(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: GoogleFonts.kanit(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AdminOrderStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case AdminOrderStatus.completed:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        break;
      case AdminOrderStatus.inTransit:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        break;
      case AdminOrderStatus.accepted:
        bg = const Color(0xFFF5F3FF);
        fg = const Color(0xFF6D28D9);
        break;
      case AdminOrderStatus.cancelled:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        break;
      default:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status.thaiLabel, style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
