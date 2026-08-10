import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_model.dart';

class StatusChip extends StatelessWidget {
  final DeliveryStatus status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DeliveryStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0A6CFF), width: 1.2),
          ),
          child: Text(
            'กำลังดำเนินการ',
            style: GoogleFonts.prompt(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A6CFF),
            ),
          ),
        );
      case DeliveryStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'เสร็จสิ้น',
            style: GoogleFonts.prompt(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      case DeliveryStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
          ),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.prompt(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEF4444),
            ),
          ),
        );
    }
  }
}
