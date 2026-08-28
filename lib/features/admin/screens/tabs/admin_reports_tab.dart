import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_export_service.dart';

class AdminReportsTab extends ConsumerStatefulWidget {
  final String? initialReportType;
  const AdminReportsTab({super.key, this.initialReportType});

  @override
  ConsumerState<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends ConsumerState<AdminReportsTab> {
  String _selectedReportType = 'Order Report'; // Order Report, Revenue Report, Driver Report, Customer Report

  @override
  void initState() {
    super.initState();
    if (widget.initialReportType != null && widget.initialReportType!.isNotEmpty) {
      _applyInitialType(widget.initialReportType!);
    }
  }

  @override
  void didUpdateWidget(covariant AdminReportsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialReportType != oldWidget.initialReportType && widget.initialReportType != null) {
      _applyInitialType(widget.initialReportType!);
    }
  }

  void _applyInitialType(String type) {
    switch (type.toLowerCase()) {
      case 'revenue':
        _selectedReportType = 'Revenue Report';
        break;
      case 'drivers':
      case 'driver':
        _selectedReportType = 'Driver Report';
        break;
      case 'customers':
      case 'customer':
        _selectedReportType = 'Customer Report';
        break;
      default:
        _selectedReportType = 'Order Report';
    }
  }

  // Date Range Controls
  DateTime _startDate = DateTime(2026, 8, 1);
  DateTime _endDate = DateTime(2026, 8, 17);
  String _orderStatusFilter = 'All';
  String _revenuePeriod = 'This Month'; // Today, This Week, This Month, Custom Range
  bool _isGenerated = true;
  bool get isGenerated => _isGenerated;

