import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../history/providers/history_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/driver_provider.dart';

class DeliverySuccessScreen extends ConsumerStatefulWidget {
  const DeliverySuccessScreen({super.key});

  @override
  ConsumerState<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends ConsumerState<DeliverySuccessScreen> with SingleTickerProviderStateMixin {
  int _rating = 5;
  bool _isSubmitted = false;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedFeedbackChips = {'ตรงเวลา ⚡', 'พัสดุปลอดภัย 📦', 'บริการดีเยี่ยม 😊'};

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _feedbackOptions = [
    'ตรงเวลา ⚡',
    'พัสดุปลอดภัย 📦',
    'บริการดีเยี่ยม 😊',
    'ระวังพัสดุแตกหัก 🛡️',
    'สุภาพเป็นกันเอง 🤝',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingState = ref.read(bookingProvider);
      final driver = ref.read(driverProvider);
      final orderNo = (bookingState.bookingId != null && bookingState.bookingId!.isNotEmpty)
          ? bookingState.bookingId!
          : 'TB668511';

      String emoji = '🛵';
      if (bookingState.vehicleType.contains('กระบะ') || bookingState.vehicleType.contains('บรรทุก')) emoji = '🚚';
      if (bookingState.vehicleType.contains('เก๋ง')) emoji = '🚗';
      if (bookingState.vehicleType.contains('ห้องเย็น')) emoji = '🚛';

      final pName = bookingState.pickupName.isNotEmpty ? bookingState.pickupName : 'ตำแหน่งปัจจุบันของคุณ';
      final dName = bookingState.dropoffName.isNotEmpty ? bookingState.dropoffName : 'วิทยาลัยอาชีวศึกษาชลบุรี';
      final pAddr = bookingState.pickup.isNotEmpty ? bookingState.pickup : 'กรุงเทพมหานคร';
      final dAddr = bookingState.dropoff.isNotEmpty ? bookingState.dropoff : 'ชลบุรี';

      final completedItem = HistoryItemModel(
        orderNo: orderNo,
        pickupAddress: pAddr,
        destinationAddress: dAddr,
        route: '$pName ➔ $dName',
        dateTime: 'เมื่อสักครู่ (จัดส่งสำเร็จ)',
        price: bookingState.estimatedPrice.toStringAsFixed(2),
        status: HistoryStatus.completed,
        vehicle: emoji,
        vehicleName: bookingState.vehicleType,
        statusText: 'จัดส่งสำเร็จ (ผู้รับเซ็นชื่อเรียบร้อย)',
        driverName: driver.name,
        driverPhone: driver.phone,
      );

      ref.read(historyProvider.notifier).addOrUpdateOrder(completedItem);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        return 'ประทับใจมากที่สุด! 🌟';
      default:
        return 'แตะดาวเพื่อให้คะแนน';
    }
  }

  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณาเลือกดาวเพื่อให้คะแนนการบริการ',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: const Color(0xFFF59E0B),
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
            const Icon(Icons.verified_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ขอบคุณสำหรับการประเมิน $_rating ดาว! บันทึกข้อมูลเรียบร้อยแล้ว',
                style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C7FF6),
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;

    final bookingState = ref.watch(bookingProvider);
    final driver = ref.watch(driverProvider);

