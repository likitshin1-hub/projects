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
    final allOrders = widget.dataService.orders;
    final pendingUnassigned = allOrders.where((o) => o.status == AdminOrderStatus.pending || o.driverName == 'รอคนขับตอบรับ').toList();

    final filtered = allOrders.where((o) {
      final matchStatus = _selectedStatus == 'all' || 
          (_selectedStatus == 'unassigned' ? (o.status == AdminOrderStatus.pending || o.driverName == 'รอคนขับตอบรับ') : o.status.name == _selectedStatus);
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'จัดการคำสั่งซื้อและการจัดสรรไรเดอร์ (Orders & Logistics Dispatch)',
                        style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (pendingUnassigned.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminTheme.accentOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminTheme.accentOrange.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'รอจัดสรร ${pendingUnassigned.length} ออเดอร์',
                            style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text('ตรวจสอบสถานะการจัดส่ง มอบหมายงานลูกค้าให้ไรเดอร์ ไทม์ไลน์พัสดุ และพิมพ์ใบเสร็จ', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedStatus,
                    style: GoogleFonts.kanit(color: isDark ? Colors.white : Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('ทุกสถานะการส่ง')),
                      DropdownMenuItem(value: 'unassigned', child: Text('⚠️ รอจัดสรรไรเดอร์ (Unassigned)')),
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
          const SizedBox(height: 16),

          // Unassigned Orders Dispatch Banner
          if (pendingUnassigned.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AdminTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AdminTheme.accentOrange.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AdminTheme.accentOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚡ มี ${pendingUnassigned.length} ออเดอร์ของลูกค้าที่ยังไม่ได้รับมอบหมายไรเดอร์',
                          style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange),
                        ),
                        Text(
                          'สามารถเลือกมอบหมายรายบุคคล หรือใช้ระบบ AI Dispatcher จับคู่ไรเดอร์ที่ใกล้ที่สุดให้อัตโนมัติทันที',
                          style: GoogleFonts.kanit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.accentOrange,
                      side: const BorderSide(color: AdminTheme.accentOrange),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _selectedStatus = 'unassigned'),
                    icon: const Icon(Icons.filter_list_rounded, size: 16),
                    label: Text('กรองเฉพาะรอจัดสรร', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final count = widget.dataService.autoDispatchPendingOrders();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⚡ จัดสรรงานอัตโนมัติสำเร็จ! มอบหมายงานให้ไรเดอร์เรียบร้อย $count ออเดอร์'),
                          backgroundColor: AdminTheme.accentGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: Text('⚡ จัดสรรอัตโนมัติทั้งหมด (Auto-Dispatch)', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],

          // Orders Data Table
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
                    DataColumn(label: Text('ไรเดอร์ผู้รับงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ยานพาหนะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ประเภทพัสดุ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('จุดรับ (ต้นทาง)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('จุดส่ง (ปลายทาง)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ยอดชำระ / วิธี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('สถานะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('การจัดการ & มอบหมายงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((order) {
                    final isUnassigned = order.driverName == 'รอคนขับตอบรับ' || order.status == AdminOrderStatus.pending;

                    return DataRow(
                      cells: [
                        DataCell(Text(order.orderNo, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue))),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(order.customerName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                              Text(order.customerPhone, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        // Rider Cell with Assign Badge if empty
                        DataCell(
                          isUnassigned
                              ? InkWell(
                                  onTap: () => _showAssignDriverModal(context, order),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AdminTheme.accentOrange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AdminTheme.accentOrange.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person_add_rounded, size: 14, color: AdminTheme.accentOrange),
                                        const SizedBox(width: 4),
                                        Text('คลิกมอบหมายไรเดอร์', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange)),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(order.driverName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                                    Text(order.driverPhone, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                        ),
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
                        // Actions
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Button: Assign / Re-assign driver
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUnassigned ? AdminTheme.accentOrange : AdminTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: () => _showAssignDriverModal(context, order),
                                icon: const Icon(Icons.assignment_ind_rounded, size: 14),
                                label: Text(
                                  isUnassigned ? 'มอบหมายไรเดอร์' : 'เปลี่ยนไรเดอร์',
                                  style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.timeline_rounded, size: 18, color: AdminTheme.primaryBlue),
                                tooltip: 'ดูไทม์ไลน์การส่ง',
                                onPressed: () => _showOrderTimelineModal(context, order),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.teal),
                                tooltip: 'เปลี่ยนสถานะออเดอร์',
                                onPressed: () => _showUpdateStatusModal(context, order),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, size: 18, color: AdminTheme.accentRed),
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

  // =============================================================
  // MODAL: ASSIGN DRIVER TO CUSTOMER ORDER
  // =============================================================
  void _showAssignDriverModal(BuildContext context, AdminOrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AssignDriverDialog(
        order: order,
        dataService: widget.dataService,
        onAssigned: () {
          setState(() {});
        },
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

// =============================================================
// ASSIGN DRIVER DIALOG COMPONENT
// =============================================================
class _AssignDriverDialog extends StatefulWidget {
  final AdminOrderModel order;
  final AdminDataService dataService;
  final VoidCallback onAssigned;

  const _AssignDriverDialog({
    required this.order,
    required this.dataService,
    required this.onAssigned,
  });

  @override
  State<_AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends State<_AssignDriverDialog> {
  String _driverSearch = '';
  String _tabFilter = 'recommended'; // 'recommended' or 'all'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final trackingDrivers = widget.dataService.trackingDrivers;

    // Filter drivers
    final filteredDrivers = trackingDrivers.where((d) {
      final q = _driverSearch.toLowerCase();
      final matchSearch = d.driverName.toLowerCase().contains(q) ||
          d.driverPhone.contains(q) ||
          d.vehiclePlate.toLowerCase().contains(q) ||
          d.vehicleType.toLowerCase().contains(q);

      if (_tabFilter == 'recommended') {
        final vehicleMatch = d.vehicleType.contains(order.vehicleType) || order.vehicleType.contains(d.vehicleType);
        final statusAvailable = d.status == TrackingStatus.available || d.status == TrackingStatus.inTransit;
        return matchSearch && (vehicleMatch || statusAvailable);
      }
      return matchSearch;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Container(
        width: 820,
        height: 720,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AdminTheme.primaryBlue.withValues(alpha: 0.12),
                border: Border(bottom: BorderSide(color: AdminTheme.primaryBlue.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AdminTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'จัดสรรและมอบหมายงานให้ไรเดอร์ (Customer Job Assignment)',
                              style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.primaryBlue),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AdminTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(order.orderNo, style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                        Text(
                          'ลูกค้า: ${order.customerName} (${order.customerPhone}) • พัสดุ: ${order.parcelType}',
                          style: GoogleFonts.kanit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Order Summary Highlight Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.place_rounded, color: AdminTheme.accentGreen, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('จุดรับพัสดุ (ต้นทาง):', style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                                  Text(order.pickupAddress, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AdminTheme.accentRed, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('จุดส่งมอบ (ปลายทาง):', style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                                  Text(order.dropoffAddress, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AdminTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('ต้องการ: ${order.vehicleType}', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue)),
                          ),
                          const SizedBox(width: 8),
                          Text('ระยะทาง ${order.distanceKm} กม.', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text('ยอดค่าส่ง ฿${order.amount.toInt()}', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          widget.dataService.autoMatchOrderToBestDriver(order.orderNo);
                          widget.onAssigned();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('⚡ ระบบ AI Dispatcher มอบหมายออเดอร์ ${order.orderNo} ให้ไรเดอร์ที่เหมาะสมที่สุดเรียบร้อย'),
                              backgroundColor: AdminTheme.accentGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.bolt_rounded, size: 16),
                        label: Text('⚡ แมตช์ไรเดอร์ที่เหมาะสมที่สุด (AI Best Match)', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search & Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ค้นหาชื่อไรเดอร์, เบอร์โทร, ทะเบียนรถ, พิกัดถนน...',
                        hintStyle: GoogleFonts.kanit(fontSize: 12),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _driverSearch = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'recommended', label: Text('แนะนำ & รถตรงประเภท')),
                      ButtonSegment(value: 'all', label: Text('ไรเดอร์ทั้งหมดในระบบ')),
                    ],
                    selected: {_tabFilter},
                    onSelectionChanged: (set) => setState(() => _tabFilter = set.first),
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(GoogleFonts.kanit(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Driver List
            Expanded(
              child: filteredDrivers.isEmpty
                  ? Center(
                      child: Text('ไม่พบข้อมูลไรเดอร์ที่ตรงกับเงื่อนไขการค้นหา', style: GoogleFonts.kanit(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredDrivers.length,
                      itemBuilder: (context, idx) {
                        final driver = filteredDrivers[idx];
                        final isAvailable = driver.status == TrackingStatus.available;
                        final isMatchingVehicle = driver.vehicleType.contains(order.vehicleType) || order.vehicleType.contains(driver.vehicleType);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMatchingVehicle
                                  ? AdminTheme.primaryBlue.withValues(alpha: 0.5)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: isMatchingVehicle ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isAvailable
                                    ? AdminTheme.accentGreen.withValues(alpha: 0.15)
                                    : AdminTheme.primaryBlue.withValues(alpha: 0.15),
                                child: Text(
                                  driver.driverName.isNotEmpty ? driver.driverName.substring(0, 1) : 'D',
                                  style: GoogleFonts.kanit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? AdminTheme.accentGreen : AdminTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Driver Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          driver.driverName,
                                          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? AdminTheme.accentGreen.withValues(alpha: 0.15)
                                                : Colors.blue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isAvailable ? '🟢 พร้อมรับงาน' : '🛵 กำลังวิ่งงาน',
                                            style: GoogleFonts.kanit(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isAvailable ? AdminTheme.accentGreen : Colors.blue,
                                            ),
                                          ),
                                        ),
                                        if (isMatchingVehicle) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AdminTheme.accentGreen,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text('รถตรงประเภท ⭐', style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${driver.vehiclePlate} (${driver.vehicleType}) • โทร ${driver.driverPhone}',
                                      style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            'พิกัดปัจจุบัน: ${driver.currentRoad}',
                                            style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '⭐ ${driver.rating} • ส่งแล้ว ${driver.todayCompletedJobs} งาน',
                                          style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Assign Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  widget.dataService.assignOrderToDriver(driver.driverId, order.orderNo);
                                  widget.onAssigned();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🚀 มอบหมายออเดอร์ ${order.orderNo} ให้ไรเดอร์ ${driver.driverName} (${driver.vehiclePlate}) เรียบร้อยแล้ว!'),
                                      backgroundColor: AdminTheme.accentGreen,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                label: Text('มอบหมายงานนี้', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('ปิดหน้าต่าง', style: GoogleFonts.kanit()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