  void _exportCSV() {
    final orders = ref.read(adminOrdersProvider).value ?? [];
    final drivers = ref.read(adminDriversProvider).value ?? [];
    final customers = ref.read(adminCustomersProvider).value ?? [];

    final csvContent = AdminExportService.generateCSV(
      reportType: _selectedReportType,
      orders: orders,
      drivers: drivers,
      customers: customers,
    );

    final filename = 'TBMoveHub_${_selectedReportType.replaceAll(' ', '_')}_${_formatDate(_startDate).replaceAll('/', '-')}.csv';
    AdminExportService.downloadCSV(filename, csvContent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📥 ส่งออกไฟล์ CSV ($filename) สำเร็จแล้ว! (รองรับฟอนต์ไทยใน Excel)', style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportPDF() {
    _showPdfPrintPreviewDialog();
  }

  void _showPdfPrintPreviewDialog() {
    final orders = ref.read(adminOrdersProvider).value ?? [];
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 720,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 24),
                        const SizedBox(width: 10),
                        Text('📄 PDF Report Document Preview: $_selectedReportType',
                            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),

                // Printable Paper Sheet Preview Simulation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TBMoveHub Logistics System', style: GoogleFonts.kanit(color: const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('รายงานประจำวันที่: ${_formatDate(_startDate)} ถึง ${_formatDate(_endDate)}', style: GoogleFonts.kanit(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF1C7FF6), borderRadius: BorderRadius.circular(6)),
                            child: Text('OFFICIAL REPORT', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      const SizedBox(height: 12),

                      // Document Summary Table
                      Text('สรุปภาพรวมข้อมูล ($_selectedReportType)', style: GoogleFonts.kanit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade100),
                            children: [
                              Padding(padding: const EdgeInsets.all(8.0), child: Text('หัวข้อสถิติ', style: GoogleFonts.kanit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(8.0), child: Text('จำนวน / ยอดรวม', style: GoogleFonts.kanit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8.0), child: Text('คำสั่งซื้อทั้งหมดในระบบ', style: GoogleFonts.kanit(color: Colors.black87, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(8.0), child: Text('${orders.length} รายการ', style: GoogleFonts.kanit(color: Colors.black87, fontSize: 12))),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8.0), child: Text('สถานะเอกสารรายงาน', style: GoogleFonts.kanit(color: Colors.black87, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(8.0), child: Text('พร้อมพิมพ์ / บันทึก PDF', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🖨️ สั่งพิมพ์เอกสาร PDF และบันทึกไฟล์สำเร็จแล้ว!', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF3B82F6)),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text('พิมพ์เอกสาร PDF (Print)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1C7FF6),
              surface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(adminOrdersProvider);
    final driversState = ref.watch(adminDriversProvider);
    final customersState = ref.watch(adminCustomersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar & Category Selector Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📊 รายงานและสถิติการใช้งานระบบ', style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _exportCSV,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text('ส่งออกไฟล์ CSV', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _exportPDF,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text('พิมพ์รายงาน PDF', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4 Category Tabs
          Row(
            children: [
              _buildCategoryTab('Order Report', Icons.shopping_bag_rounded, const Color(0xFF3B82F6), label: 'รายงานคำสั่งซื้อ'),
              const SizedBox(width: 12),
              _buildCategoryTab('Revenue Report', Icons.account_balance_wallet_rounded, const Color(0xFF10B981), label: 'รายงานรายได้รวม'),
              const SizedBox(width: 12),
              _buildCategoryTab('Driver Report', Icons.two_wheeler_rounded, const Color(0xFF8B5CF6), label: 'รายงานผลงานคนขับ'),
              const SizedBox(width: 12),
              _buildCategoryTab('Customer Report', Icons.people_alt_rounded, const Color(0xFFF59E0B), label: 'รายงานการเติบโตลูกค้า'),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Controls Toolbar Container (Date + Filters + Generate)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
            child: Row(
              children: [
                // Date Range Button
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF334155))),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Color(0xFF3B82F6), size: 18),
                        const SizedBox(width: 8),
                        Text('ช่วงเวลา: [ ${_formatDate(_startDate)} ] - [ ${_formatDate(_endDate)} ]', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Specific Category Filter Dropdown
                if (_selectedReportType == 'Order Report') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF334155))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _orderStatusFilter,
                        dropdownColor: const Color(0xFF1E293B),
                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 13),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('Status: ทั้งหมด')),
                          DropdownMenuItem(value: 'Completed', child: Text('Completed (จัดส่งสำเร็จ)')),
                          DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled (ยกเลิก)')),
                          DropdownMenuItem(value: 'Pending', child: Text('Pending (รอคนขับ)')),
                          DropdownMenuItem(value: 'InProgress', child: Text('In Progress (กำลังส่ง)')),
                        ],
                        onChanged: (val) => setState(() => _orderStatusFilter = val!),
                      ),
                    ),
                  ),
                ] else if (_selectedReportType == 'Revenue Report') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF334155))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _revenuePeriod,
                        dropdownColor: const Color(0xFF1E293B),
                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 13),
                        items: const [
                          DropdownMenuItem(value: 'Today', child: Text('Revenue: Today (วันนี้)')),
                          DropdownMenuItem(value: 'This Week', child: Text('Revenue: This Week (สัปดาห์นี้)')),
                          DropdownMenuItem(value: 'This Month', child: Text('Revenue: This Month (เดือนนี้)')),
                          DropdownMenuItem(value: 'Custom Range', child: Text('Custom Range (กำหนดเอง)')),
                        ],
                        onChanged: (val) => setState(() => _revenuePeriod = val!),
                      ),
                    ),
                  ),
                ],
                const Spacer(),

                // Generate Report Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isGenerated = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('⚡ สร้างรายงาน $_selectedReportType สำเร็จแล้ว', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF10B981)),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: Text('Generate Report', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Render Selected Category Report Results
          if (_selectedReportType == 'Order Report')
            _buildOrderReportView(ordersState.value ?? [])
          else if (_selectedReportType == 'Revenue Report')
            _buildRevenueReportView(ordersState.value ?? [])
          else if (_selectedReportType == 'Driver Report')
            _buildDriverReportView(driversState.value ?? [])
          else if (_selectedReportType == 'Customer Report')
            _buildCustomerReportView(customersState.value ?? []),
        ],
      ),
    );
  }

  // 1. Order Report View Component
  Widget _buildOrderReportView(List<AdminOrderModel> orders) {
    final totalOrders = 1250;
    final completed = 980;
    final cancelled = 90;
    final pending = 40;
    final inProgress = 140;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Results Metric Cards
        Row(
          children: [
            Expanded(child: _buildReportMetricBox('Total Orders', totalOrders.toString(), Icons.all_inbox_rounded, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _buildReportMetricBox('Completed', completed.toString(), Icons.check_circle_rounded, const Color(0xFF10B981))),
            const SizedBox(width: 12),
            Expanded(child: _buildReportMetricBox('Cancelled', cancelled.toString(), Icons.cancel_rounded, Colors.redAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildReportMetricBox('Pending', pending.toString(), Icons.hourglass_top_rounded, Colors.amberAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildReportMetricBox('In Progress', inProgress.toString(), Icons.local_shipping_rounded, Colors.purpleAccent)),
          ],
        ),
        const SizedBox(height: 20),

        // Order Report Table Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('📦 รายงานสรุปคำสั่งซื้อ (Order Report Dataset)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                  columns: [
                    DataColumn(label: Text('Order ID', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Customer', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Driver', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Vehicle', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Price', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Created At', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                  ],
                  rows: orders.map((o) {
                    return DataRow(cells: [
                      DataCell(Text('#${o.orderNo}', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                      DataCell(Text(o.customerName, style: GoogleFonts.kanit(color: Colors.white))),
                      DataCell(Text(o.driverName.isEmpty ? 'ยังไม่มีคนขับ' : o.driverName, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      DataCell(Text(o.vehicleType, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      DataCell(Text('฿${o.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold))),
                      DataCell(Text(o.status.name.toUpperCase(), style: GoogleFonts.kanit(color: Colors.blueAccent, fontSize: 12))),
                      DataCell(Text('${o.createdAt.day}/${o.createdAt.month}/${o.createdAt.year}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Revenue Report View Component
  Widget _buildRevenueReportView(List<AdminOrderModel> orders) {
    const totalRev = 125500.0;
    const driverEarn = 95000.0;
    const platformRev = 30500.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildReportMetricBox('Total Revenue', '฿${totalRev.toStringAsFixed(0)}', Icons.payments_rounded, const Color(0xFF3B82F6))),
            const SizedBox(width: 16),
            Expanded(child: _buildReportMetricBox('Driver Earnings', '฿${driverEarn.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _buildReportMetricBox('Platform Revenue', '฿${platformRev.toStringAsFixed(0)}', Icons.pie_chart_rounded, const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💰 สรุปรายได้ประจำช่วงเวลา: $_revenuePeriod', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Text('ระบบคำนวณส่วนแบ่งการบริการ Platform Fee อยู่ที่ 20% และกระจายส่วนแบ่งให้ผู้ให้บริการคนขับที่ 80% สำหรับทุกประเภทการจัดส่ง', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Driver Report View Component with Top Drivers Leaderboard
  Widget _buildDriverReportView(List<DriverAdminModel> drivers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Drivers Ranking Leaderboard Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent, size: 24),
                  const SizedBox(width: 10),
                  Text('🏆 Top Drivers (อันดับคนขับที่มีผลงานสูงสุดประจำเดือน)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTopDriverLeaderboardCard('🥇 อันดับ 1', 'นายสมชาย สายเปย์ (Somchai)', '125 Orders', '⭐ 4.9', '฿18,750', Colors.amber)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTopDriverLeaderboardCard('🥈 อันดับ 2', 'นายอนันต์ วงศ์สว่าง (Anan)', '118 Orders', '⭐ 4.8', '฿17,700', Colors.grey.shade300)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTopDriverLeaderboardCard('🥉 อันดับ 3', 'นายกฤตยชญ์ มั่นคง (Krit)', '96 Orders', '⭐ 4.8', '฿14,400', Colors.brown.shade300)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Driver Performance Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('🚚 รายงานสถิติและผลงานคนขับทั้งหมด (Driver Performance Report)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                  columns: [
                    DataColumn(label: Text('Driver Name', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Vehicle', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Orders Completed', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Orders Cancelled', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Total Earnings', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Rating', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                  ],
                  rows: [
                    _buildDriverDataRow('นายสมชาย สายเปย์ (Somchai)', 'มอเตอร์ไซค์', '125', '2', '฿18,750.00', '⭐ 4.9'),
                    _buildDriverDataRow('นายอนันต์ วงศ์สว่าง (Anan)', 'รถกระบะ 4 ประตู', '118', '1', '฿17,700.00', '⭐ 4.8'),
                    _buildDriverDataRow('นายกฤตยชญ์ มั่นคง (Krit)', 'รถตู้ทึบ', '96', '3', '฿14,400.00', '⭐ 4.8'),
                    _buildDriverDataRow('นายวิชัย ใจดี', 'รถเก๋ง 5 ประตู', '84', '0', '฿12,600.00', '⭐ 4.7'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Customer Report View Component
  Widget _buildCustomerReportView(List<CustomerModel> customers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildReportMetricBox('Total Customers', '1,250 คน', Icons.people_alt_rounded, const Color(0xFF3B82F6))),
            const SizedBox(width: 16),
            Expanded(child: _buildReportMetricBox('Active Customers', '940 คน (75%)', Icons.check_circle_rounded, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _buildReportMetricBox('Avg Order Value', '฿280.00', Icons.shopping_basket_rounded, const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('👤 รายงานข้อมูลและยอดใช้บริการของลูกค้า (Customer Analytics)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                  columns: [
                    DataColumn(label: Text('Customer Name', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Email / Phone', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Total Orders', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Total Spend', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    DataColumn(label: Text('Account Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                  ],
                  rows: customers.map((c) {
                    return DataRow(cells: [
                      DataCell(Text(c.name, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                      DataCell(Text('${c.email}\n${c.phone}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12))),
                      DataCell(Text('${c.totalOrders} Orders', style: GoogleFonts.kanit(color: Colors.white))),
                      DataCell(Text('฿${c.totalSpent.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold))),
                      DataCell(Text(!c.isSuspended ? 'Active' : 'Suspended', style: GoogleFonts.kanit(color: !c.isSuspended ? Colors.greenAccent : Colors.redAccent, fontSize: 12))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDriverDataRow(String name, String vehicle, String completed, String cancelled, String earnings, String rating) {
    return DataRow(cells: [
      DataCell(Text(name, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
      DataCell(Text(vehicle, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
      DataCell(Text(completed, style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold))),
      DataCell(Text(cancelled, style: GoogleFonts.kanit(color: Colors.redAccent))),
      DataCell(Text(earnings, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
      DataCell(Text(rating, style: GoogleFonts.kanit(color: Colors.amberAccent, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildTopDriverLeaderboardCard(String badge, String name, String orders, String rating, String earnings, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(badge, style: GoogleFonts.kanit(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Text(name, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orders, style: GoogleFonts.kanit(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 13)),
              Text(rating, style: GoogleFonts.kanit(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Text('รายได้รวม: $earnings', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, IconData icon, Color activeColor, {String? label}) {
    final isSelected = _selectedReportType == title;
    return InkWell(
      onTap: () => setState(() => _selectedReportType = title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeColor : const Color(0xFF334155), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? activeColor : const Color(0xFF94A3B8), size: 18),
            const SizedBox(width: 8),
            Text(label ?? title, style: GoogleFonts.kanit(color: isSelected ? Colors.white : const Color(0xFF94A3B8), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.kanit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
