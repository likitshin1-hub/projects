import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

class ChatScreen extends ConsumerWidget {
  final String driverId;
  const ChatScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ทนงทวย ตีหอย',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
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
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // System Message
                    Container(
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
                              children: const [
                                Text('ยินดีต้อนรับสู่บริการข้อความอัตโนมัติ',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'ทีมงานของเราพร้อมช่วยเหลือคุณ\nกรุณาเลือกหัวข้อ หรือพิมพ์ข้อความได้เลย',
                                    style: TextStyle(
                                        color: AppColors.primary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.close, color: AppColors.primary, size: 16),
                        ],
                      ),
                    ),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'วันนี้',
                          style: TextStyle(fontSize: 10, color: subTextColor),
                        ),
                      ),
                    ),

                    // Bot Greeting Bubble
                    Row(
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
                          child: Text(
                            'สวัสดีค่ะ 👋\nยินดีให้บริการค่ะ คุณต้องการให้\nเราช่วยเรื่องใดคะ ?',
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ),
                      ],
                    ),

                    // Driver Bubble
                    Row(
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'สวัสดีครับ\nพัสดุกำลังจัดส่งนะครับ\nให้ช่วยอะไรไหมครับ',
                                style: TextStyle(fontSize: 14, color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '10:32',
                                style: TextStyle(color: subTextColor, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // User Bubble
                    Align(
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'พัสดุถึงไหนแล้วค่ะ',
                              style: TextStyle(fontSize: 14, color: textColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '10:42',
                              style: TextStyle(color: subTextColor, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
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
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'พิมพ์ข้อความ',
                              hintStyle: TextStyle(color: subTextColor),
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.mic, color: subTextColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C7FF6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
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
