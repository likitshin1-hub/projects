import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/vehicle_model.dart';

class ServiceCard extends ConsumerStatefulWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  ConsumerState<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends ConsumerState<ServiceCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final vehicle = widget.vehicle;
    final isRefrigerated = vehicle.tempControl != null;

    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return AnimatedScale(
      scale: _isHovered ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            if (_isHovered)
              BoxShadow(
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isHovered = true),
            onTapCancel: () => setState(() => _isHovered = false),
            onTapUp: (_) => setState(() => _isHovered = false),
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF1C7FF6).withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Icon / Image Area
                  Hero(
                    tag: 'vehicle-${vehicle.name}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          vehicle.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            vehicle.icon,
                            size: 40,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Vehicle Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.description,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: subTextColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Dimension & Weight info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Color(0xFF1C7FF6),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${vehicle.dimensions} • ${vehicle.maxWeight}',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // If refrigerated, show temp badge
                        if (isRefrigerated) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.ac_unit_rounded,
                                  size: 11,
                                  color: Color(0xFF38BDF8),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    vehicle.tempControl!,
                                    style: GoogleFonts.kanit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF38BDF8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Arrow button
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}