import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/admin_provider.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedTabIndex = 0; // 0=Overview, 1=Driver Approvals, 2=Orders, 3=Users
  final TextEditingController _rejectReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  void _showDriverDocumentModal(PendingDriverApplication driver) {
    final isDarkMode = ref.read(themeProvider);
    final bg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ตรวจสอบเอกสารใบสมัครคนขับ: ${driver.fullName}',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // Driver Info Grid
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _buildInfoItem('ชื่อ-นามสกุล', driver.fullName, isDarkMode),
                      _buildInfoItem('เบอร์โทรศัพท์', driver.phone, isDarkMode),
                      _buildInfoItem('อีเมล', driver.email, isDarkMode),
                      _buildInfoItem('ประเภทรถ', driver.vehicleType, isDarkMode),
                      _buildInfoItem('ยี่ห้อ/รุ่น', '${driver.brand} ${driver.model}', isDarkMode),
                      _buildInfoItem('ทะเบียนรถ', driver.plate, isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'ไฟล์เอกสารและรูปถ่ายที่อัปโหลด:',
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Documents Preview Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildDocPreviewCard('บัตรประชาชน', driver.idCardUrl, isDarkMode),
                      _buildDocPreviewCard('ใบขับขี่', driver.driverLicenseUrl, isDarkMode),
                      _buildDocPreviewCard('เล่มทะเบียนรถ', driver.vehicleDocUrl, isDarkMode),
                      _buildDocPreviewCard('สมุดบัญชีธนาคาร', driver.bankBookUrl, isDarkMode),
                      _buildDocPreviewCard('รูปถ่ายรถยนต์', driver.vehiclePhotoUrl, isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        label: Text('ปฏิเสธใบสมัคร', style: GoogleFonts.kanit(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showRejectConfirmationModal(driver);
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                        label: Text('อนุมัติเป็นคนขับพาร์ทเนอร์', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final success = await ref.read(adminProvider.notifier).approveDriver(driver.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('อนุมัติคุณ ${driver.fullName} เป็นคนขับพาร์ทเนอร์สำเร็จแล้ว!', style: GoogleFonts.kanit()),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRejectConfirmationModal(PendingDriverApplication driver) {
    final isDarkMode = ref.read(themeProvider);
    _rejectReasonController.text = 'เอกสารรูปถ่ายไม่ชัดเจน';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'ระบุเหตุผลในการปฏิเสธใบสมัคร',
            style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
          ),
          content: TextField(
            controller: _rejectReasonController,
            style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'กรอกเหตุผล (เช่น รูปถ่ายบัตรประชาชนไม่ชัดเจน)...',
              hintStyle: GoogleFonts.kanit(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: GoogleFonts.kanit()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref.read(adminProvider.notifier).rejectDriver(driver.id, _rejectReasonController.text);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ปฏิเสธใบสมัครของคุณ ${driver.fullName} เรียบร้อยแล้ว', style: GoogleFonts.kanit()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('ยืนยันปฏิเสธ', style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, bool isDarkMode) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDocPreviewCard(String title, String imageUrl, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.grey.shade300 : Colors.black87)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: 190,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 190,
              height: 120,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(Icons.insert_drive_file_rounded, color: Colors.grey, size: 36),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final adminState = ref.watch(adminProvider);

    final bg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final sidebarBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final stats = adminState.stats;

    return Scaffold(
      backgroundColor: bg,
      body: Row(
        children: [
          // ==========================================
          // ADMIN SIDEBAR NAVIGATION
          // ==========================================
          Container(
            width: 240,
            color: sidebarBg,
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Brand Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7FF6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'TB Move Hub\nADMIN WEB',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(height: 1),

                // Nav Items
                _buildNavItem(0, Icons.dashboard_rounded, 'ภาพรวมระบบ (Overview)'),
                _buildNavItem(1, Icons.how_to_reg_rounded, 'อนุมัติคนขับ (Approvals)', badgeCount: stats?.pendingDriverApplications),
                _buildNavItem(2, Icons.local_shipping_rounded, 'การจัดส่ง (Live Orders)'),
                _buildNavItem(3, Icons.people_alt_rounded, 'ผู้ใช้งาน (Users & Drivers)'),

                const Spacer(),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
                  title: Text('กลับหน้าแอปหลัก', style: GoogleFonts.kanit(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () => context.go(AppRoutes.home),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ==========================================
          // DASHBOARD CONTENT AREA
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Welcome Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'แผงควบคุมผู้ดูแลระบบ (Admin Dashboard)',
                            style: GoogleFonts.kanit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'ระบบบริหารจัดการออเดอร์ การอนุมัติคนขับพาร์ทเนอร์ และสถิติแพลตฟอร์มแบบเรียลไทม์',
                            style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1C7FF6)),
                        onPressed: () => ref.read(adminProvider.notifier).refreshData(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 1. KPI CARDS
                  // ==========================================
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildKpiCard('ออเดอร์ทั้งหมดวันนี้', '${stats?.totalOrdersToday ?? 0} งาน', Icons.shopping_bag_rounded, const Color(0xFF3B82F6), cardBg, isDarkMode),
                      _buildKpiCard('รายได้รวมแพลตฟอร์ม', '฿${stats?.totalRevenueToday.toStringAsFixed(2) ?? '0.00'}', Icons.account_balance_wallet_rounded, const Color(0xFF10B981), cardBg, isDarkMode),
                      _buildKpiCard('ไรเดอร์ที่ออนไลน์สด', '${stats?.activeDriversOnline ?? 0} คน', Icons.two_wheeler_rounded, const Color(0xFFF59E0B), cardBg, isDarkMode),
                      _buildKpiCard('ใบสมัครรออนุมัติ', '${stats?.pendingDriverApplications ?? 0} รายการ', Icons.pending_actions_rounded, const Color(0xFFEF4444), cardBg, isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ==========================================
                  // 2. DRIVER APPROVAL SYSTEM (อนุมัติคนขับ)
                  // ==========================================
                  if (_selectedTabIndex == 0 || _selectedTabIndex == 1) ...[
                    Row(
                      children: [
                        const Icon(Icons.how_to_reg_rounded, color: Color(0xFF1C7FF6), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'รายการยื่นใบสมัครเป็นคนขับพาร์ทเนอร์ (รอการตรวจสอบอนุมัติ)',
                          style: GoogleFonts.kanit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (adminState.pendingDrivers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: Text('ไม่มีรายการใบสมัครค้างอนุมัติในขณะนี้ 🎉', style: GoogleFonts.kanit(color: Colors.grey)),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: adminState.pendingDrivers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final driver = adminState.pendingDrivers[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.person_rounded, color: Color(0xFF1C7FF6)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driver.fullName,
                                        style: GoogleFonts.kanit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'สมัครเมื่อ: ${driver.submittedAt.hour}:${driver.submittedAt.minute.toString().padLeft(2, '0')} น. • ${driver.vehicleType} (${driver.brand} ${driver.model} ทะเบียน ${driver.plate})',
                                        style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                                  label: Text('ตรวจสอบเอกสาร', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1C7FF6),
                                    side: const BorderSide(color: Color(0xFF1C7FF6)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _showDriverDocumentModal(driver),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 36),
                  ],

                  // ==========================================
                  // 3. LIVE ORDERS MONITORING TABLE
                  // ==========================================
                  if (_selectedTabIndex == 0 || _selectedTabIndex == 2) ...[
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded, color: Color(0xFF10B981), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'รายการการจัดส่งในระบบทั้งหมด (Live Orders)',
                          style: GoogleFonts.kanit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('เลขคำสั่งซื้อ')),
                            DataColumn(label: Text('ผู้ใช้บริการ')),
                            DataColumn(label: Text('พนักงานขับรถ')),
                            DataColumn(label: Text('เส้นทางจัดส่ง')),
                            DataColumn(label: Text('ประเภทรถ')),
                            DataColumn(label: Text('ค่าบริการ')),
                            DataColumn(label: Text('สถานะ')),
                          ],
                          rows: adminState.allOrders.map((order) {
                            final isDone = order.status == 'Delivered';
                            return DataRow(
                              cells: [
                                DataCell(Text(order.orderNo, style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                                DataCell(Text(order.customerName, style: GoogleFonts.kanit())),
                                DataCell(Text(order.driverName, style: GoogleFonts.kanit())),
                                DataCell(Text('${order.pickupAddress} ➔ ${order.dropoffAddress}', style: GoogleFonts.kanit())),
                                DataCell(Text(order.vehicleType, style: GoogleFonts.kanit())),
                                DataCell(Text('฿${order.amount.toStringAsFixed(2)}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDone ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFF3B82F6).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order.status,
                                      style: GoogleFonts.kanit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDone ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title, {int? badgeCount}) {
    final isSelected = _selectedTabIndex == index;
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1C7FF6).withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF1C7FF6) : Colors.grey),
        title: Text(
          title,
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? const Color(0xFF1C7FF6)
                : isDarkMode
                    ? Colors.grey.shade300
                    : Colors.black87,
          ),
        ),
        trailing: (badgeCount != null && badgeCount > 0)
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: Text('$badgeCount', style: GoogleFonts.kanit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, Color cardBg, bool isDarkMode) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
