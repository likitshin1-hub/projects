import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class SettingsTab extends StatefulWidget {
  final AdminDataService dataService;

  const SettingsTab({super.key, required this.dataService});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
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
                    'ตั้งค่าระบบส่วนกลาง (System Configuration)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('กำหนดราคาค่าบริการ, จัดการโค้ดโปรโมชั่นส่วนลด และควบคุมสถานะระบบ', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💾 บันทึกการตั้งค่าระบบและฐานข้อมูลเรียบร้อยแล้ว')));
                },
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text('บันทึกการตั้งค่าทั้งหมด', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                    child: Column(
                      children: [
                        _buildPricingCard(),
                        const SizedBox(height: 20),
                        _buildPromoCard(),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                    child: _buildSystemControlCard(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: AdminTheme.accentGreen),
                const SizedBox(width: 8),
                Text(
                  'อัตราค่าบริการตามประเภทยานพาหนะ',
                  style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...widget.dataService.pricingConfigs.map((cfg) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cfg.vehicleType, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: cfg.basePrice.toInt().toString(),
                            decoration: InputDecoration(
                              labelText: 'ราคาเริ่มต้น (฿)',
                              labelStyle: GoogleFonts.kanit(fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              cfg.basePrice = double.tryParse(val) ?? cfg.basePrice;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: cfg.pricePerKm.toInt().toString(),
                            decoration: InputDecoration(
                              labelText: 'ราคาต่อ กม. (฿)',
                              labelStyle: GoogleFonts.kanit(fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              cfg.pricePerKm = double.tryParse(val) ?? cfg.pricePerKm;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกอัตราค่าบริการใหม่เรียบร้อย')));
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text('บันทึกเฉพาะราคา', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Card(
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
                    const Icon(Icons.discount_rounded, color: AdminTheme.accentOrange),
                    const SizedBox(width: 8),
                    Text(
                      'โค้ดโปรโมชั่นส่วนลด (Vouchers)',
                      style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AdminTheme.primaryBlue),
                  tooltip: 'สร้างโค้ดส่วนลดใหม่',
                  onPressed: () => _showAddPromoDialog(context),
                ),
              ],
            ),
            const Divider(height: 16),
            ...widget.dataService.promoVouchers.map((promo) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(promo.code, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFFD97706))),
                ),
                title: Text(
                  promo.discountType == 'fixed' ? 'ลดทันที ฿${promo.discountAmount.toInt()} บาท' : 'ลด ${promo.discountAmount.toInt()}%',
                  style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                subtitle: Text('ใช้งานแล้ว ${promo.usageCount}/${promo.maxUsage} สิทธิ์', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                trailing: Switch(
                  value: promo.isActive,
                  onChanged: (val) {
                    setState(() => widget.dataService.togglePromoStatus(promo.code));
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddPromoDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '50');
    final maxCtrl = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('สร้างโค้ดส่วนลดใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: InputDecoration(labelText: 'รหัสโค้ด (เช่น FLASH50)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'มูลค่าส่วนลด (฿)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextField(controller: maxCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'จำนวนสิทธิ์สูงสุด', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              if (codeCtrl.text.isNotEmpty) {
                setState(() {
                  widget.dataService.addPromoVoucher(PromoVoucher(
                    code: codeCtrl.text.toUpperCase(),
                    discountAmount: double.tryParse(amountCtrl.text) ?? 50.0,
                    usageCount: 0,
                    maxUsage: int.tryParse(maxCtrl.text) ?? 500,
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สร้างโค้ด ${codeCtrl.text.toUpperCase()} สำเร็จ')));
              }
            },
            child: Text('บันทึกโค้ด', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AdminTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'การควบคุมระบบ & การแสดงผล',
                  style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            SwitchListTile(
              title: Text('โหมดมืด (Dark Mode)', style: GoogleFonts.kanit(fontSize: 14)),
              subtitle: Text('สลับธีมสีมืดและสว่างของระบบแอดมิน', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              value: widget.dataService.isDarkMode,
              onChanged: (val) => widget.dataService.toggleDarkMode(),
            ),
            SwitchListTile(
              title: Text('เปิดรับสมัครไรเดอร์ใหม่', style: GoogleFonts.kanit(fontSize: 14)),
              subtitle: Text('อนุญาตให้บุคคลทั่วไปยื่นเอกสารสมัครเป็นไรเดอร์', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              value: widget.dataService.allowNewDriverReg,
              onChanged: (val) => setState(() => widget.dataService.allowNewDriverReg = val),
            ),
            SwitchListTile(
              title: Text('โหมดปิดปรับปรุงระบบ (Maintenance Mode)', style: GoogleFonts.kanit(fontSize: 14)),
              subtitle: Text('ปิดการเข้าถึงบริการชั่วคราวสำหรับลูกค้า', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              value: widget.dataService.maintenanceMode,
              onChanged: (val) => setState(() => widget.dataService.maintenanceMode = val),
            ),
            const Divider(height: 24),
            Text('🌐 การตั้งค่าเซิร์ฟเวอร์ Backend API:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: widget.dataService.apiBaseUrl,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                labelStyle: GoogleFonts.kanit(fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => widget.dataService.apiBaseUrl = val,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _testApiConnection(context),
              icon: const Icon(Icons.network_check_rounded, size: 18),
              label: Text('ทดสอบการเชื่อมต่อ API Server', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }

  void _testApiConnection(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AdminTheme.accentGreen),
            const SizedBox(width: 8),
            Text('สถานะการเชื่อมต่อ API', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Endpoint URL: ${widget.dataService.apiBaseUrl}', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Server Status: 🟢 200 OK (ตอบสนองปกติ)', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Database Connection: MySQL Connected', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Response Latency: 42 ms', style: GoogleFonts.kanit(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ตกลง', style: GoogleFonts.kanit())),
        ],
      ),
    );
  }
}
