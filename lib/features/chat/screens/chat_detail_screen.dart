import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../booking/providers/driver_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final driver = ref.watch(driverProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER (APPBAR)
          // ==========================================
          Container(
            width: double.infinity,
            height: 80 + statusBarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1C7FF6),
                  Color(0xFF0056C6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 0),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),

                // Driver Avatar with Active green dot
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: driver.avatarBgColor,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Icon(driver.avatarIcon, color: Colors.white, size: 24),
                    ),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1C7FF6), width: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'คนขับ : ${driver.name}',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ออนไลน์',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons on right
                IconButton(
                  icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 22),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังโทรออกหาคนขับ สมชาย...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 22),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ==========================================
          // CHAT AREA
          // ==========================================
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Floating Order Details Card at top
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Blue Package Box Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: Color(0xFF1C7FF6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Column Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ออเดอร์ #TB2405081234',
                              style: GoogleFonts.kanit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ไปรับพัสดุ: เซ็นทรัล พระราม 2',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              'ส่งพัสดุ: บางนา กรุงเทพฯ',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Track button
                      OutlinedButton(
                        onPressed: () {
                          context.push('${AppRoutes.tracking}/TB2405081234');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1C7FF6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'ติดตามพัสดุ',
                          style: GoogleFonts.kanit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Date separator "วันนี้"
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'วันนี้',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Message 1 (Left - Driver): "สวัสดีครับ 🙏"
                _buildLeftMessage(
                  message: 'สวัสดีครับ 🙏',
                  time: '09:15',
                ),

                // Message 2 (Left - Driver): "ผมกำลังไปยังจุดรับพัสดุครับ"
                _buildLeftMessage(
                  message: 'ผมกำลังไปยังจุดรับพัสดุครับ',
                  time: '09:15',
                ),

                // Message 3 (Right - User): "ครับผม ขอบคุณครับ..."
                _buildRightMessage(
                  message: 'ครับผม ขอบคุณครับ\nรบกวนแจ้งเมื่อถึงจุดรับพัสดุด้วยนะครับ',
                  time: '09:16',
                ),

                // Message 4 (Left - Driver): "รับทราบครับ 😊"
                _buildLeftMessage(
                  message: 'รับทราบครับ 😊',
                  time: '09:16',
                ),

                // Message 5 (Left - Driver): Driver Map location card
                _buildLeftLocationCard(
                  locationName: 'ซอย พระรามที่ 2 ซอย 54 แสมดำ\nกรุงเทพฯ 10150',
                  time: '09:17',
                ),

                // Message 6 (Right - User): "ขอบคุณครับผม"
                _buildRightMessage(
                  message: 'ขอบคุณครับผม',
                  time: '09:18',
                ),
              ],
            ),
          ),

          // ==========================================
          // INPUT BAR (BOTTOM)
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: Colors.white,
            child: Row(
              children: [
                // Plus add icon
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF64748B),
                    size: 26,
                  ),
                  onPressed: () {},
                ),

                // Input bar area
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: GoogleFonts.kanit(fontSize: 14.5),
                            decoration: InputDecoration(
                              hintText: 'พิมพ์ข้อความ...',
                              hintStyle: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13.5),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Emoji icon
                        const Icon(
                          Icons.sentiment_satisfied_alt_rounded,
                          color: Color(0xFF64748B),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        // Microphone icon
                        const Icon(
                          Icons.mic_none_rounded,
                          color: Color(0xFF64748B),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: () {
                    if (_textController.text.trim().isNotEmpty) {
                      _textController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ส่งข้อความสำเร็จ (จำลอง)', style: GoogleFonts.kanit()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C7FF6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftMessage({required String message, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(AppAssets.defaultDriver),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 10),

          // Message Bubble
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.kanit(
                    fontSize: 14.5,
                    color: const Color(0xFF1F2937),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightMessage({required String message, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1C7FF6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message,
                style: GoogleFonts.kanit(
                  fontSize: 14.5,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.done_all_rounded,
                  color: Color(0xFF1C7FF6),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftLocationCard({required String locationName, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(AppAssets.defaultDriver),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 10),

          // Message Bubble with location card inside
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF1C7FF6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ตำแหน่งปัจจุบันของคนขับ',
                                style: GoogleFonts.kanit(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                locationName,
                                style: GoogleFonts.kanit(
                                  fontSize: 11.5,
                                  color: const Color(0xFF4B5563),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          context.push('${AppRoutes.tracking}/TB2405081234');
                        },
                        child: Text(
                          'ดูบนแผนที่',
                          style: GoogleFonts.kanit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
