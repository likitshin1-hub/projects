import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';
import '../../models/admin_models.dart';

class ChatTab extends StatefulWidget {
  final AdminDataService dataService;

  const ChatTab({super.key, required this.dataService});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  String _selectedCategory = 'all'; // all, team, driver, customer
  String _searchQuery = '';
  late String _activeRoomId;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickReplies = [
    '👋 สวัสดีครับ แอดมินยินดีให้บริการครับ',
    '⏳ กำลังตรวจสอบข้อมูลให้สักครู่ครับ',
    '✅ อนุมัติรายการเรียบร้อยแล้วครับ',
    '📍 ตรวจสอบพิกัด Live GPS ให้แล้วครับ',
    '🙏 ขอบคุณที่ติดต่อทีมงาน TBMoveHub ครับ',
  ];

  @override
  void initState() {
    super.initState();
    _activeRoomId = widget.dataService.chatRooms.isNotEmpty
        ? widget.dataService.chatRooms.first.id
        : 'team_general';
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    widget.dataService.sendMessage(_activeRoomId, text);
    _msgController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredRooms = widget.dataService.chatRooms.where((room) {
      final matchCat = _selectedCategory == 'all' ||
          (_selectedCategory == 'team' && room.category == ChatCategory.team) ||
          (_selectedCategory == 'driver' && room.category == ChatCategory.driver) ||
          (_selectedCategory == 'customer' && room.category == ChatCategory.customer);

      final q = _searchQuery.toLowerCase();
      final matchSearch = room.name.toLowerCase().contains(q) ||
          room.subtitle.toLowerCase().contains(q);

      return matchCat && matchSearch;
    }).toList();

    ChatRoom activeRoom;
    try {
      activeRoom = widget.dataService.chatRooms.firstWhere((r) => r.id == _activeRoomId);
    } catch (_) {
      activeRoom = widget.dataService.chatRooms.first;
      _activeRoomId = activeRoom.id;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
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
                    'ศูนย์แชท & สื่อสารทีมงาน (Chat Center)',
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'พูดคุยประสานงานภายในทีมแอดมิน ติดต่อไรเดอร์ และดูแลลูกค้าแบบเรียลไทม์',
                    style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showCreateRoomDialog(context),
                icon: const Icon(Icons.add_comment_rounded, size: 18),
                label: Text('+ เปิดห้องแชทใหม่', style: GoogleFonts.kanit(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // Left Pane: Room List
                  SizedBox(
                    width: 320,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: Border(right: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                      ),
                      child: Column(
                        children: [
                          // Search Box
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'ค้นหาห้องแชท หรือชื่อ...',
                                hintStyle: GoogleFonts.kanit(fontSize: 12),
                                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                isDense: true,
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),

                          // Filter Categories
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                _buildCategoryChip('all', 'ทั้งหมด'),
                                _buildCategoryChip('team', '🏢 ทีมงาน'),
                                _buildCategoryChip('driver', '🛵 ไรเดอร์'),
                                _buildCategoryChip('customer', '👥 ลูกค้า'),
                              ],
                            ),
                          ),
                          const Divider(height: 16),

                          // Rooms List
                          Expanded(
                            child: ListView.separated(
                              itemCount: filteredRooms.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                              itemBuilder: (context, idx) {
                                final room = filteredRooms[idx];
                                final isSelected = room.id == _activeRoomId;
                                final lastMsg = room.messages.isNotEmpty ? room.messages.last.text : 'ยังไม่มีข้อความ';

                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: AdminTheme.primaryBlue.withValues(alpha: 0.12),
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _getCategoryColor(room.category),
                                        child: Text(
                                          room.avatarText,
                                          style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      if (room.isOnline)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: AdminTheme.accentGreen,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1.5),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    room.name,
                                    style: GoogleFonts.kanit(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    lastMsg,
                                    style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: room.unreadCount > 0
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: const BoxDecoration(color: AdminTheme.accentRed, shape: BoxShape.circle),
                                          child: Text('${room.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _activeRoomId = room.id;
                                      widget.dataService.markRoomAsRead(room.id);
                                    });
                                    _scrollToBottom();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Pane: Active Chat Room
                  Expanded(
                    child: Column(
                      children: [
                        // Room Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getCategoryColor(activeRoom.category),
                                radius: 18,
                                child: Text(activeRoom.avatarText, style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(activeRoom.name, style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold)),
                                    Text(activeRoom.subtitle, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone_rounded, color: AdminTheme.accentGreen, size: 20),
                                tooltip: 'โทรติดต่อด่วน (Voice Call Simulation)',
                                onPressed: () => _showCallDialog(context, activeRoom.name),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline_rounded, color: AdminTheme.primaryBlue, size: 20),
                                tooltip: 'ดูข้อมูลห้องสนทนา',
                                onPressed: () => _showRoomInfoDialog(context, activeRoom),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_outlined, color: AdminTheme.accentRed, size: 20),
                                tooltip: 'ล้างประวัติแชทห้องนี้',
                                onPressed: () {
                                  setState(() => widget.dataService.clearRoomMessages(activeRoom.id));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ล้างข้อความในห้องนี้เรียบร้อย')));
                                },
                              ),
                            ],
                          ),
                        ),

                        // Messages Body
                        Expanded(
                          child: activeRoom.messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.forum_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                                      const SizedBox(height: 8),
                                      Text('ยังไม่มีข้อความ เริ่มต้นการสนทนาได้เลย', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 13)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: activeRoom.messages.length,
                                  itemBuilder: (context, idx) {
                                    final msg = activeRoom.messages[idx];
                                    return _buildMessageBubble(msg, isDark);
                                  },
                                ),
                        ),

                        // Quick Replies Bar
                        Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _quickReplies.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              return ActionChip(
                                label: Text(_quickReplies[i], style: GoogleFonts.kanit(fontSize: 11)),
                                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                onPressed: () {
                                  widget.dataService.sendMessage(_activeRoomId, _quickReplies[i]);
                                  _scrollToBottom();
                                },
                              );
                            },
                          ),
                        ),

                        // Bottom Input Area
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.grey),
                                tooltip: 'ใส่อีโมจิ',
                                onPressed: () {
                                  _msgController.text += ' 😊';
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.image_outlined, color: Colors.grey),
                                tooltip: 'แนบรูปภาพหรือเอกสาร',
                                onPressed: () {
                                  widget.dataService.sendMessage(_activeRoomId, '📷 [ส่งรูปภาพแนบ: receipt_doc.jpg]');
                                  _scrollToBottom();
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _msgController,
                                  style: GoogleFonts.kanit(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'พิมพ์ข้อความตอบกลับ...',
                                    hintStyle: GoogleFonts.kanit(fontSize: 13),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  ),
                                  onSubmitted: (_) => _handleSend(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                style: IconButton.styleFrom(backgroundColor: AdminTheme.primaryBlue),
                                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                tooltip: 'ส่งข้อความ',
                                onPressed: _handleSend,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: GoogleFonts.kanit(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        onSelected: (_) => setState(() => _selectedCategory = cat),
        selectedColor: AdminTheme.primaryBlue.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: msg.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isFromMe) ...[
            CircleAvatar(
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              radius: 14,
              child: Text(msg.sender.substring(0, 1), style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isFromMe
                    ? AdminTheme.primaryBlue
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: msg.isFromMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: msg.isFromMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: msg.isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!msg.isFromMe)
                    Text(
                      msg.sender,
                      style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange),
                    ),
                  Text(
                    msg.text,
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: msg.isFromMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('HH:mm').format(msg.timestamp),
                    style: GoogleFonts.kanit(
                      fontSize: 9,
                      color: msg.isFromMe ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (msg.isFromMe) ...[
            const SizedBox(width: 4),
            const Icon(Icons.done_all_rounded, size: 14, color: AdminTheme.primaryBlue),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(ChatCategory cat) {
    switch (cat) {
      case ChatCategory.team:
        return AdminTheme.primaryBlue;
      case ChatCategory.driver:
        return AdminTheme.accentOrange;
      case ChatCategory.customer:
        return AdminTheme.accentGreen;
      case ChatCategory.emergency:
        return AdminTheme.accentRed;
    }
  }

  void _showCallDialog(BuildContext context, String roomName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AdminTheme.accentGreen),
            const SizedBox(width: 8),
            Text('โทรติดต่อ: $roomName', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 36, backgroundColor: AdminTheme.accentGreen, child: Icon(Icons.person_rounded, size: 40, color: Colors.white)),
            const SizedBox(height: 14),
            Text('กำลังโทรออกผ่านระบบสัญญาณเสียง TBMoveHub VoIP...', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('00:04 • กำลังเชื่อมต่อ', style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.accentGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: Text('วางสาย', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showRoomInfoDialog(BuildContext context, ChatRoom room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ข้อมูลห้องสนทนา: ${room.name}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• หมวดหมู่: ${room.category.name.toUpperCase()}', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('• รายละเอียด: ${room.subtitle}', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('• จำนวนข้อความทั้งหมด: ${room.messages.length} ข้อความ', style: GoogleFonts.kanit(fontSize: 13)),
            const SizedBox(height: 6),
            Text('• สถานะ: ${room.isOnline ? "🟢 ออนไลน์พร้อมตอบ" : "⚫ ออฟไลน์"}', style: GoogleFonts.kanit(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    ChatCategory selectedCategory = ChatCategory.team;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('เปิดห้องสนทนาใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'ชื่อห้องสนทนา หรือบุคคล', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subCtrl,
                decoration: InputDecoration(labelText: 'คำอธิบาย / เบอร์โทร / แผนก', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ChatCategory>(
                value: selectedCategory,
                decoration: InputDecoration(labelText: 'ประเภทการสนทนา', labelStyle: GoogleFonts.kanit(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: const [
                  DropdownMenuItem(value: ChatCategory.team, child: Text('🏢 ทีมงานภายใน (Team)')),
                  DropdownMenuItem(value: ChatCategory.driver, child: Text('🛵 ไรเดอร์ (Driver)')),
                  DropdownMenuItem(value: ChatCategory.customer, child: Text('👥 ลูกค้า (Customer)')),
                ],
                onChanged: (val) => setDialogState(() => selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final newId = 'room_${DateTime.now().millisecondsSinceEpoch}';
                  setState(() {
                    widget.dataService.chatRooms.insert(
                      0,
                      ChatRoom(
                        id: newId,
                        name: nameCtrl.text,
                        subtitle: subCtrl.text.isNotEmpty ? subCtrl.text : 'ห้องสนทนาใหม่',
                        category: selectedCategory,
                        avatarText: nameCtrl.text.substring(0, 1),
                        messages: [
                          ChatMessage(
                            id: '1',
                            sender: 'ระบบ',
                            text: 'สร้างห้องสนทนาใหม่เรียบร้อยแล้ว',
                            timestamp: DateTime.now(),
                            isFromMe: false,
                          ),
                        ],
                      ),
                    );
                    _activeRoomId = newId;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เปิดห้องสนทนา ${nameCtrl.text} เรียบร้อย')));
                }
              },
              child: Text('สร้างห้องแชท', style: GoogleFonts.kanit()),
            ),
          ],
        ),
      ),
    );
  }
}
