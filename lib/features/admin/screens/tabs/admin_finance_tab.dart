import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class TransactionModel {
  final String txId;
  final String orderNo;
  final String customerName;
  final String driverName;
  final double orderAmount;
  final double driverEarning;
  final double platformFee;
  final String status; // PAID, PENDING_PAYOUT, REFUNDED
  final DateTime date;

  TransactionModel({
    required this.txId,
    required this.orderNo,
    required this.customerName,
    required this.driverName,
    required this.orderAmount,
    required this.driverEarning,
    required this.platformFee,
    required this.status,
    required this.date,
  });
}

class AdminFinanceTab extends ConsumerStatefulWidget {
  final String? initialSubTab;
  const AdminFinanceTab({super.key, this.initialSubTab});

  @override
  ConsumerState<AdminFinanceTab> createState() => _AdminFinanceTabState();
}

class _AdminFinanceTabState extends ConsumerState<AdminFinanceTab> {
  final TextEditingController _searchController = TextEditingController();
  String _activeSection = 'transactions'; // transactions, wallets
  String get activeSection => _activeSection;
  String _datePeriodFilter = 'Today'; // Today, Yesterday, ThisWeek, ThisMonth
  String _paymentStatusFilter = 'All'; // All, PAID, PENDING_PAYOUT, REFUNDED

  @override
  void initState() {
    super.initState();
    if (widget.initialSubTab != null && widget.initialSubTab!.isNotEmpty) {
      _activeSection = widget.initialSubTab!;
    }
  }

