import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/theme_provider.dart';

class DriverHeader extends ConsumerWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onClockOutPressed;

  const DriverHeader({
    super.key,
    this.onMenuPressed,
    this.onNotificationPressed,
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
        32,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF0F192C),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D0F192C),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // MENU & NOTIFICATION ROW (1:1 with HomeHeader)
          // =========================
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
              SizedBox(
                width: 48,
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onNotificationPressed,
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =========================
          // GREETING (1:1 with HomeHeader)
          // =========================
          Text(
            'สวัสดีครับ พาร์ทเนอร์ไรเดอร์!',
            style: GoogleFonts.kanit(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 3),

          // =========================
          // LOGO / APP NAME (1:1 with HomeHeader)
          // =========================
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'TB MOVE HUB RIDER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kanit(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.two_wheeler_rounded,
                color: Color(0xFF38BDF8),
                size: 28,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // =========================
          // SUBTITLE (1:1 with HomeHeader)
          // =========================
          Text(
            'ระบบพาร์ทเนอร์คนขับ / ขนส่งสินค้าอย่างมืออาชีพ',
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w300,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
