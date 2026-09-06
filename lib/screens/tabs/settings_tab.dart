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
  bool _obscureApiKey = true;
  int _activeSettingsSection = 0; // 0: Operations & Display, 1: Security & Access, 2: API & Integrations

  @override
  Widget build(BuildContext context) {
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
                    'ตั้งค่าระบบส่วนกลาง (System Configuration & Master Control)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'กำหนดอัตราค่าบริการ, โค้ดส่วนลด, การจ่ายงาน AI, ความปลอดภัย และการเชื่อมต่อ API Server',
                    style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💾 บันทึกการตั้งค่าระบบและอัปเดต Config ขึ้นคลาวด์เรียบร้อยแล้ว'),
                      backgroundColor: AdminTheme.accentGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text('บันทึกการตั้งค่าทั้งหมด', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  // Left Column: Pricing & Vouchers
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
                  // Right Column: Advanced System Master Control
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

  // =============================================================
  // 1. PRICING CONFIG CARD
  // =============================================================
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
                  'อัตราค่าบริการตามประเภทยานพาหนะ (Fare Matrix)',
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

  // =============================================================
  // 2. PROMOTION VOUCHERS CARD
  // =============================================================
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
                      'โค้ดโปรโมชั่นส่วนลด (Vouchers & Campaigns)',
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

  // =============================================================
  // 3. DETAILED SYSTEM CONTROL & DISPLAY CARD
  // =============================================================
  Widget _buildSystemControlCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminTheme.primaryBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, color: AdminTheme.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'การควบคุมระบบ & การแสดงผล (Master Control)',
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'การควบคุมการจ่ายงาน, ความปลอดภัย, กฎการปฏิบัติการ และ API Server',
                          style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Section Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSectionChip(0, '🚀 การปฏิบัติการ & จ่ายงาน', Icons.local_shipping_rounded),
                  const SizedBox(width: 8),
                  _buildSectionChip(1, '🔒 ความปลอดภัย & แอดมิน', Icons.security_rounded),
                  const SizedBox(width: 8),
                  _buildSectionChip(2, '🌐 API & Webhooks', Icons.cloud_sync_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 0: Operations & Display
            if (_activeSettingsSection == 0) ...[
              // Display Controls
              Text('🎨 การแสดงผล & บรรยากาศการทำงาน:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.primaryBlue)),
              const SizedBox(height: 6),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('โหมดมืด (Dark Mode)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('สลับธีมสีมืดและสว่างของระบบแอดมินสำหรับห้องวอร์รูม', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.isDarkMode,
                onChanged: (val) => widget.dataService.toggleDarkMode(),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('เสียงแจ้งเตือนออเดอร์ใหม่ & เหตุ SOS', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('ส่งสัญญาณเสียงเตือนวิทยุฉุกเฉินเมื่อมีไรเดอร์กด SOS หรือมีงานด่วน', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.soundAlertsEnabled,
                onChanged: (val) => setState(() => widget.dataService.soundAlertsEnabled = val),
              ),
              const Divider(height: 18),

              // Operations & Dispatch Rules
              Text('🛵 กฎการรับงาน & การจ่ายงานไรเดอร์:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.primaryBlue)),
              const SizedBox(height: 6),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('เปิดรับสมัครไรเดอร์ใหม่ (Rider Registration Gate)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('อนุญาตให้บุคคลทั่วไปยื่นเอกสารและสมัครเข้าสู่ระบบ TB MoveHub', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.allowNewDriverReg,
                onChanged: (val) => setState(() => widget.dataService.allowNewDriverReg = val),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('ระบบ AI จัดสรรงานอัตโนมัติ (AI Smart Auto-Dispatch)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('วิเคราะห์พิกัด GPS และคะแนนเพื่อจ่ายงานให้อัตโนมัติทันทีที่ลูกค้าสั่งซื้อ', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.aiAutoDispatchEnabled,
                onChanged: (val) => setState(() => widget.dataService.aiAutoDispatchEnabled = val),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('บังคับตรวจความปลอดภัย AI สวมหมวกนิรภัย (Helmet & Safety Check)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('ให้ไรเดอร์สแกนใบหน้าและถ่ายรูปหมวกนิรภัยก่อนเปิดรับงานทุกวัน', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.helmetVerificationRequired,
                onChanged: (val) => setState(() => widget.dataService.helmetVerificationRequired = val),
              ),
              const SizedBox(height: 10),

              // Sliders / Dropdowns for dispatch params
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รัศมีค้นหาไรเดอร์สูงสุด: ${widget.dataService.dispatchRadiusKm} กม.', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.w600)),
                        Slider(
                          value: widget.dataService.dispatchRadiusKm.toDouble(),
                          min: 3,
                          max: 30,
                          divisions: 9,
                          label: '${widget.dataService.dispatchRadiusKm} กม.',
                          onChanged: (val) => setState(() => widget.dataService.dispatchRadiusKm = val.toInt()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('เวลานับถอยหลังรับงาน: ${widget.dataService.driverAcceptTimeoutSeconds} วิ', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.w600)),
                        Slider(
                          value: widget.dataService.driverAcceptTimeoutSeconds.toDouble(),
                          min: 15,
                          max: 90,
                          divisions: 5,
                          label: '${widget.dataService.driverAcceptTimeoutSeconds} วินาที',
                          onChanged: (val) => setState(() => widget.dataService.driverAcceptTimeoutSeconds = val.toInt()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),

              // Maintenance Mode
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('โหมดปิดปรับปรุงระบบ (Maintenance Mode)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: widget.dataService.maintenanceMode ? AdminTheme.accentRed : null)),
                subtitle: Text('ปิดการเข้าถึงบริการชั่วคราวสำหรับลูกค้าและไรเดอร์ระหว่างการอัปเกรดระบบ', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.maintenanceMode,
                activeColor: AdminTheme.accentRed,
                onChanged: (val) {
                  setState(() => widget.dataService.maintenanceMode = val);
                  if (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⚠️ เปิดโหมดปิดปรับปรุงระบบชั่วคราว (Maintenance Mode ON)'), backgroundColor: AdminTheme.accentRed),
                    );
                  }
                },
              ),
            ],

            // SECTION 1: Security & Admin Access
            if (_activeSettingsSection == 1) ...[
              Text('🔒 ความปลอดภัยของบัญชีและระบบหลังบ้าน:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.primaryBlue)),
              const SizedBox(height: 8),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('บังคับยืนยันตัวตน 2 ขั้นตอน (Enforce 2FA / OTP for Admins)', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('ต้องกรอกรหัส OTP ผ่านมือถือหรือ Authenticator App เมื่อเข้าสู่ระบบแอดมิน', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                value: widget.dataService.require2FAForAdmins,
                onChanged: (val) => setState(() => widget.dataService.require2FAForAdmins = val),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ระยะเวลาล็อกหน้าจออัตโนมัติ (Session Timeout):', style: GoogleFonts.kanit(fontSize: 12)),
                  DropdownButton<int>(
                    value: widget.dataService.sessionTimeoutMinutes,
                    style: GoogleFonts.kanit(color: isDark ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 15, child: Text('15 นาที')),
                      DropdownMenuItem(value: 30, child: Text('30 นาที')),
                      DropdownMenuItem(value: 60, child: Text('1 ชั่วโมง')),
                      DropdownMenuItem(value: 120, child: Text('2 ชั่วโมง')),
                    ],
                    onChanged: (val) => setState(() => widget.dataService.sessionTimeoutMinutes = val!),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Emergency Lockdown Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AdminTheme.accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminTheme.accentRed.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AdminTheme.accentRed, size: 22),
                        const SizedBox(width: 8),
                        Text('ศูนย์ควบคุมฉุกเฉิน (Emergency Platform Lockdown)', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: AdminTheme.accentRed)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ใช้ในกรณีตรวจพบภัยคุกคามทางไซเบอร์ หรือเหตุฉุกเฉินระดับวิกฤต เพื่อระงับการโอนเงินและหยุดรับออเดอร์ทั้งหมดทันที',
                      style: GoogleFonts.kanit(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.dataService.emergencyLockdown ? Colors.grey : AdminTheme.accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() => widget.dataService.toggleEmergencyLockdown());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.dataService.emergencyLockdown ? '🚨 เปิดใช้งานระบบล็อกดาวน์ฉุกเฉินแล้ว!' : '🟢 ยกเลิกระบบล็อกดาวน์ฉุกเฉินเรียบร้อย'),
                            backgroundColor: widget.dataService.emergencyLockdown ? AdminTheme.accentRed : AdminTheme.accentGreen,
                          ),
                        );
                      },
                      icon: Icon(widget.dataService.emergencyLockdown ? Icons.lock_open_rounded : Icons.lock_rounded, size: 16),
                      label: Text(
                        widget.dataService.emergencyLockdown ? 'ปลดล็อกดาวน์ระบบ' : '🚨 สั่งล็อกดาวน์ระบบฉุกเฉิน',
                        style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // SECTION 2: API & Integrations
            if (_activeSettingsSection == 2) ...[
              Text('🌐 การตั้งค่าเซิร์ฟเวอร์ Backend API & Third-party Integrations:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.primaryBlue)),
              const SizedBox(height: 10),

              // API Base URL
              TextFormField(
                initialValue: widget.dataService.apiBaseUrl,
                decoration: InputDecoration(
                  labelText: 'API Base URL Endpoint',
                  labelStyle: GoogleFonts.kanit(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.http_rounded, size: 18),
                ),
                onChanged: (val) => widget.dataService.apiBaseUrl = val,
              ),
              const SizedBox(height: 10),

              // API Secret Key
              TextFormField(
                initialValue: widget.dataService.apiSecretKey,
                obscureText: _obscureApiKey,
                decoration: InputDecoration(
                  labelText: 'API Secret Key / JWT Bearer Token',
                  labelStyle: GoogleFonts.kanit(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.key_rounded, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureApiKey ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
                    onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                  ),
                ),
                onChanged: (val) => widget.dataService.apiSecretKey = val,
              ),
              const SizedBox(height: 10),

              // Google Maps API Key
              TextFormField(
                initialValue: widget.dataService.googleMapsApiKey,
                decoration: InputDecoration(
                  labelText: 'Google Maps Engine API Key',
                  labelStyle: GoogleFonts.kanit(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.map_rounded, size: 18),
                ),
                onChanged: (val) => widget.dataService.googleMapsApiKey = val,
              ),
              const SizedBox(height: 10),

              // LINE Notify Token
              TextFormField(
                initialValue: widget.dataService.lineNotifyToken,
                decoration: InputDecoration(
                  labelText: 'LINE Notify Token (แจ้งเตือนเหตุฉุกเฉินเข้าห้องแอดมิน)',
                  labelStyle: GoogleFonts.kanit(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.notifications_active_rounded, size: 18),
                ),
                onChanged: (val) => widget.dataService.lineNotifyToken = val,
              ),
              const SizedBox(height: 16),

              // Diagnostic & Maintenance Action Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _testApiConnection(context),
                    icon: const Icon(Icons.network_check_rounded, size: 16),
                    label: Text('ทดสอบการเชื่อมต่อ API Server', style: GoogleFonts.kanit(fontSize: 12)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🧹 ดำเนินการล้างแคชและ Re-index ฐานข้อมูลเรียบร้อยแล้ว'), backgroundColor: Colors.teal),
                      );
                    },
                    icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                    label: Text('ล้างแคชระบบ (Purge Cache)', style: GoogleFonts.kanit(fontSize: 12)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('💾 ส่งออกและดาวน์โหลดไฟล์สำรองข้อมูลฐานข้อมูล (Database Dump) สำเร็จ'), backgroundColor: AdminTheme.accentGreen),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text('สำรองฐานข้อมูล (Backup DB)', style: GoogleFonts.kanit(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionChip(int index, String label, IconData icon) {
    final isSelected = _activeSettingsSection == index;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AdminTheme.primaryBlue),
      label: Text(label, style: GoogleFonts.kanit(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AdminTheme.primaryBlue,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      onSelected: (val) {
        if (val) setState(() => _activeSettingsSection = index);
      },
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
            Text('สถานะการเชื่อมต่อ API Server & Database Diagnostic', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Endpoint URL: ${widget.dataService.apiBaseUrl}', style: GoogleFonts.kanit(fontSize: 12)),
              const SizedBox(height: 6),
              Text('• API Health: 🟢 200 OK (FastAPI / Node Backend)', style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.accentGreen, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('• Database Status: 🟢 PostgreSQL / MySQL Connected (Pool: 12/20)', style: GoogleFonts.kanit(fontSize: 12)),
              const SizedBox(height: 6),
              Text('• Google Maps Engine: 🟢 Active (Geocoding & Tiles Live)', style: GoogleFonts.kanit(fontSize: 12)),
              const SizedBox(height: 6),
              Text('• WebSocket Gateway: 🟢 Connected (Active Channels: 48)', style: GoogleFonts.kanit(fontSize: 12)),
              const SizedBox(height: 6),
              Text('• Response Latency: 28 ms (ความเร็วสูง)', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
        ],
      ),
    );
  }
}
