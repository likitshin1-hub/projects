import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class AdminDriversTab extends ConsumerStatefulWidget {
  const AdminDriversTab({super.key});

  @override
  ConsumerState<AdminDriversTab> createState() => _AdminDriversTabState();
}

class _AdminDriversTabState extends ConsumerState<AdminDriversTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _rejectReasonController = TextEditingController();
  String _onlineFilter = 'All'; // All, Online, Offline
  String _verificationFilter = 'All'; // All, Pending, Approved, Rejected, Suspended

  @override
  void dispose() {
    _searchController.dispose();
    _rejectReasonController.dispose();
    super.dispose();
  }

  void _showImagePreviewDialog(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return DriverDocumentLightboxDialog(title: title, imageUrl: imageUrl);
      },
    );
  }

  void _showRejectReasonDialog(DriverAdminModel driver) {
    _rejectReasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 22),
                            const SizedBox(width: 8),
                            Text('❌ ปฏิเสธเอกสารคนขับ', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 12),
                    Text('เลือกเหตุผลด่วน (Presets):', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('📷 ภาพถ่ายเอกสารไม่ชัดเจน', setModalState),
                        _buildPresetChip('⚠️ ใบขับขี่หมดอายุ', setModalState),
                        _buildPresetChip('🏦 หน้าสมุดบัญชีอ่านเลขไม่ชัด', setModalState),
                        _buildPresetChip('🚗 ข้อมูลรถไม่ตรงกับเอกสาร', setModalState),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('ระบุรายละเอียดเหตุผลเพิ่มเติม (Driver จะได้รับการแจ้งเตือน FCM ป๊อปอัป):', style: GoogleFonts.kanit(color: const Color(0xFFCBD5E1), fontSize: 13)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _rejectReasonController,
                      maxLines: 3,
                      style: GoogleFonts.kanit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'พิมพ์เหตุผลรายละเอียดในการปฏิเสธที่นี่...',
                        hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final reason = _rejectReasonController.text.trim();
                            if (reason.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาระบุเหตุผลในการปฏิเสธ', style: GoogleFonts.kanit()), backgroundColor: Colors.orange));
                              return;
                            }
                            await ref.read(adminDriversProvider.notifier).rejectDriver(driver.id, reason);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('📲 ปฏิเสธเอกสารและส่ง FCM แจ้งเตือนคนขับ ${driver.fullName} เรียบร้อย', style: GoogleFonts.kanit()), backgroundColor: Colors.redAccent),
                              );
                            }
                          },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text('ยืนยันส่งการแจ้งเตือน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
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

  Widget _buildPresetChip(String text, StateSetter setModalState) {
    return ActionChip(
      label: Text(text, style: GoogleFonts.kanit(fontSize: 12, color: Colors.white)),
      backgroundColor: const Color(0xFF0F172A),
      side: const BorderSide(color: Color(0xFF334155)),
      onPressed: () {
        setModalState(() {
          _rejectReasonController.text = text;
        });
      },
    );
  }

  void _showDriverVerificationModal(DriverAdminModel driver) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Modal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge_rounded, color: Color(0xFF1C7FF6), size: 24),
                          const SizedBox(width: 10),
                          Text('Driver Detail & Verification: ${driver.fullName}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(color: Color(0xFF334155)),
                  const SizedBox(height: 12),

                  // Profile & Vehicle Cards Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Info Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('👤 Profile ข้อมูลส่วนตัว', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                              const SizedBox(height: 10),
                              _buildInfoRow('ID คนขับ:', driver.id),
                              _buildInfoRow('ชื่อ-นามสกุล:', driver.fullName),
                              _buildInfoRow('เบอร์โทรศัพท์:', driver.phone),
                              _buildInfoRow('อีเมล:', driver.email),
                              _buildInfoRow('สถานะพร้อมรับงาน:', driver.isOnline ? 'Online 🟢' : 'Offline ⚪'),
                              _buildInfoRow('การอนุมัติเอกสาร:', driver.status.name.toUpperCase()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Vehicle & Earnings Info Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🚚 Vehicle & Wallet ข้อมูลรถและการเงิน', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                              const SizedBox(height: 10),
                              _buildInfoRow('ประเภทรถ:', driver.vehicleType),
                              _buildInfoRow('ยี่ห้อ/รุ่น:', '${driver.brand} ${driver.model}'),
                              _buildInfoRow('ทะเบียนรถ:', driver.plate),
                              _buildInfoRow('สีรถ:', driver.color),
                              _buildInfoRow('คะแนนรีวิว:', '⭐ ${driver.rating} / 5.0'),
                              _buildInfoRow('ยอดเงินในกระเป๋า:', '฿${driver.walletBalance.toStringAsFixed(2)}'),
                              _buildInfoRow('รายได้สะสมทั้งหมด:', '฿${driver.totalEarnings.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Documents Inspection Section
                  Text('🖼️ Documents ตรวจสอบเอกสารสมัคร', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildDocCard('บัตรประชาชน', driver.idCardUrl),
                      _buildDocCard('ใบขับขี่', driver.driverLicenseUrl),
                      _buildDocCard('เล่มทะเบียนรถ', driver.vehicleDocUrl),
                      _buildDocCard('หน้าสมุดบัญชีธนาคาร', driver.bankBookUrl),
                      _buildDocCard('รูปถ่ายยานพาหนะ', driver.vehiclePhotoUrl),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (driver.rejectionReason != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade900.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade700)),
                      child: Text('⚠️ เหตุผลที่ปฏิเสธล่าสุด: ${driver.rejectionReason}', style: GoogleFonts.kanit(color: Colors.redAccent, fontSize: 13)),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons Toolbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(adminDriversProvider.notifier).toggleSuspend(driver.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: Icon(driver.status == DriverVerificationStatus.suspended ? Icons.check_circle : Icons.block, size: 18),
                        label: Text(driver.status == DriverVerificationStatus.suspended ? 'ปลดระงับบัญชี' : 'ระงับบัญชีคนขับ (Suspend)', style: GoogleFonts.kanit()),
                        style: ElevatedButton.styleFrom(backgroundColor: driver.status == DriverVerificationStatus.suspended ? const Color(0xFF10B981) : Colors.orange.shade800, foregroundColor: Colors.white),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showRejectReasonDialog(driver);
                            },
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: Text('Reject (ปฏิเสธเอกสาร)', style: GoogleFonts.kanit()),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(adminDriversProvider.notifier).approveDriver(driver.id);
                              if (context.mounted) Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('✅ อนุมัติเอกสารคนขับ ${driver.fullName} เรียบร้อยแล้ว', style: GoogleFonts.kanit()), backgroundColor: const Color(0xFF10B981)),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: Text('Approve (อนุมัติเอกสาร)', style: GoogleFonts.kanit()),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                          ),
                        ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
          Text(value, style: GoogleFonts.kanit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDocCard(String label, String imageUrl) {
    return InkWell(
      onTap: () => _showImagePreviewDialog(label, imageUrl),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 135,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 80, color: const Color(0xFF1E293B), child: const Icon(Icons.insert_drive_file_outlined, color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.kanit(color: Colors.white, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('🔍 คลิกดูรูปใหญ่', style: GoogleFonts.kanit(color: const Color(0xFF3B82F6), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driversState = ref.watch(adminDriversProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Toolbar Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: '🔍 ค้นหาชื่อคนขับ / เบอร์โทร / ประเภทรถ / ทะเบียน',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Operational Status Filter (Online/Offline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _onlineFilter,
                    dropdownColor: const Color(0xFF1E293B),
                    style: GoogleFonts.kanit(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('สถานะทำงาน: ทั้งหมด')),
                      DropdownMenuItem(value: 'Online', child: Text('🟢 Online (พร้อมรับงาน)')),
                      DropdownMenuItem(value: 'Offline', child: Text('⚪ Offline (ปิดรับงาน)')),
                    ],
                    onChanged: (val) => setState(() => _onlineFilter = val!),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Verification Filter (Pending/Approved/Rejected/Suspended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _verificationFilter,
                    dropdownColor: const Color(0xFF1E293B),
                    style: GoogleFonts.kanit(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('เอกสาร: ทั้งหมด')),
                      DropdownMenuItem(value: 'Pending', child: Text('🟡 Pending (รอตรวจ)')),
                      DropdownMenuItem(value: 'Approved', child: Text('🟢 Approved (อนุมัติ)')),
                      DropdownMenuItem(value: 'Rejected', child: Text('🔴 Rejected (ปฏิเสธ)')),
                      DropdownMenuItem(value: 'Suspended', child: Text('🟣 Suspended (ระงับ)')),
                    ],
                    onChanged: (val) => setState(() => _verificationFilter = val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Drivers DataTable
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
              child: driversState.when(
                data: (list) {
                  final query = _searchController.text.toLowerCase();
                  var filtered = list.where((d) {
                    final matchQuery = d.fullName.toLowerCase().contains(query) || d.phone.contains(query) || d.vehicleType.toLowerCase().contains(query) || d.plate.toLowerCase().contains(query);

                    bool matchOnline = true;
                    if (_onlineFilter == 'Online') matchOnline = d.isOnline;
                    if (_onlineFilter == 'Offline') matchOnline = !d.isOnline;

                    bool matchVerification = true;
                    if (_verificationFilter == 'Pending') matchVerification = d.status == DriverVerificationStatus.pending;
                    if (_verificationFilter == 'Approved') matchVerification = d.status == DriverVerificationStatus.approved;
                    if (_verificationFilter == 'Rejected') matchVerification = d.status == DriverVerificationStatus.rejected;
                    if (_verificationFilter == 'Suspended') matchVerification = d.status == DriverVerificationStatus.suspended;

                    return matchQuery && matchOnline && matchVerification;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text('ไม่พบข้อมูลคนขับที่ค้นหา', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))));
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                      columns: [
                        DataColumn(label: Text('Driver ID', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Name', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Phone', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Vehicle', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Status (รับงาน)', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Verification (เอกสาร)', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                        DataColumn(label: Text('Action', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                      ],
                      rows: filtered.map((d) {
                        return DataRow(cells: [
                          DataCell(Text(d.id, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(Text(d.fullName, style: GoogleFonts.kanit(color: Colors.white))),
                          DataCell(Text(d.phone, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          DataCell(Text('${d.vehicleType} • ${d.plate}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8)))),
                          
                          // Operational Status Badge (Online/Offline)
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: d.isOnline ? Colors.greenAccent : Colors.grey),
                                ),
                                const SizedBox(width: 6),
                                Text(d.isOnline ? 'Online' : 'Offline', style: GoogleFonts.kanit(color: d.isOnline ? Colors.greenAccent : const Color(0xFF94A3B8), fontSize: 13)),
                              ],
                            ),
                          ),

                          // Verification Status Badge (Pending/Approved/Rejected/Suspended)
                          DataCell(_buildVerificationBadge(d.status)),

                          // Action Button (Inspect Documents)
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () => _showDriverVerificationModal(d),
                              icon: const Icon(Icons.file_present_rounded, size: 16),
                              label: Text(d.status == DriverVerificationStatus.pending ? 'ตรวจเอกสาร' : 'ดูรายละเอียด', style: GoogleFonts.kanit(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: d.status == DriverVerificationStatus.pending ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('เกิดข้อผิดพลาดในการโหลดข้อมูลคนขับ', style: GoogleFonts.kanit(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(DriverVerificationStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case DriverVerificationStatus.pending:
        bg = Colors.amber.shade900.withValues(alpha: 0.3);
        fg = Colors.amberAccent;
        label = 'Pending (รออนุมัติ)';
        break;
      case DriverVerificationStatus.approved:
        bg = Colors.green.shade900.withValues(alpha: 0.3);
        fg = Colors.greenAccent;
        label = 'Approved (อนุมัติ)';
        break;
      case DriverVerificationStatus.rejected:
        bg = Colors.red.shade900.withValues(alpha: 0.3);
        fg = Colors.redAccent;
        label = 'Rejected (ปฏิเสธ)';
        break;
      case DriverVerificationStatus.suspended:
        bg = Colors.purple.shade900.withValues(alpha: 0.3);
        fg = Colors.purpleAccent;
        label = 'Suspended (ระงับ)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.kanit(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// 🖼️ Interactive Document Lightbox Dialog (Zooming, Rotation, Panning)
class DriverDocumentLightboxDialog extends StatefulWidget {
  final String title;
  final String imageUrl;

  const DriverDocumentLightboxDialog({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  State<DriverDocumentLightboxDialog> createState() => _DriverDocumentLightboxDialogState();
}

class _DriverDocumentLightboxDialogState extends State<DriverDocumentLightboxDialog> {
  final TransformationController _transformationController = TransformationController();
  int _quarterTurns = 0;
  bool _isFullscreen = false;

  void _rotateLeft() {
    setState(() {
      _quarterTurns = (_quarterTurns - 1) % 4;
    });
  }

  void _rotateRight() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _quarterTurns = 0;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      insetPadding: _isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isFullscreen ? 0 : 20)),
      child: Container(
        width: _isFullscreen ? MediaQuery.of(context).size.width : 780,
        height: _isFullscreen ? MediaQuery.of(context).size.height : 580,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Lightbox Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.document_scanner_rounded, color: Color(0xFF1C7FF6), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '🔍 Document Inspector: ${widget.title}',
                      style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'หมุนซ้าย 90°',
                      icon: const Icon(Icons.rotate_left_rounded, color: Colors.white),
                      onPressed: _rotateLeft,
                    ),
                    IconButton(
                      tooltip: 'หมุนขวา 90°',
                      icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
                      onPressed: _rotateRight,
                    ),
                    IconButton(
                      tooltip: 'รีเซ็ตมุมมอง',
                      icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
                      onPressed: _resetZoom,
                    ),
                    IconButton(
                      tooltip: _isFullscreen ? 'ออกจากหน้าจอเต็ม' : 'ขยายเต็มจอ',
                      icon: Icon(_isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, color: Colors.white),
                      onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Color(0xFF334155)),
            const SizedBox(height: 10),

            // Interactive Image Canvas
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: const Color(0xFF020617),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.8,
                    maxScale: 4.5,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: _quarterTurns,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image_rounded, color: Color(0xFF64748B), size: 48),
                                const SizedBox(height: 10),
                                Text('ไม่สามารถโหลดรูปภาพเอกสารได้', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Lightbox Footer Controls Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '💡 คำแนะนำ: ใช้นิ้วเลื่อน/Scroll Mouse เพื่อซูมขยาย และลากเพื่อเคลื่อนย้ายมุมมองเอกสาร',
                  style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
                  child: Text('ปิดหน้าต่าง', style: GoogleFonts.kanit()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
