import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/booking_provider.dart';

class SearchingRiderScreen extends ConsumerStatefulWidget {
  const SearchingRiderScreen({super.key});

  @override
  ConsumerState<SearchingRiderScreen> createState() => _SearchingRiderScreenState();
}

class _SearchingRiderScreenState extends ConsumerState<SearchingRiderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  Timer? _searchTimer;
  bool _isDriverFound = false;
  int _searchSeconds = 0;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startSearchSimulation();
  }

  void _startSearchSimulation() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _searchSeconds++;
      });

      if (_searchSeconds >= 4 && !_isDriverFound) {
        timer.cancel();
        setState(() {
          _isDriverFound = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'มอเตอร์ไซค์':
        return Icons.two_wheeler_rounded;
      case 'รถเก๋ง 4 ประตู':
        return Icons.directions_car_rounded;
      case 'รถกระบะ':
        return Icons.airport_shuttle_rounded;
      case 'รถห้องเย็น':
        return Icons.ac_unit_rounded;
      case 'รถบรรทุกมีลิฟท์ท้าย':
        return Icons.local_shipping_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final bookingState = ref.watch(bookingProvider);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final displayOrderNo = bookingState.bookingId ?? 'TB504321-5598';

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==========================================
          // TOP HEADER GRADIENT
          // ==========================================
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _isDriverFound
                            ? (currentLang == AppLanguage.en ? 'Driver Found!' : 'พบคนขับแล้ว!')
                            : (currentLang == AppLanguage.en ? 'Searching for Driver...' : 'กำลังค้นหาคนขับ...'),
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        currentLang == AppLanguage.en
                            ? 'Order #$displayOrderNo'
                            : 'หมายเลขคำสั่งซื้อ #$displayOrderNo',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // ==========================================
          // MAIN BODY WITH RADAR & DRIVER CARD
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // RADAR PULSE ANIMATION CONTAINER (FIXED BOUNDS TO PREVENT STUTTERING/JERKING)
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Radar Rings inside RepaintBoundary
                          RepaintBoundary(
                            child: Stack(
                              alignment: Alignment.center,
                              children: List.generate(3, (index) {
                                return AnimatedBuilder(
                                  animation: _radarController,
                                  builder: (context, child) {
                                    final progress = (_radarController.value + (index * 0.33)) % 1.0;
                                    return Container(
                                      width: 130 + (progress * 140),
                                      height: 130 + (progress * 140),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (_isDriverFound
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF1C7FF6))
                                            .withValues(alpha: (1.0 - progress) * 0.25),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),

                          // Center Icon / Avatar Box
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isDriverFound ? const Color(0xFF10B981) : const Color(0xFF1C7FF6),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isDriverFound ? const Color(0xFF10B981) : const Color(0xFF1C7FF6))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isDriverFound ? Icons.check_rounded : _getVehicleIcon(bookingState.vehicleType),
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // STATUS MESSAGE BADGE
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isDriverFound
                        ? Container(
                            key: const ValueKey('found'),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  currentLang == AppLanguage.en
                                      ? 'Driver accepted your order!'
                                      : 'คนขับตอบรับออเดอร์ของคุณแล้ว!',
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            key: const ValueKey('searching'),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C7FF6)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  currentLang == AppLanguage.en
                                      ? 'Broadcasting to nearby riders ($_searchSeconds s)...'
                                      : 'กำลังกระจายงานให้ไรเดอร์ในพื้นที่ ($_searchSeconds วินาที)...',
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C7FF6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 28),

                  // DRIVER CARD DETAILS (ANIMATED IN UPON MATCH)
                  if (_isDriverFound) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Driver Photo
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    AppAssets.defaultDriver,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.person, color: Color(0xFF10B981), size: 36),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentLang == AppLanguage.en ? 'Somchai Jaidee' : 'นาย สมชาย ใจดี',
                                      style: GoogleFonts.kanit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '4.9',
                                          style: GoogleFonts.kanit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          currentLang == AppLanguage.en
                                              ? ' (1,240 completed deliveries)'
                                              : ' (1,240 ออเดอร์สำเร็จ)',
                                          style: GoogleFonts.kanit(
                                            fontSize: 12,
                                            color: subTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentLang == AppLanguage.en
                                          ? 'Isuzu D-Max Closed Van (Plate 1KB-9999)'
                                          : 'Isuzu D-Max ตู้ทึบ (ทะเบียน 1กข-9999 ชลบุรี)',
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
                          const SizedBox(height: 20),

                          // Action Buttons: Call / Chat
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.call_rounded, color: Color(0xFF10B981), size: 18),
                                  label: Text(
                                    currentLang == AppLanguage.en ? 'Call Driver' : 'โทรหาคนขับ',
                                    style: GoogleFonts.kanit(
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: Color(0xFF10B981)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () {
                                    context.push('${AppRoutes.call}/driver_somchai');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                                  label: Text(
                                    currentLang == AppLanguage.en ? 'Chat Driver' : 'แชทกับคนขับ',
                                    style: GoogleFonts.kanit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1C7FF6),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () {
                                    context.push('${AppRoutes.chat}/driver_somchai');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CTA: TRACK LIVE GPS
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
                        label: Text(
                          currentLang == AppLanguage.en ? 'View Live GPS Tracking' : 'ดูตำแหน่งติดตามพัสดุเรียลไทม์',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                        onPressed: () {
                          context.pushReplacement('${AppRoutes.tracking}/TB504321-5598');
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
