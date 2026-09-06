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
                    child: const ModernOrdersChartCard(),
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


// =============================================================
// MODERN BEAUTIFUL & CLEAN ANALYTICS CHART COMPONENT
// =============================================================
class ModernOrdersChartCard extends StatefulWidget {
  const ModernOrdersChartCard({super.key});

  @override
  State<ModernOrdersChartCard> createState() => _ModernOrdersChartCardState();
}

class _ModernOrdersChartCardState extends State<ModernOrdersChartCard> {
  String _chartType = 'spline'; // 'spline' or 'bar'
  String _timeframe = '7D'; // '7D', '30D', 'Today'
  int? _hoveredIndex = 5; // Default highlight Friday 4 ก.ย.

  final List<Map<String, dynamic>> _data7D = [
    {'label': '30 ส.ค.', 'fullDate': 'เสาร์ 30 ส.ค.', 'orders': 987, 'revenue': '฿88,830', 'growth': '+4.2%'},
    {'label': '31 ส.ค.', 'fullDate': 'อาทิตย์ 31 ส.ค.', 'orders': 1124, 'revenue': '฿101,160', 'growth': '+13.8%'},
    {'label': '1 ก.ย.', 'fullDate': 'จันทร์ 1 ก.ย.', 'orders': 1056, 'revenue': '฿95,040', 'growth': '-6.0%'},
    {'label': '2 ก.ย.', 'fullDate': 'อังคาร 2 ก.ย.', 'orders': 1234, 'revenue': '฿111,060', 'growth': '+16.8%'},
    {'label': '3 ก.ย.', 'fullDate': 'พุธ 3 ก.ย.', 'orders': 1198, 'revenue': '฿107,820', 'growth': '-2.9%'},
    {'label': '4 ก.ย.', 'fullDate': 'พฤหัสบดี 4 ก.ย.', 'orders': 1312, 'revenue': '฿118,080', 'growth': '+9.5%'},
    {'label': '5 ก.ย.', 'fullDate': 'ศุกร์ 5 ก.ย.', 'orders': 1284, 'revenue': '฿115,560', 'growth': '-2.1%'},
  ];

