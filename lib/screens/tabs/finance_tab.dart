import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class FinanceTab extends StatefulWidget {
  final AdminDataService dataService;

  const FinanceTab({super.key, required this.dataService});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFmt = NumberFormat("#,##0", "en_US");

    final totalMonthlyRevenue = 2847500.0;
    final platformFee = totalMonthlyRevenue * (widget.dataService.platformFeePercent / 100);
    final driverEarnings = totalMonthlyRevenue - platformFee;
    final pendingWithdraw = widget.dataService.withdrawals
        .where((w) => w.status == 'pending')
        .fold(0.0, (sum, w) => sum + w.amount);

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
                    'การเงิน & ธุรกรรม (Finance & Settlement)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('สรุปกระแสเงินสด รายได้คอมมิชชั่น 15% และระบบอนุมัติเบิกจ่ายไรเดอร์', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showExportDialog(context),
                    icon: const Icon(Icons.file_download_rounded, size: 18),
                    label: Text('ส่งออกรายงาน Excel/PDF', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAddWithdrawalDialog(context),
                    icon: const Icon(Icons.add_card_rounded, size: 18),
                    label: Text('+ คำขอถอนเงิน', style: GoogleFonts.kanit(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stat Cards
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
                    title: 'รายได้รวมเดือนนี้ (Total Revenue)',
                    value: '฿ ${currencyFmt.format(totalMonthlyRevenue)}',
                    subtitle: 'เปรียบเทียบเดือนก่อน +12.8%',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AdminTheme.accentGreen,
                  ),
                  _buildStatCard(
                    title: 'กำไรค่าคอมมิชชั่น (${widget.dataService.platformFeePercent.toInt()}%)',
                    value: '฿ ${currencyFmt.format(platformFee)}',
                    subtitle: 'ส่วนแบ่งแพลตฟอร์มสุทธิ',
                    icon: Icons.pie_chart_rounded,
                    color: AdminTheme.primaryBlue,
                  ),
                  _buildStatCard(
                    title: 'ส่วนแบ่งไรเดอร์ (85%)',
                    value: '฿ ${currencyFmt.format(driverEarnings)}',
                    subtitle: 'โอนแล้ว 96.4% ของยอดทั้งหมด',
                    icon: Icons.payments_rounded,
                    color: AdminTheme.accentOrange,
                  ),
                  _buildStatCard(
                    title: 'รออนุมัติถอนเงิน (Pending)',
                    value: '฿ ${currencyFmt.format(pendingWithdraw)}',
                    subtitle: 'จาก ${widget.dataService.withdrawals.where((w) => w.status == "pending").length} รายการ',
                    icon: Icons.hourglass_top_rounded,
                    color: AdminTheme.accentRed,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Payment Gateway Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('สัดส่วนช่องทางการชำระเงิน (Payment Gateway Breakdown)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPaymentMethodBar('📱 พร้อมเพย์ QR Code (PromptPay)', 62, AdminTheme.primaryBlue, '฿ 1,765,450'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodBar('💳 บัตรเครดิต/เดบิต (Visa/Mastercard)', 28, AdminTheme.accentGreen, '฿ 797,300'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodBar('💵 เก็บเงินปลายทาง (Cash on Delivery - COD)', 10, AdminTheme.accentOrange, '฿ 284,750'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Withdrawals Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'รายการขอถอนเงินของไรเดอร์ (Withdrawal Requests)',
                        style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('อนุมัติแล้ว ${widget.dataService.withdrawals.where((w) => w.status == "approved").length} รายการ', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
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
                        DataColumn(label: Text('ชื่อไรเดอร์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ยอดถอนเงิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ธนาคาร', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('เลขที่บัญชี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('วันที่ยื่นเรื่อง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('สถานะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('การจัดการ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                      ],
                      rows: widget.dataService.withdrawals.map((req) {
                        return DataRow(
                          cells: [
                            DataCell(Text(req.driverName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                            DataCell(Text('฿ ${currencyFmt.format(req.amount)}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: AdminTheme.accentGreen))),
                            DataCell(Text(req.bankName, style: GoogleFonts.kanit(fontSize: 12))),
                            DataCell(Text(req.bankAccount, style: GoogleFonts.kanit())),
                            DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(req.requestDate), style: GoogleFonts.kanit())),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: req.status == 'approved' ? const Color(0xFFECFDF5) : (req.status == 'rejected' ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  req.status == 'approved' ? 'โอนสำเร็จ' : (req.status == 'rejected' ? 'ปฏิเสธ' : 'รอดำเนินการ'),
                                  style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: req.status == 'approved' ? const Color(0xFF047857) : (req.status == 'rejected' ? const Color(0xFFB91C1C) : const Color(0xFFB45309)),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              req.status == 'pending'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AdminTheme.accentGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          ),
                                          onPressed: () {
                                            setState(() => widget.dataService.approveWithdrawal(req.id));
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ อนุมัติโอนเงิน ฿${req.amount.toInt()} ให้ ${req.driverName} เรียบร้อย')));
                                          },
                                          child: Text('อนุมัติโอน', style: GoogleFonts.kanit(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 6),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AdminTheme.accentRed,
                                            side: const BorderSide(color: AdminTheme.accentRed),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          ),
                                          onPressed: () {
                                            setState(() => widget.dataService.rejectWithdrawal(req.id));
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ ปฏิเสธคำขอถอนเงินของ ${req.driverName} แล้ว')));
                                          },
                                          child: Text('ปฏิเสธ', style: GoogleFonts.kanit(fontSize: 12)),
                                        ),
                                      ],
                                    )
                                  : Text(req.status == 'approved' ? '✓ ดำเนินการแล้ว' : '✗ ยกเลิก', style: GoogleFonts.kanit(color: req.status == 'approved' ? AdminTheme.accentGreen : AdminTheme.accentRed, fontWeight: FontWeight.bold)),
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

  Widget _buildPaymentMethodBar(String label, int percent, Color color, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('$amount ($percent%)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            color: color,
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ส่งออกรายงานสรุปทางการเงิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เลือกประเภทไฟล์รายงานที่ต้องการดาวน์โหลด:', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AdminTheme.accentGreen),
              title: Text('Microsoft Excel (.xlsx)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('ข้อมูลคำนวณและแจกแจงรายรับรายจ่ายแบบละเอียด', style: GoogleFonts.kanit(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📥 ดาวน์โหลดไฟล์ Financial_Report_2026.xlsx สำเร็จ')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AdminTheme.accentRed),
              title: Text('Adobe PDF Document (.pdf)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('เอกสารสรุปยอดรายได้ทางการพร้อมตรายางรับรอง', style: GoogleFonts.kanit(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📥 ดาวน์โหลดไฟล์ Financial_Report_2026.pdf สำเร็จ')));
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
        ],
      ),
    );
  }

  void _showAddWithdrawalDialog(BuildContext context) {
    final driverCtrl = TextEditingController(text: 'สมหมาย ขับดี');
    final amountCtrl = TextEditingController(text: '2000');
    final bankNameCtrl = TextEditingController(text: 'กสิกรไทย (KBANK)');
    final bankAccountCtrl = TextEditingController(text: '009-1-23456-7');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ยื่นคำขอถอนเงินจำลอง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: driverCtrl, decoration: InputDecoration(labelText: 'ชื่อไรเดอร์', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'จำนวนเงิน (฿)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextField(controller: bankNameCtrl, decoration: InputDecoration(labelText: 'ชื่อธนาคาร', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextField(controller: bankAccountCtrl, decoration: InputDecoration(labelText: 'เลขที่บัญชี', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                widget.dataService.withdrawals.insert(
                  0,
                  WithdrawalRequest(
                    id: 'W${(widget.dataService.withdrawals.length + 1).toString().padLeft(3, '0')}',
                    driverName: driverCtrl.text,
                    amount: double.tryParse(amountCtrl.text) ?? 1000.0,
                    bankName: bankNameCtrl.text,
                    bankAccount: bankAccountCtrl.text,
                    requestDate: DateTime.now(),
                  ),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มคำขอถอนเงินของ ${driverCtrl.text} สำเร็จ')));
            },
            child: Text('บันทึกคำขอ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String subtitle, required IconData icon, required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
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
          ],
        ),
      ),
    );
  }
}
