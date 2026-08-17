import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class AdminCustomersTab extends ConsumerStatefulWidget {
  const AdminCustomersTab({super.key});

  @override
  ConsumerState<AdminCustomersTab> createState() => _AdminCustomersTabState();
}

class _AdminCustomersTabState extends ConsumerState<AdminCustomersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditCustomerModal(CustomerModel customer) {
    final nameCtrl = TextEditingController(text: customer.name);
    final emailCtrl = TextEditingController(text: customer.email);
    final phoneCtrl = TextEditingController(text: customer.phone);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('✏️ แก้ไขข้อมูลลูกค้า', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                Text('เบอร์โทรศัพท์ (Phone)', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1))),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneCtrl,
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(adminCustomersProvider.notifier).updateCustomer(
                          customer.id,
                          nameCtrl.text.trim(),
                          emailCtrl.text.trim(),
                          phoneCtrl.text.trim(),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✅ แก้ไขข้อมูลลูกค้าเรียบร้อยแล้ว', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF10B981)),
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
  }

  void _showCustomerDetailModal(CustomerModel customer) {
    final dt = customer.createdAt;
    final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('👤 Customer Detail (รายละเอียดลูกค้า)', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(radius: 24, backgroundColor: Color(0xFF3B82F6), child: Icon(Icons.person, color: Colors.white, size: 28)),
                  title: Text(customer.name, style: GoogleFonts.kanit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${customer.id}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: customer.isSuspended ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.green.shade900.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      customer.isSuspended ? 'Suspended (ถูกระงับ)' : 'Active (ปกติ)',
                      style: GoogleFonts.kanit(color: customer.isSuspended ? Colors.redAccent : Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Customer Detailed Attributes
                _buildDetailRow('อีเมล (Email):', customer.email),
                _buildDetailRow('เบอร์โทรศัพท์ (Phone):', customer.phone),
                _buildDetailRow('วันที่สมัครสมาชิก:', dateStr),
                _buildDetailRow('จำนวน Order ทั้งหมด:', '${customer.totalOrders} รายการ'),
                _buildDetailRow('ยอดใช้บริการสะสมทั้งหมด:', '฿${customer.totalSpent.toStringAsFixed(2)}'),

                const SizedBox(height: 16),
                Text('📜 Order History (ประวัติคำสั่งซื้อล่าสุด)', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      _buildHistoryRow('ORD-8821', '2026-08-16 14:20', '฿350.00', 'COMPLETED'),
                      _buildHistoryRow('ORD-8790', '2026-08-10 11:05', '฿1,200.00', 'COMPLETED'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Admin Actions Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditCustomerModal(customer);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('แก้ไขข้อมูลลูกค้า', style: GoogleFonts.kanit()),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(adminCustomersProvider.notifier).toggleSuspend(customer.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: Icon(customer.isSuspended ? Icons.check_circle : Icons.block, size: 18),
                      label: Text(customer.isSuspended ? 'ปลดระงับบัญชี' : 'ระงับบัญชีการใช้งาน', style: GoogleFonts.kanit()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customer.isSuspended ? const Color(0xFF10B981) : Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))),
          Text(value, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String orderNo, String date, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$orderNo ($date)', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
          Text('$amount [$status]', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(adminCustomersProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Toolbar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: '🔍 Search name / email / phone',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    dropdownColor: const Color(0xFF1E293B),
                    style: GoogleFonts.kanit(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('Status: ทั้งหมด')),
                      DropdownMenuItem(value: 'Active', child: Text('Status: ปกติ (Active)')),
                      DropdownMenuItem(value: 'Suspended', child: Text('Status: ถูกระงับ (Suspended)')),
                    ],
                    onChanged: (val) => setState(() => _statusFilter = val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Customers DataTable
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: customersState.when(
                data: (list) {
                  final query = _searchController.text.toLowerCase();
                  var filtered = list.where((c) {
                    final matchQuery = c.name.toLowerCase().contains(query) || c.email.toLowerCase().contains(query) || c.phone.contains(query);
                    if (_statusFilter == 'Active') return matchQuery && !c.isSuspended;
                    if (_statusFilter == 'Suspended') return matchQuery && c.isSuspended;
                    return matchQuery;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text('ไม่พบข้อมูลลูกค้าที่ค้นหา', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))));
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                      columns: [
                        DataColumn(label: Text('ID', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Name', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Email', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Phone', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Orders', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Status', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      ],
                      rows: filtered.map((c) {
                        return DataRow(cells: [
                          DataCell(Text(c.id, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text(c.name, style: GoogleFonts.kanit(color: Colors.white))),
                          DataCell(Text(c.email, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(Text(c.phone, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(Text('${c.totalOrders}', style: GoogleFonts.kanit(color: Colors.white))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: c.isSuspended ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.green.shade900.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(c.isSuspended ? 'Suspended' : 'Active', style: GoogleFonts.kanit(color: c.isSuspended ? Colors.redAccent : Colors.greenAccent, fontSize: 12)),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF3B82F6)),
                              onPressed: () => _showCustomerDetailModal(c),
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
}
