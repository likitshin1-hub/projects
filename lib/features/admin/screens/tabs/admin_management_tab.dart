import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class AdminManagementTab extends ConsumerStatefulWidget {
  const AdminManagementTab({super.key});

  @override
  ConsumerState<AdminManagementTab> createState() => _AdminManagementTabState();
}

class _AdminManagementTabState extends ConsumerState<AdminManagementTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddAdminModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    AdminRole selectedRole = AdminRole.admin;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        Text('➕ เพิ่มผู้ดูแลระบบ (Add Admin Staff)', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 16),
                    Text('ชื่อ-นามสกุล', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.kanit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'กรอกชื่อ-นามสกุลเจ้าหน้าที่',
                        hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('อีเมล (Email)', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailCtrl,
                      style: GoogleFonts.kanit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'staff@tbmovehub.com',
                        hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('บทบาทและกำหนดสิทธิ์ (Role)', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF334155))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AdminRole>(
                          value: selectedRole,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: GoogleFonts.kanit(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: AdminRole.superAdmin, child: Text('👑 Super Admin (สิทธิ์สูงสุดทุกระบบ)')),
                            DropdownMenuItem(value: AdminRole.admin, child: Text('🛡️ Admin (จัดการ User, Driver, Order)')),
                            DropdownMenuItem(value: AdminRole.staff, child: Text('👤 Staff (ดูข้อมูลเป็นหลัก Read-Only)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedRole = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน', style: GoogleFonts.kanit()), backgroundColor: Colors.orange));
                              return;
                            }
                            await ref.read(adminUsersProvider.notifier).addAdmin(nameCtrl.text.trim(), emailCtrl.text.trim(), selectedRole);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ เพิ่มผู้ดูแลระบบใหม่เรียบร้อยแล้ว', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF10B981)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
                          child: Text('เพิ่ม Admin', style: GoogleFonts.kanit()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditAdminModal(AdminUserModel admin) {
    final nameCtrl = TextEditingController(text: admin.name);
    final emailCtrl = TextEditingController(text: admin.email);
    AdminRole selectedRole = admin.role;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        Text('✏️ แก้ไขข้อมูลและเปลี่ยนสิทธิ์ Admin: ${admin.name}', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 16),
                    Text('ชื่อ-นามสกุล', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.kanit(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('อีเมล (Email)', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailCtrl,
                      style: GoogleFonts.kanit(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('เปลี่ยนสิทธิ์บทบาท (Change Role)', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF334155))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AdminRole>(
                          value: selectedRole,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: GoogleFonts.kanit(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: AdminRole.superAdmin, child: Text('👑 Super Admin')),
                            DropdownMenuItem(value: AdminRole.admin, child: Text('🛡️ Admin')),
                            DropdownMenuItem(value: AdminRole.staff, child: Text('👤 Staff')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedRole = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(adminUsersProvider.notifier).updateAdmin(admin.id, nameCtrl.text.trim(), emailCtrl.text.trim(), selectedRole);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ อัปเดตข้อมูลและสิทธิ์เรียบร้อยแล้ว', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF10B981)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
                          child: Text('บันทึกการแก้ไข', style: GoogleFonts.kanit()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminsState = ref.watch(adminUsersProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Structure Privileges Reference Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildRolePermissionInfo('👑 Super Admin', 'จัดการ Admin, User, Driver, Order, Finance')),
                Container(width: 1, height: 35, color: const Color(0xFF334155)),
                Expanded(child: _buildRolePermissionInfo('🛡️ Admin', 'จัดการ User, Driver, Order')),
                Container(width: 1, height: 35, color: const Color(0xFF334155)),
                Expanded(child: _buildRolePermissionInfo('👤 Staff', 'ดูข้อมูลและรายงานสถิติเป็นหลัก (Read-Only)')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search & Add Admin Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: '🔍 ค้นหา Admin / อีเมล / บทบาท',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddAdminModal,
                icon: const Icon(Icons.add, size: 20),
                label: Text('เพิ่ม Admin', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C7FF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Admin Users DataTable
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
              child: adminsState.when(
                data: (list) {
                  final query = _searchController.text.toLowerCase();
                  var filtered = list.where((a) {
                    return a.name.toLowerCase().contains(query) || a.email.toLowerCase().contains(query) || a.role.name.toLowerCase().contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text('ไม่พบผู้ดูแลระบบ', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))));
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                      columns: [
                        DataColumn(label: Text('Admin ID', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Name', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Email', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Role', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Last Login', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      ],
                      rows: filtered.map((a) {
                        final dt = a.lastLogin;
                        final lastLoginStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                        return DataRow(cells: [
                          DataCell(Text(a.id, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text(a.name, style: GoogleFonts.kanit(color: Colors.white))),
                          DataCell(Text(a.email, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(_buildRoleBadge(a.role)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: a.isActive ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.red.shade900.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(a.isActive ? 'Active (ปกติ)' : 'Suspended (ถูกระงับ)', style: GoogleFonts.kanit(color: a.isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 12)),
                            ),
                          ),
                          DataCell(Text(lastLoginStr, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 18),
                                  onPressed: () => _showEditAdminModal(a),
                                ),
                                IconButton(
                                  icon: Icon(a.isActive ? Icons.block : Icons.check_circle, color: a.isActive ? Colors.redAccent : Colors.greenAccent, size: 18),
                                  onPressed: () async {
                                    await ref.read(adminUsersProvider.notifier).toggleSuspend(a.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('เกิดข้อผิดพลาดในการโหลดข้อมูล', style: GoogleFonts.kanit(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePermissionInfo(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(desc, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(AdminRole role) {
    Color bg;
    Color fg;
    String label;

    switch (role) {
      case AdminRole.superAdmin:
        bg = Colors.amber.shade900.withValues(alpha: 0.3);
        fg = Colors.amberAccent;
        label = '👑 Super Admin';
        break;
      case AdminRole.admin:
        bg = Colors.blue.shade900.withValues(alpha: 0.3);
        fg = Colors.blueAccent;
        label = '🛡️ Admin';
        break;
      case AdminRole.staff:
        bg = Colors.grey.shade800.withValues(alpha: 0.5);
        fg = Colors.white70;
        label = '👤 Staff';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.kanit(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
