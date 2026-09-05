import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class OrdersTab extends StatefulWidget {
  final AdminDataService dataService;

  const OrdersTab({super.key, required this.dataService});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = widget.dataService.orders.where((o) {
      final matchStatus = _selectedStatus == 'all' || o.status.name == _selectedStatus;
      final q = _searchQuery.toLowerCase();
      final matchSearch = o.orderNo.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.driverName.toLowerCase().contains(q) ||
          o.parcelType.toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'จัดการคำสั่งซื้อ (Orders & Logistics)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('ตรวจสอบสถานะการจัดส่ง ไทม์ไลน์พัสดุ พิมพ์ใบเสร็จ และเปลี่ยนสถานะคำสั่งซื้อ', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedStatus,
                    style: GoogleFonts.kanit(color: isDark ? Colors.white : Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('ทุกสถานะการส่ง')),
                      DropdownMenuItem(value: 'pending', child: Text('⏳ รอคนขับตอบรับ (Pending)')),
                      DropdownMenuItem(value: 'accepted', child: Text('🤝 คนขับรับงานแล้ว (Accepted)')),
                      DropdownMenuItem(value: 'inTransit', child: Text('🚚 กำลังนำส่ง (In Transit)')),
                      DropdownMenuItem(value: 'completed', child: Text('✅ จัดส่งสำเร็จ (Completed)')),
                      DropdownMenuItem(value: 'cancelled', child: Text('❌ ยกเลิกคำสั่งซื้อ (Cancelled)')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ค้นหาเลขออเดอร์, ชื่อ...',
                        hintStyle: GoogleFonts.kanit(fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showCreateOrderDialog(context),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: Text('+ เพิ่มออเดอร์', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? const Color(0xFF1C7FF6).withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                  ),
                  columns: [
                    DataColumn(label: Text('เลขออเดอร์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ลูกค้าผู้ส่ง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ไรเดอร์ผู้ส่ง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ยานพาหนะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ประเภทพัสดุ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('จุดรับ (ต้นทาง)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('จุดส่ง (ปลายทาง)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ยอดชำระ / วิธี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('สถานะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('การจัดการ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(Text(order.orderNo, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue))),
                        DataCell(Text(order.customerName, style: GoogleFonts.kanit())),
                        DataCell(Text(order.driverName, style: GoogleFonts.kanit())),
                        DataCell(Text(order.vehicleType, style: GoogleFonts.kanit())),
                        DataCell(SizedBox(width: 120, child: Text(order.parcelType, style: GoogleFonts.kanit(fontSize: 12), overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 130, child: Text(order.pickupAddress, style: GoogleFonts.kanit(fontSize: 12), overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 130, child: Text(order.dropoffAddress, style: GoogleFonts.kanit(fontSize: 12), overflow: TextOverflow.ellipsis))),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('฿ ${order.amount.toInt()}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                              Text(order.paymentMethod, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        DataCell(_buildStatusBadge(order.status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.timeline_rounded, size: 20, color: AdminTheme.primaryBlue),
                                tooltip: 'ดูไทม์ไลน์การส่ง',
                                onPressed: () => _showOrderTimelineModal(context, order),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 20, color: AdminTheme.accentOrange),
                                tooltip: 'เปลี่ยนสถานะออเดอร์',
                                onPressed: () => _showUpdateStatusModal(context, order),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, size: 20, color: AdminTheme.accentRed),
                                tooltip: 'ยกเลิกออเดอร์',
                                onPressed: () {
                                  setState(() => widget.dataService.cancelOrder(order.orderNo));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ยกเลิกออเดอร์ ${order.orderNo} เรียบร้อย')));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderTimelineModal(BuildContext context, AdminOrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.alt_route_rounded, color: AdminTheme.primaryBlue),
            const SizedBox(width: 8),
            Text('ไทม์ไลน์การจัดส่ง: ${order.orderNo}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineStep('1. สร้างคำสั่งซื้อและชำระเงิน', 'เสร็จสิ้น (${order.paymentMethod})', true, Icons.check_circle_rounded),
              _buildTimelineStep('2. ไรเดอร์ตอบรับงาน', '${order.driverName} (${order.driverPhone})', order.status != AdminOrderStatus.pending, Icons.handshake_rounded),
              _buildTimelineStep('3. ไรเดอร์เดินทางถึงจุดรับพัสดุ', order.pickupAddress, order.status == AdminOrderStatus.pickedUp || order.status == AdminOrderStatus.inTransit || order.status == AdminOrderStatus.completed, Icons.place_rounded),
              _buildTimelineStep('4. รับมอบพัสดุและเริ่มเดินทาง', order.parcelType, order.status == AdminOrderStatus.inTransit || order.status == AdminOrderStatus.completed, Icons.local_shipping_rounded),
              _buildTimelineStep('5. จัดส่งถึงปลายทางเรียบร้อย', order.dropoffAddress, order.status == AdminOrderStatus.completed, Icons.task_alt_rounded),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ยอดรวมค่าบริการ:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                  Text('฿ ${order.amount.toInt()} บาท', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🖨️ พิมพ์ใบส่งของออเดอร์ ${order.orderNo} สำเร็จ')));
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: Text('พิมพ์ใบส่งของ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String desc, bool isDone, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isDone ? AdminTheme.accentGreen : Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: isDone ? null : Colors.grey)),
                Text(desc, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOrderDialog(BuildContext context) {
    final custCtrl = TextEditingController(text: 'ลูกค้าทั่วไป (Walk-in)');
    final pickupCtrl = TextEditingController(text: 'ศูนย์การค้าสยามพารากอน ปทุมวัน');
    final dropCtrl = TextEditingController(text: 'ไอคอนสยาม คลองสาน กรุงเทพฯ');
    final parcelCtrl = TextEditingController(text: 'กล่องพัสดุด่วนสินค้าแฟชั่น');
    final amountCtrl = TextEditingController(text: '140');
    String vehicle = '🛵 มอเตอร์ไซค์';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('สร้างออเดอร์ใหม่ในระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: custCtrl, decoration: InputDecoration(labelText: 'ชื่อลูกค้า / องค์กร', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: vehicle,
                  decoration: InputDecoration(labelText: 'ประเภทยานพาหนะ', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: const [
                    DropdownMenuItem(value: '🛵 มอเตอร์ไซค์', child: Text('🛵 มอเตอร์ไซค์')),
                    DropdownMenuItem(value: '🚗 รถกระบะตู้ทึบ', child: Text('🚗 รถกระบะตู้ทึบ')),
                    DropdownMenuItem(value: '🚛 รถบรรทุก 4 ล้อใหญ่', child: Text('🚛 รถบรรทุก 4 ล้อใหญ่')),
                    DropdownMenuItem(value: '🚚 รถบรรทุก 6 ล้อ', child: Text('🚚 รถบรรทุก 6 ล้อ')),
                  ],
                  onChanged: (val) => setDialogState(() => vehicle = val!),
                ),
                const SizedBox(height: 10),
                TextField(controller: parcelCtrl, decoration: InputDecoration(labelText: 'รายละเอียดพัสดุ / สินค้า', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: pickupCtrl, decoration: InputDecoration(labelText: 'จุดรับพัสดุ (ต้นทาง)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: dropCtrl, decoration: InputDecoration(labelText: 'จุดส่งพัสดุ (ปลายทาง)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'ยอดค่าบริการคำนวณ (฿)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                final newNo = 'TB${(668511 + widget.dataService.orders.length + 1)}';
                setState(() {
                  widget.dataService.addOrder(AdminOrderModel(
                    orderNo: newNo,
                    customerName: custCtrl.text,
                    customerPhone: '081-999-8888',
                    driverName: 'รอคนขับตอบรับ',
                    driverPhone: '-',
                    vehicleType: vehicle,
                    parcelType: parcelCtrl.text,
                    paymentMethod: 'PromptPay QR',
                    distanceKm: 9.2,
                    pickupAddress: pickupCtrl.text,
                    dropoffAddress: dropCtrl.text,
                    amount: double.tryParse(amountCtrl.text) ?? 140.0,
                    status: AdminOrderStatus.pending,
                    createdAt: DateTime.now(),
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สร้างออเดอร์ $newNo เรียบร้อย')));
              },
              child: Text('สร้างออเดอร์', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusModal(BuildContext context, AdminOrderModel order) {
    AdminOrderStatus selected = order.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('เปลี่ยนสถานะ: ${order.orderNo}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AdminOrderStatus.values.map((st) {
              return ListTile(
                title: Text(st.thaiLabel, style: GoogleFonts.kanit(fontSize: 13)),
                leading: Icon(
                  selected == st ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: selected == st ? AdminTheme.primaryBlue : Colors.grey,
                ),
                onTap: () => setDialogState(() => selected = st),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                setState(() => widget.dataService.updateOrderStatus(order.orderNo, selected));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('อัปเดตสถานะออเดอร์ ${order.orderNo} สำเร็จ')));
              },
              child: Text('บันทึกสถานะ', style: GoogleFonts.kanit()),
            ),
          ],
        ),
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
