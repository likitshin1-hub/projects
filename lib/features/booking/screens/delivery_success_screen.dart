import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/driver_provider.dart';

class DeliverySuccessScreen extends ConsumerStatefulWidget {
  const DeliverySuccessScreen({super.key});

  @override
  ConsumerState<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends ConsumerState<DeliverySuccessScreen> {
  int _rating = 0;
  bool _isSubmitted = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingText(int stars) {
    switch (stars) {
      case 1:
        return 'ต้องปรับปรุง 😞';
      case 2:
        return 'พอใช้ 🙂';
      case 3:
        return 'ปานกลาง 😊';
      case 4:
        return 'ดีมาก 😃';
      case 5:
        return 'ประทับใจสุดๆ! ⭐';
      default:
        return 'แตะดาวเพื่อให้คะแนน';
    }
  }

  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณาเลือกดาวเพื่อให้คะแนนไรเดอร์',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ขอบคุณสำหรับคะแนน $_rating ดาว! บันทึกข้อมูลเรียบร้อยแล้ว',
                style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _cleanPlaceName(String input, String fallbackAddress, String defaultName) {
    final invalidStrings = {'sad', 'asd', 'abc', 'test', '123', 'a', 'b', 'c', '1', '2', '3', 'xxx', 'yyy', 'zzz'};
    final trimmedInput = input.trim();
    if (trimmedInput.length > 3 && !invalidStrings.contains(trimmedInput.toLowerCase())) {
      return trimmedInput;
    }
    final trimmedFallback = fallbackAddress.trim();
    if (trimmedFallback.length > 3 && !invalidStrings.contains(trimmedFallback.toLowerCase())) {
      return trimmedFallback;
    }
    return defaultName;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final bookingState = ref.watch(bookingProvider);
    final driver = ref.watch(driverProvider);
    final recipientStr = _cleanPlaceName(bookingState.dropoffName, '', 'คุณอนันต์ (ผู้รับปลายทาง ชลบุรี)');
    final dropoffStr = _cleanPlaceName(bookingState.dropoffName, bookingState.dropoff, 'วิทยาลัยอาชีวศึกษาชลบุรี');

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF2F9F2);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : Colors.grey[300]!;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'จัดส่งสำเร็จ',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decorations (e.g. confetti, boxes)
          Positioned(
            bottom: -20,
            right: -20,
            child: Icon(
              Icons.inventory,
              size: 150,
              color: Colors.orange.withValues(alpha: isDarkMode ? 0.1 : 0.2),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Green checkmark
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'จัดส่งสำเร็จแล้ว!',
                  style: GoogleFonts.kanit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ขอบคุณที่ใช้บริการของเรา',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Delivery Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รายละเอียดการจัดส่ง',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.inventory_2, 'หมายเลขพัสดุ', 'TH2154966541A', Colors.orange, textColor, subTextColor),
                      Divider(height: 24, color: borderColor),
                      _buildDetailRow(Icons.person, 'ผู้รับสินค้า', recipientStr, AppColors.primary, textColor, subTextColor),
                      Divider(height: 24, color: borderColor),
                      _buildDetailRow(Icons.location_on, 'จัดส่งไปยัง', dropoffStr, Colors.red, textColor, subTextColor),
                      Divider(height: 24, color: borderColor),
                      _buildDetailRow(Icons.calendar_today, 'วันที่จัดส่ง', '18 พ.ค 2569 15.30น.', AppColors.primary, textColor, subTextColor),
                      Divider(height: 24, color: borderColor),
                      _buildDetailRow(Icons.directions_car, 'ผู้จัดส่ง', '${driver.name} (${driver.fullVehicleInfo})', isDarkMode ? Colors.white : Colors.black, textColor, subTextColor),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Rating Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isSubmitted ? const Color(0xFF10B981) : borderColor,
                      width: _isSubmitted ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ให้คะแนนการให้บริการของไรเดอร์',
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ความพึงพอใจของคุณ ช่วยพัฒนาเราให้ดียิ่งขึ้น',
                                  style: GoogleFonts.kanit(color: subTextColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Interactive Star Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starNumber = index + 1;
                          final isSelected = starNumber <= _rating;
                          return GestureDetector(
                            onTap: _isSubmitted
                                ? null
                                : () {
                                    setState(() {
                                      _rating = starNumber;
                                    });
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 42,
                                color: isSelected ? Colors.amber : (isDarkMode ? const Color(0xFF475569) : Colors.grey.shade400),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),

                      // Rating Sentiment Label
                      Text(
                        _getRatingText(_rating),
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _rating > 0 ? (isDarkMode ? const Color(0xFFFBBF24) : Colors.amber.shade900) : subTextColor,
                        ),
                      ),

                      if (!_isSubmitted && _rating > 0) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _commentController,
                          maxLines: 2,
                          style: GoogleFonts.kanit(fontSize: 13, color: textColor),
                          decoration: InputDecoration(
                            hintText: 'เขียนข้อความชมเชยหรือติชมเพิ่มเติม (ถ้ามี)...',
                            hintStyle: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
                            contentPadding: const EdgeInsets.all(12),
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              'ส่งคะแนนประเมิน',
                              style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _submitRating,
                          ),
                        ),
                      ],

                      if (_isSubmitted) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'ส่งคะแนนประเมินเรียบร้อยแล้ว',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Emerald green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'กลับไปหน้าหลัก',
                      style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor, Color textColor, Color subTextColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(label, style: GoogleFonts.kanit(color: subTextColor, fontSize: 14)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