  final List<Map<String, dynamic>> _dataToday = [
    {'label': '08:00', 'fullDate': '08:00 - 10:00', 'orders': 180, 'revenue': '฿16,200', 'growth': '+12%'},
    {'label': '10:00', 'fullDate': '10:00 - 12:00', 'orders': 310, 'revenue': '฿27,900', 'growth': '+72%'},
    {'label': '12:00', 'fullDate': '12:00 - 14:00', 'orders': 420, 'revenue': '฿37,800', 'growth': '+35%'},
    {'label': '14:00', 'fullDate': '14:00 - 16:00', 'orders': 295, 'revenue': '฿26,550', 'growth': '-29%'},
    {'label': '16:00', 'fullDate': '16:00 - 18:00', 'orders': 380, 'revenue': '฿34,200', 'growth': '+28%'},
    {'label': '18:00', 'fullDate': '18:00 - 20:00', 'orders': 450, 'revenue': '฿40,500', 'growth': '+18%'},
    {'label': '20:00', 'fullDate': '20:00 - 22:00', 'orders': 210, 'revenue': '฿18,900', 'growth': '-53%'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentData = _timeframe == 'Today' ? _dataToday : _data7D;
    final maxOrder = currentData.map((e) => e['orders'] as int).reduce((a, b) => a > b ? a : b);
    final totalOrders = currentData.fold<int>(0, (sum, item) => sum + (item['orders'] as int));
    final avgOrders = (totalOrders / currentData.length).round();

    final activePoint = (_hoveredIndex != null && _hoveredIndex! < currentData.length)
        ? currentData[_hoveredIndex!]
        : currentData.last;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Title & Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AdminTheme.primaryBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.analytics_rounded, size: 20, color: AdminTheme.primaryBlue),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'สถิติคำสั่งซื้อและการเติบโต (Order Analytics)',
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AdminTheme.accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.trending_up_rounded, size: 14, color: AdminTheme.accentGreen),
                              const SizedBox(width: 4),
                              Text('+12.4% WoW', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ยอดรวม $totalOrders ออเดอร์ • เฉลี่ย $avgOrders ออเดอร์/วัน • สำเร็จ 99.1%',
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                // Switchers: Type & Timeframe
                Row(
                  children: [
                    // Timeframe pills
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          _buildTimePill('7D', '7 วัน'),
                          _buildTimePill('Today', 'วันนี้ (รายชม.)'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Chart type toggle
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _chartType = 'spline'),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _chartType == 'spline' ? AdminTheme.primaryBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.show_chart_rounded, size: 16, color: _chartType == 'spline' ? Colors.white : Colors.grey),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _chartType = 'bar'),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _chartType == 'bar' ? AdminTheme.primaryBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.bar_chart_rounded, size: 16, color: _chartType == 'bar' ? Colors.white : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Active Point Info Callout Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: AdminTheme.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        activePoint['fullDate'],
                        style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('ยอดออเดอร์: ', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${activePoint['orders']} รายการ',
                        style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Text('ยอดจัดส่ง: ', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                      Text(
                        activePoint['revenue'],
                        style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: (activePoint['growth'] as String).startsWith('+') ? AdminTheme.accentGreen.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activePoint['growth'],
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: (activePoint['growth'] as String).startsWith('+') ? AdminTheme.accentGreen : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Canvas & Chart Body
            SizedBox(
              height: 190,
              child: _chartType == 'spline'
                  ? _buildSplineChartView(currentData, maxOrder, isDark)
                  : _buildBarChartView(currentData, maxOrder, isDark),
            ),

            const SizedBox(height: 8),

            // X-Axis Labels Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(currentData.length, (idx) {
                final isHovered = _hoveredIndex == idx;
                return InkWell(
                  onTap: () => setState(() => _hoveredIndex = idx),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHovered ? AdminTheme.primaryBlue.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentData[idx]['label'],
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                        color: isHovered ? AdminTheme.primaryBlue : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePill(String key, String label) {
    final isSelected = _timeframe == key;
    return InkWell(
      onTap: () => setState(() {
        _timeframe = key;
        _hoveredIndex = 0;
      }),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 1. Spline Area Chart with CustomPainter
  Widget _buildSplineChartView(List<Map<String, dynamic>> data, int maxVal, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ModernSplineAreaPainter(
            data: data,
            maxVal: (maxVal * 1.15).toInt(),
            hoveredIndex: _hoveredIndex,
            isDark: isDark,
          ),
        );
      },
    );
  }

  // 2. Modern Rounded Capsule Bar Chart
  Widget _buildBarChartView(List<Map<String, dynamic>> data, int maxVal, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ceiling = (maxVal * 1.15);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(data.length, (i) {
            final val = data[i]['orders'] as int;
            final heightFactor = val / ceiling;
            final isHovered = _hoveredIndex == i;

            return InkWell(
              onTap: () => setState(() => _hoveredIndex = i),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$val',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                        color: isHovered ? AdminTheme.primaryBlue : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 34,
                      height: 140 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isHovered
                              ? [const Color(0xFF06B6D4), const Color(0xFF2563EB)]
                              : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: AdminTheme.primaryBlue.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// CUSTOM PAINTER FOR SMOOTH SPLINE AREA CHART
// -------------------------------------------------------------
class _ModernSplineAreaPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final int maxVal;
  final int? hoveredIndex;
  final bool isDark;

  _ModernSplineAreaPainter({
    required this.data,
    required this.maxVal,
    required this.hoveredIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double bottomPadding = 10;
    final double chartHeight = height - bottomPadding;

    // 1. Draw subtle horizontal grid lines (0%, 25%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155).withValues(alpha: 0.4) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // 2. Compute point coordinates
    final points = <Offset>[];
    final stepX = width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final val = data[i]['orders'] as int;
      final ratio = val / maxVal;
      final x = i * stepX;
      final y = chartHeight - (ratio * chartHeight);
      points.add(Offset(x, y));
    }

    // 3. Build Smooth Bezier Spline Path
    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }

    // Close area fill path to bottom
    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.lineTo(points.first.dx, chartHeight);
    fillPath.close();

    // 4. Draw Area Gradient Fill
    final areaGradient = LinearGradient(
      colors: [
        const Color(0xFF3B82F6).withValues(alpha: 0.35),
        const Color(0xFF06B6D4).withValues(alpha: 0.12),
        const Color(0xFF3B82F6).withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillPaint = Paint()
      ..shader = areaGradient.createShader(Rect.fromLTWH(0, 0, width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw Smooth Curve Stroke
    final strokeGradient = const LinearGradient(
      colors: [Color(0xFF2563EB), Color(0xFF06B6D4), Color(0xFF3B82F6)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final strokePaint = Paint()
      ..shader = strokeGradient.createShader(Rect.fromLTWH(0, 0, width, chartHeight))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 6. Draw Nodes / Pins
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isHovered = hoveredIndex == i;

      if (isHovered) {
        // Vertical dashed guideline for selected node
        final guidePaint = Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: 0.5)
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(p.dx, 0), Offset(p.dx, chartHeight), guidePaint);

        // Outer glow
        final glowPaint = Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 12, glowPaint);

        // Outer ring
        final outerPaint = Paint()
          ..color = const Color(0xFF2563EB)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 6, outerPaint);

        // Inner white dot
        final innerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 3.5, innerPaint);
      } else {
        // Regular node
        final nodeBorderPaint = Paint()
          ..color = const Color(0xFF3B82F6)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 4.5, nodeBorderPaint);

        final nodeCenterPaint = Paint()
          ..color = isDark ? const Color(0xFF0F172A) : Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 2.5, nodeCenterPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ModernSplineAreaPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.isDark != isDark ||
        oldDelegate.data != data ||
        oldDelegate.maxVal != maxVal;
  }
}
