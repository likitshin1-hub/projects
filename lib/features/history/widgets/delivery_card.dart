import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_model.dart';
import 'status_chip.dart';

class DeliveryCard extends StatefulWidget {
  final DeliveryModel delivery;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
  });

  @override
  State<DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends State<DeliveryCard> {
  bool _isPressed = false;

  Color _getIndicatorColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.inProgress:
        return const Color(0xFF0A6CFF);
      case DeliveryStatus.completed:
        return const Color(0xFF22C55E);
      case DeliveryStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.inProgress:
        return Icons.local_shipping_rounded;
      case DeliveryStatus.completed:
        return Icons.check_circle_rounded;
      case DeliveryStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color _getIconBgColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.inProgress:
        return const Color(0xFFEDF5FF);
      case DeliveryStatus.completed:
        return const Color(0xFFDCFCE7);
      case DeliveryStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.delivery;
    final indicatorColor = _getIndicatorColor(item.status);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: indicatorColor,
                  width: 5,
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                splashColor: indicatorColor.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Icon + Order No + Status Chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _getIconBgColor(item.status),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(item.status),
                              color: indicatorColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.prompt(
                                  fontSize: 13,
                                  color: const Color(0xFF4B5563),
                                ),
                                children: [
                                  const TextSpan(text: 'เลขที่ออเดอร์ : '),
                                  TextSpan(
                                    text: item.orderNo,
                                    style: GoogleFonts.prompt(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          StatusChip(status: item.status),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Second Line: Route e.g. บ้าน → ชลบุรี
                      Row(
                        children: [
                          Text(
                            item.pickup,
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: indicatorColor,
                            ),
                          ),
                          Text(
                            item.destination,
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Bottom Row: Date/Time (Left) & Price/Arrow (Right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Date & Time (Gray)
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.date} • ${item.time}',
                                style: GoogleFonts.prompt(
                                  fontSize: 11,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),

                          // Price & Chevron >
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.price.toStringAsFixed(2)} บาท',
                                style: GoogleFonts.prompt(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
