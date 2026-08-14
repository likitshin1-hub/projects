import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

class _Message {
  final String text;
  final String sender; // 'bot', 'driver', 'user'
  final String time;

  _Message({
    required this.text,
    required this.sender,
    required this.time,
  });
}

class ChatScreen extends ConsumerStatefulWidget {
  final String driverId;
  const ChatScreen({super.key, required this.driverId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<_Message> _messages = [
    _Message(
      text: 'สวัสดีค่ะ 👋\nยินดีให้บริการค่ะ คุณต้องการให้\nเราช่วยเรื่องใดคะ ?',
      sender: 'bot',
      time: '10:30',
    ),
    _Message(
      text: 'สวัสดีครับ\nพัสดุกำลังจัดส่งนะครับ\nให้ช่วยอะไรไหมครับ',
      sender: 'driver',
      time: '10:32',
    ),
    _Message(
      text: 'พัสดุถึงไหนแล้วคะ',
      sender: 'user',
      time: '10:42',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final String timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(_Message(
        text: text,
        sender: 'user',
        time: timeStr,
      ));
    });
    _textController.clear();
    _scrollToBottom();

    // Simulated driver auto-reply after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      String replyText = 'รับทราบครับผม! เดี๋ยวรีบขับรถนำส่งให้ถึงจุดหมายอย่างปลอดภัยครับ 🛵';
      
      final lowerText = text.toLowerCase();
      if (lowerText.contains('ตรงไหน') || lowerText.contains('ไหน') || lowerText.contains('อยู่ที่ไหน') || lowerText.contains('ถึงไหน')) {
        replyText = 'ตอนนี้ผมอยู่ห่างออกไปราว ๆ 1.5 กิโลเมตรครับ ขับขี่มาถึงแถวแยกถนนหลักแล้วครับ ใกล้ถึงแล้วครับ! 🛣️';
      } else if (lowerText.contains('ขอบคุณ') || lowerText.contains('thx') || lowerText.contains('thanks') || lowerText.contains('ขอบใจ')) {
        replyText = 'ด้วยความยินดีครับคุณลูกค้า เดินทางปลอดภัยและขอบคุณที่เลือกใช้บริการของเรานะครับ 😊';
      } else if (lowerText.contains('โทร') || lowerText.contains('เบอร์') || lowerText.contains('ติดต่อ')) {
        replyText = 'รับทราบครับ เดี๋ยวถ้าใกล้พิกัดส่งของแล้วผมจะโทรติดต่อคุณลูกค้าทางเบอร์โทรศัพท์อีกครั้งนะครับ 📞';
      } else if (lowerText.contains('รีบ') || lowerText.contains('ด่วน') || lowerText.contains('เร็ว')) {
        replyText = 'กำลังรีบเร่งเดินรถให้อย่างรวดเร็วและปลอดภัยที่สุดครับผม อดใจรอสักครู่นะครับ!';
      }

      final replyTime = DateTime.now();
      final String replyTimeStr = '${replyTime.hour.toString().padLeft(2, '0')}:${replyTime.minute.toString().padLeft(2, '0')}';

      setState(() {
        _messages.add(_Message(
          text: replyText,
          sender: 'driver',
          time: replyTimeStr,
        ));
      });
      _scrollToBottom();
    });
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

  Widget _buildBotBubble(String text, String time, Color cardBg, Color borderColor, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFE8F0FE),
          child: Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.kanit(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.kanit(color: subTextColor, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverBubble(String text, String time, Color cardBg, Color borderColor, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFF4285F4),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.kanit(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.kanit(color: subTextColor, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserBubble(String text, String time, Color textColor, Color subTextColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C7FF6).withValues(alpha: 0.25),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Text(
                text,
                style: GoogleFonts.kanit(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.kanit(color: subTextColor, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : Colors.white;
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100]!;
    final borderColor = isDarkMode ? const Color(0xFF334155) : Colors.grey[300]!;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF4285F4),
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ทนงทวย ตีหอย (คนขับ)',
                    style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ออนไลน์',
                        style: GoogleFonts.kanit(color: subTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          // Background abstract bubbles
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + 2, // +2 for welcome banner and today header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Welcome auto message banner
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.smart_toy, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ยินดีต้อนรับสู่บริการข้อความอัตโนมัติ',
                                    style: GoogleFonts.kanit(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    'ทีมงานของเราพร้อมช่วยเหลือคุณ\nกรุณาเลือกหัวข้อ หรือพิมพ์ข้อความได้เลย',
                                    style: GoogleFonts.kanit(
                                      color: AppColors.primary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.close, color: AppColors.primary, size: 16),
                          ],
                        ),
                      );
                    }

                    if (index == 1) {
                      // Today Header
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'วันนี้',
                            style: GoogleFonts.kanit(fontSize: 10, color: subTextColor),
                          ),
                        ),
                      );
                    }

                    final msg = _messages[index - 2];
                    if (msg.sender == 'bot') {
                      return _buildBotBubble(msg.text, msg.time, cardBg, borderColor, textColor, subTextColor);
                    } else if (msg.sender == 'driver') {
                      return _buildDriverBubble(msg.text, msg.time, cardBg, borderColor, textColor, subTextColor);
                    } else {
                      return _buildUserBubble(msg.text, msg.time, textColor, subTextColor);
                    }
                  },
                ),
              ),

              // Bottom Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                          ),
                          child: TextField(
                            controller: _textController,
                            style: GoogleFonts.kanit(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'พิมพ์ข้อความ...',
                              hintStyle: GoogleFonts.kanit(color: subTextColor, fontSize: 13),
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.mic, color: subTextColor),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C7FF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
