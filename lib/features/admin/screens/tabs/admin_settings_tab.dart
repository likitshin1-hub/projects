import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/admin_provider.dart';

class AdminSettingsTab extends ConsumerStatefulWidget {
  final String? initialNavCategory;
  const AdminSettingsTab({super.key, this.initialNavCategory});

  @override
  ConsumerState<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends ConsumerState<AdminSettingsTab> {
  String _selectedNavCategory = 'Admin Profile';

  @override
  void initState() {
    super.initState();
    if (widget.initialNavCategory != null && widget.initialNavCategory!.isNotEmpty) {
      _applyInitialCategory(widget.initialNavCategory!);
    }
  }

  @override
  void didUpdateWidget(covariant AdminSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNavCategory != oldWidget.initialNavCategory && widget.initialNavCategory != null) {
      _applyInitialCategory(widget.initialNavCategory!);
    }
  }

  void _applyInitialCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'security':
        _selectedNavCategory = 'Security';
        break;
      case 'vehicletypes':
      case 'vehicle_types':
        _selectedNavCategory = 'Vehicle Types';
        break;
      case 'pricing':
        _selectedNavCategory = 'Pricing';
        break;
      case 'cancellation':
        _selectedNavCategory = 'Cancellation';
        break;
      case 'system':
        _selectedNavCategory = 'System';
        break;
      default:
        _selectedNavCategory = 'Admin Profile';
    }
  }

  // Admin Profile Controllers
  final _profileNameCtrl = TextEditingController(text: 'Super Admin');
  final _profileEmailCtrl = TextEditingController(text: 'admin@tbmovehub.com');
  final _profilePhoneCtrl = TextEditingController(text: '089-999-8888');

  // Security Controllers
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Pricing Controllers
  final _motoBaseCtrl = TextEditingController(text: '30');
  final _motoKmCtrl = TextEditingController(text: '5');
  final _carBaseCtrl = TextEditingController(text: '50');
  final _carKmCtrl = TextEditingController(text: '8');
  final _vanBaseCtrl = TextEditingController(text: '80');
  final _vanKmCtrl = TextEditingController(text: '12');

  // Cancellation Settings
  bool _enableCustomerCancel = true;
  final _feeBeforeAcceptCtrl = TextEditingController(text: '0');
  final _feeAfterAcceptCtrl = TextEditingController(text: '20');

  // System Settings Switches
  bool _maintenanceMode = false;
  bool _newRegistration = true;
  bool _driverRegistration = true;
  bool _notifications = true;

  @override
  void dispose() {
    _profileNameCtrl.dispose();
    _profileEmailCtrl.dispose();
    _profilePhoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _motoBaseCtrl.dispose();
    _motoKmCtrl.dispose();
    _carBaseCtrl.dispose();
    _carKmCtrl.dispose();
    _vanBaseCtrl.dispose();
    _vanKmCtrl.dispose();
    _feeBeforeAcceptCtrl.dispose();
    _feeAfterAcceptCtrl.dispose();
    super.dispose();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddVehicleTypeModal() {
    final nameCtrl = TextEditingController();
    final basePriceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🚗 เพิ่มประเภทรถ (Add Vehicle Type)', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 14),
                Text('ชื่อประเภทรถ (เช่น Truck, EV Car):', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'กรอกชื่อประเภทรถ',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
                const SizedBox(height: 14),
                Text('ค่าบริการเริ่มต้น (Base Price ฿):', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                const SizedBox(height: 6),
                TextField(
                  controller: basePriceCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'เช่น 120',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        _showSuccessSnackbar('✅ เพิ่มประเภทรถใหม่เรียบร้อยแล้ว');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
                      child: Text('เพิ่มประเภทรถ', style: GoogleFonts.kanit()),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Text('⚙️ Settings (ตั้งค่าระบบและกำหนดราคา)', style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),

          // Structured Categorized Navigation Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryTab('Admin Profile', '👤 Admin Profile', const Color(0xFF3B82F6)),
                const SizedBox(width: 10),
                _buildCategoryTab('Security', '🔐 Security', const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _buildCategoryTab('Vehicle Types', '🚗 Vehicle Types', const Color(0xFF8B5CF6)),
                const SizedBox(width: 10),
                _buildCategoryTab('Pricing', '💵 Pricing', const Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                _buildCategoryTab('Cancellation', '❌ Cancellation', Colors.redAccent),
                const SizedBox(width: 10),
                _buildCategoryTab('System', '🖥️ System', Colors.cyanAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Render Selected Category View
          if (_selectedNavCategory == 'Admin Profile')
            _buildAdminProfileSection()
          else if (_selectedNavCategory == 'Security')
            _buildSecuritySection()
          else if (_selectedNavCategory == 'Vehicle Types')
            _buildVehicleTypesSection()
          else if (_selectedNavCategory == 'Pricing')
            _buildPricingSection()
          else if (_selectedNavCategory == 'Cancellation')
            _buildCancellationSection()
          else if (_selectedNavCategory == 'System')
            _buildSystemSection(),
        ],
      ),
    );
  }

  // 1. Admin Profile View
  Widget _buildAdminProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👤 Admin Profile (โปรไฟล์ผู้ดูแลระบบ)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),

          // Avatar Card
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFF1C7FF6),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Super Admin', style: GoogleFonts.kanit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('admin@tbmovehub.com • สิทธิ์สูงสุดทุกระบบ', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Inputs
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField('Name (ชื่อ-นามสกุล)', _profileNameCtrl),
                const SizedBox(height: 14),
                _buildInputField('Email (อีเมล)', _profileEmailCtrl),
                const SizedBox(height: 14),
                _buildInputField('Phone (เบอร์โทรศัพท์)', _profilePhoneCtrl),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showSuccessSnackbar('✅ บันทึกการแก้ไขข้อมูลโปรไฟล์เรียบร้อยแล้ว'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  child: Text('Save Changes (บันทึกข้อมูล)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Security View
  Widget _buildSecuritySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔐 Security (เปลี่ยนรหัสผ่านและความปลอดภัย)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField('Current Password (รหัสผ่านปัจจุบัน)', _currentPassCtrl, isObscure: true),
                const SizedBox(height: 14),
                _buildInputField('New Password (รหัสผ่านใหม่)', _newPassCtrl, isObscure: true),
                const SizedBox(height: 14),
                _buildInputField('Confirm Password (ยืนยันรหัสผ่านใหม่)', _confirmPassCtrl, isObscure: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _currentPassCtrl.clear();
                    _newPassCtrl.clear();
                    _confirmPassCtrl.clear();
                    _showSuccessSnackbar('✅ เปลี่ยนรหัสผ่านเรียบร้อยแล้ว');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  child: Text('Change Password (เปลี่ยนรหัสผ่าน)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Vehicle Types View
  Widget _buildVehicleTypesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🚗 Vehicle Types (จัดการประเภทรถที่ให้บริการ)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: _showAddVehicleTypeModal,
                icon: const Icon(Icons.add, size: 18),
                label: Text('+ Add Vehicle Type', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table
          SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
              columns: [
                DataColumn(label: Text('Type', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                DataColumn(label: Text('Base Price', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
              ],
              rows: [
                _buildVehicleTypeRow('Motorcycle (มอเตอร์ไซค์)', '฿30', 'Active'),
                _buildVehicleTypeRow('Car (รถเก๋ง 4 ประตู)', '฿50', 'Active'),
                _buildVehicleTypeRow('Van (รถตู้ทึบ)', '฿80', 'Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Pricing View (Critical for Order API calculation)
  Widget _buildPricingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('💵 Pricing (กำหนดอัตราค่าบริการคำนวณราคา Order)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () => _showSuccessSnackbar('✅ บันทึกอัตราค่าบริการใหม่สำหรับคำนวณ API เรียบร้อยแล้ว'),
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text('Save (บันทึกราคา)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('⚠️ ตรงนี้สำคัญ: Flutter Mobile App & Web จะเรียก API อ้างอิงตารางราคานี้เพื่อคำนวณราคา Order ทันที', style: GoogleFonts.kanit(color: Colors.amberAccent, fontSize: 12)),
          const SizedBox(height: 20),

          // Pricing Cards per Vehicle Type
          Row(
            children: [
              Expanded(child: _buildPricingVehicleCard('Motorcycle', '🏍️ มอเตอร์ไซค์', _motoBaseCtrl, _motoKmCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildPricingVehicleCard('Car', '🚗 รถเก๋ง 4 ประตู', _carBaseCtrl, _carKmCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildPricingVehicleCard('Van', '🚐 รถตู้ทึบ', _vanBaseCtrl, _vanKmCtrl)),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Cancellation View
  Widget _buildCancellationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('❌ Cancellation Rules (กฎและค่าธรรมเนียมการยกเลิก)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer Cancellation (เปิดให้ลูกค้ายกเลิก)', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _enableCustomerCancel,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) => setState(() => _enableCustomerCancel = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField('Cancellation before driver accepts Fee (ก่อนคนขับรับงาน ฿)', _feeBeforeAcceptCtrl),
                const SizedBox(height: 14),
                _buildInputField('Cancellation after driver accepts Fee (หลังคนขับรับงาน ฿)', _feeAfterAcceptCtrl),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showSuccessSnackbar('✅ บันทึกเงื่อนไขค่าธรรมเนียมการยกเลิกเรียบร้อยแล้ว'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  child: Text('Save Changes (บันทึกกฎการยกเลิก)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. System Settings View
  Widget _buildSystemSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🖥️ System Settings (การตั้งค่าสถานะระบบ)', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                _buildSystemSwitchTile('Maintenance Mode (โหมดปิดปรับปรุงระบบ)', 'ปิดการสั่งซื้อชั่วคราว', _maintenanceMode, (v) => setState(() => _maintenanceMode = v)),
                const Divider(color: Color(0xFF334155)),
                _buildSystemSwitchTile('New Registration (เปิดรับสมัครลูกค้าใหม่)', 'อนุญาตให้ผู้ใช้ลงทะเบียนใหม่', _newRegistration, (v) => setState(() => _newRegistration = v)),
                const Divider(color: Color(0xFF334155)),
                _buildSystemSwitchTile('Driver Registration (เปิดรับสมัครไรเดอร์ใหม่)', 'อนุญาตให้คนขับสมัครสมาชิก', _driverRegistration, (v) => setState(() => _driverRegistration = v)),
                const Divider(color: Color(0xFF334155)),
                _buildSystemSwitchTile('Notifications (ระบบแจ้งเตือน)', 'เปิดใช้งานระบบส่งการแจ้งเตือน Push Notification', _notifications, (v) => setState(() => _notifications = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) {
              onChanged(val);
              _showSuccessSnackbar('อัปเดต $title เรียบร้อย');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingVehicleCard(String type, String label, TextEditingController baseCtrl, TextEditingController kmCtrl) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          Text('Base Price (ค่าบริการเริ่มต้น ฿)', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: baseCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
            ),
          ),
          const SizedBox(height: 12),
          Text('Price / KM (ค่าระยะทาง ฿/กม.)', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: kmCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildVehicleTypeRow(String type, String basePrice, String status) {
    return DataRow(cells: [
      DataCell(Text(type, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
      DataCell(Text(basePrice, style: GoogleFonts.kanit(color: Colors.white))),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.shade900.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)),
          child: Text(status, style: GoogleFonts.kanit(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
      DataCell(
        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 18), onPressed: () {}),
      ),
    ]);
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1), fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.kanit(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(String categoryId, String label, Color activeColor) {
    final isSelected = _selectedNavCategory == categoryId;
    return InkWell(
      onTap: () => setState(() => _selectedNavCategory = categoryId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeColor : const Color(0xFF334155), width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(color: isSelected ? Colors.white : const Color(0xFF94A3B8), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}
