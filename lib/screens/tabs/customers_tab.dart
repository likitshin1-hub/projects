import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class CustomersTab extends StatefulWidget {
  final AdminDataService dataService;

  const CustomersTab({super.key, required this.dataService});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  int _currentSubTab = 0; // 0: Customers CRM, 1: Complaints & Disputes
  String _searchQuery = '';
  String _filterType = 'all'; // all, vip, active, suspended, high_risk
  String _complaintStatusFilter = 'all'; // all, pending, investigating, action_taken, dismissed
  String _complaintSeverityFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingComplaintsCount = widget.dataService.complaints.where((c) => c.status == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'จัดการลูกค้า & ข้อร้องเรียน (Customers & Disputes)',
                        style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (pendingComplaintsCount > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminTheme.accentRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$pendingComplaintsCount ร้องเรียนใหม่',
                            style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text('มอนิเตอร์พฤติกรรมลูกค้า, การระงับบัญชีผู้ใช้ที่ทำผิดกฎ, และศูนย์รับเรื่องร้องเรียนจากไรเดอร์', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.accentGreen,
                      side: const BorderSide(color: AdminTheme.accentGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📥 ส่งออกรายงาน Customers_and_Disputes_2026.csv เรียบร้อย')));
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text('ส่งออก CSV', style: GoogleFonts.kanit(fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAddCustomerDialog(context),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: Text('+ เพิ่มลูกค้าใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sub-Tab Switcher (Segmented View)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSubTabButton(0, Icons.people_alt_rounded, 'รายชื่อลูกค้า & พฤติกรรม (${widget.dataService.customers.length})'),
                const SizedBox(width: 4),
                _buildSubTabButton(
                  1,
                  Icons.report_problem_rounded,
                  'ศูนย์รับเรื่องร้องเรียน (Disputes)',
                  badgeCount: pendingComplaintsCount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Render Selected View
          _currentSubTab == 0 ? _buildCustomersDirectoryView(isDark) : _buildComplaintsCenterView(isDark),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(int index, IconData icon, String title, {int badgeCount = 0}) {
    final isSelected = _currentSubTab == index;

    return InkWell(
      onTap: () => setState(() => _currentSubTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.kanit(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                fontSize: 13,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AdminTheme.accentRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AdminTheme.primaryBlue : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= VIEW 1: CUSTOMERS DIRECTORY =================
  Widget _buildCustomersDirectoryView(bool isDark) {
    final customers = widget.dataService.customers;
    final suspendedCount = customers.where((c) => c.isSuspended).length;
    final highRiskCount = customers.where((c) => c.warningCount > 0 && !c.isSuspended).length;

    final filtered = customers.where((c) {
      final matchFilter = _filterType == 'all' ||
          (_filterType == 'vip' && c.isVip) ||
          (_filterType == 'active' && !c.isSuspended) ||
          (_filterType == 'suspended' && c.isSuspended) ||
          (_filterType == 'high_risk' && (c.warningCount > 0 || c.isSuspended));

      final q = _searchQuery.toLowerCase();
      final matchSearch = c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.address.toLowerCase().contains(q);

      return matchFilter && matchSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Quick Stats Row
        Row(
          children: [
            _buildStatCard('ลูกค้าทั้งหมด', '${customers.length} คน', Icons.people_outline_rounded, AdminTheme.primaryBlue),
            const SizedBox(width: 12),
            _buildStatCard('สมาชิก VIP', '${customers.where((c) => c.isVip).length} คน', Icons.workspace_premium_rounded, const Color(0xFFD97706)),
            const SizedBox(width: 12),
            _buildStatCard('กลุ่มเสี่ยง (มี Strike)', '$highRiskCount คน', Icons.warning_amber_rounded, AdminTheme.accentOrange),
            const SizedBox(width: 12),
            _buildStatCard('บัญชีที่ถูกระงับ (Banned)', '$suspendedCount คน', Icons.block_rounded, AdminTheme.accentRed, isAlert: suspendedCount > 0),
          ],
        ),
        const SizedBox(height: 16),

        // Search & Filter Bar
        Row(
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหาชื่อ, อีเมล, เบอร์โทร, ที่อยู่...',
                  hintStyle: GoogleFonts.kanit(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: 14),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('all', 'ทั้งหมด (${customers.length})'),
                _buildFilterChip('vip', '👑 VIP (${customers.where((c) => c.isVip).length})'),
                _buildFilterChip('active', 'ปกติ (${customers.where((c) => !c.isSuspended).length})'),
                _buildFilterChip('high_risk', '⚠️ พฤติกรรมเสี่ยง ($highRiskCount)'),
                _buildFilterChip('suspended', '🚫 ถูกระงับ ($suspendedCount)'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Customer Table Card
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
                  DataColumn(label: Text('ชื่อลูกค้า / สถานะพฤติกรรม', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('เบอร์โทร & อีเมล', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ที่อยู่จัดส่ง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ประวัติการสั่ง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('คะแนนพฤติกรรม', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('สถานะบัญชี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('การจัดการ & ระงับ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                ],
                rows: filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final customer = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}', style: GoogleFonts.kanit())),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(customer.name, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                                if (customer.isVip) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('VIP', style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD97706))),
                                  ),
                                ],
                              ],
                            ),
                            if (customer.warningCount > 0)
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AdminTheme.accentOrange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('⚠️ มี ${customer.warningCount} ใบเตือน', style: GoogleFonts.kanit(fontSize: 10, color: AdminTheme.accentOrange, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(customer.phone, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(customer.email, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      DataCell(SizedBox(width: 140, child: Text(customer.address, style: GoogleFonts.kanit(fontSize: 12), overflow: TextOverflow.ellipsis))),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${customer.totalOrders} คำสั่งซื้อ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('฿${customer.totalSpent.toInt()}', style: GoogleFonts.kanit(fontSize: 11, color: AdminTheme.accentGreen)),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: customer.rating < 3.0 ? AdminTheme.accentRed : Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              customer.rating.toStringAsFixed(1),
                              style: GoogleFonts.kanit(
                                fontWeight: FontWeight.bold,
                                color: customer.rating < 3.0 ? AdminTheme.accentRed : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: customer.isSuspended
                                ? AdminTheme.accentRed.withValues(alpha: 0.15)
                                : AdminTheme.accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: customer.isSuspended ? AdminTheme.accentRed.withValues(alpha: 0.4) : AdminTheme.accentGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                customer.isSuspended ? '🚫 ถูกระงับบัญชี' : '🟢 ใช้งานปกติ',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: customer.isSuspended ? AdminTheme.accentRed : AdminTheme.accentGreen,
                                ),
                              ),
                              if (customer.isSuspended && customer.suspensionDuration != null)
                                Text(
                                  '(${customer.suspensionDuration})',
                                  style: GoogleFonts.kanit(fontSize: 10, color: AdminTheme.accentRed),
                                ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.assignment_ind_rounded, size: 20, color: AdminTheme.primaryBlue),
                              tooltip: 'ดูประวัติ & รายละเอียด CRM',
                              onPressed: () => _showCustomerDetails(context, customer),
                            ),
                            if (customer.isSuspended) ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.accentGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _confirmUnsuspendCustomer(customer),
                                icon: const Icon(Icons.lock_open_rounded, size: 14),
                                label: Text('ปลดระงับ', style: GoogleFonts.kanit(fontSize: 11)),
                              ),
                            ] else ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AdminTheme.accentRed,
                                  side: const BorderSide(color: AdminTheme.accentRed),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _showSuspendCustomerModal(customer),
                                icon: const Icon(Icons.block_rounded, size: 14),
                                label: Text('ระงับบัญชี', style: GoogleFonts.kanit(fontSize: 11)),
                              ),
                            ],
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.warning_amber_rounded, size: 18, color: AdminTheme.accentOrange),
                              tooltip: 'ออกใบเตือนพฤติกรรม (Strike)',
                              onPressed: () => _showIssueWarningModal(customer),
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
      ],
    );
  }

  // ================= VIEW 2: COMPLAINTS & DISPUTES CENTER =================
  Widget _buildComplaintsCenterView(bool isDark) {
    final complaints = widget.dataService.complaints;
    final pendingList = complaints.where((c) => c.status == 'pending').toList();
    final investigatingList = complaints.where((c) => c.status == 'investigating').toList();
    final actionTakenList = complaints.where((c) => c.status == 'action_taken').toList();

    final filteredComplaints = complaints.where((c) {
      final matchStatus = _complaintStatusFilter == 'all' || c.status == _complaintStatusFilter;
      final matchSeverity = _complaintSeverityFilter == 'all' || c.severity == _complaintSeverityFilter;
      return matchStatus && matchSeverity;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dispute KPI Badges
        Row(
          children: [
            _buildStatCard('เรื่องร้องเรียนทั้งหมด', '${complaints.length} เรื่อง', Icons.inbox_rounded, Colors.blueGrey),
            const SizedBox(width: 12),
            _buildStatCard('รอการตรวจสอบด่วน', '${pendingList.length} เรื่อง', Icons.hourglass_top_rounded, AdminTheme.accentRed, isAlert: pendingList.isNotEmpty),
            const SizedBox(width: 12),
            _buildStatCard('กำลังไต่สวนข้อเท็จจริง', '${investigatingList.length} เรื่อง', Icons.plagiarism_rounded, AdminTheme.accentOrange),
            const SizedBox(width: 12),
            _buildStatCard('ดำเนินการลงโทษ/ระงับแล้ว', '${actionTakenList.length} เรื่อง', Icons.gavel_rounded, AdminTheme.accentGreen),
          ],
        ),
        const SizedBox(height: 16),

        // Complaint Filters
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text('ทั้งหมด (${complaints.length})', style: GoogleFonts.kanit(fontSize: 12)),
                  selected: _complaintStatusFilter == 'all',
                  onSelected: (_) => setState(() => _complaintStatusFilter = 'all'),
                ),
                ChoiceChip(
                  label: Text('🚨 รอตรวจสอบ (${pendingList.length})', style: GoogleFonts.kanit(fontSize: 12)),
                  selected: _complaintStatusFilter == 'pending',
                  selectedColor: AdminTheme.accentRed,
                  onSelected: (_) => setState(() => _complaintStatusFilter = 'pending'),
                ),
                ChoiceChip(
                  label: Text('🔍 กำลังไต่สวน (${investigatingList.length})', style: GoogleFonts.kanit(fontSize: 12)),
                  selected: _complaintStatusFilter == 'investigating',
                  selectedColor: AdminTheme.accentOrange,
                  onSelected: (_) => setState(() => _complaintStatusFilter = 'investigating'),
                ),
                ChoiceChip(
                  label: Text('✅ ดำเนินการแล้ว (${actionTakenList.length})', style: GoogleFonts.kanit(fontSize: 12)),
                  selected: _complaintStatusFilter == 'action_taken',
                  selectedColor: AdminTheme.accentGreen,
                  onSelected: (_) => setState(() => _complaintStatusFilter = 'action_taken'),
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_rounded),
              tooltip: 'กรองระดับความรุนแรง',
              onSelected: (val) => setState(() => _complaintSeverityFilter = val),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'all', child: Text('ความรุนแรง: ทั้งหมด')),
                const PopupMenuItem(value: 'critical', child: Text('🔴 วิกฤต (Critical)')),
                const PopupMenuItem(value: 'high', child: Text('🟠 สูง (High)')),
                const PopupMenuItem(value: 'medium', child: Text('🟡 ปานกลาง (Medium)')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Complaint Cards List
        if (filteredComplaints.isEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 48, color: AdminTheme.accentGreen),
                const SizedBox(height: 10),
                Text('ไม่มีเรื่องร้องเรียนที่ค้างอยู่ในหมวดหมู่นี้', style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredComplaints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final ticket = filteredComplaints[idx];
              return _buildComplaintTicketCard(ticket, isDark);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildComplaintTicketCard(ComplaintTicket ticket, bool isDark) {
    Color severityColor;
    String severityLabel;

    switch (ticket.severity) {
      case 'critical':
        severityColor = AdminTheme.accentRed;
        severityLabel = '🔴 วิกฤต (Critical)';
        break;
      case 'high':
        severityColor = AdminTheme.accentOrange;
        severityLabel = '🟠 สูง (High)';
        break;
      default:
        severityColor = Colors.amber;
        severityLabel = '🟡 ปานกลาง (Medium)';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: ticket.status == 'pending'
              ? AdminTheme.accentRed.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Ticket ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AdminTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ticket.id,
                        style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        severityLabel,
                        style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: severityColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'คำสั่งซื้อ: ${ticket.orderNo}',
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                _buildComplaintStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 12),

            // Category & Description
            Text(
              'หมวดหมู่: ${ticket.category}',
              style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description,
              style: GoogleFonts.kanit(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 10),

            // Evidence Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, size: 16, color: AdminTheme.primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'หลักฐานที่แนบมา: ${ticket.evidenceSummary}',
                      style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Parties Row: Reporter vs Accused
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ผู้ร้องเรียน (${ticket.reporterType}):', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                        Text(ticket.reporterName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('โทร: ${ticket.reporterPhone}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminTheme.accentRed.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.accentRed.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ลูกค้าผู้ถูกร้องเรียน (Accused):', style: GoogleFonts.kanit(fontSize: 11, color: AdminTheme.accentRed)),
                        Text(ticket.accusedCustomerName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('โทร: ${ticket.accusedCustomerPhone}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (ticket.actionTakenNotes != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.accentGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_rounded, size: 16, color: AdminTheme.accentGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'บันทึกการลงโทษ: ${ticket.actionTakenNotes}',
                        style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.accentGreen, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'แจ้งเมื่อ: ${DateFormat('d MMM yyyy HH:mm').format(ticket.createdAt)}',
                  style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showContactPartiesDialog(ticket),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                      label: Text('โทรสอบสวน', style: GoogleFonts.kanit(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showTakeActionOnDisputeModal(ticket),
                      icon: const Icon(Icons.gavel_rounded, size: 14),
                      label: Text('พิจารณาและลงโทษ', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'pending':
        bg = AdminTheme.accentRed;
        fg = Colors.white;
        label = '🚨 รอตรวจสอบ';
        break;
      case 'investigating':
        bg = AdminTheme.accentOrange;
        fg = Colors.white;
        label = '🔍 กำลังไต่สวน';
        break;
      case 'action_taken':
        bg = AdminTheme.accentGreen;
        fg = Colors.white;
        label = '✅ ดำเนินการแล้ว';
        break;
      default:
        bg = Colors.grey;
        fg = Colors.white;
        label = 'ยกคำร้อง';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAlert ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: isAlert ? 0.6 : 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(value, style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _filterType == type;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label, style: GoogleFonts.kanit(fontSize: 12)),
      onSelected: (_) => setState(() => _filterType = type),
    );
  }

  // ================= MODALS & ACTIONS =================
  void _showSuspendCustomerModal(CustomerModel customer) {
    String selectedReason = 'ปฏิเสธชำระเงินปลายทาง (COD Reject)';
    String selectedDuration = '30 วัน';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.block_rounded, color: AdminTheme.accentRed),
              const SizedBox(width: 8),
              Text('ระงับบัญชีผู้ใช้: ${customer.name}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('เบอร์โทรศัพท์: ${customer.phone} • บัญชี ID: ${customer.id}', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Text('สาเหตุการระงับการใช้งาน:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'ปฏิเสธชำระเงินปลายทาง (COD Reject)', child: Text('ปฏิเสธชำระเงินปลายทาง (COD Reject)')),
                    DropdownMenuItem(value: 'ใช้ถ้อยคำหยาบคาย / ข่มขู่ไรเดอร์ (Verbal Abuse)', child: Text('ใช้ถ้อยคำหยาบคาย / ข่มขู่ไรเดอร์')),
                    DropdownMenuItem(value: 'สร้างออเดอร์ปลอม / แกล้งสั่ง (Fake Orders)', child: Text('สร้างออเดอร์ปลอม / แกล้งสั่ง')),
                    DropdownMenuItem(value: 'ฝากส่งพัสดุอันตราย / ผิดกฎหมาย (Illegal Parcel)', child: Text('ฝากส่งพัสดุอันตราย / ผิดกฎหมาย')),
                    DropdownMenuItem(value: 'ยกเลิกคำสั่งซื้อบ่อยครั้งโดยไม่มีเหตุผล', child: Text('ยกเลิกคำสั่งซื้อบ่อยครั้งโดยไม่มีเหตุผล')),
                    DropdownMenuItem(value: 'อื่นๆ (ตามดุลยพินิจฝ่ายตรวจสอบ)', child: Text('อื่นๆ (ตามดุลยพินิจฝ่ายตรวจสอบ)')),
                  ],
                  onChanged: (val) => setModalState(() => selectedReason = val!),
                ),
                const SizedBox(height: 12),
                Text('ระยะเวลาการระงับ:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedDuration,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true),
                  items: const [
                    DropdownMenuItem(value: '7 วัน', child: Text('7 วัน (ตักเตือนขั้นต้น)')),
                    DropdownMenuItem(value: '30 วัน', child: Text('30 วัน (พฤติกรรมร้ายแรงปานกลาง)')),
                    DropdownMenuItem(value: '90 วัน', child: Text('90 วัน (พฤติกรรมร้ายแรงมาก)')),
                    DropdownMenuItem(value: 'ถาวร (Permanent Ban)', child: Text('🚫 ถาวร (Permanent Ban ขึ้นบัญชีดำ)')),
                  ],
                  onChanged: (val) => setModalState(() => selectedDuration = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'หมายเหตุเพิ่มเติมสำหรับแอดมิน (Admin Notes)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentRed, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  widget.dataService.suspendCustomer(customer.id, selectedReason, selectedDuration);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🚫 ระงับการใช้งานบัญชี ${customer.name} ($selectedDuration) เรียบร้อย')),
                );
              },
              child: Text('ยืนยันการระงับบัญชี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUnsuspendCustomer(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_open_rounded, color: AdminTheme.accentGreen),
            const SizedBox(width: 8),
            Text('ยืนยันการปลดระงับบัญชี', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'คุณต้องการปลดการระงับบัญชีของ ${customer.name} (${customer.phone}) และอนุญาตให้สั่งงานในระบบ TB MoveHub ตามปกติหรือไม่?',
          style: GoogleFonts.kanit(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentGreen, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                widget.dataService.unsuspendCustomer(customer.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ ปลดระงับบัญชี ${customer.name} เรียบร้อย')),
              );
            },
            child: Text('ยืนยันปลดระงับ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showIssueWarningModal(CustomerModel customer) {
    String reason = 'ยกเลิกคำสั่งซื้อหลังจากไรเดอร์รับงานแล้ว';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AdminTheme.accentOrange),
            const SizedBox(width: 8),
            Text('ออกใบเตือนพฤติกรรม (Issue Strike)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ออกใบเตือนให้กับ: ${customer.name} (${customer.phone})', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
            Text('ปัจจุบันมีสะสม: ${customer.warningCount} ใบเตือน (หากครบ 3 ครั้งระบบจะแนะนำให้ระงับบัญชี)', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'ระบุพฤติกรรมที่ไม่เหมาะสม / สาเหตุการเตือน',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => reason = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentOrange, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                widget.dataService.issueCustomerWarning(customer.id, reason);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('⚠️ ออกใบเตือน (Strike ${customer.warningCount}) ให้กับ ${customer.name} เรียบร้อย')),
              );
            },
            child: Text('ออกใบเตือนทันที', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showTakeActionOnDisputeModal(ComplaintTicket ticket) {
    String actionType = 'suspend_30';
    final notesCtrl = TextEditingController(text: 'แอดมินตรวจสอบหลักฐานครบถ้วนและดำเนินการลงโทษตามกฎระเบียบ TB MoveHub');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.gavel_rounded, color: AdminTheme.accentRed),
              const SizedBox(width: 8),
              Text('พิจารณาและลงโทษ: ${ticket.id}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ผู้ถูกร้องเรียน: ${ticket.accusedCustomerName} (${ticket.accusedCustomerPhone})', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('หมวดหมู่ข้อร้องเรียน: ${ticket.category}', style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.accentRed)),
                const Divider(height: 16),
                Text('เลือกมาตรการลงโทษ:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                RadioListTile<String>(
                  title: Text('🚫 ระงับการใช้งาน 30 วัน', style: GoogleFonts.kanit(fontSize: 13)),
                  value: 'suspend_30',
                  groupValue: actionType,
                  onChanged: (val) => setModalState(() => actionType = val!),
                ),
                RadioListTile<String>(
                  title: Text('🚫 แบนถาวร (Permanent Ban ขึ้นบัญชีดำ)', style: GoogleFonts.kanit(fontSize: 13)),
                  value: 'suspend_perm',
                  groupValue: actionType,
                  onChanged: (val) => setModalState(() => actionType = val!),
                ),
                RadioListTile<String>(
                  title: Text('⚠️ ออกใบเตือน Strike และชดเชยค่าบริการให้ไรเดอร์', style: GoogleFonts.kanit(fontSize: 13)),
                  value: 'warning_strike',
                  groupValue: actionType,
                  onChanged: (val) => setModalState(() => actionType = val!),
                ),
                RadioListTile<String>(
                  title: Text('ยกคำร้อง (หลักฐานไม่เพียงพอ / ไม่มีมูล)', style: GoogleFonts.kanit(fontSize: 13)),
                  value: 'dismiss',
                  groupValue: actionType,
                  onChanged: (val) => setModalState(() => actionType = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'บันทึกการตัดสินของแอดมิน',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentRed, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  if (actionType == 'suspend_30') {
                    widget.dataService.suspendCustomer(ticket.accusedCustomerId, ticket.category, '30 วัน');
                    widget.dataService.updateComplaintStatus(ticket.id, 'action_taken', 'ระงับบัญชี 30 วัน: ${notesCtrl.text}');
                  } else if (actionType == 'suspend_perm') {
                    widget.dataService.suspendCustomer(ticket.accusedCustomerId, ticket.category, 'ถาวร (Permanent)');
                    widget.dataService.updateComplaintStatus(ticket.id, 'action_taken', 'แบนถาวร: ${notesCtrl.text}');
                  } else if (actionType == 'warning_strike') {
                    widget.dataService.issueCustomerWarning(ticket.accusedCustomerId, ticket.category);
                    widget.dataService.updateComplaintStatus(ticket.id, 'action_taken', 'ออกใบเตือน Strike: ${notesCtrl.text}');
                  } else {
                    widget.dataService.updateComplaintStatus(ticket.id, 'dismissed', 'ยกคำร้อง: ${notesCtrl.text}');
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('⚖️ ดำเนินการตัดสินข้อร้องเรียน ${ticket.id} เรียบร้อย')),
                );
              },
              child: Text('บันทึกคำตัดสิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactPartiesDialog(ComplaintTicket ticket) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VoIPInvestigationCallDialog(
        ticket: ticket,
        dataService: widget.dataService,
        onAdjudicateRequested: () {
          _showTakeActionOnDisputeModal(ticket);
        },
      ),
    );
  }
  void _showCustomerDetails(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_outline_rounded, color: AdminTheme.primaryBlue),
            const SizedBox(width: 8),
            Text('ข้อมูลเชิงลึก CRM: ${customer.name}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('รหัสลูกค้า:', customer.id),
              _buildDetailRow('สถานะสมาชิก:', customer.isVip ? '👑 VIP Member (สมาชิกพิเศษ)' : 'Regular Member (ทั่วไป)'),
              _buildDetailRow('อีเมล:', customer.email),
              _buildDetailRow('เบอร์โทรศัพท์:', customer.phone),
              _buildDetailRow('ที่อยู่หลัก:', customer.address),
              _buildDetailRow('จำนวนออเดอร์สะสม:', '${customer.totalOrders} ครั้ง'),
              _buildDetailRow('ยอดใช้จ่ายรวม:', '฿ ${customer.totalSpent.toInt()} บาท'),
              _buildDetailRow('คะแนนพฤติกรรม:', '⭐ ${customer.rating.toStringAsFixed(1)} / 5.0'),
              _buildDetailRow('ประวัติใบเตือน (Strikes):', '${customer.warningCount} ครั้ง'),
              _buildDetailRow('วันที่สมัครสมาชิก:', DateFormat('d MMMM yyyy').format(customer.createdAt)),
              _buildDetailRow(
                'สถานะบัญชี:',
                customer.isSuspended
                    ? '🚫 ถูกระงับ (${customer.suspensionDuration ?? "ระงับชั่วคราว"}) - ${customer.suspensionReason ?? ""}'
                    : '🟢 บัญชีปกติ',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
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
          SizedBox(width: 150, child: Text(label, style: GoogleFonts.kanit(color: Colors.grey, fontSize: 12))),
          Expanded(child: Text(value, style: GoogleFonts.kanit(fontWeight: FontWeight.w500, fontSize: 12))),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool isVip = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person_add_rounded, color: AdminTheme.primaryBlue),
              const SizedBox(width: 8),
              Text('เพิ่มข้อมูลลูกค้าใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'ชื่อ-นามสกุล / บริษัท', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'อีเมล', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'เบอร์โทรศัพท์', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: addressCtrl, maxLines: 2, decoration: InputDecoration(labelText: 'ที่อยู่หลัก', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true)),
                const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('เป็นสมาชิก VIP พิเศษ', style: GoogleFonts.kanit(fontSize: 13)),
                  value: isVip,
                  onChanged: (val) => setModalState(() => isVip = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                setState(() {
                  widget.dataService.addCustomer(nameCtrl.text, emailCtrl.text, phoneCtrl.text, addressCtrl.text, isVip: isVip);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มลูกค้าใหม่เรียบร้อย')));
              },
              child: Text('บันทึก', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }
}


// -------------------------------------------------------------
// VOIP INVESTIGATION PHONE CALL DIALOG
// -------------------------------------------------------------
class _VoIPInvestigationCallDialog extends StatefulWidget {
  final ComplaintTicket ticket;
  final AdminDataService dataService;
  final VoidCallback onAdjudicateRequested;

  const _VoIPInvestigationCallDialog({
    required this.ticket,
    required this.dataService,
    required this.onAdjudicateRequested,
  });

  @override
  State<_VoIPInvestigationCallDialog> createState() => _VoIPInvestigationCallDialogState();
}

class _VoIPInvestigationCallDialogState extends State<_VoIPInvestigationCallDialog> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  Timer? _callTimer;
  int _callSeconds = 0;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeaker = true;
  bool _isRecording = true;
  String _activeParty = 'accused'; // 'accused' or 'reporter'
  final TextEditingController _callNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate connecting within 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _callNotesCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _switchParty(String party) {
    if (_activeParty == party) return;
    setState(() {
      _activeParty = party;
      _isConnected = false;
      _callSeconds = 0;
      _callTimer?.cancel();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAccused = _activeParty == 'accused';
    final targetName = isAccused ? widget.ticket.accusedCustomerName : widget.ticket.reporterName;
    final targetPhone = isAccused ? widget.ticket.accusedCustomerPhone : widget.ticket.reporterPhone;
    final targetRole = isAccused ? 'ลูกค้าผู้ถูกร้องเรียน (Accused)' : 'ผู้ร้องเรียน (${widget.ticket.reporterType})';
    final targetColor = isAccused ? AdminTheme.accentRed : AdminTheme.primaryBlue;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Container(
        width: 680,
        height: 640,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Top Bar: Call Status & Switch Party Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isConnected ? AdminTheme.accentGreen.withValues(alpha: 0.15) : AdminTheme.accentOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isConnected ? AdminTheme.accentGreen : AdminTheme.accentOrange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isConnected ? AdminTheme.accentGreen : AdminTheme.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isConnected ? 'สนทนาสด (${_formatDuration(_callSeconds)})' : 'กำลังโทรออก...',
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isConnected ? AdminTheme.accentGreen : AdminTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminTheme.accentRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.fiber_manual_record_rounded, size: 10, color: AdminTheme.accentRed),
                              const SizedBox(width: 4),
                              Text('REC บันทึกเสียง', style: GoogleFonts.kanit(fontSize: 10, color: AdminTheme.accentRed, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Party Switcher Buttons
                  Row(
                    children: [
                      Text('สลับสายสนทนา:', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text('👤 ลูกค้า (ผู้ถูกร้องเรียน)', style: GoogleFonts.kanit(fontSize: 11)),
                        selected: _activeParty == 'accused',
                        selectedColor: AdminTheme.accentRed,
                        onSelected: (_) => _switchParty('accused'),
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: Text('🛵 ไรเดอร์ (ผู้ร้องเรียน)', style: GoogleFonts.kanit(fontSize: 11)),
                        selected: _activeParty == 'reporter',
                        selectedColor: AdminTheme.primaryBlue,
                        onSelected: (_) => _switchParty('reporter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Caller Visual & Voice Waveform
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar with Ripple Radar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isConnected)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 96 + (_pulseController.value * 28),
                                height: 96 + (_pulseController.value * 28),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: targetColor.withValues(alpha: (1.0 - _pulseController.value) * 0.3),
                                ),
                              );
                            },
                          ),
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: targetColor,
                          child: Text(
                            targetName.isNotEmpty ? targetName.substring(0, targetName.length > 2 ? 2 : 1) : 'ID',
                            style: GoogleFonts.kanit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Caller Details
                    Text(
                      targetName,
                      style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$targetPhone • $targetRole',
                      style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: targetColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'คดีร้องเรียน: ${widget.ticket.id} (${widget.ticket.category}) • ออเดอร์ ${widget.ticket.orderNo}',
                        style: GoogleFonts.kanit(fontSize: 11, color: targetColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sound Wave Visualizer Bars
                    if (_isConnected)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(16, (index) {
                              final waveOffset = (math.sin((_waveController.value * 2 * math.pi) + (index * 0.4)) + 1) / 2;
                              final barHeight = 8.0 + (waveOffset * 24.0);
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 4,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: targetColor.withValues(alpha: 0.6 + (waveOffset * 0.4)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          );
                        },
                      )
                    else
                      Text('กำลังเชื่อมสัญญาณ RTK VoIP...', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),

                    const SizedBox(height: 16),

                    // Live Investigation Statement Notes Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.edit_note_rounded, size: 18, color: AdminTheme.primaryBlue),
                                  const SizedBox(width: 6),
                                  Text('บันทึกคำให้การและการไต่สวนสด (Live Case Notes):', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text('ระบบบันทึกอัตโนมัติ', style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _callNotesCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'พิมพ์สรุปปากคำของคู่กรณี หรือคลิกข้อความลัดด้านล่าง...',
                              hintStyle: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.all(10),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildQuickTag('🗣️ คู่กรณียอมรับข้อกล่าวหา'),
                              _buildQuickTag('📦 ยืนยันพัสดุเสียหายจริง'),
                              _buildQuickTag('🤝 ยินยอมชดใช้ค่าเสียหาย'),
                              _buildQuickTag('🚫 ปฏิเสธและไม่ให้ความร่วมมือ'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // In-Call Controls Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mute Button
                  _buildCallControlButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'เปิดไมค์' : 'ปิดไมค์',
                    color: _isMuted ? AdminTheme.accentRed : Colors.grey,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),

                  // Speaker Button
                  _buildCallControlButton(
                    icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    label: _isSpeaker ? 'ลำโพง HD' : 'หูฟัง',
                    color: _isSpeaker ? AdminTheme.primaryBlue : Colors.grey,
                    onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                  ),

                  // Record Toggle
                  _buildCallControlButton(
                    icon: _isRecording ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    label: _isRecording ? 'กำลังอัดเสียง' : 'เริ่มอัดเสียง',
                    color: _isRecording ? AdminTheme.accentRed : Colors.grey,
                    onTap: () => setState(() => _isRecording = !_isRecording),
                  ),

                  // Keypad
                  _buildCallControlButton(
                    icon: Icons.dialpad_rounded,
                    label: 'แป้นตัวเลข',
                    color: Colors.grey,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ส่งสัญญาณเสียง DTMF พร้อมใช้งาน'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),

                  // End Call & Adjudicate
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.accentRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('📞 วางสายเรียบร้อย (${_formatDuration(_callSeconds)}) • บันทึกคำให้การพร้อมส่งต่อคำตัดสิน')),
                      );
                      widget.onAdjudicateRequested();
                    },
                    icon: const Icon(Icons.call_end_rounded, size: 18),
                    label: Text('วางสายและไปหน้าตัดสิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTag(String label) {
    return ActionChip(
      label: Text(label, style: GoogleFonts.kanit(fontSize: 10)),
      padding: EdgeInsets.zero,
      onPressed: () {
        final current = _callNotesCtrl.text;
        _callNotesCtrl.text = current.isEmpty ? label : '$current\n• $label';
      },
    );
  }
}