  @override
  void didUpdateWidget(covariant AdminFinanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTab != oldWidget.initialSubTab && widget.initialSubTab != null) {
      setState(() => _activeSection = widget.initialSubTab!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _generateMockTransactions(List<AdminOrderModel> orders) {
    if (orders.isEmpty) {
      return [
        TransactionModel(
          txId: '#TX001',
          orderNo: '#TB001',
          customerName: 'คุณสมชาย สายเปย์',
          driverName: 'นายวิชัย ใจดี',
          orderAmount: 150.0,
          driverEarning: 120.0,
          platformFee: 30.0,
          status: 'PAID',
          date: DateTime(2026, 8, 17, 14, 30),
        ),
        TransactionModel(
          txId: '#TX002',
          orderNo: '#TB002',
          customerName: 'คุณนภา สุขสวัสดิ์',
          driverName: 'นายอนันต์ วงศ์สว่าง',
          orderAmount: 450.0,
          driverEarning: 360.0,
          platformFee: 90.0,
          status: 'PAID',
          date: DateTime(2026, 8, 17, 13, 15),
        ),
        TransactionModel(
          txId: '#TX003',
          orderNo: '#TB003',
          customerName: 'คุณเกรียงไกร มีทรัพย์',
          driverName: 'นายศักดา มั่นคง',
          orderAmount: 1200.0,
          driverEarning: 960.0,
          platformFee: 240.0,
          status: 'PENDING_PAYOUT',
          date: DateTime(2026, 8, 17, 11, 45),
        ),
      ];
    }

    return orders.asMap().entries.map((entry) {
      final idx = entry.key;
      final o = entry.value;
      final amount = o.amount;
      final driverEarn = amount * 0.80; // 80% Driver share
      final platform = amount * 0.20; // 20% Platform fee

      return TransactionModel(
        txId: '#TX${(idx + 1).toString().padLeft(3, '0')}',
        orderNo: '#${o.orderNo}',
        customerName: o.customerName,
        driverName: o.driverName.isEmpty ? 'ยังไม่มีคนขับ' : o.driverName,
        orderAmount: amount,
        driverEarning: driverEarn,
        platformFee: platform,
        status: o.status == AdminOrderStatus.completed ? 'PAID' : (o.status == AdminOrderStatus.cancelled ? 'REFUNDED' : 'PENDING_PAYOUT'),
        date: o.createdAt,
      );
    }).toList();
  }

  void _showTransactionDetailModal(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 480,
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
                        const Icon(Icons.receipt_long_rounded, color: Color(0xFF1C7FF6), size: 24),
                        const SizedBox(width: 10),
                        Text('Transaction ${tx.txId}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),

                _buildTxDetailRow('Order Reference:', tx.orderNo),
                _buildTxDetailRow('Customer:', tx.customerName),
                _buildTxDetailRow('Driver:', tx.driverName),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 8),

                _buildTxDetailRow('Order Amount (ราคารวม):', '฿${tx.orderAmount.toStringAsFixed(2)}', valueColor: Colors.white, isBold: true),
                _buildTxDetailRow('Driver Earning (80% คนขับ):', '฿${tx.driverEarning.toStringAsFixed(2)}', valueColor: const Color(0xFF10B981)),
                _buildTxDetailRow('Platform Fee (20% ระบบ):', '฿${tx.platformFee.toStringAsFixed(2)}', valueColor: const Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 8),

                _buildTxDetailRow('Payment Status:', tx.status, valueColor: _getStatusColor(tx.status), isBold: true),
                _buildTxDetailRow('Date:', '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year} ${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}'),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
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

  Widget _buildTxDetailRow(String label, String value, {Color valueColor = Colors.white, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
          Text(value, style: GoogleFonts.kanit(color: valueColor, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return const Color(0xFF10B981);
      case 'PENDING_PAYOUT':
        return Colors.amberAccent;
      case 'REFUNDED':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(adminOrdersProvider);
    final ordersList = ordersState.value ?? [];

    final totalRevenue = 125500.0;
    final driverPay = 95000.0;
    final platformRevenue = 30500.0;

    final txList = _generateMockTransactions(ordersList);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Text('Finance (สรุปยอดการเงินและส่วนแบ่งระบบ)', style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),

          // 3 Financial Dashboard Cards
          Row(
            children: [
              Expanded(
                child: _buildFinanceMetricCard(
                  title: 'Revenue (ยอดหมุนเวียนรวม)',
                  value: '฿${totalRevenue.toStringAsFixed(0)}',
                  subText: 'ยอดรวมคำสั่งซื้อชำระแล้วทั้งหมด',
                  icon: Icons.account_balance_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinanceMetricCard(
                  title: 'Driver Pay (รายได้คนขับรวม)',
                  value: '฿${driverPay.toStringAsFixed(0)}',
                  subText: 'ส่วนแบ่งรายได้คนขับประมาณ 80%',
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinanceMetricCard(
                  title: 'Platform Revenue (รายได้แพลตฟอร์ม)',
                  value: '฿${platformRevenue.toStringAsFixed(0)}',
                  subText: 'ค่าธรรมเนียมบริการระบบ 20%',
                  icon: Icons.pie_chart_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 📈 Revenue Chart Section
          Container(
            width: double.infinity,
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
                    Text('📈 Revenue Chart (สรุปสถิติรายได้และส่วนแบ่งตามช่วงเวลา)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                      child: Text('อัปเดตประจำวัน', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar('จันทร์', 0.45, '฿4,500'),
                      _buildChartBar('อังคาร', 0.65, '฿6,800'),
                      _buildChartBar('พุธ', 0.55, '฿5,500'),
                      _buildChartBar('พฤหัส', 0.85, '฿9,100'),
                      _buildChartBar('ศุกร์', 0.98, '฿12,500'),
                      _buildChartBar('เสาร์', 0.75, '฿8,200'),
                      _buildChartBar('อาทิตย์', 0.88, '฿9,800'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Filter Toolbar Row (Search + 2 Filter Dropdowns)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: '🔍 Search Order / Transaction ID / Customer / Driver',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Date Period Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _datePeriodFilter,
                    dropdownColor: const Color(0xFF1E293B),
                    style: GoogleFonts.kanit(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('วันนี้ (Today)')),
                      DropdownMenuItem(value: 'Yesterday', child: Text('เมื่อวานนี้')),
                      DropdownMenuItem(value: 'ThisWeek', child: Text('สัปดาห์นี้')),
                      DropdownMenuItem(value: 'ThisMonth', child: Text('เดือนนี้')),
                    ],
                    onChanged: (val) => setState(() => _datePeriodFilter = val!),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Payment Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _paymentStatusFilter,
                    dropdownColor: const Color(0xFF1E293B),
                    style: GoogleFonts.kanit(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('Payment Status: ทั้งหมด')),
                      DropdownMenuItem(value: 'PAID', child: Text('🟢 PAID (ชำระแล้ว)')),
                      DropdownMenuItem(value: 'PENDING_PAYOUT', child: Text('🟡 PENDING (รอโอน)')),
                      DropdownMenuItem(value: 'REFUNDED', child: Text('🔴 REFUNDED (คืนเงิน)')),
                    ],
                    onChanged: (val) => setState(() => _paymentStatusFilter = val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Transactions DataTable
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('💳 Recent Transactions (รายการทำธุรกรรมการเงินล่าสุด)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const Divider(height: 1, color: Color(0xFF334155)),

                (() {
                  final query = _searchController.text.toLowerCase();
                  var filtered = txList.where((tx) {
                    final matchQuery = tx.txId.toLowerCase().contains(query) ||
                        tx.orderNo.toLowerCase().contains(query) ||
                        tx.customerName.toLowerCase().contains(query) ||
                        tx.driverName.toLowerCase().contains(query);

                    bool matchStatus = _paymentStatusFilter == 'All' || tx.status == _paymentStatusFilter;
                    return matchQuery && matchStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(child: Text('ไม่พบรายการธุรกรรมที่ตรงตามเงื่อนไข', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    );
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                      columns: [
                        DataColumn(label: Text('Tx ID', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Order No.', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Customer', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Driver', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Order Amount', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Driver Earning', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Platform Fee', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Date', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      ],
                      rows: filtered.map((tx) {
                        final dateStr = '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}';

                        return DataRow(cells: [
                          DataCell(Text(tx.txId, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text(tx.orderNo, style: GoogleFonts.kanit(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold))),
                          DataCell(Text(tx.customerName, style: GoogleFonts.kanit(color: Colors.white))),
                          DataCell(Text(tx.driverName, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(Text('฿${tx.orderAmount.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text('฿${tx.driverEarning.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF10B981)))),
                          DataCell(Text('฿${tx.platformFee.toStringAsFixed(2)}', style: GoogleFonts.kanit(color: const Color(0xFF3B82F6)))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(tx.status).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(tx.status, style: GoogleFonts.kanit(color: _getStatusColor(tx.status), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataCell(Text(dateStr, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.receipt_rounded, color: Color(0xFF3B82F6)),
                              onPressed: () => _showTransactionDetailModal(tx),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                })(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceMetricCard({
    required String title,
    required String value,
    required String subText,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          Text(subText, style: GoogleFonts.kanit(color: const Color(0xFF64748B), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double heightPct, String amountStr) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(amountStr, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 120 * heightPct,
          decoration: BoxDecoration(
            color: const Color(0xFF1C7FF6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }
}
