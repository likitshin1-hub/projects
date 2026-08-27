import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/theme_provider.dart';

class DriverHeader extends ConsumerWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onClockOutPressed;

  const DriverHeader({
    super.key,
    this.onMenuPressed,
    this.onClockOutPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        statusBarHeight + 8,
        16,
        28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFF0F192C), const Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x660F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: onMenuPressed,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFF38BDF8), size: 10),
                        const SizedBox(width: 6),
                        Text(
                          'Rider Mode',
                          style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (onClockOutPressed != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onClockOutPressed,
                      icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 14),
                      label: Text('ออกงาน', style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'TBMoveHub Driver Panel',
            style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'ระบบงานคนขับ / ผู้ให้บริการขนส่งสินค้า',
            style: GoogleFonts.kanit(fontSize: 13, color: Colors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}
