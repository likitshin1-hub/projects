import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';

class DriverPartnerLandingScreen extends ConsumerWidget {
  const DriverPartnerLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFF0F62FE);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient Gradient Glow
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF0F172A), const Color(0xFF0B0F17)]
                    : [const Color(0xFF1C7FF6), const Color(0xFF0052CC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.assignment_outlined, color: Colors.white),
                            tooltip: 'เช็คสถานะใบสมัคร',
                            onPressed: () => context.push(AppRoutes.partnerStatus),
                          ),
                          IconButton(
                            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
                            onPressed: () => context.push(AppRoutes.help),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo & Brand Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(AppAssets.logo),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'TB MoveHub',
                              style: GoogleFonts.kanit(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Title Banner
                        Text(
                          'สมัครเป็นพาร์ทเนอร์คนขับ',
                          style: GoogleFonts.kanit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ร่วมสร้างรายได้ไปกับ TB MoveHub\nรับงานง่าย รายได้ดี เลือกเวลาทำงานได้เอง',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Hero Vehicle Graphic Card
                        Container(
                          width: double.infinity,
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                right: -10,
                                bottom: 10,
                                child: Image.asset(
                                  AppAssets.bannerVehicle,
                                  height: 160,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.local_shipping_rounded,
                                    size: 110,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                top: 25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'เปิดรับสมัครคนขับทั่วไทย',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'สร้างรายได้เติบโต\nไปกับเรา',
                                      style: GoogleFonts.kanit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Benefits Card (3 Highlight Points)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildBenefitRow(
                                icon: Icons.monetization_on_rounded,
                                iconColor: const Color(0xFF10B981),
                                iconBg: const Color(0xFFD1FAE5),
                                title: 'รายได้ดี',
                                subtitle: 'รับงานได้ต่อเนื่อง รายได้มั่นคง จ่ายตรงเวลา',
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                              const Divider(height: 24),
                              _buildBenefitRow(
                                icon: Icons.access_time_filled_rounded,
                                iconColor: const Color(0xFF1C7FF6),
                                iconBg: const Color(0xFFE0F2FE),
                                title: 'อิสระในการทำงาน',
                                subtitle: 'เลือกเวลาทำงานได้ตามต้องการ วางแผนชีวิตเองได้',
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                              const Divider(height: 24),
                              _buildBenefitRow(
                                icon: Icons.support_agent_rounded,
                                iconColor: const Color(0xFF8B5CF6),
                                iconBg: const Color(0xFFF3E8FF),
                                title: 'ทีมงานดูแล 24 ชม.',
                                subtitle: 'มีทีมช่วยเหลือคุณตลอดการทำงาน อุ่นใจทุกเส้นทาง',
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Call To Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0B0F17) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => context.push(AppRoutes.registerPartner),
                      child: Text(
                        'สมัครเป็นพาร์ทเนอร์',
                        style: GoogleFonts.kanit(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
