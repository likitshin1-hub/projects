import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../booking/providers/driver_provider.dart';
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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

  Widget _buildMessageBubble(ChatMessageModel message, bool isDarkMode, DriverModel driver) {
    final isUser = message.sender == 'user';
    final isBot = message.sender == 'bot';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C7FF6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.messageType == ChatMessageType.image && message.imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    message.imageBytes!,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else if (message.messageType == ChatMessageType.location)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message.text,
                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  message.text,
                  style: GoogleFonts.kanit(color: Colors.white, fontSize: 13.5),
                ),
              const SizedBox(height: 4),
              Text(
                message.timeText,
                style: GoogleFonts.kanit(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    // Driver or Bot bubble
    final avatarBg = isBot ? const Color(0xFF4285F4) : driver.avatarBgColor;
    final avatarIcon = isBot ? Icons.smart_toy_rounded : driver.avatarIcon;
    final bubbleBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: avatarBg,
              child: Icon(avatarIcon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bubbleBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: GoogleFonts.kanit(color: textColor, fontSize: 13.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.timeText,
                      style: GoogleFonts.kanit(
                        color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final driver = ref.watch(driverProvider);
    final chatState = ref.watch(chatProvider);

    final isCallCenter = widget.driverId == 'call_center' || widget.driverId == 'support' || widget.driverId == 'center';
    final displayName = isCallCenter ? 'ศูนย์บริการลูกค้า (Call Center)' : '${driver.name} (คนขับ)';
    final subTitleText = isCallCenter ? 'เจ้าหน้าที่พร้อมให้บริการ 24 ชั่วโมง' : 'กำลังออนไลน์ • ${driver.fullVehicleInfo}';
    final avatarBgColor = isCallCenter ? const Color(0xFF4285F4) : driver.avatarBgColor;
    final avatarIcon = isCallCenter ? Icons.headset_mic_rounded : driver.avatarIcon;

    final scaffoldBg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final headerBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          // ==========================================
          // TOP HEADER WITH DYNAMIC DRIVER INFO
          // ==========================================
          Container(
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 12),
            decoration: BoxDecoration(
              color: headerBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : AppColors.textPrimary),
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
                      radius: 20,
                      backgroundColor: avatarBgColor,
                      child: Icon(avatarIcon, color: Colors.white, size: 20),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
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
                        displayName,
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subTitleText,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: const Color(0xFF10B981),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Phone Call Button -> CallScreen
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981), size: 20),
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
                return _buildMessageBubble(message, isDarkMode, driver);
              },
            ),
          ),

          // ==========================================
          // QUICK REPLIES BAR
          // ==========================================
          Container(
            height: 38,
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
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
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
}
