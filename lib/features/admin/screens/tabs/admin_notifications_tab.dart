import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/push_notification_service.dart';

class AdminNotificationsTab extends ConsumerStatefulWidget {
  const AdminNotificationsTab({super.key});

  @override
  ConsumerState<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends ConsumerState<AdminNotificationsTab> {
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF-001',
      'title': 'คนขับใหม่รออนุมัติเอกสาร',
      'message': 'นายสมชาย มั่นคง (DRV-1001) ได้ทำการอัปโหลดเอกสารยืนยันตัวตนใหม่เพิ่มเติม',
      'category': 'driver',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': false,
      'type': 'alert',
    },
    {
      'id': 'NOTIF-002',
      'title': 'คำร้องถอนเงินสดจำนวน ฿4,500',
      'message': 'นายวิชัย ใจดี ขอถอนเงินจาก Wallet เข้าบัญชี ธ.กสิกรไทย (xxx-x-x8812-x)',
      'category': 'finance',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': false,
      'type': 'finance',
    },
    {
      'id': 'NOTIF-003',
      'title': 'คำสั่งซื้อยกเลิกกลางทาง (TB504992)',
      'message': 'ลูกค้าขอยกเลิกคำสั่งซื้อเนื่องจากระบุจุดปักหมุดผิดพลาด',
      'category': 'order',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': true,
      'type': 'warning',
    },
    {
      'id': 'NOTIF-004',
      'title': 'ประกาศแจ้งเตือนระบบประจำสัปดาห์ (Broadcast)',
      'message': 'ส่งข้อความ Push Notification ไปยังไรเดอร์ทั้งหมด 1,240 เครื่องสำเร็จ',
      'category': 'system',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'type': 'broadcast',
    },
  ];

  void _showBroadcastModal() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String targetGroup = 'all';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 540,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('📢 บรอดแคสต์แจ้งเตือน (Send Broadcast Notification)',
                        style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 14),
                Text('กลุ่มผู้รับข้อความ', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: targetGroup,
                  dropdownColor: const Color(0xFF1E293B),
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('👥 ผู้ใช้และคนขับทั้งหมด')),
                    DropdownMenuItem(value: 'drivers', child: Text('🚚 เฉพาะคนขับ/ไรเดอร์')),
                    DropdownMenuItem(value: 'customers', child: Text('👤 เฉพาะลูกค้าทั่วไป')),
                  ],
                  onChanged: (val) {
                    if (val != null) targetGroup = val;
                  },
                ),
                const SizedBox(height: 14),
                Text('หัวข้อการแจ้งเตือน', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'เช่น ปรับปรุงระบบชั่วคราว / โปรโมชั่นพิเศษ',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Text('รายละเอียดข้อความ', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  style: GoogleFonts.kanit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'พิมพ์เนื้อหาข้อความที่จะส่งแจ้งเตือน...',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty) return;
                        final title = titleCtrl.text.trim();
                        final body = bodyCtrl.text.isEmpty ? 'ประกาศสำคัญจากผู้ดูแลระบบ TBMoveHub' : bodyCtrl.text.trim();

                        await PushNotificationService().sendBroadcastNotification(
                          targetGroup: targetGroup,
                          title: title,
                          body: body,
                        );

                        setState(() {
                          _notifications.insert(0, {
                            'id': 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
                            'title': title,
                            'message': body,
                            'category': 'system',
                            'timestamp': DateTime.now(),
                            'isRead': true,
                            'type': 'broadcast',
                          });
                        });

                        if (context.mounted) Navigator.pop(context);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🚀 ยิงข้อความ FCM Push Notification ไปยังกลุ่ม [$targetGroup] สำเร็จแล้ว!', style: GoogleFonts.kanit()),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text('ส่งข้อความ (Send FCM)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _notifications.where((n) {
      if (_selectedCategory == 'all') return true;
      return n['category'] == _selectedCategory;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔔 ศูนย์แจ้งเตือน & บรอดแคสต์ (Notifications Center)',
                    style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ตรวจสอบการแจ้งเตือนระบบ คำร้องขอ และส่งข้อความ Push Notification หาผู้ใช้',
                    style: GoogleFonts.kanit(fontSize: 14, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showBroadcastModal,
                icon: const Icon(Icons.campaign_rounded, color: Colors.white),
                label: Text('สร้างบรอดแคสต์ใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C7FF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'ทั้งหมด (${_notifications.length})'),
                _buildFilterChip('driver', '🚚 เอกสารคนขับ'),
                _buildFilterChip('finance', '💰 คำขอถอนเงิน'),
                _buildFilterChip('order', '📦 คำสั่งซื้อ'),
                _buildFilterChip('system', '⚙️ ประกาศระบบ'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Notification Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = filteredList[index];
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif['isRead'] ? const Color(0xFF334155) : const Color(0xFF1C7FF6).withValues(alpha: 0.5),
                    width: notif['isRead'] ? 1 : 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getNotifColor(notif['type']).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getNotifIcon(notif['type']), color: _getNotifColor(notif['type']), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notif['title'],
                                style: GoogleFonts.kanit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _formatTime(notif['timestamp']),
                                style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif['message'],
                            style: GoogleFonts.kanit(fontSize: 14, color: const Color(0xFFCBD5E1)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.kanit(color: isSelected ? Colors.white : const Color(0xFF94A3B8))),
        selected: isSelected,
        selectedColor: const Color(0xFF1C7FF6),
        backgroundColor: const Color(0xFF1E293B),
        onSelected: (val) {
          if (val) setState(() => _selectedCategory = key);
        },
      ),
    );
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'alert':
        return const Color(0xFF3B82F6);
      case 'finance':
        return const Color(0xFF10B981);
      case 'warning':
        return const Color(0xFFEF4444);
      case 'broadcast':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.badge_rounded;
      case 'finance':
        return Icons.account_balance_wallet_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'broadcast':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
