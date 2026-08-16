import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String driverId;
  const ChatScreen({super.key, required this.driverId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _quickReplies = [
    'พัสดุถึงไหนแล้วคะ?',
    'ใกล้ถึงแล้วหรือยังครับ?',
    'ฝากไว้ที่ป้อมยามได้เลยครับ 🛡️',
    'ขอบคุณมากครับ 🙏',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSendMessage([String? predefinedText]) {
    final text = predefinedText ?? _textController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        ref.read(chatProvider.notifier).sendImageMessage(bytes);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถแนบรูปภาพได้: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareLocation() {
    // Current location Bangkok Sukhumvit
    const currentLoc = LatLng(13.7466, 100.5393);
    ref.read(chatProvider.notifier).sendLocationMessage(
          currentLoc,
          locationName: '123 อาคารสุขุมวิท กรุงเทพฯ (ตำแหน่งของฉัน)',
        );
    _scrollToBottom();
  }

  void _showAttachmentModal() {
    final isDarkMode = ref.read(themeProvider);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'เลือกสื่อแนบข้อความ',
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xFF3B82F6),
                    label: 'ถ่ายรูปภาพ',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendImage(ImageSource.camera);
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.photo_library_rounded,
                    color: const Color(0xFF10B981),
                    label: 'คลังรูปภาพ',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendImage(ImageSource.gallery);
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_on_rounded,
                    color: const Color(0xFFEF4444),
                    label: 'ส่งพิกัด GPS',
                    onTap: () {
                      Navigator.pop(context);
                      _shareLocation();
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: isDarkMode ? Colors.grey.shade300 : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final chatState = ref.watch(chatProvider);

    final scaffoldBg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final headerBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          // ==========================================
          // APP BAR / HEADER
          // ==========================================
          Container(
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 14),
            decoration: BoxDecoration(
              color: headerBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        '🛵',
                        style: GoogleFonts.kanit(fontSize: 22),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: headerBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สมชาย มั่นคง (ไรเดอร์)',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'กำลังออนไลน์ • Honda Wave (1กข 5598)',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                // Phone Call Button -> CallScreen
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981), size: 22),
                    onPressed: () {
                      context.push('${AppRoutes.call}/${widget.driverId}');
                    },
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // MESSAGES LIST
          // ==========================================
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return _buildMessageBubble(message, isDarkMode);
              },
            ),
          ),

          // ==========================================
          // QUICK REPLIES BAR
          // ==========================================
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final pillText = _quickReplies[index];
                return ActionChip(
                  label: Text(
                    pillText,
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: isDarkMode ? Colors.blue.shade200 : const Color(0xFF1C7FF6),
                    ),
                  ),
                  backgroundColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  side: BorderSide(
                    color: isDarkMode ? Colors.blue.shade900 : const Color(0xFFBFDBFE),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () => _onSendMessage(pillText),
                );
              },
            ),
          ),

          // ==========================================
          // INPUT BAR
          // ==========================================
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1C7FF6), size: 26),
                    onPressed: _showAttachmentModal,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความหาไรเดอร์...',
                        hintStyle: GoogleFonts.kanit(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _onSendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C7FF6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _onSendMessage(),
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

  Widget _buildMessageBubble(ChatMessageModel message, bool isDarkMode) {
    final isUser = message.sender == 'user';
    final isBot = message.sender == 'bot';

    final bubbleBg = isUser
        ? const Color(0xFF1C7FF6)
        : isBot
            ? (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
            : (isDarkMode ? const Color(0xFF1E293B) : Colors.white);

    final textColor = isUser
        ? Colors.white
        : isBot
            ? (isDarkMode ? Colors.white : AppColors.textPrimary)
            : (isDarkMode ? Colors.white : AppColors.textPrimary);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 1. Text Message
            if (message.messageType == ChatMessageType.text) ...[
              Text(
                message.text,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ],

            // 2. Image Message Attachment
            if (message.messageType == ChatMessageType.image && message.imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  message.imageBytes!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              if (message.text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  message.text,
                  style: GoogleFonts.kanit(fontSize: 13, color: textColor),
                ),
              ],
            ],

            // 3. Location Pin Card Message
            if (message.messageType == ChatMessageType.location) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message.locationName ?? 'พิกัด GPS',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_rounded, color: Color(0xFF1C7FF6), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'กดเปิดดูเส้นทางใน Google Maps',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF1C7FF6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 4),
            Text(
              message.timeText,
              style: GoogleFonts.kanit(
                fontSize: 10,
                color: isUser ? Colors.white.withOpacity(0.75) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
