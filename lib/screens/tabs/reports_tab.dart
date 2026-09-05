import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';

class ReportsTab extends StatefulWidget {
  final AdminDataService dataService;

  const ReportsTab({super.key, required this.dataService});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _selectedPeriod = '30';

  @override
  Widget build(BuildContext context) {
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
                    'รายงาน & สถิติเชิงลึก (Reports & Analytics)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('วิเคราะห์ประสิทธิภาพแพลตฟอร์ม อัตราการจัดส่งสำเร็จ และพฤติกรรมผู้ใช้', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    items: const [
                      DropdownMenuItem(value: '7', child: Text('7 วันล่าสุด')),
                      DropdownMenuItem(value: '30', child: Text('30 วันล่าสุด')),
                      DropdownMenuItem(value: '90', child: Text('3 เดือนย้อนหลัง')),
                      DropdownMenuItem(value: '365', child: Text('รายปี 2026')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedPeriod = val!);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('อัปเดตช่วงเวลาสถิติ: $_selectedPeriod วันล่าสุด')));
                    },
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📊 กำลังประมวลผลและสร้างรายงาน PDF สรุปประจำเดือน...')),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text('ดาวน์โหลดรายงานฉบับเต็ม', style: GoogleFonts.kanit(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Summary Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.4,
                children: [
                  _buildKpiCard('อัตราส่งสำเร็จ (Success Rate)', '94.2%', AdminTheme.accentGreen),
                  _buildKpiCard('อัตรายกเลิก (Cancellation)', '5.8%', AdminTheme.accentRed),
                  _buildKpiCard('คะแนนเฉลี่ยแพลตฟอร์ม', '4.87 ⭐', AdminTheme.accentOrange),
                  _buildKpiCard('ระยะเวลาจัดส่งเฉลี่ย', '28 นาที', AdminTheme.primaryBlue),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Peak Hours Analysis Card
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
                        'ช่วงเวลาที่มีคำสั่งซื้อหนาแน่น (Peak Hours Distribution)',
                        style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('อิงตามปริมาณการเรียกใช้งานจริง', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildBarRow('06:00 - 08:00 (เช้าตรู่)', 120, 1000),
                  _buildBarRow('08:00 - 10:00 (ช่วงเร่งด่วนเช้า)', 540, 1000),
                  _buildBarRow('11:00 - 13:00 (ช่วงพักเที่ยง - สูงสุด)', 820, 1000),
                  _buildBarRow('14:00 - 16:00 (ช่วงบ่าย)', 670, 1000),
                  _buildBarRow('17:00 - 19:00 (ช่วงเร่งด่วนเย็น - สูงสุด)', 890, 1000),
                  _buildBarRow('20:00 - 22:00 (ช่วงค่ำ)', 440, 1000),
                  _buildBarRow('22:00 - 00:00 (ดึก)', 180, 1000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildBarRow(String label, int value, int max) {
    final percent = value / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.kanit(fontSize: 13)),
              Text('$value ออเดอร์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              color: AdminTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
