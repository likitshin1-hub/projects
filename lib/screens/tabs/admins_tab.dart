import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class AdminsTab extends StatefulWidget {
  final AdminDataService dataService;

  const AdminsTab({super.key, required this.dataService});

  @override
  State<AdminsTab> createState() => _AdminsTabState();
}

class _AdminsTabState extends State<AdminsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    'ผู้ดูแลระบบ & ความปลอดภัย (Admin & Access Control)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('จัดการบัญชีผู้ดูแลระบบ กำหนดสิทธิ์ Role-Based และตรวจสอบประวัติการใช้งาน (Audit Logs)', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddAdminDialog(context),
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: Text('+ เพิ่มแอดมินใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sub Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(icon: Icon(Icons.shield_rounded, size: 18), text: 'รายชื่อผู้ดูแลระบบ (Admin Users)'),
              Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'บันทึกประวัติการทำงาน (Audit Logs)'),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 520,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Admins Table
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
                          DataColumn(label: Text('อีเมล', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('แผนก / ฝ่ายงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('บทบาท (Role)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('เข้าสู่ระบบล่าสุด', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('สถานะ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('การจัดการ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                        ],
                        rows: widget.dataService.admins.asMap().entries.map((entry) {
                          final index = entry.key;
                          final admin = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}', style: GoogleFonts.kanit())),
                              DataCell(Text(admin.name, style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                              DataCell(Text(admin.email, style: GoogleFonts.kanit())),
                              DataCell(Text(admin.department, style: GoogleFonts.kanit(fontSize: 12))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(admin.role).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    admin.role.name.toUpperCase(),
                                    style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: _getRoleColor(admin.role)),
                                  ),
                                ),
                              ),
                              DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(admin.lastLogin), style: GoogleFonts.kanit())),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: admin.isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    admin.isActive ? 'ใช้งาน' : 'ปิดใช้งาน',
                                    style: GoogleFonts.kanit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: admin.isActive ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AdminTheme.primaryBlue),
                                      tooltip: 'แก้ไขแอดมิน',
                                      onPressed: () => _showEditAdminDialog(context, admin),
                                    ),
                                    if (admin.id != 'A001')
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AdminTheme.accentRed),
                                        tooltip: 'ลบแอดมิน',
                                        onPressed: () => _confirmDeleteAdmin(context, admin),
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

                // Tab 2: Audit Logs
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: widget.dataService.auditLogs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final log = widget.dataService.auditLogs[idx];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AdminTheme.primaryBlue.withValues(alpha: 0.1),
                            child: const Icon(Icons.history_toggle_off_rounded, color: AdminTheme.primaryBlue, size: 20),
                          ),
                          title: Text('${log.action} - ${log.target}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('ดำเนินการโดย: ${log.adminName}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                          trailing: Text(DateFormat('HH:mm:ss dd/MM/yyyy').format(log.timestamp), style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminTheme.accentRed;
      case AdminRole.admin:
        return AdminTheme.primaryBlue;
      case AdminRole.staff:
        return AdminTheme.accentGreen;
      case AdminRole.auditor:
        return AdminTheme.accentOrange;
    }
  }

  void _showAddAdminDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'ฝ่ายปฏิบัติการ & ดูแลไรเดอร์');
    AdminRole selectedRole = AdminRole.staff;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('เพิ่มผู้ดูแลระบบใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'ชื่อ-นามสกุล',
                  labelStyle: GoogleFonts.kanit(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'อีเมลผู้ใช้',
                  labelStyle: GoogleFonts.kanit(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deptCtrl,
                decoration: InputDecoration(
                  labelText: 'แผนก / ฝ่ายงาน',
                  labelStyle: GoogleFonts.kanit(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AdminRole>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'ระดับสิทธิ์การใช้งาน (Role)',
                  labelStyle: GoogleFonts.kanit(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: AdminRole.staff, child: Text('Staff (พนักงานทั่วไป)')),
                  DropdownMenuItem(value: AdminRole.admin, child: Text('Admin (ผู้จัดการ)')),
                  DropdownMenuItem(value: AdminRole.auditor, child: Text('Auditor (ผู้ตรวจสอบระบบ)')),
                  DropdownMenuItem(value: AdminRole.superAdmin, child: Text('Super Admin (สูงสุด)')),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก', style: GoogleFonts.kanit()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  setState(() {
                    widget.dataService.addAdmin(nameCtrl.text, emailCtrl.text, selectedRole, deptCtrl.text);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เพิ่มแอดมิน ${nameCtrl.text} สำเร็จ')),
                  );
                }
              },
              child: Text('บันทึก', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdminDialog(BuildContext context, AdminUserModel admin) {
    final nameCtrl = TextEditingController(text: admin.name);
    final emailCtrl = TextEditingController(text: admin.email);
    final deptCtrl = TextEditingController(text: admin.department);
    AdminRole selectedRole = admin.role;
    bool isActive = admin.isActive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('แก้ไขข้อมูล: ${admin.name}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'ชื่อ-นามสกุล', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'อีเมล', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: deptCtrl, decoration: InputDecoration(labelText: 'แผนก / ฝ่ายงาน', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              DropdownButtonFormField<AdminRole>(
                initialValue: selectedRole,
                decoration: InputDecoration(labelText: 'บทบาท (Role)', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: const [
                  DropdownMenuItem(value: AdminRole.staff, child: Text('Staff')),
                  DropdownMenuItem(value: AdminRole.admin, child: Text('Admin')),
                  DropdownMenuItem(value: AdminRole.auditor, child: Text('Auditor')),
                  DropdownMenuItem(value: AdminRole.superAdmin, child: Text('Super Admin')),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val!),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text('สถานะเปิดใช้งาน', style: GoogleFonts.kanit(fontSize: 14)),
                value: isActive,
                onChanged: (val) => setDialogState(() => isActive = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  widget.dataService.updateAdmin(admin.id, nameCtrl.text, emailCtrl.text, selectedRole, deptCtrl.text, isActive);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('อัปเดตข้อมูล ${nameCtrl.text} สำเร็จ')));
              },
              child: Text('บันทึกการแก้ไข', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAdmin(BuildContext context, AdminUserModel admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ยืนยันการลบแอดมิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบบัญชีแอดมิน "${admin.name}" (${admin.email})?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () {
              setState(() => widget.dataService.deleteAdmin(admin.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ลบแอดมิน ${admin.name} เรียบร้อย')));
            },
            child: Text('ลบแอดมิน', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }
}
