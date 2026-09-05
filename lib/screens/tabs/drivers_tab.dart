import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class DriversTab extends StatefulWidget {
  final AdminDataService dataService;

  const DriversTab({super.key, required this.dataService});

  @override
  State<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<DriversTab> {
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = widget.dataService.drivers.where((d) {
      final matchStatus = _selectedStatus == 'all' || d.status.name == _selectedStatus;
      final q = _searchQuery.toLowerCase();
      final matchSearch = d.fullName.toLowerCase().contains(q) ||
          d.plate.toLowerCase().contains(q) ||
          d.phone.contains(q) ||
          d.area.toLowerCase().contains(q) ||
          d.vehicleType.toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();

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
                    'ไรเดอร์ & การยืนยันตัวตน (Drivers & Fleet)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('ตรวจสอบประวัติและเอกสาร อนุมัติผู้สมัครใหม่ จัดการกองยานพาหนะ', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedStatus,
                    style: GoogleFonts.kanit(color: isDark ? Colors.white : Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('ทุกสถานะ')),
                      DropdownMenuItem(value: 'pending', child: Text('⏳ รอยืนยัน (Pending)')),
                      DropdownMenuItem(value: 'approved', child: Text('✅ อนุมัติแล้ว (Approved)')),
                      DropdownMenuItem(value: 'rejected', child: Text('❌ ปฏิเสธ (Rejected)')),
                      DropdownMenuItem(value: 'suspended', child: Text('🚫 ระงับ (Suspended)')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ค้นหาชื่อ, ทะเบียน, พื้นที่...',
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
                    onPressed: () => _showAddDriverDialog(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text('+ เพิ่มไรเดอร์', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Drivers Table Card
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
                    DataColumn(label: Text('#', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ชื่อ-นามสกุล', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ยานพาหนะ / รุ่น', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ทะเบียน / จังหวัด', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('พื้นที่ประจำ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ส่งสำเร็จ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('เรทติ้ง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('กระเป๋าเงิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('สถานะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ออนไลน์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('การจัดการ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.asMap().entries.map((entry) {
                    final index = entry.key;
                    final driver = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}', style: GoogleFonts.kanit())),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(driver.fullName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                              Text(driver.phone, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(driver.vehicleType, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('${driver.brand} ${driver.model}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        DataCell(Text('${driver.plate} (${driver.province})', style: GoogleFonts.kanit())),
                        DataCell(Text(driver.area, style: GoogleFonts.kanit(fontSize: 12))),
                        DataCell(Text('${driver.completedJobs} งาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        DataCell(Text(driver.rating > 0 ? '⭐ ${driver.rating.toStringAsFixed(2)}' : '—', style: GoogleFonts.kanit(color: const Color(0xFFD97706), fontWeight: FontWeight.bold))),
                        DataCell(Text('฿ ${driver.walletBalance.toInt()}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: AdminTheme.accentGreen))),
                        DataCell(_buildVerificationBadge(driver.status)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: driver.isOnline ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              driver.isOnline ? '🟢 ออนไลน์' : '⚫ ออฟไลน์',
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: driver.isOnline ? const Color(0xFF047857) : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.badge_outlined, size: 20, color: AdminTheme.primaryBlue),
                                tooltip: 'ตรวจสอบเอกสาร & รถ',
                                onPressed: () => _showDriverDetailsModal(context, driver),
                              ),
                              if (driver.status == DriverVerificationStatus.pending) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminTheme.accentGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  onPressed: () {
                                    setState(() => widget.dataService.approveDriver(driver.id));
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('อนุมัติ ${driver.fullName} เรียบร้อย')));
                                  },
                                  child: Text('อนุมัติ', style: GoogleFonts.kanit(fontSize: 12)),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AdminTheme.accentRed,
                                    side: const BorderSide(color: AdminTheme.accentRed),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  onPressed: () => _showRejectDialog(context, driver),
                                  child: Text('ปฏิเสธ', style: GoogleFonts.kanit(fontSize: 12)),
                                ),
                              ] else if (driver.status == DriverVerificationStatus.approved) ...[
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: AdminTheme.accentRed),
                                  onPressed: () {
                                    setState(() => widget.dataService.suspendDriver(driver.id));
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ระงับบัญชี ${driver.fullName} แล้ว')));
                                  },
                                  child: Text('ระงับ', style: GoogleFonts.kanit(fontSize: 12)),
                                ),
                              ] else if (driver.status == DriverVerificationStatus.suspended) ...[
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: AdminTheme.accentGreen),
                                  onPressed: () {
                                    setState(() => widget.dataService.reinstateDriver(driver.id));
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('คืนสถานะ ${driver.fullName} เรียบร้อย')));
                                  },
                                  child: Text('คืนสถานะ', style: GoogleFonts.kanit(fontSize: 12)),
                                ),
                              ],
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

  void _showAddDriverDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final areaCtrl = TextEditingController(text: 'สุขุมวิท - บางนา');
    String vehicleType = '🛵 มอเตอร์ไซค์';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('เพิ่มไรเดอร์ใหม่ในระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'ชื่อ-นามสกุล', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'เบอร์โทรศัพท์', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: vehicleType,
                  decoration: InputDecoration(labelText: 'ประเภทรถ', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: const [
                    DropdownMenuItem(value: '🛵 มอเตอร์ไซค์', child: Text('🛵 มอเตอร์ไซค์')),
                    DropdownMenuItem(value: '🚗 รถกระบะตู้ทึบ', child: Text('🚗 รถกระบะตู้ทึบ')),
                    DropdownMenuItem(value: '🚛 รถบรรทุก 4 ล้อใหญ่', child: Text('🚛 รถบรรทุก 4 ล้อใหญ่')),
                    DropdownMenuItem(value: '🚚 รถบรรทุก 6 ล้อ', child: Text('🚚 รถบรรทุก 6 ล้อ')),
                  ],
                  onChanged: (val) => setDialogState(() => vehicleType = val!),
                ),
                const SizedBox(height: 10),
                TextField(controller: plateCtrl, decoration: InputDecoration(labelText: 'ป้ายทะเบียน', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: areaCtrl, decoration: InputDecoration(labelText: 'พื้นที่วิ่งรับงานหลัก', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  setState(() {
                    widget.dataService.addDriver(DriverAdminModel(
                      id: 'D${(widget.dataService.drivers.length + 1).toString().padLeft(3, '0')}',
                      fullName: nameCtrl.text,
                      phone: phoneCtrl.text,
                      email: '${nameCtrl.text.toLowerCase().replaceAll(' ', '')}@rider.com',
                      vehicleType: vehicleType,
                      brand: 'Honda',
                      model: 'Std',
                      plate: plateCtrl.text.isNotEmpty ? plateCtrl.text : 'กข 9999',
                      province: 'กรุงเทพฯ',
                      color: 'ดำ',
                      area: areaCtrl.text,
                      status: DriverVerificationStatus.approved,
                      isOnline: true,
                      submittedAt: DateTime.now(),
                    ));
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มไรเดอร์ ${nameCtrl.text} เรียบร้อย')));
                }
              },
              child: Text('บันทึกข้อมูล', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, DriverAdminModel driver) {
    final reasonCtrl = TextEditingController(text: 'ภาพถ่ายใบขับขี่หมดอายุหรือไม่ชัดเจน');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ปฏิเสธการสมัคร: ${driver.fullName}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ระบุเหตุผลในการปฏิเสธเพื่อส่งแจ้งเตือนไปยังผู้สมัครผ่าน SMS/แอป:', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () {
              setState(() => widget.dataService.rejectDriver(driver.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ปฏิเสธการสมัครของ ${driver.fullName} แล้ว')));
            },
            child: Text('ยืนยันปฏิเสธ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showDriverDetailsModal(BuildContext context, DriverAdminModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: AdminTheme.primaryBlue),
            const SizedBox(width: 8),
            Text('ประวัติและเอกสารยืนยันตัวตน: ${driver.fullName}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('รหัสไรเดอร์:', driver.id),
              _buildDetailRow('เบอร์โทรศัพท์:', driver.phone),
              _buildDetailRow('ประเภทยานพาหนะ:', driver.vehicleType),
              _buildDetailRow('ยี่ห้อ / รุ่น:', '${driver.brand} ${driver.model}'),
              _buildDetailRow('ป้ายทะเบียน / สี:', '${driver.plate} (${driver.color}) - ${driver.province}'),
              _buildDetailRow('พื้นที่รับงานประจำ:', driver.area),
              _buildDetailRow('จำนวนงานที่สำเร็จ:', '${driver.completedJobs} งาน'),
              _buildDetailRow('คะแนนรีวิว:', driver.rating > 0 ? '⭐ ${driver.rating}' : 'ยังไม่มีคะแนน'),
              _buildDetailRow('ยอดเงินในกระเป๋า:', '฿ ${driver.walletBalance.toInt()} บาท'),
              _buildDetailRow('รายได้รวมสะสม:', '฿ ${driver.totalEarnings.toInt()} บาท'),
              _buildDetailRow('วันที่สมัคร:', DateFormat('d MMMM yyyy HH:mm').format(driver.submittedAt)),
              const Divider(height: 24),
              Text('📑 รายการเอกสารยืนยันตัวตน (Verification Checkpoints):', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              _buildDocCheckItem('บัตรประจำตัวประชาชน (ผ่านการยืนยัน DOPA)', true),
              _buildDocCheckItem('ใบอนุญาตขับขี่สาธารณะ/ส่วนบุคคล (ไม่หมดอายุ)', true),
              _buildDocCheckItem('สมุดคู่มือจดทะเบียนรถ และ พ.ร.บ. คุ้มครอง', true),
              _buildDocCheckItem('ภาพถ่ายยานพาหนะรอบคัน 4 ด้าน', true),
              _buildDocCheckItem('สมุดบัญชีธนาคารสำหรับรับเงินค่ารอบ', true),
              _buildDocCheckItem('ใบตรวจประวัติอาชญากรรมจากสำนักงานตำรวจแห่งชาติ', true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ปิด', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCheckItem(String label, bool isOk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(isOk ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 16, color: isOk ? AdminTheme.accentGreen : AdminTheme.accentRed),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.kanit(fontSize: 12))),
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
          SizedBox(width: 140, child: Text(label, style: GoogleFonts.kanit(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: GoogleFonts.kanit(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(DriverVerificationStatus status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case DriverVerificationStatus.approved:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        label = 'อนุมัติแล้ว';
        break;
      case DriverVerificationStatus.rejected:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        label = 'ปฏิเสธ';
        break;
      case DriverVerificationStatus.suspended:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = 'ระงับ';
        break;
      default:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        label = 'รอยืนยัน';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