    final displayBookingId = (bookingState.bookingId != null && bookingState.bookingId!.isNotEmpty) ? bookingState.bookingId! : 'TB668511';
    final pickupName = _cleanPlaceName(bookingState.pickupName, bookingState.pickup ?? '', 'ตำแหน่งปัจจุบันของคุณ (สยามพารากอน)');
    final dropoffName = _cleanPlaceName(bookingState.dropoffName, bookingState.dropoff ?? '', 'วิทยาลัยอาชีวศึกษาชลบุรี');
    final recipientName = _cleanPlaceName(bookingState.dropoffName, '', 'คุณอนันต์ (ผู้รับปลายทาง ชลบุรี)');

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HERO SUCCESS BANNER WITH BLUE GRADIENT
            // ==========================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1C7FF6),
                    Color(0xFF0056C6),
                    Color(0xFF003E99),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // App Bar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Text(
                        isEn ? 'Delivery Completed' : 'จัดส่งพัสดุสำเร็จแล้ว',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance spacer
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Animated Checkmark Icon Badge
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_rounded,
                          size: 58,
                          color: Color(0xFF1C7FF6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    isEn ? 'Package Delivered Successfully! 🎉' : 'พัสดุจัดส่งถึงปลายทางเรียบร้อยแล้ว! 🎉',
                    style: GoogleFonts.kanit(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEn ? 'Thank you for choosing TB MOVE Interprovincial Delivery' : 'ขอบคุณที่เลือกใช้บริการส่งพัสดุข้ามจังหวัด TB MOVE HUB',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // Order Tracking Number Pill Badge
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: displayBookingId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('คัดลอกเลขคำสั่งซื้อ #$displayBookingId แล้ว', style: GoogleFonts.kanit()),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'หมายเลขคำสั่งซื้อ: #$displayBookingId',
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ==========================================
                  // 2. ROUTE & RECIPIENT SUMMARY CARD
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.route_rounded, color: Color(0xFF1C7FF6), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isEn ? 'Route & Receiver Details' : 'เส้นทางและข้อมูลการจัดส่ง',
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.draw_rounded, color: Color(0xFF1C7FF6), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'เซ็นรับแล้ว',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1C7FF6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Route Timeline
                        _buildRouteItem(
                          icon: Icons.my_location_rounded,
                          color: const Color(0xFF1C7FF6),
                          label: isEn ? 'Pickup Location' : 'จุดรับพัสดุ (ต้นทาง)',
                          address: pickupName,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
                          child: Container(
                            width: 2,
                            height: 24,
                            color: const Color(0xFF1C7FF6).withValues(alpha: 0.3),
                          ),
                        ),
                        _buildRouteItem(
                          icon: Icons.location_on_rounded,
                          color: const Color(0xFFEF4444),
                          label: isEn ? 'Dropoff Location & Receiver' : 'สถานที่ส่ง & ผู้รับปลายทาง',
                          address: '$dropoffName\n($recipientName)',
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),

                        Divider(height: 28, color: borderColor),

                        // Summary details grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniInfo(
                                icon: Icons.straighten_rounded,
                                label: 'ระยะทางรวม',
                                value: '${bookingState.distanceKm} กม.',
                                isDark: isDarkMode,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                            Expanded(
                              child: _buildMiniInfo(
                                icon: Icons.timer_outlined,
                                label: 'เวลาจัดส่งรวม',
                                value: '${bookingState.estimatedDurationMinutes} นาที',
                                isDark: isDarkMode,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                            Expanded(
                              child: _buildMiniInfo(
                                icon: Icons.payments_outlined,
                                label: 'ชำระเงินสุทธิ',
                                value: '${bookingState.estimatedPrice.toInt()} ฿',
                                isDark: isDarkMode,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================
                  // 3. RIDER PROFILE & RATING CARD
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isSubmitted ? const Color(0xFF1C7FF6) : borderColor,
                        width: _isSubmitted ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Rider Info Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: driver.avatarBgColor,
                              child: Icon(driver.avatarIcon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        driver.name,
                                        style: GoogleFonts.kanit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: Color(0xFF1C7FF6), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    driver.fullVehicleInfo,
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Divider(height: 28, color: borderColor),

                        Text(
                          isEn ? 'Rate Your Driver Experience' : 'ประเมินความพึงพอใจการให้บริการของคนขับ',
                          style: GoogleFonts.kanit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Star Rating Selection
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
                        const SizedBox(height: 8),

                        Text(
                          _getRatingText(_rating),
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _rating > 0 ? (isDarkMode ? const Color(0xFFFBBF24) : Colors.amber.shade900) : subTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Feedback Tags Chips
                        if (!_isSubmitted) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _feedbackOptions.map((chipText) {
                              final isSelected = _selectedFeedbackChips.contains(chipText);
                              return FilterChip(
                                label: Text(
                                  chipText,
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF1C7FF6),
                                backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                checkmarkColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF1C7FF6)
                                      : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFeedbackChips.add(chipText);
                                    } else {
                                      _selectedFeedbackChips.remove(chipText);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _commentController,
                            maxLines: 2,
                            style: GoogleFonts.kanit(fontSize: 13, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'เขียนคำติชมหรือข้อเสนอแนะเพิ่มเติม (ถ้ามี)...',
                              hintStyle: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
                              contentPadding: const EdgeInsets.all(12),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: Text(
                                isEn ? 'Submit Feedback' : 'ส่งคะแนนประเมินไรเดอร์',
                                style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C7FF6),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _submitRating,
                            ),
                          ),
                        ],

                        if (_isSubmitted) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_rounded, color: Color(0xFF1C7FF6), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'บันทึกคะแนนการประเมินเรียบร้อยแล้ว ขอบคุณครับ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C7FF6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 4. ACTION BUTTONS
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.home_rounded, size: 22),
                      label: Text(
                        isEn ? 'Back to Home' : 'กลับสู่หน้าหลัก (Home)',
                        style: GoogleFonts.kanit(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.history_rounded, size: 20),
                      label: Text(
                        isEn ? 'View Delivery History' : 'ดูประวัติการขนส่งทั้งหมด',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF1C7FF6),
                        side: BorderSide(
                          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => context.push(AppRoutes.history),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem({
    required IconData icon,
    required Color color,
    required String label,
    required String address,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniInfo({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF1C7FF6)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.kanit(fontSize: 11, color: subTextColor),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
